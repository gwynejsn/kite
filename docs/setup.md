# Deployment & Local Environment Setup Guide

This guide provides instructions for setting up, building, testing, and deploying the Kite messaging system across local development environments and production servers.

---

## System Requirements & Prerequisites

* **Operating System**: macOS, Linux, or Windows (WSL2 recommended)
* **Java Development Kit**: JDK 21 or later
* **Flutter SDK**: Version 3.x or later
* **Container Runtime**: Docker 24.x and Docker Compose 2.x
* **Build Tools**: Apache Maven 3.9+ (or included `mvnw` wrapper)
* **Python Runtime**: Python 3.10+ (for MkDocs site generation)

---

## 1. Infrastructure Provisioning

Provision local infrastructure services (MongoDB database and GridFS storage) using Docker Compose:

```bash
# Start MongoDB container in background
docker-compose up -d

# Verify container health
docker-compose ps
```

---

## 2. Backend Building & Deployment (`kite-backend`)

### Compilation & Static Analysis
```bash
cd kite-backend

# Clean and compile Java 21 sources
./mvnw clean compile

# Execute backend unit and integration tests
./mvnw test
```

### Execution
```bash
# Launch Spring Boot application
./mvnw spring-boot:run
```
The server will initialize on `http://localhost:8080/kite/api/v1`.

---

## 3. Mobile Frontend Setup (`kite-flutter/kite`)

### Dependency Installation & Verification
```bash
cd kite-flutter/kite

# Fetch Flutter dependencies
flutter pub get

# Execute Dart static analysis
flutter analyze

# Execute Flutter unit and widget tests
flutter test
```

### Application Execution
```bash
# Target iOS Simulator
flutter run -d iphone

# Target Android Emulator
flutter run -d android
```

---

## 4. Documentation Site Building (`MkDocs`)

### Local Documentation Server
To preview the production documentation website locally:

```bash
# Install MkDocs Material theme engine
pip install mkdocs-material

# Build static site assets
mkdocs build

# Start live documentation server with hot reloading
mkdocs serve
```
Access the local documentation suite at `http://127.0.0.1:8000`.
