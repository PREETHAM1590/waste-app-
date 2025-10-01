# Web3Auth Configuration Guide

## Current Configuration Status

✅ **Completed Steps:**
- Updated Flutter code to use consistent redirect URI: `com.wastemanagement.app://auth`
- Fixed Android manifest intent-filter
- Fixed iOS Info.plist URL types
- Cleaned Flutter build cache

## Next Steps Required

### 1. Configure Web3Auth Dashboard

You need to log into your Web3Auth dashboard at https://dashboard.web3auth.io and:

1. **Navigate to your project**
2. **Ensure you're on the Sapphire Devnet network** (as configured in your Flutter app)
3. **Verify/Copy the exact Client ID** from the dashboard and compare with your code
4. **Add Redirect URI**: `com.wastemanagement.app://auth` to the whitelist
5. **Save changes**

### 2. Potential Client ID Issue

Your error message shows this Client ID format:
```
BNbry2zJSK74683/DUYTEHK14, FICHB-VWmgmk9GGVQHZJJ17-Nugg750.JmgFg7FEzL0xC20
```

But your code has:
```
BNlbty2zJSKt7A6B3rDUyfEHKl4_FlChBj-rVWmgmk9bGGVQHi2tqhZJJhjJ7-hNugg7SOJmgFg7FEzL0xC2o
```

**Action Required:** Copy the exact Client ID from your Web3Auth dashboard and replace it in `lib/web3auth_config.dart`.

### 3. Testing Steps

After configuring the dashboard:

1. Run your app: `flutter run`
2. Try to authenticate with Web3Auth
3. Verify the redirect works properly
4. Check that no "could not validate redirect" error occurs

### 4. Troubleshooting

If you still get errors:

#### Check Android Logs
```bash
adb logcat | grep -i web3auth
```

#### Check iOS Logs
Use Xcode console or device logs to see Web3Auth-related messages.

#### Common Issues
- **Client ID mismatch**: Ensure exact match between dashboard and code
- **Network mismatch**: Ensure using Sapphire Devnet in both places
- **Redirect URI not whitelisted**: Must add `com.wastemanagement.app://auth` to dashboard

## Files Modified

✅ `lib/web3auth_config.dart` - Updated redirect scheme
✅ `android/app/src/main/AndroidManifest.xml` - Fixed intent-filter
✅ `ios/Runner/Info.plist` - Updated URL scheme (was already correct)

## Current Configuration

- **Network**: Sapphire Devnet
- **Redirect URI**: `com.wastemanagement.app://auth`
- **Client ID**: `BNlbty2zJSKt7A6B3rDUyfEHKl4_FlChBj-rVWmgmk9bGGVQHi2tqhZJJhjJ7-hNugg7SOJmgFg7FEzL0xC2o`

## Contact Support

If the issue persists after following these steps, contact Web3Auth support with:
- Your exact Client ID
- The redirect URI you're trying to use
- Your network (Sapphire Devnet)
- Error message details
