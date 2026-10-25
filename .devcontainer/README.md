# VCCVerticalTab — GitHub Codespaces

Open the repository in GitHub, select **Code → Codespaces → Create codespace**. The dev container installs Java 17, Android command-line tools, API 35, build-tools 35.0.0 and platform-tools.

## Build

From the repository root (once the Android project and Gradle Wrapper exist):

```bash
./gradlew assembleDebug
```

The debug APK is usually written to `app/build/outputs/apk/debug/`.

## Device testing

A Codespace is not expected to provide an accelerated Android emulator. Download the APK and install it on a physical Android device, or use a local emulator. Launchers must be tested as the default HOME app.

## Adjustments

Match the installed `platforms;android-35` and `build-tools;35.0.0` in `setup-android.sh` to the project's actual Gradle configuration. JDK 17 is a starting point; check Android Gradle Plugin requirements before upgrading.

## Notes

This setup does not modify the Android application. Review the project's existing build configuration before assuming `assembleDebug` will succeed. The initial command-line tools package is downloaded from Google's official Android repository.
