# OpenAPI 3.0 & STOMP Protocol Specification

The Kite backend utilizes **Springdoc OpenAPI 3.0** (`OpenApiConfig.java`) to automatically generate REST API specifications, interactive Swagger UI interfaces, and JSON schema contracts.

---

## OpenAPI & Swagger Links

When the backend application is running locally:
* **Interactive Swagger UI**: `http://localhost:8080/kite/api/v1/swagger-ui/index.html`
* **OpenAPI 3.0 JSON Specification**: `http://localhost:8080/kite/api/v1/v3/api-docs`

---

## REST Endpoints Overview

### 1. Authentication Services (`/auth`)

| Method | Endpoint | Description | Auth Required |
| :--- | :--- | :--- | :--- |
| `POST` | `/auth/sign-up` | Registers a new user account and uploads initial public key | No |
| `POST` | `/auth/login` | Authenticates credentials and issues JWT Access & Refresh Tokens | No |
| `POST` | `/auth/refresh` | Re-issues an Access Token using a valid Refresh Token | No |
| `POST` | `/auth/logout` | Revokes active user session | Yes |

---

### 2. Media Storage Services (`/media`)

| Method | Endpoint | Description | Auth Required |
| :--- | :--- | :--- | :--- |
| `POST` | `/media/upload` | Uploads multipart binary file stream (unencrypted avatar or encrypted media blob) | No |
| `GET` | `/media/download/{filename}` | Downloads binary file stream from MongoDB GridFS | No |
| `GET` | `/media/{conversationId}` | Lists all media download links for a conversation | Yes |

---

### 3. Conversation Services (`/conversation`)

| Method | Endpoint | Description | Auth Required |
| :--- | :--- | :--- | :--- |
| `GET` | `/conversation/all` | Fetches all active conversations for the authenticated user | Yes |
| `GET` | `/conversation/{conversationId}` | Fetches message history for a specific conversation | Yes |
| `POST` | `/conversation/message` | Sends an encrypted text or media message to a conversation | Yes |
| `POST` | `/conversation/group` | Creates a new group conversation with member/admin assignments | Yes |
| `PUT` | `/conversation/{id}/members` | Adds new members to an existing group conversation | Yes |
| `DELETE` | `/conversation/{id}/members/{targetId}` | Kicks a member from a group conversation | Yes |
| `POST` | `/conversation/{id}/leave` | Leaves a group conversation | Yes |

---

### 4. Social & Relation Services (`/social`)

| Method | Endpoint | Description | Auth Required |
| :--- | :--- | :--- | :--- |
| `GET` | `/social/people` | Discovers system users with relation status relative to current user | Yes |
| `POST` | `/social/request/{targetUserId}` | Sends a pending friend request | Yes |
| `PUT` | `/social/accept/{relationId}` | Accepts friend request, initializes direct chat, & broadcasts STOMP update | Yes |
| `PUT` | `/social/decline/{relationId}` | Declines a pending friend request | Yes |
| `POST` | `/social/block/{targetUserId}` | Blocks a target user | Yes |
| `GET` | `/social/friends` | Lists all accepted friends | Yes |
| `GET` | `/social/pending` | Lists all incoming pending friend requests | Yes |

---

## Real-Time WebSocket STOMP Protocol Specification

Because WebSockets operate on pub/sub channels rather than traditional HTTP REST endpoints, STOMP topic destinations are specified below:

* **WebSocket Connection Endpoint**: `ws://localhost:8080/kite/api/v1/ws-connect`

| STOMP Topic Destination | Payload Type | Description |
| :--- | :--- | :--- |
| `/topic/conversation.{conversationId}` | `MessageResponse` | Live message stream within an active chat room |
| `/topic/user.{userId}.conversations` | `ConversationResponse` | Live inbox re-ordering and new chat creation |
| `/topic/presence` | `UserPresence` | Online and offline presence notifications |
