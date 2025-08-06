#!/usr/bin/env bash
set -euo pipefail

# Configure JDK 24 home locally without changing global machine settings
JDK24_DEFAULT="C:/Program Files/Eclipse Adoptium/jdk-24.0.2.12-hotspot"

# Usage:
#   bash run-jlink.sh
#   bash run-jlink.sh "C:/Program Files/Eclipse Adoptium/jdk-24.0.2.12-hotspot"
JDK24="${1:-$JDK24_DEFAULT}"

if [[ ! -x "$JDK24/bin/java.exe" ]]; then
  echo "[ERROR] JDK 24 not found at: $JDK24"
  echo "Usage: bash run-jlink.sh \"C:/Path/To/jdk-24.x.y\""
  exit 1
fi

echo "Using JDK: $JDK24"
"$JDK24/bin/java.exe" -version || true

# Export JAVA_HOME for this process and prepend its bin to PATH
export JAVA_HOME="$JDK24"
export PATH="$JAVA_HOME/bin:$PATH"

# Ensure Maven Wrapper exists
if [[ ! -f "./mvnw" ]]; then
  echo "[ERROR] Maven Wrapper (mvnw) not found in project root"
  exit 1
fi

# Build with jlink profile to produce bench/runtime
echo "Building jlink image with JDK 24..."
./mvnw -q --no-transfer-progress -P jlink -DskipTests package

# Show resulting runtime contents and size on Windows Git Bash
if [[ -d "bench/runtime" ]]; then
  echo
  echo "=== jlink runtime created at bench/runtime ==="
  # If running in Git Bash on Windows, use 'du' fallback if available
  if command -v du >/dev/null 2>&1; then
    du -sh bench/runtime || true
  fi
  # List a few key directories
  find bench/runtime -maxdepth 2 -type d -print 2>/dev/null || true
else
  echo "[ERROR] bench/runtime not found. jlink build may have failed."
  exit 1
fi

echo
echo "Done. You can run with the custom runtime using:"
echo "  bench/runtime/bin/java -jar target/example-0.0.1-SNAPSHOT.jar"