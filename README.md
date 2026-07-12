# Sanad (سند) 🤝

[![Flutter](https://img.shields.io/badge/Flutter-v3.22+-02569B?logo=flutter&logoColor=white)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-v3.0+-0175C2?logo=dart&logoColor=white)](https://dart.dev)
[![Firebase](https://img.shields.io/badge/Firebase-Auth%20%7C%20Firestore%20%7C%20FCM-FFCA28?logo=firebase&logoColor=black)](https://firebase.google.com)
[![Architecture](https://img.shields.io/badge/Architecture-Clean%20Architecture-green)](#architecture)
[![State Management](https://img.shields.io/badge/State%20Management-Bloc%20%2F%20Cubit-blue)](https://pub.dev/packages/flutter_bloc)

**Sanad (سند)** is a comprehensive service booking platform designed to seamlessly connect clients in need of non-medical daily assistance (such as the elderly, visually impaired, or mobility-impaired individuals) with verified, trusted helpers. 

Developed as a final-year IT graduation project, Sanad provides a safe, reliable, and intuitive mobile solution to support and elevate independent living.

---

## 🌟 Key Features

- 👥 **Role-Based Access Control**: Tailored portals and user experiences for both **Clients** (seeking assistance) and **Helpers** (offering daily support services).
- 💬 **Session-Based Isolated Chat**: High-performance, real-time messaging locked strictly to active booking sessions to enforce safety and prevent transaction offboarding.
- ⏱ **Automated Task Progress Tracking**: Live lifecycle monitoring of bookings—from pending requests, price negotiation, and secure escrow hold, to final service completion validation.
- 🔔 **Firebase Push Notifications**: Real-time updates for new booking requests, counter-offers, and message receipts powered by Firebase Cloud Messaging (FCM).
- 👤 **Robust Profile Management**: Uploading profile pictures, updating personal information, and presenting official documents (e.g., National ID) for helper background verification.

---

## 🛠 Tech Stack

- **Frontend**: [Flutter](https://flutter.dev) (Dart)
- **Backend & Database**: [Firebase](https://firebase.google.com)
  - **Firebase Authentication**: Secure client and helper credentials management.
  - **Cloud Firestore**: Real-time, scalable NoSQL document database.
  - **Firebase Cloud Messaging (FCM)**: Push notification triggers for mobile devices.
- **State Management**: [Bloc / Cubit](https://pub.dev/packages/flutter_bloc) for predictable, reactive UI state flows.
- **Routing & Navigation**: [GoRouter](https://pub.dev/packages/go_router) for declarative routing.
- **Architecture**: **Clean Architecture** patterns separated into:
  - `Data`: Repository implementations, Models, and Remote Data Sources.
  - `Domain`: Business rules, Entities, and Use Case logic.
  - `Presentation`: UI Widgets, Screens, and Cubits.

---

## 📐 Architecture Overview

The codebase is organized following strict Clean Architecture principles to ensure high maintainability, testability, and scalability:

```text
lib/
├── core/                  # Shared utilities, widgets, constants, and routing
│   ├── constants/         # AppStrings, AppColors, AppTextStyles
│   ├── errors/            # Failures and Exception definitions
│   └── widgets/           # Global reusable UI components
└── features/              # Feature-centric modules
    ├── auth/              # Registration, Login, Forget Password, Role selection
    ├── booking/           # Booking creation, Escrow Payment, Rating, and Reviewing
    ├── chat/              # Private session messaging and notifications
    ├── emergency/         # SOS Contacts registry and alerts
    ├── notifications/     # User notifications list and unread badge flows
    └── main_layout/       # App shell navigation controllers
```

---

## 👨‍💻 Developed By

**Abdelrhman Kamal**  
**Mohamed Abdelemam**  
**Ali Abdelkader**  
**Sefen Mahrous**  
*Mobile Application Developer*  

Feel free to explore the repository, run the application, or reach out for inquiries regarding the architecture or implementation details.
