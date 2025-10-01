const {
  Connection,
  PublicKey,
  Keypair,
  Transaction,
  SystemProgram,
  sendAndConfirmTransaction,
  LAMPORTS_PER_SOL,
} = require('@solana/web3.js');
const {
  TOKEN_PROGRAM_ID,
  ASSOCIATED_TOKEN_PROGRAM_ID,
  getOrCreateAssociatedTokenAccount,
  createTransferInstruction,
  getAccount,
  getMint,
  createMintToInstruction,
  getAssociatedTokenAddress,
} = require('@solana/spl-token');
const bs58 = require('bs58');

/**
 * Solana Blockchain Service for Token Distribution
 * Handles minting and transferring tokens on Solana devnet/mainnet
 */
class SolanaBlockchainService {
  constructor() {
    // Configure your Solana network (update these with your actual values)
    this.config = {
      // Update with your CoinFactory token details
      TOKEN_MINT_ADDRESS: process.env.SOLANA_TOKEN_MINT_ADDRESS || 'YOUR_TOKEN_MINT_ADDRESS',
      TOKEN_SYMBOL: process.env.TOKEN_SYMBOL || 'WASTE',
      TOKEN_NAME: process.env.TOKEN_NAME || 'WasteWise Token',
      
      // Network configuration
      NETWORK_URL: process.env.SOLANA_RPC_URL || 'https://api.devnet.solana.com', // Solana devnet
      COMMITMENT: 'confirmed',
      
      // Admin wallet (for distributing tokens) - Base58 encoded private key
      ADMIN_PRIVATE_KEY: process.env.SOLANA_ADMIN_PRIVATE_KEY, // Base58 encoded
      
      // Transaction configuration
      SKIP_PREFLIGHT: false,
      MAX_RETRIES: 3,
    };

    this.connection = null;
    this.adminKeypair = null;
    this.tokenMint = null;
    
    this.initializeConnection();
  }

  /**
   * Initialize Solana connection and admin wallet
   */
  async initializeConnection() {
    try {
      // Initialize connection
      this.connection = new Connection(this.config.NETWORK_URL, this.config.COMMITMENT);
      
      // Initialize admin keypair from private key
      if (this.config.ADMIN_PRIVATE_KEY) {
        const privateKeyBytes = bs58.decode(this.config.ADMIN_PRIVATE_KEY);
        this.adminKeypair = Keypair.fromSecretKey(privateKeyBytes);
        console.log('Admin wallet:', this.adminKeypair.publicKey.toString());
      }

      // Initialize token mint
      if (this.config.TOKEN_MINT_ADDRESS) {
        this.tokenMint = new PublicKey(this.config.TOKEN_MINT_ADDRESS);
      }

      // Test connection
      const version = await this.connection.getVersion();
      console.log('Solana blockchain service initialized successfully');
      console.log('Connected to Solana cluster version:', version['solana-core']);
      
    } catch (error) {
      console.error('Failed to initialize Solana blockchain service:', error);
      throw error;
    }
  }

  /**
   * Distribute tokens to a single user
   * @param {string} userWalletAddress - User's Solana wallet address (Base58)
   * @param {number} tokenAmount - Amount of tokens to send
   * @param {string} reason - Reason for the reward (for logging)
   * @returns {Object} - Transaction result
   */
  async distributeTokensToUser(userWalletAddress, tokenAmount, reason = 'Recycling reward') {
    try {
      if (!this.connection || !this.adminKeypair || !this.tokenMint) {
        throw new Error('Solana service not properly initialized');
      }

      // Validate wallet address
      let userPublicKey;
      try {
        userPublicKey = new PublicKey(userWalletAddress);
      } catch (error) {
        throw new Error('Invalid Solana wallet address');
      }

      // Get token mint info
      const mintInfo = await getMint(this.connection, this.tokenMint);
      const tokenAmountWithDecimals = tokenAmount * Math.pow(10, mintInfo.decimals);

      // Get or create admin's token account
      const adminTokenAccount = await getOrCreateAssociatedTokenAccount(
        this.connection,
        this.adminKeypair,
        this.tokenMint,
        this.adminKeypair.publicKey
      );

      // Get or create user's token account
      const userTokenAccount = await getOrCreateAssociatedTokenAccount(
        this.connection,
        this.adminKeypair, // Payer
        this.tokenMint,
        userPublicKey // Owner
      );

      // Check admin balance
      const adminAccountInfo = await getAccount(this.connection, adminTokenAccount.address);
      if (Number(adminAccountInfo.amount) < tokenAmountWithDecimals) {
        throw new Error('Insufficient admin token balance for distribution');
      }

      // Create transfer instruction
      const transferInstruction = createTransferInstruction(
        adminTokenAccount.address, // Source
        userTokenAccount.address,   // Destination
        this.adminKeypair.publicKey, // Owner
        tokenAmountWithDecimals,    // Amount
        [],                         // Signers
        TOKEN_PROGRAM_ID           // Token program
      );

      // Create transaction
      const transaction = new Transaction().add(transferInstruction);
      
      // Get recent blockhash
      const { blockhash } = await this.connection.getLatestBlockhash();
      transaction.recentBlockhash = blockhash;
      transaction.feePayer = this.adminKeypair.publicKey;

      // Send and confirm transaction
      const signature = await sendAndConfirmTransaction(
        this.connection,
        transaction,
        [this.adminKeypair],
        {
          commitment: this.config.COMMITMENT,
          skipPreflight: this.config.SKIP_PREFLIGHT,
          maxRetries: this.config.MAX_RETRIES,
        }
      );

      // Get transaction details
      const confirmedTx = await this.connection.getTransaction(signature, {
        commitment: this.config.COMMITMENT
      });

      return {
        success: true,
        transactionSignature: signature,
        blockHeight: confirmedTx?.blockTime || 0,
        tokenAmount,
        userWalletAddress,
        reason,
        timestamp: new Date().toISOString(),
        explorerUrl: `https://explorer.solana.com/tx/${signature}?cluster=devnet`
      };

    } catch (error) {
      console.error('Solana token distribution failed:', error);
      return {
        success: false,
        error: error.message,
        userWalletAddress,
        tokenAmount,
        reason,
        timestamp: new Date().toISOString()
      };
    }
  }

  /**
   * Batch distribute tokens to multiple users
   * @param {Array} distributions - Array of {address, amount, reason} objects
   * @returns {Array} - Array of transaction results
   */
  async batchDistributeTokens(distributions) {
    const results = [];

    for (const distribution of distributions) {
      const { address, amount, reason } = distribution;
      
      try {
        const result = await this.distributeTokensToUser(address, amount, reason);
        results.push(result);

        // Add small delay to prevent overwhelming the network
        await new Promise(resolve => setTimeout(resolve, 500));
        
      } catch (error) {
        results.push({
          success: false,
          error: error.message,
          userWalletAddress: address,
          tokenAmount: amount,
          reason,
          timestamp: new Date().toISOString()
        });
      }
    }

    return results;
  }

  /**
   * Mint new tokens (if your token supports it and you have mint authority)
   * @param {string} recipientAddress - Address to mint tokens to
   * @param {number} tokenAmount - Amount of tokens to mint
   * @returns {Object} - Transaction result
   */
  async mintTokens(recipientAddress, tokenAmount) {
    try {
      if (!this.connection || !this.adminKeypair || !this.tokenMint) {
        throw new Error('Solana service not properly initialized');
      }

      const recipientPublicKey = new PublicKey(recipientAddress);

      // Get token mint info
      const mintInfo = await getMint(this.connection, this.tokenMint);
      const tokenAmountWithDecimals = tokenAmount * Math.pow(10, mintInfo.decimals);

      // Get or create recipient's token account
      const recipientTokenAccount = await getOrCreateAssociatedTokenAccount(
        this.connection,
        this.adminKeypair, // Payer
        this.tokenMint,
        recipientPublicKey // Owner
      );

      // Create mint instruction
      const mintInstruction = createMintToInstruction(
        this.tokenMint,                    // Mint
        recipientTokenAccount.address,     // Destination
        this.adminKeypair.publicKey,      // Mint authority
        tokenAmountWithDecimals,          // Amount
        [],                               // Signers
        TOKEN_PROGRAM_ID                  // Token program
      );

      // Create transaction
      const transaction = new Transaction().add(mintInstruction);
      
      // Get recent blockhash
      const { blockhash } = await this.connection.getLatestBlockhash();
      transaction.recentBlockhash = blockhash;
      transaction.feePayer = this.adminKeypair.publicKey;

      // Send and confirm transaction
      const signature = await sendAndConfirmTransaction(
        this.connection,
        transaction,
        [this.adminKeypair],
        {
          commitment: this.config.COMMITMENT,
          skipPreflight: this.config.SKIP_PREFLIGHT,
          maxRetries: this.config.MAX_RETRIES,
        }
      );

      return {
        success: true,
        transactionSignature: signature,
        tokenAmount,
        recipientAddress,
        timestamp: new Date().toISOString(),
        explorerUrl: `https://explorer.solana.com/tx/${signature}?cluster=devnet`
      };

    } catch (error) {
      console.error('Solana token minting failed:', error);
      return {
        success: false,
        error: error.message,
        recipientAddress,
        tokenAmount,
        timestamp: new Date().toISOString()
      };
    }
  }

  /**
   * Get user's token balance
   * @param {string} userWalletAddress - User's Solana wallet address
   * @returns {Object} - Balance information
   */
  async getUserTokenBalance(userWalletAddress) {
    try {
      if (!this.connection || !this.tokenMint) {
        throw new Error('Solana service not initialized');
      }

      const userPublicKey = new PublicKey(userWalletAddress);
      
      // Get associated token account address
      const userTokenAccountAddress = await getAssociatedTokenAddress(
        this.tokenMint,
        userPublicKey
      );

      try {
        // Get token account info
        const accountInfo = await getAccount(this.connection, userTokenAccountAddress);
        const mintInfo = await getMint(this.connection, this.tokenMint);
        
        const balance = Number(accountInfo.amount) / Math.pow(10, mintInfo.decimals);

        return {
          success: true,
          balance,
          walletAddress: userWalletAddress,
          tokenSymbol: this.config.TOKEN_SYMBOL,
          tokenAccountAddress: userTokenAccountAddress.toString()
        };

      } catch (accountError) {
        // Token account doesn't exist, balance is 0
        return {
          success: true,
          balance: 0,
          walletAddress: userWalletAddress,
          tokenSymbol: this.config.TOKEN_SYMBOL,
          message: 'Token account not yet created'
        };
      }

    } catch (error) {
      console.error('Failed to get Solana token balance:', error);
      return {
        success: false,
        error: error.message,
        balance: 0,
        walletAddress: userWalletAddress
      };
    }
  }

  /**
   * Get token information
   * @returns {Object} - Token details
   */
  async getTokenInfo() {
    try {
      if (!this.connection || !this.tokenMint) {
        throw new Error('Solana service not initialized');
      }

      const mintInfo = await getMint(this.connection, this.tokenMint);

      return {
        success: true,
        name: this.config.TOKEN_NAME,
        symbol: this.config.TOKEN_SYMBOL,
        decimals: mintInfo.decimals,
        supply: Number(mintInfo.supply) / Math.pow(10, mintInfo.decimals),
        mintAddress: this.tokenMint.toString(),
        mintAuthority: mintInfo.mintAuthority?.toString(),
        freezeAuthority: mintInfo.freezeAuthority?.toString()
      };

    } catch (error) {
      console.error('Failed to get Solana token info:', error);
      return {
        success: false,
        error: error.message
      };
    }
  }

  /**
   * Get transaction status
   * @param {string} signature - Transaction signature
   * @returns {Object} - Transaction status
   */
  async getTransactionStatus(signature) {
    try {
      if (!this.connection) {
        throw new Error('Solana service not initialized');
      }

      const status = await this.connection.getSignatureStatus(signature);
      
      if (!status.value) {
        return {
          success: true,
          status: 'pending',
          signature
        };
      }

      const confirmedTx = await this.connection.getTransaction(signature, {
        commitment: this.config.COMMITMENT
      });

      return {
        success: true,
        status: status.value.err ? 'failed' : 'confirmed',
        signature,
        blockHeight: confirmedTx?.blockTime || null,
        confirmations: status.value.confirmations || 0,
        explorerUrl: `https://explorer.solana.com/tx/${signature}?cluster=devnet`
      };

    } catch (error) {
      console.error('Failed to get Solana transaction status:', error);
      return {
        success: false,
        error: error.message,
        signature
      };
    }
  }

  /**
   * Get SOL balance (for gas fees)
   * @param {string} walletAddress - Wallet address
   * @returns {Object} - SOL balance
   */
  async getSolBalance(walletAddress) {
    try {
      if (!this.connection) {
        throw new Error('Solana service not initialized');
      }

      const publicKey = new PublicKey(walletAddress);
      const balance = await this.connection.getBalance(publicKey);

      return {
        success: true,
        balance: balance / LAMPORTS_PER_SOL,
        balanceLamports: balance,
        walletAddress
      };

    } catch (error) {
      console.error('Failed to get SOL balance:', error);
      return {
        success: false,
        error: error.message,
        balance: 0,
        walletAddress
      };
    }
  }

  /**
   * Validate Solana wallet address format
   * @param {string} address - Wallet address to validate
   * @returns {boolean} - Whether address is valid
   */
  isValidAddress(address) {
    try {
      new PublicKey(address);
      return true;
    } catch (error) {
      return false;
    }
  }

  /**
   * Get network information
   * @returns {Object} - Network details
   */
  async getNetworkInfo() {
    try {
      if (!this.connection) {
        throw new Error('Solana service not initialized');
      }

      const version = await this.connection.getVersion();
      const slot = await this.connection.getSlot();
      const epochInfo = await this.connection.getEpochInfo();

      return {
        success: true,
        cluster: this.config.NETWORK_URL.includes('devnet') ? 'devnet' : 'mainnet-beta',
        version: version['solana-core'],
        currentSlot: slot,
        epoch: epochInfo.epoch,
        rpcUrl: this.config.NETWORK_URL
      };

    } catch (error) {
      console.error('Failed to get Solana network info:', error);
      return {
        success: false,
        error: error.message
      };
    }
  }

  /**
   * Airdrop SOL (devnet only) for testing
   * @param {string} walletAddress - Address to receive SOL
   * @param {number} solAmount - Amount of SOL to airdrop
   * @returns {Object} - Airdrop result
   */
  async airdropSol(walletAddress, solAmount = 1) {
    try {
      if (!this.connection) {
        throw new Error('Solana service not initialized');
      }

      if (!this.config.NETWORK_URL.includes('devnet')) {
        throw new Error('Airdrop only available on devnet');
      }

      const publicKey = new PublicKey(walletAddress);
      const lamports = solAmount * LAMPORTS_PER_SOL;

      const signature = await this.connection.requestAirdrop(publicKey, lamports);
      await this.connection.confirmTransaction(signature);

      return {
        success: true,
        signature,
        amount: solAmount,
        walletAddress,
        explorerUrl: `https://explorer.solana.com/tx/${signature}?cluster=devnet`
      };

    } catch (error) {
      console.error('SOL airdrop failed:', error);
      return {
        success: false,
        error: error.message,
        walletAddress,
        amount: solAmount
      };
    }
  }
}

module.exports = SolanaBlockchainService;
