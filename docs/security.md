# End-to-End Encryption (E2EE) & Security Specification

Kite operates on a strict **zero-knowledge trust model**. The application architecture ensures that the central backend server acts strictly as an untrusted message broker and media host. All encryption and decryption operations take place client-side on user devices. The server never possesses private keys or unencrypted message payloads.

---

## 1. User Onboarding & Key Generation

Whenever a user signs up for an account (`POST /auth/sign-up`):

1. **Keypair Generation**: The client application locally generates an asymmetric key pair using **X25519 Elliptic-Curve Diffie-Hellman (ECDH)**.
2. **Local Private Key Storage**: The private key is saved locally on the user's mobile device inside hardware-backed secure storage (`Flutter Secure Storage` using iOS Keychain and Android KeyStore). The private key **never leaves the client device**.
3. **Public Key Directory**: The public key is uploaded to the backend server during registration and stored in the user profile directory. Other users retrieve this public key to establish encrypted communication channels.

---

## 2. Direct 1-on-1 Chat Encryption & Decryption

When **User A** wants to send a direct message to **User B**:

```mermaid
sequenceDiagram
    autonumber
    actor Alice as User A (Sender)
    participant Server as Backend Server (Untrusted Relay)
    actor Bob as User B (Recipient)

    Note over Alice,Bob: 1-on-1 Direct Message Flow
    Alice->>Alice: 1. Encrypt message payload with AES-256 GCM using Secret Key
    Alice->>Alice: 2. Encrypt Secret Key via X25519 (User A Private Key + User B Public Key)
    Alice->>Server: 3. Send Encrypted Envelope & Payload (POST /conversation/message)
    Server->>Bob: 4. Push Encrypted Message via STOMP WebSocket
    Bob->>Bob: 5. Decrypt Secret Key via X25519 (User B Private Key + User A Public Key)
    Bob->>Bob: 6. Decrypt Message Payload using Secret Key (AES-256 GCM)
```

### Encryption Steps (User A)
1. **Symmetric Payload Cipher**: User A encrypts the plaintext message using **AES-256 GCM** with a randomly generated secret key.
2. **Asymmetric Key Envelope**: User A derives a shared secret using **User A's private key** and **User B's public key** via X25519 ECDH. User A encrypts the secret key using this shared secret.
3. **Transmission**: User A sends the encrypted secret key envelope, AES-GCM ciphertext, nonce, and authentication tag to the server.

### Decryption Steps (User B)
1. **Key Envelope Decryption**: User B uses **User B's private key** and **User A's public key** via X25519 to derive the exact same shared secret. User B decrypts the envelope to retrieve the secret key.
2. **Payload Decryption**: User B uses the secret key to decrypt the AES-256 GCM ciphertext back into original plaintext.

---

## 3. Group Chat Encryption Architecture

### Initial Naive Approach & Limitations
In the initial design consideration, whenever User A sent a group message, User A would encrypt the message $N$ separate times for each of the $N$ members of the group chat.

This approach had severe engineering limitations:
1. **Computational & Bandwidth Overhead $O(N)$**: Encrypting and transmitting payloads $N$ times scales poorly as group membership grows.
2. **Historical Access Limitation for New Members**: When a new user is added to an existing group chat, that new user cannot decrypt past messages because previous messages were encrypted strictly for members who belonged to the group at the time of sending.

### Implemented Group Key Distribution Architecture

To solve these limitations cleanly, Kite uses a **Group Chat (GC) Key Architecture** divided into three distinct operations:

#### Phase A: Group Creation & Initial Key Distribution
```mermaid
sequenceDiagram
    autonumber
    actor Admin as Group Admin
    participant Server as Backend Server

    Admin->>Admin: 1. Generate random Group Chat Key (GC Key)
    Admin->>Admin: 2. Encrypt GC Key for each member (X25519)
    Admin->>Server: 3. Store groupKeyMap (POST /conversation/group)
```

#### Phase B: Group Message Transmission & Decryption
```mermaid
sequenceDiagram
    autonumber
    actor Alice as Sender (User A)
    participant Server as Backend Server
    actor Bob as Recipient (User B)

    Alice->>Alice: 1. Decrypt GC Key using Private Key (X25519)
    Alice->>Alice: 2. Encrypt Message ONCE with AES-256 GCM using GC Key
    Alice->>Server: 3. Send Encrypted Message Payload
    Server->>Bob: 4. Push Message via WebSocket (STOMP)
    Bob->>Bob: 5. Decrypt GC Key & Decrypt Message (AES-256 GCM)
```

#### Phase C: Kicking Members & Key Rotation
```mermaid
sequenceDiagram
    autonumber
    actor Admin as Group Admin
    participant Server as Backend Server

    Admin->>Admin: 1. Kick Member from Group
    Admin->>Admin: 2. Generate NEW GC Key (Key Rotation)
    Admin->>Admin: 3. Encrypt NEW GC Key for remaining members (X25519)
    Admin->>Server: 4. Update groupKeyMap (Revokes kicked member access)
```

1. **Group Key Generation**: When a group chat is created, the creator generates a single random **Group Chat (GC) Key**.
2. **Key Map Distribution**: The creator encrypts the GC Key for each group member using X25519 (Creator's private key + Member's public key). This mapping (`groupKeyMap`) is stored in the conversation document on the server.
3. **Efficient Group Messaging O(1)**: When any member (e.g., User C) sends a message to the group, User C decrypts the GC Key using their own private key, and encrypts the message **once** using AES-256 GCM with that GC Key.
4. **Adding Members & History Access**: When an admin adds a new member to the group chat, the admin encrypts the existing GC Key using the new member's public key. This allows the newly joined member to decrypt historical group messages.
5. **Kicking Members & Key Rotation**: When an admin kicks a member from the group chat, a **GC Key Rotation** is performed: a new GC Key is generated and encrypted for all remaining members. This revokes the kicked member's ability to decrypt future messages.

---

## 4. Media Upload Encryption (Images, Videos, Files, Audio Notes)

Media attachments follow the exact same 2-layer encryption model:

### Upload & Transmission Flow
1. **Client-Side Binary Encryption**: The client encrypts the raw uncompressed media bytes (photo, video, document, or audio recording) locally using **AES-256 GCM** with a single-use symmetric key.
2. **Multipart Upload**: The client uploads the opaque binary ciphertext stream to `POST /media/upload` via a multipart `FormData` request.
3. **Ciphertext URL**: The server stores the binary ciphertext in MongoDB GridFS and returns a public download link (`http://localhost:8080/kite/api/v1/media/download/{filename}`).
4. **Encrypted Message Payload**: The client places the download link inside the message payload. Crucial decryption attributes—including the single-use AES key, `nonce`, and authentication tag (`mac`)—are encrypted inside the X25519 signaling envelope.

Even if an unauthorized third party obtains the media download link, they receive only raw opaque ciphertext bytes that cannot be decrypted without the secret key sealed inside the envelope.

---

## 5. Client Key Management & Hardware Security

* **Private Key Isolation**: User private keys never leave the client device and are never transmitted over the network.
* **Hardware-Backed Storage**: Keys are stored using `Flutter Secure Storage`:
  * **iOS**: Encrypted inside the iOS Keychain with `kSecAttrAccessibleAfterFirstUnlock`.
  * **Android**: Encrypted using the hardware-backed Android KeyStore system.

---

---

## 6. Backend Authentication & Security Architecture

> **Overview**: Kite uses a **stateless JWT architecture** combined with **MongoDB-backed refresh token rotation** and **STOMP WebSocket channel security**. The server never keeps HTTP sessions (`JSESSIONID`). Instead, every request is self-authenticated via cryptographically signed tokens.

---

### Act I: The Security Team (Component Roles)

Think of the security system as a coordinated team where each class plays a specific role:

```
[ Incoming Request ] ──► [ SecurityConfig ] ──► [ JwtFilter ] ──► [ SecurityContextHolder ]
                                                     │                     (CustomUserDetails)
                                            (Validates Signature)
```

* **`SecurityConfig` (The Rule Book)**: Defines which doors are open to everyone (`/auth/login`, `/auth/sign-up`, `/ws-connect`) and which require a badge. It forces the server to run statelessly (`SessionCreationPolicy.STATELESS`).
* **`JwtFilter` (The Checkpoint Guard)**: Stands at the entrance of every HTTP request. It inspects the `Authorization: Bearer <token>` header, verifies its digital signature, and attaches the user's identity badge to the current request.
* **`CustomUserDetails` (The User Identity Badge)**: A lightweight Java record wrapping user identity (`userId`, `email`, `roles`). It is injected directly into controllers via `@AuthenticationPrincipal CustomUserDetails`.
* **`JwtService` (The Pass Issuer)**: Mints and verifies HMAC-SHA256 digital JWT access tokens containing `email`, `userId`, and `roles`.
* **`RefreshTokenService` (The Session Manager)**: Handles long-lived refresh tokens stored in MongoDB, ensuring tokens can be revoked or rotated when expired.
* **`WebSocketAuthInterceptor` (The Live Chat Gatekeeper)**: Authenticates real-time STOMP WebSocket connections before users can subscribe to or send live messages.
* **`AsyncConfig` (The Task Dispatcher)**: Manages a dedicated background thread pool (`taskExecutor`) so event tasks (like updating online presence) run smoothly without blocking user requests.

---

### Act II: How a User Logins (`POST /auth/login`)

When a user opens the app and logs in with their email and password, the request travels through a two-step verification and token issuance process:

#### Step 1: Credential Verification
```mermaid
sequenceDiagram
    autonumber
    actor Client
    participant AuthManager as ProviderManager
    participant DaoProvider as DaoAuthenticationProvider
    participant UserDetails as UserDetailsServiceImp
    participant Encoder as BCryptPasswordEncoder

    Client->>AuthManager: 1. Submit email & password
    AuthManager->>DaoProvider: 2. Delegate to DaoAuthenticationProvider
    DaoProvider->>UserDetails: 3. Fetch user by email from MongoDB
    UserDetails-->>DaoProvider: 4. Return CustomUserDetails(user)
    DaoProvider->>Encoder: 5. Compare raw password with BCrypt hash
    Encoder-->>DaoProvider: 6. Password match confirmed!
    DaoProvider-->>AuthManager: 7. Return Authenticated Token (CustomUserDetails)
```

1. **Submitting Credentials**: The client sends `POST /auth/login` with `{ "email": "alice@example.com", "password": "secretpassword" }`.
2. **Provider Delegation**: `AuthService` passes an unauthenticated token to `AuthenticationManager` (`ProviderManager`), which hands it over to `DaoAuthenticationProvider`.
3. **Fetching User Record**: `DaoAuthenticationProvider` calls `UserDetailsServiceImp`, which queries MongoDB (`userRepo.findUserByEmail`) and wraps the account in `CustomUserDetails`.
4. **Password Hashing Check**: `DaoAuthenticationProvider` calls `BCryptPasswordEncoder.matches()`. If the password matches the stored BCrypt hash, authentication succeeds!

#### Step 2: Token Generation & Online Status
```mermaid
sequenceDiagram
    autonumber
    participant Service as AuthService
    participant Jwt as JwtService
    participant RefreshToken as RefreshTokenService
    actor Client

    Service->>Jwt: 1. Generate JWT Access Token (email, userId, roles)
    Jwt-->>Service: 2. Signed JWT Token String
    Service->>RefreshToken: 3. Generate & Save Refresh Token in MongoDB
    RefreshToken-->>Service: 4. Raw Refresh Token String
    Service-->>Client: 5. Return 200 OK (Access Token + Refresh Token)
```

5. **Minting Tokens**: `AuthService` calls `JwtService` to build a signed access token containing `email`, `userId`, and `roles`. It also calls `RefreshTokenService` to save a new refresh token in MongoDB.
6. **Going Online**: A `UserLoginEvent` is published asynchronously, triggering `UserPresenceEventListener` on a background thread (`kite-async-*`) to update the user's presence status to `ONLINE`.
7. **Response**: The client receives a `200 OK` response containing both tokens.

---

### Act III: Accessing API Endpoints (`JwtFilter`)

Once logged in, the client attaches the JWT access token to every HTTP request header: `Authorization: Bearer <jwt-token>`.

```mermaid
sequenceDiagram
    autonumber
    actor Client
    participant Filter as JwtFilter
    participant Jwt as JwtService
    participant SecurityContext as SecurityContextHolder
    participant Controller as ConversationController

    Client->>Filter: 1. Request GET /conversation/all (Header: Bearer <token>)
    Filter->>Jwt: 2. Validate token signature & expiration
    Jwt-->>Filter: 3. Valid Claims (email, userId, roles)
    Filter->>Filter: 4. Construct CustomUserDetails(user) statelessly
    Filter->>SecurityContext: 5. Store authentication principal in ThreadLocal
    Filter->>Controller: 6. Proceed to endpoint
    Controller-->>Client: 7. 200 OK (Injects @AuthenticationPrincipal CustomUserDetails)
```

1. **Intercepting the Request**: `JwtFilter` inspects the `Authorization` header. If missing, public routes continue through the filter chain, while protected routes are stopped.
2. **Stateless Signature Check**: `JwtService` verifies the HMAC-SHA256 signature using the server secret key **without querying MongoDB**.
3. **Reconstructing the Badge**: Extracts `email`, `userId`, and `roles` from token claims and builds a transient `CustomUserDetails` principal.
4. **Binding Identity**: Binds the authenticated token into `SecurityContextHolder` for the current thread.
5. **Controller Access**: The controller receives `@AuthenticationPrincipal CustomUserDetails authenticatedUser` directly as a parameter and safely calls `authenticatedUser.getUserId()`.

---

### Act IV: Connecting to Live Chat (WebSocket STOMP Security)

Real-time chat requires a WebSocket connection (`/ws-connect`):

1. **Connecting**: The Flutter client sends a STOMP `CONNECT` frame containing header `Authorization: Bearer <jwt-token>`.
2. **Interception**: `WebSocketAuthInterceptor` intercepts the frame in `preSend()`.
3. **Verification**: Validates the JWT token statelessly, builds `CustomUserDetails`, and attaches it to the WebSocket session context (`accessor.setUser(authToken)`).
4. **Live Messaging**: All future STOMP `SEND` and `SUBSCRIBE` messages in that socket session inherit this authenticated principal.

---

### Act V: Token Refresh & Logout

#### Refresh Token Rotation (`POST /auth/refresh`)
1. When the access token expires (HTTP 401), the client sends `{ "refreshToken": "<token>" }`.
2. `RefreshTokenService` checks MongoDB:
   * Revokes the old refresh token.
   * Generates and stores a **new** refresh token in MongoDB (Token Rotation).
3. `JwtService` issues a new access token.
4. Both new tokens are returned to the client.

#### Logout (`POST /auth/logout`)
1. Client sends a logout request with their refresh token.
2. `RefreshTokenService` marks the refresh token as revoked in MongoDB.
3. A `UserLogoutEvent` is published, updating the user's presence status to `OFFLINE`.
4. Returns `204 No Content`.



