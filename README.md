# 🪁 Kite — Real-Time E2EE Messaging Platform

> A modern, end-to-end encrypted (E2EE) instant messaging application built with **Flutter** and **Spring Boot 3**.

## Not yet complete!

---

## Features

* **End-to-End Encryption (E2EE)**: Messages are encrypted locally on-device using **X25519** key exchange and **AES-256 GCM** cipher.
* **Real-Time Messaging**: High-performance STOMP WebSockets for instant message delivery and live checkmark delivery status.
* **Live User Presence**: Real-time online/offline presence tracking and active friend status row.
* **Dual Theme Engine**: 1-tap switching between **LINE Sally Midnight Dark Mode** and **Soft Neutral Light Mode**.
* **Ambient Mesh & Glassmorphism UI**: Modern aesthetic with soft ambient radial mesh gradients, glassmorphic cards, and custom floating kite animations (`KiteLoader`).
* **Cinematic Video Onboarding**: Ambient video background onboarding experience.
* **People & Social Hub**: Discover users, send/accept friend requests, view interactive profile sheets, and manage contacts.

---

## Technology Stack

### **Frontend (`kite-flutter/kite`)**
* **Framework**: [Flutter](https://flutter.dev/) (Dart 3.x)
* **State Management**: Provider & `ValueListenable` Controllers
* **Security & Crypto**: `cryptography` (X25519 & AES-256-GCM), `flutter_secure_storage`
* **Real-time Networking**: `stomp_dart_client`, `web_socket_channel`, `dio`
* **Media & Assets**: `video_player`

### **Backend (`kite-backend`)**
* **Framework**: [Spring Boot 3](https://spring.io/projects/spring-boot) (Java)
* **Real-Time Protocol**: STOMP over WebSockets & Spring Messaging
* **Persistence & ORM**: Spring Data JPA, PostgreSQL / H2
* **Security**: Spring Security, JWT Authentication
* **Testing**: JUnit 5, ArchUnit

---

## Getting Started

### Prerequisites
* **Flutter SDK**: `^3.12.2` or later
* **Java SDK**: Java 21 / 26
* **Maven**: 3.9+

---

### 1. Running the Backend (`kite-backend`)

```bash
cd kite-backend

# Build and run tests
mvn test

# Start Spring Boot backend server
mvn spring-boot:run
```

---

### 2. Running the Mobile App (`kite-flutter/kite`)

```bash
cd kite-flutter/kite

# Install Flutter dependencies
flutter pub get

# Verify static analysis
flutter analyze

# Run on connected device or simulator
flutter run
```

