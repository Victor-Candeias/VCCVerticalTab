#!/usr/bin/env bash
set -euo pipefail
SDK="${ANDROID_SDK_ROOT:-/opt/android-sdk}"
TOOLS_VERSION="11076708"
mkdir -p "$SDK/cmdline-tools"
if [ ! -x "$SDK/cmdline-tools/latest/bin/sdkmanager" ]; then
  tmpdir="$(mktemp -d)"
  trap 'rm -rf "$tmpdir"' EXIT
  curl -fsSL "https://dl.google.com/android/repository/commandlinetools-linux-${TOOLS_VERSION}_latest.zip" -o "$tmpdir/tools.zip"
  unzip -q "$tmpdir/tools.zip" -d "$tmpdir"
  mv "$tmpdir/cmdline-tools" "$SDK/cmdline-tools/latest"
fi
yes | sdkmanager --sdk_root="$SDK" --licenses >/dev/null || test "${PIPESTATUS[1]}" -eq 0
sdkmanager --sdk_root="$SDK" "platform-tools" "platforms;android-35" "build-tools;35.0.0"
java -version
sdkmanager --sdk_root="$SDK" --version
if [ -f ./gradlew ]; then
  chmod +x ./gradlew
  ./gradlew --version
  echo "Gradle wrapper detected. Run ./gradlew assembleDebug to build."
else
  echo "No Gradle wrapper detected yet; add or locate the Android project before building."
fi
