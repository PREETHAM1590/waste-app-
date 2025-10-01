# Web3Auth Configuration Guide

## Issue
Your app is showing this error:
```
❌ Web3Auth initialization failed: Runtime Error
could not validate redirect, please whitelist your domain:
com.wastemanagement.app://auth
```

## Your Web3Auth Details
- **Client ID**: `BNlbty2zJSKt7A6B3rDUyfEHKl4_FlChBj-rVWmgmk9bGGVQHi2tqhZJJhjJ7-hNugg7SOJmgFg7FEzL0xC2o`
- **Network**: `sapphire_devnet`
- **Redirect URI**: `com.wastemanagement.app://auth`

## Steps to Fix

### 1. Access Web3Auth Dashboard
1. Go to https://dashboard.web3auth.io
2. Sign in with your account
3. Select your project that contains the Client ID above

### 2. Whitelist the Redirect URI
1. In your project dashboard, look for **"Whitelist URLs"** or **"Redirect URIs"** section
2. Click **"Add URL"** or **"+ Add"** button
3. Add the following redirect URI:
   ```
   com.wastemanagement.app://auth
   ```
4. Click **"Save"** or **"Add"**

### 3. Verify Network Configuration
1. Check that your project is configured for **`sapphire_devnet`** network
2. If it's on a different network (like `mainnet` or `testnet`), you need to either:
   - Switch the project to `sapphire_devnet`, OR
   - Update the app configuration to match your project's network

### 4. Alternative: Create a New Web3Auth Project
If you can't modify the existing project, you can create a new one:

1. Go to https://dashboard.web3auth.io
2. Click **"Create New Project"**
3. Fill in the details:
   - **Project Name**: Waste Wise Wallet (or any name)
   - **Network**: Select **`sapphire_devnet`**
   - **Platform**: Select **Android** and/or **iOS**
4. After creation, add the redirect URI:
   ```
   com.wastemanagement.app://auth
   ```
5. Copy the new **Client ID** from the dashboard
6. Update the Client ID in your app:
   - Open: `lib/wallet/services/web3auth_config.dart`
   - Replace the `clientId` value (line 15) with your new Client ID
   - Save the file

## Expected Result
After whitelisting the redirect URI, you should see:
```
✅ Web3Auth initialized successfully
✅ Wallet service initialized
```

## Common Issues

### Issue: "Client ID belongs to different network"
**Solution**: Make sure your Web3Auth project network matches `sapphire_devnet`. If not, either change the project network or update the app config.

### Issue: "Invalid redirect URI format"
**Solution**: Make sure you're using exactly: `com.wastemanagement.app://auth` (no spaces, no http://, no trailing slashes)

### Issue: Still getting errors after whitelisting
**Solutions**:
1. Wait 1-2 minutes for changes to propagate
2. Restart your Flutter app completely (not hot reload)
3. Clear app data on device and reinstall

## Testing
After making changes:

1. Stop the Flutter app (press Ctrl+C in terminal)
2. Clean the build:
   ```bash
   flutter clean
   ```
3. Rebuild and run:
   ```bash
   flutter run
   ```
4. Check the logs for: `✅ Web3Auth initialized successfully`

## Need Help?
If you continue having issues:
1. Check the Web3Auth documentation: https://web3auth.io/docs/
2. Verify your dashboard settings match the app configuration
3. Contact Web3Auth support if the redirect URI won't save

---

**Note**: The BackgroundIsolateBinaryMessenger error has been fixed in the latest update. You should no longer see those errors after restarting the app.
