# 🪁 Kite Backend

[![Test Backend](https://github.com/gwynejsn/kite/actions/workflows/test.yml/badge.svg)](https://github.com/gwynejsn/kite/actions/workflows/test.yml)
![Coverage](../.github/badges/jacoco.svg)
![Branches](../.github/badges/branches.svg)

Spring Boot 3 backend application powering the Kite real-time E2EE messaging platform.

---

## Features

- **Authentication & Security**: JWT-based stateless authentication with password hashing and Spring Security filter chains.
- **Real-Time WebSockets**: STOMP protocol over WebSockets for instant message delivery and conversation status updates.
- **E2EE Support**: Handles asymmetric public key storage (X25519) and encrypted message payload routing (AES-256-GCM).
- **Group Management**: Admin management, member promotion/demotion, and key distribution.
- **Interactive OpenAPI Documentation**: Built-in Swagger UI with JWT Authorization support.

---

## Interactive API Documentation (Swagger UI)

When the Spring Boot application is running locally (`http://localhost:8080`), access the interactive Swagger documentation at:

- **Swagger UI Interface**: [http://localhost:8080/kite/api/v1/swagger-ui.html](http://localhost:8080/kite/api/v1/swagger-ui.html)
- **Raw OpenAPI JSON Spec**: [http://localhost:8080/kite/api/v1/v3/api-docs](http://localhost:8080/kite/api/v1/v3/api-docs)

### Testing Authenticated Endpoints in Swagger
1. Login via `POST /auth/login` to obtain your JWT `accessToken`.
2. Click the **"Authorize"** button at the top right of the Swagger UI page.
3. Enter your token into the `bearerAuth` field and click **Authorize**.
4. You can now execute protected endpoints directly from Swagger UI.

---

## Development Setup

```bash
# Build project and run tests
mvn test

# Run backend application
mvn spring-boot:run
```
