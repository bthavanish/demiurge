# Domains Reference

DeFi dimensional analysis, Firebase/Android security.

---

## DeFi Dimensional Analysis

### Unit System

DeFi protocols use tokens as base units. Every quantity has a dimension.

| Dimension | Base Unit | Example |
|---|---|---|
| Token | token | 100 USDC |
| Price | token/token | 1500 ETH/USDC |
| Rate | token/time | 5% APY = 0.05 token/token/year |
| Volume | token*time | 24h trading volume |

### Common Dimensional Errors

- **Price x Price**: multiplying two prices gives meaningless units
- **Rate + Rate**: adding rates with different time dimensions
- **Volume mismatch**: comparing 24h volume to 7d volume without normalization

### Validation Pattern

```python
# Before any DeFi calculation, verify dimensional consistency:
# price * amount = value (token * token/token = token)
# rate * time * principal = interest (1/time * time * token = token)
# invariant * total_supply = reserves (token/token * token = token)
```

---

## Firebase / Android APK Security

### Firebase Misconfigurations

- **Realtime Database open read**: `".read": true` allows anyone to read all data
- **Realtime Database open write**: `".write": true` allows anyone to modify
- **Firestore open rules**: `allow read, write: if true;`
- **Storage open rules**: `allow read, write: if true;`

### Detection

```
# Check Firebase config in APK
grep -r "firebaseio.com" .
grep -r "firestore.googleapis.com" .
grep -r "googleapis.com/storage" .

# Check Android manifest for Firebase
grep -r "firebase" AndroidManifest.xml
```

### Android APK Security

- **Exported components**: components with `android:exported="true"` without intent filters
- **Insecure storage**: `SharedPreferences` with `MODE_WORLD_READABLE`
- **Hardcoded secrets**: API keys, tokens in BuildConfig or strings.xml
- **Insecure network**: `android:usesCleartextTraffic="true"` in manifest
- **Debuggable builds**: `android:debuggable="true"` in manifest

### Remediation

- Set Firebase rules to require authentication
- Use `android:exported="false"` unless explicitly needed
- Store secrets in Android Keystore, not hardcoded
- Use network security config for cleartext exceptions
- Disable debuggable in release builds
