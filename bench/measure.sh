#!/usr/bin/env bash
# shellcheck shell=bash
set -euo pipefail

# Minimal benchmark helper for Git Bash on Windows:
# - Builds once
# - Measures jar size
# - Runs once, waits for /ping, measures launch time
# - Does NOT attempt memory or process management
# If the jar is locked, manually close any running Java apps and retry.

JDK24_DEFAULT="C:/Program Files/Eclipse Adoptium/jdk-24.0.2.12-hotspot"
JDK24="${1:-$JDK24_DEFAULT}"
PORT="${2:-8080}"
JAR="target/example-0.0.1-SNAPSHOT.jar"
RESULTS="bench/results.csv"

if [[ ! -x "$JDK24/bin/java.exe" ]]; then
  echo "[ERROR] JDK not found at $JDK24"
  echo "Usage: bash bench/measure.sh \"C:/Path/To/jdk-24.x\" [port=8080]"
  exit 1
fi

export JAVA_HOME="$JDK24"
export PATH="$JAVA_HOME/bin:$PATH"

echo "Using JDK: $("$JAVA_HOME/bin/java.exe" -version 2>&1 | tr '\n' ' ' )"
echo "Port: $PORT"

if [[ ! -f "$RESULTS" ]]; then
  echo "timestamp,variant,build_ms,jar_bytes,launch_ms" > "$RESULTS"
fi

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

echo "Starting app..."
"$JAVA_HOME/bin/java.exe" -jar "$JAR" > bench/app.log 2>&1 &
APP_PID=$!
echo "PID=$APP_PID"

echo "Waiting for readiness on /ping ..."
start_ms=$(date +%s%3N)
for i in {1..120}; do
  sleep 0.25
  if curl -s "http://localhost:${PORT}/ping" | grep -q "ok"; then
    break
  fi
done
end_ms=$(date +%s%3N)
launch_ms=$((end_ms - start_ms))

echo "Shutting down (CTRL+C)..."
kill -INT "$APP_PID" >/dev/null 2>&1 || true
sleep 1

ts=$(date -u +%Y-%m-%dT%H:%M:%SZ)
variant="jpms-java24-boot4-min"
echo "$ts,$variant,$build_ms,$jar_bytes,$launch_ms" | tee -a "$RESULTS"

echo "Done. Results appended to $RESULTS"