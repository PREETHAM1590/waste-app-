// Test script to verify your Solana token integration setup
require('dotenv').config();
const SolanaBlockchainService = require('./services/solanaBlockchainService');

async function testSetup() {
  console.log('🚀 Testing Waste Wise Solana Token Integration...\n');

  try {
    const service = new SolanaBlockchainService();
    
    // Test 1: Connection
    console.log('1️⃣ Testing Solana connection...');
    const networkInfo = await service.getNetworkInfo();
    if (networkInfo.success) {
      console.log('✅ Connected to Solana successfully!');
      console.log(`   Cluster: ${networkInfo.cluster}`);
      console.log(`   Version: ${networkInfo.version}`);
      console.log(`   Current Slot: ${networkInfo.currentSlot}`);
    } else {
      console.log('❌ Failed to connect to Solana:', networkInfo.error);
      return;
    }

    console.log();

    // Test 2: Token Information
    console.log('2️⃣ Getting token information...');
    const tokenInfo = await service.getTokenInfo();
    if (tokenInfo.success) {
      console.log('✅ Token information retrieved successfully!');
      console.log(`   Name: ${tokenInfo.name}`);
      console.log(`   Symbol: ${tokenInfo.symbol}`);
      console.log(`   Decimals: ${tokenInfo.decimals}`);
      console.log(`   Supply: ${tokenInfo.supply}`);
      console.log(`   Mint Address: ${tokenInfo.mintAddress}`);
    } else {
      console.log('❌ Failed to get token info:', tokenInfo.error);
      return;
    }

    console.log();

    // Test 3: Admin Wallet
    console.log('3️⃣ Checking admin wallet...');
    const adminAddress = service.adminKeypair?.publicKey.toString();
    if (adminAddress) {
      console.log('✅ Admin wallet loaded successfully!');
      console.log(`   Address: ${adminAddress}`);

      // Check SOL balance
      const solBalance = await service.getSolBalance(adminAddress);
      if (solBalance.success) {
        console.log(`   SOL Balance: ${solBalance.balance} SOL`);
        
        if (solBalance.balance < 0.01) {
          console.log('⚠️  Warning: Low SOL balance. You may need more SOL for transaction fees.');
          console.log('   Get devnet SOL from: https://faucet.solana.com/');
        }
      }

      // Check token balance
      const tokenBalance = await service.getUserTokenBalance(adminAddress);
      if (tokenBalance.success) {
        console.log(`   Token Balance: ${tokenBalance.balance} ${tokenBalance.tokenSymbol}`);
        
        if (tokenBalance.balance === 0) {
          console.log('⚠️  Warning: No tokens in admin wallet. Make sure to transfer some tokens for distribution.');
        }
      } else {
        console.log('ℹ️  Note: Admin token account not yet created. This is normal for new tokens.');
      }
    } else {
      console.log('❌ Admin wallet not configured. Check your SOLANA_ADMIN_PRIVATE_KEY.');
      return;
    }

    console.log();

    // Test 4: Configuration Check
    console.log('4️⃣ Checking configuration...');
    
    const requiredEnvVars = [
      'SOLANA_TOKEN_MINT_ADDRESS',
      'SOLANA_ADMIN_PRIVATE_KEY',
      'TOKEN_SYMBOL',
      'TOKEN_NAME'
    ];

    let configValid = true;
    for (const envVar of requiredEnvVars) {
      if (!process.env[envVar] || process.env[envVar] === `YOUR_${envVar}`) {
        console.log(`❌ Missing or invalid: ${envVar}`);
        configValid = false;
      } else {
        console.log(`✅ ${envVar}: configured`);
      }
    }

    if (!configValid) {
      console.log('\n📝 Please update your .env file with correct values.');
      return;
    }

    console.log();

    // Test 5: Address Validation
    console.log('5️⃣ Testing address validation...');
    
    const testAddresses = [
      adminAddress, // Should be valid
      '11111111111111111111111111111112', // Valid format
      'invalid-address', // Should be invalid
      '0x1234567890123456789012345678901234567890' // Ethereum format (should be invalid)
    ];

    testAddresses.forEach((addr, index) => {
      const isValid = service.isValidAddress(addr);
      const label = index === 0 ? 'Admin address' : 
                   index === 1 ? 'Test valid address' :
                   index === 2 ? 'Invalid address' : 'Ethereum address';
      
      console.log(`   ${label}: ${isValid ? '✅ Valid' : '❌ Invalid'}`);
    });

    console.log();

    // Summary
    console.log('🎉 Setup Test Complete!');
    console.log();
    console.log('📋 Summary:');
    console.log('✅ Solana connection working');
    console.log('✅ Token configuration loaded');
    console.log('✅ Admin wallet configured');
    console.log('✅ Environment variables set');
    console.log();
    console.log('🚀 Your token reward system is ready to use!');
    console.log();
    console.log('📝 Next steps:');
    console.log('1. Start the API server: npm start');
    console.log('2. Test the API endpoints');
    console.log('3. Integrate with your Flutter app');
    console.log();
    console.log('🔗 Useful links:');
    console.log(`   Token on explorer: https://explorer.solana.com/address/${tokenInfo.mintAddress}?cluster=devnet`);
    console.log(`   Admin wallet: https://explorer.solana.com/address/${adminAddress}?cluster=devnet`);
    console.log('   Solana faucet: https://faucet.solana.com/');

  } catch (error) {
    console.log('❌ Setup test failed:', error.message);
    console.log();
    console.log('🔧 Troubleshooting tips:');
    console.log('1. Make sure your .env file is configured correctly');
    console.log('2. Check that your SOLANA_TOKEN_MINT_ADDRESS is valid');
    console.log('3. Verify your SOLANA_ADMIN_PRIVATE_KEY is Base58 encoded');
    console.log('4. Ensure you have internet connection');
    console.log('5. Check Solana network status: https://status.solana.com/');
  }
}

// Run the test
testSetup().catch(console.error);
