# En2lyDriver

## Overview
En2lyDriver is a mobile application designed for drivers in the En2ly transportation network. The app provides features for trip management, navigation, ride requests, and earnings tracking, offering a seamless experience for drivers.

## Features
- **Trip Management**: Accept and track rides in real time.
- **Navigation Integration**: Get route guidance for destinations.
- **Earnings Overview**: View trip history and earnings summary.
- **Ride Requests**: Receive ride requests with passenger details.
- **Profile & Settings**: Manage driver profile and app preferences.

## Tech Stack
- **Frontend**: Flutter
- **Backend**: Firebase
- **State Management**: Provider / Riverpod (if applicable)
- **Authentication**: Firebase Authentication
- **Maps & Navigation**: Google Maps API

## Installation
### Prerequisites
- Flutter SDK installed ([Download here](https://flutter.dev/docs/get-started/install))
- Android Studio / Xcode for running the app
- Firebase project setup (for backend functionality)

### Steps
1. Clone the repository:
   ```sh
   git clone https://github.com/Zafaranii/En2lyDriver.git
   cd En2lyDriver
   ```
2. Install dependencies:
   ```sh
   flutter pub get
   ```
3. Run the app:
   ```sh
   flutter run
   ```
   *(Make sure a simulator/emulator or physical device is connected.)*

## Project Structure
```
En2lyDriver/
│-- lib/
│   │-- main.dart         # Entry point of the app
│   │-- screens/          # UI screens
│   │-- providers/        # State management
│   │-- services/         # Firebase and API services
│   │-- widgets/          # Reusable UI components
│-- assets/               # Images and other assets
│-- pubspec.yaml          # Dependencies and configurations
│-- android/              # Android-specific files
│-- ios/                  # iOS-specific files
```

## Contributing
1. Fork the repository.
2. Create a new branch:
   ```sh
   git checkout -b feature-name
   ```
3. Commit your changes:
   ```sh
   git commit -m "Add new feature"
   ```
4. Push the branch:
   ```sh
   git push origin feature-name
   ```
5. Open a pull request.

## License
This project is licensed under the MIT License.

## Contact
For inquiries, contact **Marwan Hazem** at [marwan.elzafarani@gmail.com](mailto:marwan.elzafarani@gmail.com).
