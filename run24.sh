#!/usr/bin/env bash
set -euo pipefail

# Configure JDK 24 home locally without changing global JAVA_HOME or PATH
JDK24="C:/Program Files/Eclipse Adoptium/jdk-24.0.2.12-hotspot"

# Allow override: ./run24.sh "C:/Program Files/Eclipse Adoptium/jdk-24.0.2.12-hotspot"
if [[ $# -ge 1 ]]; then
  JDK24="$1"
fi

JDK24_WIN="$JDK24"

if [[ ! -x "$JDK24_WIN/bin/java.exe" ]]; then
  echo "[ERROR] JDK 24 not found at: $JDK24_WIN"
  echo "Usage: ./run24.sh \"C:/Path/To/jdk-24.x.y\""
  exit 1
fi

echo "Using JDK: $JDK24_WIN"
"$JDK24_WIN/bin/java.exe" -version || true

# Export JAVA_HOME for this process only and prepend its bin to PATH
export JAVA_HOME="$JDK24_WIN"
export PATH="$JAVA_HOME/bin:$PATH"

# Ensure Maven Wrapper exists
if [[ ! -f "./mvnw" ]]; then
  echo "[ERROR] Maven Wrapper (mvnw) not found in project root"
  exit 1
fi

# Clean build to ensure correct release level; skip tests for speed
echo "Building project with JDK 24..."
./mvnw -q --no-transfer-progress -DskipTests clean package

# Prefer running the packaged JAR to avoid Maven/Guice Unsafe warnings during run phase
JAR_FILE="target/example-0.0.1-SNAPSHOT.jar"
if [[ ! -f "$JAR_FILE" ]]; then
  echo "[ERROR] Built jar not found at $JAR_FILE"
  exit 1
fi

echo "Starting application from jar..."
exec "$JAVA_HOME/bin/java.exe" -jar "$JAR_FILE"