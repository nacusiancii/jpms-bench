#!/usr/bin/env bash
# shellcheck shell=bash
set -euo pipefail

# Minimal benchmark helper for Git Bash on Windows:
# - Builds once
# - Measures jar size
# - Runs 3 times, waits for /ping, parses memory numbers from /ping JSON, measures launch time
# - Writes a single JSON array (overwrites each run) with aggregate (averages)
# If the jar is locked, manually close any running Java apps and retry.

JDK24_DEFAULT="C:/Program Files/Eclipse Adoptium/jdk-24.0.2.12-hotspot"
JDK24="${1:-$JDK24_DEFAULT}"
PORT="${2:-8080}"
JAR="target/example-0.0.1-SNAPSHOT.jar"
JSON_RESULTS="bench/results.json"
RUNS=3

if [[ ! -x "$JDK24/bin/java.exe" ]]; then
  echo "[ERROR] JDK not found at $JDK24"
  echo "Usage: bash bench/measure.sh \"C:/Path/To/jdk-24.x\" [port=8080]"
  exit 1
fi

export JAVA_HOME="$JDK24"
export PATH="$JAVA_HOME/bin:$PATH"

echo "Using JDK: $("$JAVA_HOME/bin/java.exe" -version 2>&1 | tr '\n' ' ' )"
echo "Port: $PORT"

# Always overwrite JSON results with a fresh array on each run (no append)
echo "[]" > "$JSON_RESULTS"

echo "Building (clean package, tests skipped)..."
build_start=$(date +%s%3N)
./mvnw -q --no-transfer-progress -DskipTests clean package
build_end=$(date +%s%3N)
build_ms=$((build_end - build_start))

if [[ ! -f "$JAR" ]]; then
  echo "[ERROR] Jar not found after build: $JAR"
  exit 1
fi
jar_bytes=$(wc -c < "$JAR" | tr -d ' ')

sum_launch=0
sum_heapUsed=0
sum_heapCommitted=0
sum_heapMax=0
sum_nonHeapUsed=0
sum_nonHeapCommitted=0

parse_field() {
  # $1 = key, $2 = payload
  echo "$2" | sed -n "s/.*\"$1\"[[:space:]]*:[[:space:]]*\\([0-9][0-9]*\\).*/\\1/p" | head -n1
}

for run in $(seq 1 $RUNS); do
  echo "Starting app (run $run/$RUNS)..."
  "$JAVA_HOME/bin/java.exe" -jar "$JAR" > bench/app.log 2>&1 &
  APP_PID=$!
  echo "PID=$APP_PID"

  echo "Waiting for readiness on /ping ..."
  start_ms=$(date +%s%3N)
  payload=""
  for i in {1..120}; do
    sleep 0.25
    payload=$(curl -s "http://localhost:${PORT}/ping" || true)
    if echo "$payload" | grep -q '"status"[[:space:]]*:[[:space:]]*"ok"'; then
      break
    fi
  done
  end_ms=$(date +%s%3N)
  launch_ms=$((end_ms - start_ms))
  sum_launch=$((sum_launch + launch_ms))

  heapUsed=$(parse_field "heapUsed" "$payload"); heapUsed=${heapUsed:-0}
  heapCommitted=$(parse_field "heapCommitted" "$payload"); heapCommitted=${heapCommitted:-0}
  heapMax=$(parse_field "heapMax" "$payload"); heapMax=${heapMax:-0}
  nonHeapUsed=$(parse_field "nonHeapUsed" "$payload"); nonHeapUsed=${nonHeapUsed:-0}
  nonHeapCommitted=$(parse_field "nonHeapCommitted" "$payload"); nonHeapCommitted=${nonHeapCommitted:-0}

  sum_heapUsed=$((sum_heapUsed + heapUsed))
  sum_heapCommitted=$((sum_heapCommitted + heapCommitted))
  sum_heapMax=$((sum_heapMax + heapMax))
  sum_nonHeapUsed=$((sum_nonHeapUsed + nonHeapUsed))
  sum_nonHeapCommitted=$((sum_nonHeapCommitted + nonHeapCommitted))

  echo "Shutting down (CTRL+C)..."
  kill -INT "$APP_PID" >/dev/null 2>&1 || true
  sleep 1
done

avg_launch_ms=$((sum_launch / RUNS))
avg_heapUsed=$((sum_heapUsed / RUNS))
avg_heapCommitted=$((sum_heapCommitted / RUNS))
avg_heapMax=$((sum_heapMax / RUNS))
avg_nonHeapUsed=$((sum_nonHeapUsed / RUNS))
avg_nonHeapCommitted=$((sum_nonHeapCommitted / RUNS))

ts=$(date -u +%Y-%m-%dT%H:%M:%SZ)
variant="jpms-java24-boot4-min"

# Create a single pretty JSON array with only the latest aggregated result (overwrite behavior)
json_obj=$(cat <<EOF
{
  "timestamp": "$ts",
  "variant": "$variant",
  "build_ms": $build_ms,
  "jar_bytes": $jar_bytes,
  "runs": $RUNS,
  "averages": {
    "launch_ms": $avg_launch_ms,
    "heapUsed": $avg_heapUsed,
    "heapCommitted": $avg_heapCommitted,
    "heapMax": $avg_heapMax,
    "nonHeapUsed": $avg_nonHeapUsed,
    "nonHeapCommitted": $avg_nonHeapCommitted
  }
}
EOF
)
printf "[\n%s\n]\n" "$json_obj" > "$JSON_RESULTS"

echo "Done. JSON results written to $JSON_RESULTS"