const { ethers } = require('ethers');
const axios = require('axios');

/**
 * Blockchain Service for Token Distribution
 * Handles minting and transferring tokens from CoinFactory to user wallets
 */
class BlockchainService {
  constructor() {
    // Configure your blockchain network (update these with your actual values)
    this.config = {
      // Update with your CoinFactory token details
      TOKEN_CONTRACT_ADDRESS: process.env.TOKEN_CONTRACT_ADDRESS || 'YOUR_TOKEN_CONTRACT_ADDRESS',
      TOKEN_SYMBOL: process.env.TOKEN_SYMBOL || 'WASTE', // Your token symbol
      TOKEN_NAME: process.env.TOKEN_NAME || 'WasteWise Token',
      
      // Network configuration (update based on your deployment)
      NETWORK_RPC_URL: process.env.NETWORK_RPC_URL || 'https://polygon-rpc.com/', // Polygon mainnet
      NETWORK_CHAIN_ID: process.env.NETWORK_CHAIN_ID || 137, // Polygon
      
      // Admin wallet (for distributing tokens)
      ADMIN_PRIVATE_KEY: process.env.ADMIN_PRIVATE_KEY,
      ADMIN_ADDRESS: process.env.ADMIN_ADDRESS,
      
      // Gas configuration
      GAS_LIMIT: process.env.GAS_LIMIT || 100000,
      MAX_FEE_PER_GAS: process.env.MAX_FEE_PER_GAS || ethers.parseUnits('50', 'gwei'),
      MAX_PRIORITY_FEE_PER_GAS: process.env.MAX_PRIORITY_FEE_PER_GAS || ethers.parseUnits('2', 'gwei'),
    };

    this.provider = null;
    this.adminWallet = null;
    this.tokenContract = null;
    
    this.initializeBlockchain();
  }

  /**
   * Initialize blockchain connection and contracts
   */
  async initializeBlockchain() {
    try {
      // Initialize provider
      this.provider = new ethers.JsonRpcProvider(this.config.NETWORK_RPC_URL);
      
      // Initialize admin wallet
      if (this.config.ADMIN_PRIVATE_KEY) {
        this.adminWallet = new ethers.Wallet(this.config.ADMIN_PRIVATE_KEY, this.provider);
      }

      // ERC-20 Token ABI (standard functions we need)
      const tokenABI = [
        'function transfer(address to, uint256 amount) public returns (bool)',
        'function balanceOf(address account) public view returns (uint256)',
        'function decimals() public view returns (uint8)',
        'function symbol() public view returns (string)',
        'function name() public view returns (string)',
        'function totalSupply() public view returns (uint256)',
        'function mint(address to, uint256 amount) public', // If your token is mintable
        'event Transfer(address indexed from, address indexed to, uint256 value)'
      ];

      // Initialize token contract
      if (this.config.TOKEN_CONTRACT_ADDRESS && this.adminWallet) {
        this.tokenContract = new ethers.Contract(
          this.config.TOKEN_CONTRACT_ADDRESS,
          tokenABI,
          this.adminWallet
        );
      }

      console.log('Blockchain service initialized successfully');
    } catch (error) {
      console.error('Failed to initialize blockchain service:', error);
      throw error;
    }
  }

  /**
   * Distribute tokens to a single user
   * @param {string} userWalletAddress - User's wallet address
   * @param {number} tokenAmount - Amount of tokens to send
   * @param {string} reason - Reason for the reward (for logging)
   * @returns {Object} - Transaction result
   */
  async distributeTokensToUser(userWalletAddress, tokenAmount, reason = 'Recycling reward') {
    try {
      if (!this.tokenContract || !this.adminWallet) {
        throw new Error('Blockchain service not properly initialized');
      }

      // Validate wallet address
      if (!ethers.isAddress(userWalletAddress)) {
        throw new Error('Invalid wallet address');
      }

      // Get token decimals
      const decimals = await this.tokenContract.decimals();
      const tokenAmountWei = ethers.parseUnits(tokenAmount.toString(), decimals);

      // Check admin balance
      const adminBalance = await this.tokenContract.balanceOf(this.adminWallet.address);
      if (adminBalance < tokenAmountWei) {
        throw new Error('Insufficient admin token balance for distribution');
      }

      // Prepare transaction
      const tx = await this.tokenContract.transfer(userWalletAddress, tokenAmountWei, {
        gasLimit: this.config.GAS_LIMIT,
        maxFeePerGas: this.config.MAX_FEE_PER_GAS,
        maxPriorityFeePerGas: this.config.MAX_PRIORITY_FEE_PER_GAS,
      });

      // Wait for confirmation
      const receipt = await tx.wait();

      return {
        success: true,
        transactionHash: receipt.hash,
        blockNumber: receipt.blockNumber,
        gasUsed: receipt.gasUsed.toString(),
        tokenAmount,
        userWalletAddress,
        reason,
        timestamp: new Date().toISOString()
      };

    } catch (error) {
      console.error('Token distribution failed:', error);
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

        // Add small delay to prevent nonce issues
        await new Promise(resolve => setTimeout(resolve, 1000));
        
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
   * Mint new tokens (if your contract supports it)
   * @param {string} recipientAddress - Address to mint tokens to
   * @param {number} tokenAmount - Amount of tokens to mint
   * @returns {Object} - Transaction result
   */
  async mintTokens(recipientAddress, tokenAmount) {
    try {
      if (!this.tokenContract || !this.adminWallet) {
        throw new Error('Blockchain service not properly initialized');
      }

      // Get token decimals
      const decimals = await this.tokenContract.decimals();
      const tokenAmountWei = ethers.parseUnits(tokenAmount.toString(), decimals);

      // Mint tokens
      const tx = await this.tokenContract.mint(recipientAddress, tokenAmountWei, {
        gasLimit: this.config.GAS_LIMIT * 2, // Higher gas limit for minting
        maxFeePerGas: this.config.MAX_FEE_PER_GAS,
        maxPriorityFeePerGas: this.config.MAX_PRIORITY_FEE_PER_GAS,
      });

      const receipt = await tx.wait();

      return {
        success: true,
        transactionHash: receipt.hash,
        blockNumber: receipt.blockNumber,
        gasUsed: receipt.gasUsed.toString(),
        tokenAmount,
        recipientAddress,
        timestamp: new Date().toISOString()
      };

    } catch (error) {
      console.error('Token minting failed:', error);
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
   * @param {string} userWalletAddress - User's wallet address
   * @returns {Object} - Balance information
   */
  async getUserTokenBalance(userWalletAddress) {
    try {
      if (!this.tokenContract) {
        throw new Error('Token contract not initialized');
      }

      const balanceWei = await this.tokenContract.balanceOf(userWalletAddress);
      const decimals = await this.tokenContract.decimals();
      const balance = parseFloat(ethers.formatUnits(balanceWei, decimals));

      return {
        success: true,
        balance,
        balanceWei: balanceWei.toString(),
        walletAddress: userWalletAddress,
        tokenSymbol: this.config.TOKEN_SYMBOL
      };

    } catch (error) {
      console.error('Failed to get user balance:', error);
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
      if (!this.tokenContract) {
        throw new Error('Token contract not initialized');
      }

      const [name, symbol, decimals, totalSupply] = await Promise.all([
        this.tokenContract.name(),
        this.tokenContract.symbol(),
        this.tokenContract.decimals(),
        this.tokenContract.totalSupply()
      ]);

      return {
        success: true,
        name,
        symbol,
        decimals: decimals.toString(),
        totalSupply: ethers.formatUnits(totalSupply, decimals),
        contractAddress: this.config.TOKEN_CONTRACT_ADDRESS
      };

    } catch (error) {
      console.error('Failed to get token info:', error);
      return {
        success: false,
        error: error.message
      };
    }
  }

  /**
   * Get transaction status
   * @param {string} transactionHash - Transaction hash to check
   * @returns {Object} - Transaction status
   */
  async getTransactionStatus(transactionHash) {
    try {
      const receipt = await this.provider.getTransactionReceipt(transactionHash);
      
      if (!receipt) {
        return {
          success: true,
          status: 'pending',
          transactionHash
        };
      }

      return {
        success: true,
        status: receipt.status === 1 ? 'confirmed' : 'failed',
        blockNumber: receipt.blockNumber,
        gasUsed: receipt.gasUsed.toString(),
        transactionHash,
        confirmations: await this.provider.getBlockNumber() - receipt.blockNumber
      };

    } catch (error) {
      console.error('Failed to get transaction status:', error);
      return {
        success: false,
        error: error.message,
        transactionHash
      };
    }
  }

  /**
   * Get current gas prices
   * @returns {Object} - Current gas prices
   */
  async getGasPrices() {
    try {
      const feeData = await this.provider.getFeeData();
      
      return {
        success: true,
        gasPrice: feeData.gasPrice ? ethers.formatUnits(feeData.gasPrice, 'gwei') : null,
        maxFeePerGas: feeData.maxFeePerGas ? ethers.formatUnits(feeData.maxFeePerGas, 'gwei') : null,
        maxPriorityFeePerGas: feeData.maxPriorityFeePerGas ? ethers.formatUnits(feeData.maxPriorityFeePerGas, 'gwei') : null
      };

    } catch (error) {
      console.error('Failed to get gas prices:', error);
      return {
        success: false,
        error: error.message
      };
    }
  }

  /**
   * Estimate gas for token transfer
   * @param {string} toAddress - Recipient address
   * @param {number} tokenAmount - Amount to transfer
   * @returns {Object} - Gas estimate
   */
  async estimateTransferGas(toAddress, tokenAmount) {
    try {
      if (!this.tokenContract) {
        throw new Error('Token contract not initialized');
      }

      const decimals = await this.tokenContract.decimals();
      const tokenAmountWei = ethers.parseUnits(tokenAmount.toString(), decimals);

      const gasEstimate = await this.tokenContract.transfer.estimateGas(toAddress, tokenAmountWei);

      return {
        success: true,
        gasEstimate: gasEstimate.toString(),
        tokenAmount,
        toAddress
      };

    } catch (error) {
      console.error('Failed to estimate gas:', error);
      return {
        success: false,
        error: error.message
      };
    }
  }

  /**
   * Validate wallet address format
   * @param {string} address - Wallet address to validate
   * @returns {boolean} - Whether address is valid
   */
  isValidAddress(address) {
    return ethers.isAddress(address);
  }

  /**
   * Get network information
   * @returns {Object} - Network details
   */
  async getNetworkInfo() {
    try {
      const network = await this.provider.getNetwork();
      const blockNumber = await this.provider.getBlockNumber();

      return {
        success: true,
        chainId: network.chainId.toString(),
        name: network.name,
        currentBlock: blockNumber,
        rpcUrl: this.config.NETWORK_RPC_URL
      };

    } catch (error) {
      console.error('Failed to get network info:', error);
      return {
        success: false,
        error: error.message
      };
    }
  }
}

module.exports = BlockchainService;
