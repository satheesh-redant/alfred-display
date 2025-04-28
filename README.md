

# Project - Alfred

A Flutter project built using Clean Architecture with MVVM, Riverpod for state management and dependency injection, Hive for local storage, and rosbridge for ROS connectivity. All user interface text is localized using slang with support for English (default) and Hindi.

Developers can quickly set up, generate build files, and start working on the project without any issues.

---

## Table of Contents

- [1. Prerequisites](#1-prerequisites)
- [2. Environment Setup](#2-environment-setup)
- [3. Running the App](#3-running-the-app)
- [4. Project Structure Overview](#4-project-structure-overview)
- [5. Common Commands](#5-common-commands)
- [6. Debugging & Troubleshooting](#6-debugging--troubleshooting)
- [7. Coding Guidelines](#7-coding-guidelines)
- [8. Branching & Contribution Workflow](#8-branching--contribution-workflow)
- [9. Additional Resources](#9-additional-resources)

---

## 1. Prerequisites

Before you begin, ensure you have the following installed on your machine:

- **Operating System**: Windows 10/11 or Linux (Ubuntu/Debian-based or other distros)
- **Git**: Version control [Download & Install](https://git-scm.com/downloads)
- **Flutter SDK**: Latest stable release [Install Guide](https://flutter.dev/docs/get-started/install) (follow the OS-specific instructions)
- **IDE (choose one)**:
  - **VS Code**:
    - Install the [Flutter](https://marketplace.visualstudio.com/items?itemName=Dart-Code.flutter) and [Dart](https://marketplace.visualstudio.com/items?itemName=Dart-Code.dart-code) extensions
    - Use the Command Palette (`Ctrl+Shift+P` / `Cmd+Shift+P`) for Flutter commands
  - **Android Studio**:
    - Install via [JetBrains Toolbox](https://www.jetbrains.com/toolbox-app/)
    - From Toolbox, install **Android Studio** and launch it
    - Within Android Studio, install the Flutter and Dart plugins via **Settings → Plugins**
    - Use the AVD Manager (**Tools → AVD Manager**) to create and manage emulators
- **JetBrains Runtime (JBR) 21** *(optional for Android Studio users)*:
    - Download from the official [GitHub releases](https://github.com/JetBrains/JetBrainsRuntime/releases)
    - **Windows**:
        1. Download the ZIP for JBR-21.
        2. Extract to a folder, e.g., `C:\Program Files\JetBrains\jbr-21`.
        3. Set `JAVA_HOME` in PowerShell:
            ```powershell
            [Environment]::SetEnvironmentVariable("JAVA_HOME", "C:\Program Files\JetBrains\jbr-21", "User")
            ```
        4. Add `%JAVA_HOME%\bin` to your `Path` environment variable.
    - **Linux**:
        1. Download the TAR.GZ for JBR-21.
        2. Extract to a folder, e.g., `~/jbr-21`:
            ```bash
            tar -xzf jetbrains-jbr-21-*.tar.gz -C ~/jbr-21
            ```
        3. Set `JAVA_HOME` in your shell (e.g., `~/.bashrc`):
            ```bash
            echo 'export JAVA_HOME="$HOME/jbr-21"' >> ~/.bashrc
            echo 'export PATH="$JAVA_HOME/bin:$PATH"' >> ~/.bashrc
            source ~/.bashrc
            ```
---

## 2. Environment Setup

1. **Clone the repository**
   ```bash
   git clone <your-bitbucket-repo-url>
   cd <project-folder>
   ```
2. **Install Flutter dependencies**
   ```bash
   flutter pub get
   ```
3. **Verify your setup**
   ```bash
   flutter doctor -v
   ```
   Follow any prompts to install missing components (e.g., Android licenses).
   
4. **Configure an emulator or device**
    - **Android Emulator**:
        - **VS Code**:
        Open the Command Palette (`Ctrl+Shift+P` / `Cmd+Shift+P`), type **Flutter: Launch Emulator**, and select or create an Android emulator.
        - **CLI (Linux)**:
            ```bash
            $ANDROID_HOME/emulator/emulator -list-avds
            $ANDROID_HOME/emulator/emulator -avd <emulator_name>
            ```
        - **CLI (Windows PowerShell)**:
            ```powershell
            & "$Env:ANDROID_HOME/emulator/emulator.exe" -list-avds
            & "$Env:ANDROID_HOME/emulator/emulator.exe" -avd <emulator_name>
            ```
    - **Physical Device**:
        - **Windows:**
            1. Enable USB debugging on your device.
            2. Install device drivers via SDK Manager → SDK Tools → Google USB Driver.
            3. Connect via USB and select the device in VS Code's status bar.

        - **Linux:**
            1. Enable USB debugging on your device.
            2. Install ADB tools: `sudo apt install android-tools-adb android-tools-fastboot`.
            3. Set up udev rules:
                ```bash
                sudo tee /etc/udev/rules.d/51-android.rules <<EOF
                SUBSYSTEM=="usb", ATTR{idVendor}=="<vendor_id>", MODE="0666", GROUP="plugdev"
                EOF
                sudo udevadm control --reload-rules
                ```
            4. Connect via USB, grant permissions, and select the device in VS Code's status bar.
---

## 3. Running the App

- **Start your emulator** or connect a device.
- **Generate Build Files:** 
This project uses slang generators. To generate the necessary files (e.g., localization files), run:
  ```bash
  flutter pub run build_runner build --delete-conflicting-outputs
  flutter pub run slang
  ```
  *Tip:* You can also run in watch mode during development:
  ```bash
  flutter pub run build_runner watch --delete-conflicting-outputs
  ```

- **Run the App:** 
To run the app on your emulator or device, use:
    ```bash
    flutter run
    ```

- **Hot Reload:** 
Press `r` in the terminal or click the ▶️ Hot Reload button in your IDE.

---

## 4. Project Structure Overview

```
alfred-display/
│
├── .dart_tool/                    # Flutter tooling (auto-generated)
├── .idea/                         # IDE settings (Android Studio/IDEA)
├── android/                       # Android platform-specific code (CMake, plugins, runner)
├── assets/                        # Images and localization files
│   ├── i18n/                      # Localization JSON files
│   └── images/                    # SVG and PNG assets
├── lib/                           # Dart source files
│   ├── config/                    # App constants (e.g., routes, ROS constants)
│   ├── core/                      # Themes, routes, and common utilities
│   ├── gen/                       # Generated localization files
│   ├── models/                    # Data models and state classes
│   ├── providers/                 # Riverpod providers for state management
│   ├── view_models/               # MVVM view models for business logic
│   ├── presentation/              # UI screens and widgets
│   │   ├── screens/               # Application screens
│   │   └── widgets/               # Reusable UI components
│   └── main.dart                  # App entry point
├── linux/                         # Linux desktop embedding (if supported)
├── test/                          # Unit and widget tests
├── pubspec.yaml                   # Dependencies and metadata
├── pubspec.lock                   # Locked dependency versions
├── analysis_options.yaml          # Linter and analyzer rules
└── README.md                      # Project documentation
```

## 5. Common Commands

| Command               | Description                               |
| --------------------- | ----------------------------------------- |
| `flutter clean`       | Remove build/outputs and reset caches     |
| `flutter pub get`     | Fetch project dependencies                |
| `flutter pub upgrade` | Upgrade dependencies to latest compatible |
| `flutter format .`    | Auto-format Dart code                     |
| `flutter analyze`     | Static analysis for errors and warnings   |
| `flutter test`        | Run all unit & widget tests               |

---

## 6. Debugging & Troubleshooting

- **Logs**: Use `flutter logs` to view runtime logs.
- **DevTools**: Run `flutter pub global run devtools` and open the URL.
- **Common Issues**:
  - *Android license not accepted*: `flutter doctor --android-licenses`
  - *Gradle build failures*: Delete `android/.gradle` and run `flutter pub get` again.

---

## 7. Coding Guidelines

- **Dart Style**: Follow the official [Dart Style Guide](https://dart.dev/guides/language/effective-dart).
- **Naming Conventions**:
  - Files: `snake_case.dart`
  - Classes/Widgets: `PascalCase`
  - Constants: `kCamelCase`
- **Stateless vs Stateful**: Use `StatelessWidget` when no state changes; otherwise `StatefulWidget`.
- **Null Safety**: Embrace Dart's null-safety features; avoid using `!` unless necessary.

---

## 8. Branching & Contribution Workflow

1. **Create a branch** from `develop`:
   ```bash
   git checkout develop
   git pull origin develop
   git checkout -b feature/<your-feature-name>
   ```
2. **Make changes**, commit regularly with clear messages:
   ```bash
   git add .
   git commit -m "Add <short-description>"
   ```
3. **Push to remote** and open a **Pull Request** targeting `develop`.
4. **Code Review**: Address feedback, update your branch, and squat commits if needed.
5. **Merge** after approval and ensure the CI pipeline passes.

---

## 9. Additional Resources

- **Flutter Documentation**: [flutter.dev/docs](https://flutter.dev/docs)
- **Dart Language Tour**: [dart.dev/guides/language/language-tour](https://dart.dev/guides/language/language-tour)
- **Flutter Widget Catalogue**: [flutter.dev/docs/development/ui/widgets](https://flutter.dev/docs/development/ui/widgets)

---

Happy coding! 🚀