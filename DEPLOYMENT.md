# Deployment Guide

## Pre-Deployment Checklist

### 1. Network Configuration
- [ ] Update `lib/config/network_config.dart` - set to `mainnet` for production
- [ ] Verify Web3Auth client ID is for production (sapphire_mainnet)
- [ ] Update redirect URI in Web3Auth dashboard

### 2. Build Configuration
- [ ] Update `pubspec.yaml` version number
- [ ] Update app name and package name if needed
- [ ] Remove any test/debug dependencies

### 3. Security
- [ ] Never commit `.env` files with real credentials
- [ ] Ensure all API keys are properly secured
- [ ] Review all network requests for security

### 4. Testing
- [ ] Test on real devices (Android & iOS)
- [ ] Test wallet connectivity on mainnet
- [ ] Test image classification with real waste items
- [ ] Verify token balance updates work correctly

## Build for Production

### Android
```bash
flutter build apk --release
# or for app bundle
flutter build appbundle --release
```

### iOS
```bash
flutter build ipa --release
```

## Environment Variables

Copy `.env.example` to `.env` and fill in your production values:
- `SOLANA_NETWORK=mainnet`
- `WEB3AUTH_CLIENT_ID=your_production_client_id`
- `WEB3AUTH_NETWORK=sapphire_mainnet`

## Post-Deployment

1. Monitor crash reports
2. Check wallet service connectivity
3. Verify blockchain transactions
4. Monitor user feedback

## Rollback Plan

If issues occur:
1. Keep previous APK/IPA versions
2. Document all configuration changes
3. Have rollback procedure ready

## Support

For issues, check:
- Solana network status: https://status.solana.com/
- Web3Auth status: https://status.web3auth.io/
