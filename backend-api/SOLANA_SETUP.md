# Solana Token Integration Setup Guide

## 🎯 Overview
This guide will help you integrate your CoinFactory token (on Solana devnet) with the Waste Wise reward distribution API.

## 📋 Prerequisites
- Node.js 16+ installed
- Your CoinFactory token created on Solana devnet
- A Solana wallet with your tokens and some SOL for transaction fees

## 🚀 Step-by-Step Setup

### 1. Install Dependencies
```bash
cd backend-api
npm install
```

### 2. Get Your Token Information

#### From CoinFactory:
- **Token Mint Address**: This is your token's unique identifier on Solana
- **Token Symbol**: Your token's symbol (e.g., "WASTE")
- **Token Name**: Your token's full name (e.g., "WasteWise Token")

#### From your Solana wallet:
- **Wallet Address**: Your public key (Base58 encoded)
- **Private Key**: Your wallet's private key (Base58 encoded) - **KEEP THIS SECURE!**

### 3. Configure Environment Variables

Copy the example environment file:
```bash
cp .env.example .env
```

Update your `.env` file with your actual values:
```env
# Solana Blockchain Configuration
SOLANA_TOKEN_MINT_ADDRESS=YOUR_ACTUAL_TOKEN_MINT_ADDRESS
TOKEN_SYMBOL=YOUR_TOKEN_SYMBOL
TOKEN_NAME=Your Token Name

# Solana Network Configuration
SOLANA_RPC_URL=https://api.devnet.solana.com

# Admin Wallet Configuration (KEEP SECURE!)
SOLANA_ADMIN_PRIVATE_KEY=your_base58_encoded_private_key

# Server Configuration
NODE_ENV=development
PORT=3001
```

### 4. How to Get Your Private Key

#### Option A: From Solana CLI
```bash
# If you have Solana CLI installed
solana-keygen pubkey ~/.config/solana/id.json
cat ~/.config/solana/id.json
```

#### Option B: From Phantom Wallet
1. Open Phantom wallet
2. Go to Settings → Security & Privacy → Export Private Key
3. Copy the private key (it's Base58 encoded)

#### Option C: From Solflare Wallet
1. Open Solflare wallet
2. Click on your wallet name → Export Private Key
3. Copy the private key

### 5. Verify Your Token Setup

Create a test script to verify your configuration:

```javascript
// test-setup.js
const SolanaBlockchainService = require('./services/solanaBlockchainService');

async function testSetup() {
  const service = new SolanaBlockchainService();
  
  // Test connection
  console.log('Testing Solana connection...');
  const networkInfo = await service.getNetworkInfo();
  console.log('Network Info:', networkInfo);
  
  // Test token info
  console.log('\\nGetting token information...');
  const tokenInfo = await service.getTokenInfo();
  console.log('Token Info:', tokenInfo);
  
  // Test admin balance
  console.log('\\nChecking admin token balance...');
  const adminAddress = service.adminKeypair?.publicKey.toString();
  if (adminAddress) {
    const balance = await service.getUserTokenBalance(adminAddress);
    console.log('Admin Balance:', balance);
  }
}

testSetup().catch(console.error);
```

Run the test:
```bash
node test-setup.js
```

### 6. Start the API Server

```bash
npm start
```

You should see output like:
```
🚀 Waste Wise Token API running on 0.0.0.0:3001
🌍 Environment: development
📚 API Documentation: http://0.0.0.0:3001/api/docs
❤️  Health Check: http://0.0.0.0:3001/health
```

### 7. Test the API

#### Check API Health:
```bash
curl http://localhost:3001/health
```

#### Get Token Information:
```bash
curl http://localhost:3001/api/rewards/token-info
```

#### Check a User's Balance:
```bash
curl http://localhost:3001/api/rewards/balance/YOUR_WALLET_ADDRESS
```

#### Process a Test Reward:
```bash
curl -X POST http://localhost:3001/api/rewards/scan \\
  -H "Content-Type: application/json" \\
  -d '{
    "userId": "test-user-123",
    "walletAddress": "RECIPIENT_SOLANA_ADDRESS",
    "itemType": "plastic_bottle",
    "classification": "recyclable",
    "confidence": 0.95,
    "isCorrect": true,
    "location": "Test Location"
  }'
```

## 🔧 Troubleshooting

### Common Issues:

#### 1. "Insufficient admin token balance"
- Make sure your admin wallet has enough tokens to distribute
- Check your token balance: `curl http://localhost:3001/api/rewards/balance/YOUR_ADMIN_ADDRESS`

#### 2. "Invalid Solana wallet address"
- Ensure wallet addresses are Base58 encoded and 32-44 characters long
- Solana addresses don't contain 0, O, I, or l characters

#### 3. "Failed to initialize Solana blockchain service"
- Verify your `SOLANA_TOKEN_MINT_ADDRESS` is correct
- Check that your `SOLANA_ADMIN_PRIVATE_KEY` is valid Base58 format
- Ensure you have internet connection to Solana devnet

#### 4. "Insufficient SOL for transaction fees"
- Your admin wallet needs SOL to pay for transaction fees
- Get devnet SOL from: https://faucet.solana.com/
- Or use the API airdrop endpoint: `POST /api/rewards/airdrop-sol`

### Get Devnet SOL:
```bash
# Using the API (if implemented)
curl -X POST http://localhost:3001/api/rewards/airdrop-sol \\
  -H "Content-Type: application/json" \\
  -d '{"walletAddress": "YOUR_ADMIN_ADDRESS", "amount": 2}'

# Or visit: https://faucet.solana.com/
```

## 🎮 Testing Different Reward Types

### Scan Reward:
```bash
curl -X POST http://localhost:3001/api/rewards/scan \\
  -H "Content-Type: application/json" \\
  -d '{
    "userId": "user123",
    "walletAddress": "SOLANA_ADDRESS",
    "itemType": "plastic_bottle",
    "classification": "recyclable",
    "confidence": 0.95,
    "isCorrect": true
  }'
```

### Streak Reward:
```bash
curl -X POST http://localhost:3001/api/rewards/streak \\
  -H "Content-Type: application/json" \\
  -d '{
    "userId": "user123",
    "walletAddress": "SOLANA_ADDRESS",
    "currentStreak": 7,
    "streakType": "daily",
    "isNewRecord": true
  }'
```

### Achievement Reward:
```bash
curl -X POST http://localhost:3001/api/rewards/achievement \\
  -H "Content-Type: application/json" \\
  -d '{
    "userId": "user123",
    "walletAddress": "SOLANA_ADDRESS",
    "achievementType": "recycling",
    "milestone": 100,
    "isRare": false
  }'
```

## 📱 Integration with Flutter App

Update your Flutter app to use Solana wallet addresses:

```dart
// Example API call from Flutter
final response = await http.post(
  Uri.parse('http://your-api-url.com/api/rewards/scan'),
  headers: {'Content-Type': 'application/json'},
  body: jsonEncode({
    'userId': user.id,
    'walletAddress': user.solanaWalletAddress, // Solana address
    'itemType': 'plastic_bottle',
    'classification': 'recyclable',
    'confidence': 0.95,
    'isCorrect': true,
    'location': 'New York, NY'
  }),
);

if (response.statusCode == 200) {
  final result = jsonDecode(response.body);
  if (result['success']) {
    final tokensAwarded = result['data']['tokensAwarded'];
    final transactionSignature = result['data']['transactionSignature'];
    
    // Show success message to user
    showRewardNotification(tokensAwarded, transactionSignature);
  }
}
```

## 🔐 Security Best Practices

1. **Never expose private keys in client applications**
2. **Use environment variables for sensitive configuration**
3. **Implement proper authentication for your API**
4. **Use HTTPS in production**
5. **Monitor transaction logs for suspicious activity**
6. **Keep your admin wallet separate from user wallets**

## 📊 Monitoring & Analytics

Check API statistics:
```bash
curl http://localhost:3001/api/rewards/stats
```

View transaction on Solana Explorer:
- Devnet: `https://explorer.solana.com/tx/TRANSACTION_SIGNATURE?cluster=devnet`
- Mainnet: `https://explorer.solana.com/tx/TRANSACTION_SIGNATURE`

## 🚀 Going to Production

1. Update `SOLANA_RPC_URL` to mainnet: `https://api.mainnet-beta.solana.com`
2. Move your tokens to mainnet
3. Use a production-grade admin wallet with proper security
4. Set up monitoring and alerting
5. Configure rate limiting and DDoS protection
6. Use a reverse proxy (nginx) and SSL certificates

## 📞 Support

If you encounter issues:
1. Check the console logs for detailed error messages
2. Verify your environment configuration
3. Test with small amounts first
4. Check Solana network status: https://status.solana.com/

Your Solana token reward system is now ready to distribute tokens to users based on their recycling activities! 🎉
