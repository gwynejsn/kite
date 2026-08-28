# Kite

[![Test Backend](https://github.com/gwynejsn/kite/actions/workflows/test.yml/badge.svg)](https://github.com/gwynejsn/kite/actions/workflows/test.yml)
![Coverage](https://raw.githubusercontent.com/gwynejsn/kite/badges/jacoco.svg)
![Branches](https://raw.githubusercontent.com/gwynejsn/kite/badges/branches.svg)

An End-to-End Encrypted (E2EE) real-time messaging application demonstrating a Spring Modulith backend with Package-by-Feature architecture, RabbitMQ event externalization, and a Flutter cross-platform mobile client.

> **Note**
>
> I built Kite to serve as a practical reference for a **Spring Modulith** application following enterprise-grade **Package-by-Feature** and **Clean Architecture**. This project incorporates client-side End-to-End Encryption (E2EE), where mobile devices handle all encryption and decryption operations. It also serves as an example of combining WebSockets (STOMP) and RabbitMQ for real-time messaging while utilizing the built-in application events and AMQP event externalization of Spring Modulith.
>
> Full documentation, sequence diagrams, and API specifications are available on the **[Kite Documentation Site](https://gwynejsn.github.io/kite/)** (built with MkDocs).

---

## Table of Contents

- [Features](#features)
- [Architecture & Tech Stack](#architecture--tech-stack)
- [Project Structure](#project-structure)
- [Getting Started](#getting-started)
  - [Prerequisites](#prerequisites)
  - [Running with Docker Compose](#running-with-docker-compose)
  - [Running Locally](#running-locally)
    - [Backend](#backend)
    - [Frontend](#frontend)
    - [Documentation Site](#documentation-site)
- [Security & End-to-End Encryption](#security--end-to-end-encryption)
- [API & Documentation](#api--documentation)
- [Contributing](#contributing)

---

## Features

- **Package-by-Feature Spring Modulith**: Modular backend architecture organized strictly by domain modules (`conversation`, `social`, `media`, `profile`, `notification`, `presence`, `security`, `shared`).
- **RabbitMQ & AMQP Event Externalization**: Asynchronous event publishing and externalization using RabbitMQ broker alongside Spring Modulith AMQP events (`spring-modulith-events-amqp`).
- **Client-Side End-to-End Encryption**: Zero-knowledge encryption. Text messages and binary media streams are encrypted locally before transmission.
- **Diffie-Hellman X25519 & AES-256 GCM**: Asymmetric key exchange using X25519 for envelope keys and single-use AES-256 GCM for binary payload streams.
- **Group Chat Key Architecture**: Efficient group message encryption using a shared Group Chat Key with history access on member additions and key rotation on member removal.
- **Multi-Format Encrypted Attachments**: Support for encrypted photos, videos, document files, and live audio voice note recordings.
- **Real-Time WebSockets**: Instant message streaming, room delivery events, and real-time inbox reordering over STOMP WebSockets.
- **Spring Modulith Event Listener Integration**: Decoupled domain interactions (such as friend request acceptance triggering direct chat initialization and STOMP notifications via `@ApplicationModuleListener`).
- **User Discovery & Social Management**: Add friends, manage pending requests, block users, and track live online/offline presence.
- **Database Migrations & Management**: Mongo replica sets with Flamingock schema migrations and Mongo Express administration dashboard.

---

## Architecture & Tech Stack

Kite follows a decoupled architecture separating client-side security and UI rendering from backend domain services:

```
  Flutter Mobile App (iOS & Android)
           ↓ HTTPS / REST & WebSockets (STOMP)
  Spring Security (JWT Authentication & CORS)
           ↓
  Spring Modulith Application Services (Package-by-Feature)
           ↓                                      ↓
  RabbitMQ Message Broker (AMQP)        MongoDB & GridFS Media Store
```

### Backend

| Component | Technology | Description |
| :--- | :--- | :--- |
| Java Version | Java 21 | High-throughput modern Java runtime |
| Framework | Spring Boot 3.x | Core application framework |
| Architecture | Spring Modulith 2.x | Modular monolith structure with domain verification |
| Event Relayer | RabbitMQ 4.x | Message broker for AMQP event externalization (`spring-modulith-events-amqp`) |
| Web & Security | Spring MVC + Spring Security 6.x | Stateless JWT authentication, CORS, and role-based access |
| Real-Time Protocol | Spring WebSocket STOMP Broker | Pub/Sub channels for chat room streaming and inbox updates |
| Database | MongoDB (Replica Set `rs0`) | Primary document persistence for accounts, chats, and metadata |
| Object Store | MongoDB GridFS | Binary chunked storage for media uploads and avatars |
| DB Dashboard | Mongo Express | Administrative UI dashboard for MongoDB (`http://localhost:8081`) |
| Schema Migration | Flamingock 1.4.x | Code-based MongoDB database migrations |
| Object Mapping | MapStruct 1.6.3 | Type-safe DTO and entity transformations |
| OpenAPI / Swagger | Springdoc OpenAPI 3.0 | Automated REST documentation and interactive Swagger UI |
| Validation | Jakarta Validation | Declarative request payload validation |
| Build Tool | Maven 3.9 (`mvnw`) | Dependency management and compilation |
| Containerization | Docker & Docker Compose | Containerized database and broker infrastructure |

### Frontend

| Component | Technology | Description |
| :--- | :--- | :--- |
| Framework | Flutter 3.x (Dart 3) | Cross-platform mobile client application |
| State Management | Provider & `ValueNotifier` Controllers | Unidirectional reactive state management |
| Key Storage | Flutter Secure Storage | Hardware-backed key storage (iOS Keychain & Android KeyStore) |
| Cryptography | `cryptography` package | Client-side X25519 ECDH key exchange & AES-256 GCM ciphers |
| HTTP Client | Dio 5.x | REST API integration and multipart byte stream uploads |
| Realtime WebSocket | StompDartClient & `web_socket_channel` | Persistent WebSocket connection for STOMP topic streaming |
| Audio & Media | `record`, `audioplayers`, `file_picker`, `image_picker`, `video_player` | Live voice note recording, playback, and attachment pickers |

---

## Project Structure

```
Kite
├── docker-compose.yaml             # Infrastructure (MongoDB replica set, Mongo Express, RabbitMQ)
├── mkdocs.yml                      # MkDocs Material documentation configuration
├── docs/                           # Comprehensive documentation pages
│   ├── index.md                    # System overview and architecture principles
│   ├── architecture.md             # System architecture & Mermaid sequence diagrams
│   ├── security.md                 # 2-Layer E2EE & Group Key rotation specs
│   ├── api.md                      # OpenAPI 3.0 & STOMP topic references
│   └── setup.md                    # Environment deployment guide
├── kite-backend
│   ├── pom.xml
│   ├── rabbitmq/                   # RabbitMQ plugin configurations
│   └── src
│       └── main
│           └── java
│               └── com
│                   └── gwynejsn
│                       └── kite
│                           ├── conversation   # Direct & Group Chat Domain
│                           ├── media          # GridFS Binary Storage
│                           ├── notification   # Application Event Listeners
│                           ├── presence       # User Online/Offline State
│                           ├── profile        # User Profiles & Public Keys
│                           ├── security       # Spring Security & JWT Filters
│                           ├── shared         # Base Domain Primitives (UserId, etc.)
│                           └── social         # Friend Relations & Discovery
└── kite-flutter
    └── kite
        ├── lib
        │   ├── features
        │   │   ├── auth           # Onboarding, Login & Registration
        │   │   ├── conversation   # Chat Room, Message Bubbles & Input Controls
        │   │   ├── media          # Encrypted Image, Video, Audio & File Views
        │   │   ├── profile        # Profile Viewing & Photo Editing
        │   │   └── social         # People Discovery & Pending Requests
        │   └── shared             # Cryptography Engine & WebSocket Service
        └── pubspec.yaml
```

---

## Getting Started

### Prerequisites

- **Docker & Docker Compose** (for running MongoDB replica set, Mongo Express, and RabbitMQ)
- **Java JDK 21+**
- **Flutter SDK 3.x+**
- **Maven 3.9+** (or included `./mvnw` wrapper)

---

### Running with Docker Compose

Start all infrastructure containers (MongoDB with replica set, Mongo Express, RabbitMQ):

```bash
docker-compose up -d
```

Service Dashboard URLs:
- **Mongo Express**: `http://localhost:8081`
- **RabbitMQ Management Console**: `http://localhost:15672` (User: `user`, Pass: `password`)

### Running Locally

#### 1. Backend

```bash
cd kite-backend
./mvnw clean compile
./mvnw spring-boot:run
```

Backend base URL: `http://localhost:8080/kite/api/v1`

#### 2. Frontend

```bash
cd kite-flutter/kite
flutter pub get
flutter run
```

#### 3. Documentation Site

To preview the documentation site locally:

```bash
mkdocs serve
```
Documentation URL: `http://127.0.0.1:8000`

---

## Security & End-to-End Encryption

Kite operates on a zero-knowledge trust model:

1. **Client Key Generation**: On registration, the client generates an **X25519** keypair. The private key is stored locally in hardware security (`Flutter Secure Storage`); the public key is registered on the server.
2. **Direct Messages**: Payload text is encrypted using **AES-256 GCM**. The AES key is wrapped inside an X25519 envelope derived using User A's private key and User B's public key.
3. **Group Messages**: The group creator issues a **Group Chat (GC) Key** encrypted for each member via X25519. Messages are encrypted once using AES-256 GCM with the GC Key. Adding members grants historical access by sharing the encrypted GC Key; kicking members triggers automatic **GC Key Rotation**.
4. **Media Attachments**: Raw binary files are encrypted locally with AES-256 GCM before uploading to `/media/upload`. The download link is placed in the message payload while secret keys, nonces, and authentication tags remain sealed inside the envelope.

---

## API & Documentation

For complete interactive API specifications, architecture flowcharts, and security proofs:

- **Local OpenAPI / Swagger UI**: `http://localhost:8080/kite/api/v1/swagger-ui/index.html`
- **OpenAPI JSON Spec**: `http://localhost:8080/kite/api/v1/v3/api-docs`
- **Documentation Site**: [docs/index.md](docs/index.md) (or `mkdocs serve`)

---

## Contributing

Contributions are welcome! Whether you are fixing a bug, adding a new feature, or improving documentation, here is how you can contribute:

1. **Fork the Repository**: Create your own copy of the repository on GitHub.
2. **Clone your Fork**:
   ```bash
   git clone https://github.com/your-username/kite.git
   cd kite
   ```
3. **Create a Feature Branch**:
   ```bash
   git checkout -b feature/your-feature-name
   ```
4. **Make Your Changes & Run Verification**:
   - Backend changes (`kite-backend`): verify compilation with `./mvnw clean compile` and run tests with `./mvnw test`.
   - Frontend changes (`kite-flutter/kite`): verify static analysis with `flutter analyze` and run unit tests with `flutter test`.
   - Documentation updates (`docs/`): verify local build with `mkdocs build`.
5. **Commit Your Changes**:
   ```bash
   git commit -m "feat: add brief description of your change"
   ```
6. **Push to Your Fork & Submit a Pull Request**:
   ```bash
   git push origin feature/your-feature-name
   ```
   Open a Pull Request against the `main` branch with a clear description of your changes and motivation.
