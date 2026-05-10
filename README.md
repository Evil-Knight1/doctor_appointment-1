# Doctor Appointment App 🩺

![Flutter](https://img.shields.io/badge/Flutter-3.10.7-blue?logo=flutter)
![Dart](https://img.shields.io/badge/Dart-3.1-blue?logo=dart)
![Platform](https://img.shields.io/badge/Platform-iOS%20%7C%20Android-lightgrey)

A comprehensive cross-platform mobile application that connects patients with doctors. The app provides a seamless experience for searching for medical professionals, booking appointments, managing medical records, processing payments, and real-time chatting with both doctors and an AI chatbot.

## 🌟 Key Features

### For Patients:
- **Smart Search & Filters:** Find nearby doctors using an interactive map, and filter by specialization, rating, or recommendations.
- **Appointment Booking:** View available doctor slots and book appointments easily.
- **Secure Payments:** Integrated with Paymob to support cash at clinic, online cards, and mobile wallets.
- **Real-Time Chat:** 1-on-1 messaging with doctors over SignalR.
- **AI Chatbot:** Built-in AI assistant to help patients with basic medical inquiries.
- **Medical Records:** Upload and manage personal medical files and history.

### For Doctors:
- **Doctor Dashboard:** Dedicated dashboard to view daily statistics and appointments.
- **Schedule Management:** Handle upcoming, pending, and completed appointments.
- **Profile Management:** Control visibility, working hours, and specializations.

## 🏗️ Architecture

The project strictly follows **Clean Architecture** combined with a **Feature-First** structure.

- **`core/`**: Shared infrastructure (DI, networking, themes, routing, logging, errors).
- **`features/`**: 16 self-contained modules (e.g., `auth`, `appointment`, `chat`, `payments`).

Each feature is divided into 4 layers:
1. `data/` (Datasources, Repositories, Models)
2. `domain/` (Entities, UseCases, Repository Contracts)
3. `logic/` (Cubit state management)
4. `presentation/` (Views and Widgets)

## 🛠️ Technology Stack

**Frontend Framework & State:**
- [Flutter](https://flutter.dev/) & [Dart](https://dart.dev/)
- `flutter_bloc` / Cubit for state management
- `go_router` for declarative routing and deep linking
- `get_it` for Dependency Injection (Service Locator)

**Networking & Real-Time:**
- `dio` for REST API HTTP requests
- `signalr_core` for real-time WebSockets messaging

**Storage & Security:**
- `flutter_secure_storage` for encrypted JWT storage
- `shared_preferences` for light key-value persistence
- `jwt_decoder` for proactive token validation

**Device Features:**
- `firebase_messaging` & `flutter_local_notifications` for push notifications
- `geolocator` & `flutter_osm_plugin` for location mapping
- `image_picker` & `file_picker` for media uploads

**Localization:**
- Multi-language support (English & Arabic) using `flutter_localizations` and `intl`.
- Persistence of language preference via `LocaleCubit`.

**Observability:**
- `sentry_flutter` & `sentry_dio` for crash and performance monitoring

## 🔐 Authentication & Token Refresh

The application utilizes a secure JWT-based authentication system with a **hybrid proactive/reactive refresh mechanism**:
1. **Proactive Check:** On launch (`SplashView`), the app uses `jwt_decoder` to locally inspect token expiration. If expired, it seamlessly requests a new token before entering the app.
2. **Reactive Intercepting:** During active use, a custom Dio `AuthTokenInterceptor` catches `401 Unauthorized` errors, pauses incoming requests using a `Completer`, refreshes the token, and replays the failed request completely invisibly to the user.

## 🚀 Getting Started

### Prerequisites
- Flutter SDK `^3.10.7`
- Android Studio / Xcode

### Setup
1. Clone the repository.
2. Ensure you have an `assets/envs/.env` file with your API keys (Paymob, API URL).
3. Run `flutter pub get` to fetch dependencies.
4. Run `flutter run` to launch the app on your connected device or emulator.

---
*Built as a Graduation Project.*
