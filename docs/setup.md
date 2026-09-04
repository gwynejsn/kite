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

## 2. Environment Variables & Secret Configuration

The backend application requires two key secrets to function securely in development and production environments:

| Environment Variable | Config Property | Description | Default Fallback |
| :--- | :--- | :--- | :--- |
| `SECRET_KEY` | `jwt.secret.key` | Base64/Secret key string for signing HMAC-SHA256 JWT tokens | `default_secret_key_...` (Testing only) |
| `GEMINI_KEY` | `langchain4j.google-ai-gemini.chat-model.api-key` | Google AI Gemini API key for LangChain4j AI assistant integration | `demo_key` |

---

### Option A: IntelliJ IDEA Run Configuration (Recommended for IDE Development)

1. Open **IntelliJ IDEA**.
2. Open `KiteBackendApplication.java` (`src/main/java/com/gwynejsn/kite/KiteBackendApplication.java`).
3. Click **Run** -> **Edit Configurations...** in the top menu bar (or press `Cmd + Shift + A` / `Ctrl + Shift + A` and type `Edit Configurations`).
4. Select **Spring Boot** -> **KiteBackendApplication** under the Run/Debug Configurations list.
5. In the **Environment variables** field, enter your key-value pairs separated by semicolons (`;`):
   ```text
   SECRET_KEY=your_custom_jwt_secret_key_here;GEMINI_KEY=your_actual_gemini_api_key_here
   ```
   *(Alternatively, click the document icon on the right side of the Environment Variables field to open the interactive key-value editor table).*
6. Click **Apply** and **OK**.
7. Click **Run** or **Debug** to launch the backend with your secrets populated.

---

### Option B: Terminal Export (macOS & Linux)

Export the environment variables in your terminal session before launching Maven:

```bash
export SECRET_KEY="your_custom_jwt_secret_key_here"
export GEMINI_KEY="your_actual_gemini_api_key_here"

cd kite-backend
./mvnw spring-boot:run
```

---

### Option C: Windows Command Prompt & PowerShell

* **Command Prompt (CMD)**:
  ```cmd
  set SECRET_KEY=your_custom_jwt_secret_key_here
  set GEMINI_KEY=your_actual_gemini_api_key_here
  
  cd kite-backend
  mvnw spring-boot:run
  ```

* **PowerShell**:
  ```powershell
  $env:SECRET_KEY="your_custom_jwt_secret_key_here"
  $env:GEMINI_KEY="your_actual_gemini_api_key_here"
  
  cd kite-backend
  .\mvnw spring-boot:run
  ```

---

### Option D: IntelliJ EnvFile Plugin (`.env` File)

1. Install the **EnvFile** plugin in IntelliJ (`Preferences` / `Settings` -> `Plugins` -> Search `EnvFile`).
2. Create a `.env` file in the root of `kite-backend`:
   ```env
   SECRET_KEY=your_custom_jwt_secret_key_here
   GEMINI_KEY=your_actual_gemini_api_key_here
   ```
3. Open **Run/Debug Configurations**, select **KiteBackendApplication**, click the **EnvFile** tab, check **Enable EnvFile**, and click `+` to select your `.env` file.

---

### Option E: Spring Boot Command-Line System Arguments

You can also pass environment property overrides directly as command-line arguments to Maven:

```bash
cd kite-backend
./mvnw spring-boot:run -Dspring-boot.run.arguments="--jwt.secret.key=your_secret_key --langchain4j.google-ai-gemini.chat-model.api-key=your_gemini_key"
```

---

## 3. Backend Building & Deployment (`kite-backend`)

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

## 4. Mobile Frontend Setup (`kite-flutter/kite`)

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

## 5. Documentation Site Building (`MkDocs`)

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
