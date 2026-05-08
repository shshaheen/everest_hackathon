# 🌸 [SHE (Safety Help Emergency) - Women's Safety App (Demo Link)](https://drive.google.com/file/d/1tAzgbzEizAK2UnWgtV7NIrV1rKXOHyLY/view?usp=drivesdk)

> *Empowering women with instant safety tools and emergency response capabilities*

A comprehensive Flutter application designed specifically for women's safety, built with **Clean Architecture** principles , SHE provides a complete safety ecosystem with real-time emergency response, AI assistance, and intuitive safety tools.

## 🚀 Project Overview

**SHE (Safety Help Emergency)** is a mobile women's safety application that transforms how users respond to emergency situations. The app combines cutting-edge technology with user-centric design to provide instant help when it matters most.

### 🎯 Mission
To create a reliable, fast, and intuitive safety companion that empowers women to feel secure and confident in any situation.

## ✨ Key Features

### 🔐 **Secure Authentication System**
- **OTP-based phone verification** - Quick and secure login without passwords
- **Profile setup with emergency contacts** - Streamlined onboarding process
- **Session management** - Automatic login persistence for faster access

### 🆘 **Emergency SOS Module**
- **One-tap SOS activation** - Instant emergency alert with countdown timer
- **Smart location sharing** - Automatically sends precise GPS coordinates
- **Multi-contact alerts** - Simultaneously notifies all trusted contacts
- **Cancel mechanism** - 5-second countdown with cancel option to prevent false alarms

### 📞 **Fake Call Feature**
- **Realistic incoming call simulation** - Escape uncomfortable situations discreetly
- **Customizable caller details** - Set custom names, photos, and call duration.
- **Interactive call interface** - Full call screen with answer/decline options

### 🤖 **AI-Powered Chat Assistant**
💬 Real-time conversations – Get instant responses and guidance in critical situations.
🧠 Smart emergency insights – Understand what to do, where to go, and how to stay safe with intelligent suggestions.
🗣️ Voice-enabled interaction – Talk to the assistant hands-free when you’re unable to type.
🕓 Always available – Accessible 24/7, ensuring you’re never alone in moments of uncertainty.

### 📍 **Location & Tracking Services**
- **Real-time GPS tracking** - Precise location detection and sharing



### 📞 **Emergency Helplines Directory**
- **Comprehensive helpline database** - Police, medical, women's helpline numbers
- **One-tap calling** - Direct dial to emergency services
- **24/7 availability** - Always accessible emergency contacts

### 👥 **Contact Management**
- **Trusted contacts system** - Add family and friends as emergency contacts
- **Phone book integration** - Import contacts directly from device
- **Contact verification** - Ensure all emergency contacts are reachable
- **Group messaging** - Send alerts to multiple contacts simultaneously
## 🏗️ Project Architecture

This project follows **Clean Architecture** principles with strict separation of concerns, ensuring scalability, testability, and maintainability:

```
lib/
├── app/                           # Application Layer
│   └── app.dart                   # Root app configuration
│
├── core/                          # Core Infrastructure
│   ├── config/
│   │   └── environment_config.dart # Environment & API configuration
│   ├── dependency_injection/
│   │   ├── di_container.dart      # Service locator container
│   │   └── di_setup.dart          # Dependency registration
│   ├── error/
│   │   ├── exceptions.dart        # Custom exceptions
│   │   └── failures.dart          # Error handling
│   ├── network/
│   │   ├── api_client.dart        # Dio HTTP client
│   │   ├── api_endpoints.dart     # API endpoint constants
│   │   └── dio_interceptors.dart  # Request/Response interceptors
│   ├── services/
│   │   ├── app_preferences_service.dart  # Local storage
│   │   ├── contact_storage_service.dart  # Contact management
│   │   ├── gemini_service.dart          # AI chat service
│   │   ├── location_service.dart        # GPS & location
│   │   ├── location_sharing_service.dart # Location sharing
│   │   └── ringtone_service.dart        # Audio services
│   ├── theme/
│   │   ├── app_theme.dart         # Material theme configuration
│   │   └── color_scheme.dart      # App color palette
│   └── utils/
│       ├── constants.dart         # App constants
│       ├── logger.dart           # Logging utility
│       ├── result.dart           # Result wrapper
│       └── validators.dart       # Input validation
│
├── domain/                        # Business Logic Layer
│   ├── entities/
│   │   ├── auth_entity.dart      # Authentication entity
│   │   ├── contact.dart          # Contact entity
│   │   ├── sos_entity.dart       # SOS entity
│   │   └── user_entity.dart      # User entity
│   ├── repositories/
│   │   ├── auth_repository.dart   # Auth repository interface
│   │   ├── contacts_repository.dart # Contacts repository interface
│   │   └── sos_repository.dart    # SOS repository interface
│   └── usecases/
│       ├── auth/
│       │   ├── send_otp_usecase.dart   # Send OTP use case
│       │   └── verify_otp_usecase.dart # Verify OTP use case
│       ├── add_contact_usecase.dart    # Add contact use case
│       └── get_contacts_usecase.dart   # Get contacts use case
│
├── data/                          # Data Access Layer
│   ├── datasources/
│   │   └── remote/
│   │       └── auth_remote_source.dart # Remote auth data source
│   ├── models/
│   │   ├── auth_model.dart        # Auth data model
│   │   └── user_model.dart        # User data model
│   └── repositories_impl/
│       ├── auth_repository_impl.dart     # Auth repository implementation
│       └── contacts_repository_impl.dart # Contacts repository implementation
│
├── features/                      # Feature Modules
│   ├── auth/                     # Authentication Module
│   │   ├── bloc/
│   │   │   ├── auth_bloc.dart    # Authentication BLoC
│   │   │   ├── auth_event.dart   # Auth events
│   │   │   └── auth_state.dart   # Auth states
│   │   ├── presentation/
│   │   │   ├── login_screen.dart          # Phone login screen
│   │   │   ├── otp_verification_screen.dart # OTP verification
│   │   │   └── profile_setup_screen.dart   # Profile setup
│   │   └── widgets/
│   │       └── regular_phone_field.dart   # Phone input widget
│   ├── chat/                     # AI Chat Module
│   │   ├── presentation/
│   │   │   └── chat_screen.dart   # AI chat interface
│   │   └── widgets/
│   │       └── animate_wave_bar.dart # Voice animation
│   ├── contacts/                 # Contacts Management
│   │   ├── bloc/
│   │   │   ├── contacts_bloc.dart # Contacts BLoC
│   │   │   ├── contacts_event.dart # Contacts events
│   │   │   └── contacts_state.dart # Contacts states
│   │   ├── presentation/
│   │   │   ├── contacts_screen.dart      # Emergency contacts
│   │   │   └── phone_contacts_screen.dart # Phone book integration
│   │   ├── services/
│   │   │   └── phone_contacts_service.dart # Device contacts
│   │   └── widgets/
│   │       ├── add_contact_bottom_sheet.dart # Add contact UI
│   │       └── contact_card.dart            # Contact display
│   ├── fake_call/               # Fake Call Module
│   │   ├── bloc/
│   │   │   ├── fake_call_bloc.dart # Fake call BLoC
│   │   │   ├── fake_call_event.dart # Fake call events
│   │   │   └── fake_call_state.dart # Fake call states
│   │   └── presentation/
│   │       ├── caller_details_screen.dart  # Caller customization
│   │       ├── fake_call_screen.dart       # Fake call setup
│   │       ├── in_call_screen.dart         # Active call UI
│   │       └── incoming_call_screen.dart   # Incoming call UI
│   ├── helpline/                # Emergency Helplines
│   │   ├── bloc/
│   │   │   ├── helpline_bloc.dart # Helpline BLoC
│   │   │   ├── helpline_event.dart # Helpline events
│   │   │   └── helpline_state.dart # Helpline states
│   │   ├── data/
│   │   │   └── helpline_data.dart # Helpline numbers database
│   │   ├── helpline_card.dart    # Helpline display widget
│   │   ├── helpline_model.dart   # Helpline data model
│   │   └── helpline_screen.dart  # Helplines directory
│   ├── home/                    # Home Dashboard
│   │   └── presentation/
│   │       └── home_screen.dart  # Main dashboard
│   ├── profile/                 # User Profile
│   │   └── presentation/
│   │       └── profile_screen.dart # Profile management
│   ├── sos/                     # Emergency SOS
│   │   └── presentation/
│   │       └── sos_screen.dart   # SOS activation screen
│   └── track/                   # Location Tracking
│       ├── bloc/
│       │   ├── track_bloc.dart   # Tracking BLoC
│       │   └── track_event.dart  # Tracking events
│       └── presentation/
│           └── track_screen.dart # Location tracking UI
│
├── routes/                       # Navigation
│   └── app_router.dart          # go_router configuration
│
└── shared/                      # Shared Components
    └── widgets/                 # Reusable UI widgets
```

## 🛠️ Tech Stack

| **Category** | **Technology** | **Purpose** |
|--------------|----------------|-------------|
| **Framework** | Flutter 3.8.1+ | Cross-platform mobile development |
| **Language** | Dart | Primary programming language |
| **Architecture** | Clean Architecture | Separation of concerns & scalability |
| **State Management** | BLoC Pattern | Predictable state management |
| **Dependency Injection** | GetIt | Service locator pattern |
| **Navigation** | go_router | Declarative routing |
| **Networking** | Dio | HTTP client with interceptors |
| **Data Models** | Freezed + JSON Annotation | Immutable models & serialization |
| **UI Framework** | Material 3 | Modern Material Design |
| **Responsive Design** | Flutter ScreenUtil | Adaptive layouts |
| **Authentication** | Pinput | OTP input interface |
| **Maps & Location** | Google Maps Flutter | Location services & mapping |
| **AI Integration** | Google Generative AI | Gemini AI for chat assistance |
| **Audio** | AudioPlayers | Ringtone & sound effects |
| **Permissions** | Permission Handler | Device permissions management |
| **Contacts** | Flutter Contacts | Device contact integration |
| **Storage** | Flutter Secure Storage | Secure local data storage |
| **Animations** | Animate Do | UI animations & transitions |
| **Sharing** | Share Plus | Content sharing functionality |
| **Speech** | Speech to Text | Voice input for accessibility |
| **Testing** | Flutter Test + Mockito | Unit & widget testing |
| **Code Generation** | Build Runner | Automated code generation |

## 📱 How It Works - User Journey

### 🔐 **Step 1: Secure Onboarding**
1. **Phone Registration** - Enter your mobile number for account creation
2. **OTP Verification** - Receive and enter 6-digit verification code
3. **Profile Setup** - Add your name and basic information
4. **Emergency Contacts** - Add trusted family/friends who will receive SOS alerts

### 🏠 **Step 2: Home Navigation**
- **Quick SOS Button** - Large, prominent emergency button on home screen
- **Safety Tools Grid** - Access fake call, helplines, chat assistant, and tracking
- **Profile Access** - Manage contacts and settings from top navigation

### 🆘 **Step 3: Emergency Response**
- **SOS Activation** - Tap the red SOS button to start 5-second countdown
- **Location Sharing** - GPS coordinates automatically sent to all emergency contacts
- **Cancel Option** - 5-second window to cancel false alarms

### 📞 **Step 4: Additional Safety Tools**
- **Fake Call Setup** - Customize caller name, photo, and call duration
- **AI Chat Assistant** - Get real-time safety advice and emergency guidance
- **Helpline Directory** - One-tap access to police, medical, and women's helplines
- **Location Tracking** - Share live location with trusted contacts

## 🚀 Getting Started

### Prerequisites
- Flutter SDK (^3.8.1)
- Dart SDK
- Android Studio for Android / Xcode for  ios 
- Install Flutter:
Follow the official setup instructions here → https://docs.flutter.dev/install

### Installation

1. **Clone the repository**
```bash
git clone https://github.com/shshaheen/everest_hackathon.git
cd everest_hackathon
```

2. **Install dependencies**
```bash
flutter pub get
```

3. **Generate code files (Freezed/JSON serialization)**
```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

4. **Configure environment** (Optional)
   - Edit `lib/core/config/environment_config.dart`
   - Add Google Maps API key for location features
   - Configure emergency service numbers

5. **Run the application**
```bash
flutter run
```

## 📝 Demo Credentials

🔒 **For testing the authentication module:**

> **Note:** Only registered phone numbers will receive OTPs. For demo and testing purposes, please use one of the verified numbers below:

- **Phone Numbers:** 9182028713, 8179291362
(Only these numbers are registered to receive OTPs)

⚠️ **Security Notice:** If you try with an unregistered number, you will not receive an OTP and the request will fail - this is intentional for demo security.

## 🔧 Configuration

### Environment Setup
Edit `lib/core/config/environment_config.dart` to configure:
- **API Base URLs** - Backend service endpoints
- **Google Maps API Key** - For location services and 

### Dependency Injection
All services and dependencies are registered in `lib/core/dependency_injection/di_setup.dart` using the GetIt service locator pattern.





## 🎨 UI/UX Features

- **Responsive Design**: Uses Flutter ScreenUtil for adaptive layouts
- **Theme Support**: Light and dark themes
- **Material 3**: Modern Material Design components
- **Custom Color Scheme**: safety-focused color palette

## 🔐 Security Features

- OTP-based authentication
- Secure token storage

## 📦 Build & Release

### Android
```bash
flutter build apk --release
```

### iOS
```bash
flutter build ios --release
```


## 👥 Team

**Developed for Everest Hackathon by Team SHE**

🏆 A passionate team of developers committed to women's safety and empowerment through technology.

## 📞 Support & Contact

**For support, questions, or contributions:**

📧 **Email:** 
- rr200287@rguktrkv.ac.in
- rr200815@rguktrkv.ac.in  
- rr200094@rguktrkv.ac.in

🐛 **Issues:** Please raise an issue in the GitHub repository for bug reports or feature requests.

🤝 **Contributing:** We welcome contributions! Please see the Contributing section above for guidelines.



**🌸 SHE - Safety Help Emergency**  
*Empowering women, one tap at a time.*
