# Web3Auth Dashboard Configuration

## ⚠️ CRITICAL: You MUST complete these steps to fix the authentication error

The app is currently showing this error:
```
could not validate redirect, please whitelist your domain: com.wastemanagement.app for provided client id BFg78_oqmd55.JzJYpH30Mvw4YSTHS1320 JONTFV8lzYutxvz83qhZHELYIBU3VCSM2 WI at https://dashboard.web3auth.io
```

## Step 1: Access Your Web3Auth Dashboard

1. Go to **https://dashboard.web3auth.io**
2. Log in to your account
3. Find your project (the one with Client ID starting with `BFg79_oqmd5S...`)

## Step 2: Fix the Client ID (IMPORTANT!)

⚠️ **The current Client ID in the code appears to be truncated or corrupted.**

Current Client ID in code:
```
BFg79_oqmd5SJzJYpH9bMvw4s-klY87HSt32G_lOnTFV8lzYuixvz83qhZHkLYt8u3VCSM2_WI
```

**Action Required:**
1. In your Web3Auth dashboard, copy the **complete** Client ID
2. Replace the `clientId` value in `lib/web3auth_config.dart`
3. The complete Client ID should be much longer than the current one

## Step 3: Whitelist the Redirect URI

1. In your Web3Auth project settings, go to **"Whitelist"** or **"Redirect URIs"** section
2. Add this exact redirect URI: `com.wastemanagement.app://auth`
3. Make sure there are no typos - it must match exactly
4. Remove any incorrect URIs like `w3a://...` or `wlat//...` if they exist

## Step 4: Verify Network Settings

1. Ensure your Web3Auth project is set to **"Testnet"** network
2. The Flutter app is configured for `Network.testnet`
3. If you want to use mainnet, you'll need to:
   - Change the Web3Auth dashboard project to mainnet
   - Update `lib/main.dart` to use `Network.mainnet`
   - ⚠️ **WARNING**: Mainnet uses real cryptocurrency with real value!

## Step 5: Apply Changes

After making the dashboard changes:
1. Wait 2-3 minutes for changes to propagate
2. Update the `clientId` in `lib/web3auth_config.dart` if needed
3. Run: `flutter clean && flutter run`
4. Test the authentication flow

## Expected Configuration Summary

| Setting | Value |
|---------|-------|
| **Client ID** | `BFg79_oqmd5SJzJYpH9bMvw4s-klY87HSt32G_lOnTFV8lzYuixvz83qhZHkLYt8u3VCSM2_WI` (or the complete version) |
| **Redirect URI** | `com.wastemanagement.app://auth` |
| **Network** | Testnet |
| **Platform** | Android (iOS if applicable) |

## Troubleshooting

### Error: "could not validate redirect"
- Verify the redirect URI is exactly `com.wastemanagement.app://auth` in the dashboard
- Check for typos in the whitelist
- Ensure there are no extra spaces or characters

### Error: "Client ID not found"
- Copy the complete Client ID from the dashboard
- Ensure it's not truncated
- Check that the project exists and is active

### Error: "Network mismatch"
- Verify both dashboard and app use the same network (testnet/mainnet)

## Support

If you continue having issues:
1. Screenshot your Web3Auth dashboard settings
2. Check the complete error message in the console
3. Verify the Client ID is complete and correct
4. Contact Web3Auth support if dashboard issues persist

---

**Next Steps After Configuration:**
1. Update `lib/web3auth_config.dart` with the correct Client ID
2. Test authentication flow
3. Verify login works properly