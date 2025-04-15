

# Project - Alfred

A Flutter project built using Clean Architecture with MVVM, Riverpod for state management and dependency injection, Hive for local storage, and rosbridge for ROS connectivity. All user interface text is localized using slang with support for English (default) and Hindi.

Developers can quickly set up, generate build files, and start working on the project without any issues.

---

## Table of Contents

- [Features](#features)
- [Prerequisites](#prerequisites)
- [Setup Instructions](#setup-instructions)
    - [Clone the Repository](#clone-the-repository)
    - [Install Dependencies](#install-dependencies)
    - [Generate Build Files](#generate-build-files)
    - [Run the App](#run-the-app)
- [Localization](#localization)
- [ROS Connectivity](#ros-connectivity)
- [Development Guidelines](#development-guidelines)
- [Troubleshooting](#troubleshooting)
- [Contributing](#contributing)
- [License](#license)

---

## Features

- **Clean Architecture with MVVM**: Separation of concerns with a well-structured project.
- **Riverpod**: Used for state management and dependency injection.
- **ROS Connectivity**: Connects to ROS using rosbridge (`ws://127.0.0.1:9090`).
- **Topic Repositories**: Dedicated repositories for odom, map, and cmd_vel topics.
- **Hive Local Storage**: Stores table entries locally using Hive (via hive_ce).
- **Material Design 3**: Uses the latest Material Design guidelines.
- **Localization**: All user-facing text is localized using slang, with support for English and Hindi.
- **Responsive Layouts**: Designed to handle various screen sizes dynamically.

---

## Prerequisites

- **Flutter SDK**: Ensure you are using Flutter SDK version that supports Dart SDK >= 3.7.2.
- **Dependencies**: The project uses:
    - [rosbridge](https://pub.dev/packages/rosbridge): ^0.0.2-dev+4
    - [slang](https://pub.dev/packages/slang): ^4.6.0
    - [go_router](https://pub.dev/packages/go_router): ^14.8.1
    - [flutter_riverpod](https://pub.dev/packages/flutter_riverpod): ^2.6.1
    - [dotted_border](https://pub.dev/packages/dotted_border): ^2.1.0
    - [hive_ce](https://pub.dev/packages/hive_ce): ^2.10.1
    - [path_provider](https://pub.dev/packages/path_provider): ^2.0.11

---

## Setup Instructions

### Clone the Repository

```bash
git clone https://bitbucket.org/your-username/flutter_ros_project.git
cd flutter_ros_project
```

### Install Dependencies

Run the following command to install all dependencies:

```bash
flutter pub get
```

### Generate Build Files

This project uses Hive and slang generators. To generate the necessary files (e.g., Hive adapters, localization files), run:

```bash
flutter pub run build_runner build --delete-conflicting-outputs
flutter pub run slang
```

*Tip:* You can also run in watch mode during development:

```bash
flutter pub run build_runner watch --delete-conflicting-outputs
```

### Run the App

To run the app on your emulator or device, use:

```bash
flutter run
```

---

## Localization

The project uses the slang package for localization.
- English translations are stored in `assets/i18n/en.i18n.json`.

Ensure that the JSON files are properly formatted. The generated file `lib/gen/strings_en.g.dart` (via slang) will provide all localized strings throughout the app.

---

## ROS Connectivity

This project connects to a ROS system using rosbridge over the socket URL: `ws://127.0.0.1:9090`.

- **Connection Management:**  
  The `RosConnection` class (in `lib/providers/ros_service_provider.dart`) handles connecting/disconnecting and exposes a status stream (`_statusController.stream`) so the app is notified of any connection changes.

- **Topic Repositories:**
    - **OdomRepository:** Subscribes to the `/odom` topic and converts messages to `Pose` objects.
    - **MapRepository:** Subscribes to the `/map` topic and converts messages to `OccupancyGrid` objects.
    - **CmdVelRepository:** Publishes to the `/cmd_vel` topic.

All of these repositories are consumed by the ViewModels which expose only the necessary data to the UI.

---

## Development Guidelines

- **Clean Architecture:**  
  Follow the provided project structure (core, data, mvvm, providers) to maintain a separation of concerns.

- **MVVM Pattern:**
    - **ViewModels** manage business logic and state.
    - **Views** (screens) are kept as simple as possible, reading state from the ViewModels.

- **Riverpod:**  
  Use Riverpod providers (located in `lib/providers/providers.dart`) for dependency injection and state management.

- **Build Runner:**  
  Remember to run `flutter pub run build_runner build --delete-conflicting-outputs` whenever you make changes to model files that require code generation.

- **Testing:**  
  Write tests for your ViewModels and repositories to ensure the ROS connectivity and local storage work as expected.

---

## Troubleshooting

- **Build Runner Issues:**  
  If you encounter issues with code generation, try cleaning the project:
  ```bash
  flutter clean
  flutter pub get
  flutter pub run build_runner build --delete-conflicting-outputs
  ```

- **ROS Connection:**  
  Ensure your ROS environment is accessible at `ws://127.0.0.1:9090`. Verify network settings and rosbridge availability.

- **Localization:**  
  If the generated localization file is not updated, run the slang generator and check that your JSON files are correctly formatted.

---