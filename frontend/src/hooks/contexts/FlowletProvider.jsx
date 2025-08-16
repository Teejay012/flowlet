'use client';

import React, { createContext, useContext, useState, useEffect } from 'react';
import { ethers } from 'ethers';
import toast from 'react-hot-toast';
import { useRouter, usePathname } from 'next/navigation';

import { SMART_WALLET_FACTORY } from '@/hooks/constants/contracts.js';
import { walletFactoryABI } from '@/hooks/constants/abis.js';
import { fetchContract } from '@/hooks/constants/fetchContract';

// 🏦 Factory helper
export const smartWalletFactory = (signerOrProvider) =>
  fetchContract(SMART_WALLET_FACTORY, walletFactoryABI, signerOrProvider);

const FlowletContext = createContext();

export const FlowletProvider = ({ children }) => {
  const [provider, setProvider] = useState(null);
  const [signer, setSigner] = useState(null);
  const [walletAddress, setWalletAddress] = useState(null);
  const [networkName, setNetworkName] = useState(null);
  const [isConnecting, setIsConnecting] = useState(false);
  const [smartAccount, setSmartAccount] = useState(null);

  const pathname = usePathname();
  const router = useRouter();

  // 🔌 Connect Wallet
  const connectWallet = async () => {
    if (!window.ethereum) {
      toast.error('MetaMask not detected!');
      return;
    }

    try {
      setIsConnecting(true);
      const _provider = new ethers.BrowserProvider(window.ethereum);
      await _provider.send('eth_requestAccounts', []);
      const _signer = await _provider.getSigner();
      const address = await _signer.getAddress();
      const network = await _provider.getNetwork();

      setProvider(_provider);
      setSigner(_signer);
      setWalletAddress(address);
      setNetworkName(network.name);

      toast.success(`Connected: ${address.slice(0, 6)}...${address.slice(-4)}`);
      toast(`Network: ${network.name}`, { icon: '🛰️' });

      if (pathname === '/') router.push('/dashboard');
    } catch (err) {
      console.error(err);
    } finally {
      setIsConnecting(false);
    }
  };

  // 🔌 Disconnect Wallet
  const disconnectWallet = () => {
    setProvider(null);
    setSigner(null);
    setWalletAddress(null);
    setNetworkName(null);
    setSmartAccount(null);
    localStorage.removeItem('smartAccount');
    toast.success('Disconnected');
  };



  // 🏗 Create Smart Account
  const createSmartAccount = async (salt = Date.now()) => {
    if (!signer) {
      toast.error('Connect wallet first!');
      return;
    }

    try {
      const factory = smartWalletFactory(signer);

      // Show loading toast
      const toastId = toast.loading('Creating SmartAccount...');
      const tx = await factory.createAccount(walletAddress, salt);
      const receipt = await tx.wait();
      toast.dismiss(toastId);

      // Extract AccountCreated event
      const event = receipt.logs
        .map(log => {
          try {
            return factory.interface.parseLog(log);
          } catch {
            return null;
          }
        })
        .find(parsed => parsed && parsed.name === "AccountCreated");

      if (!event) {
        toast.error('Account creation event not found.');
        return;
      }

      const smartAccountAddress = event.args.account;
      setSmartAccount(smartAccountAddress);

      // Save to localStorage
      localStorage.setItem('smartAccount', smartAccountAddress);

      toast.success(`SmartAccount created: ${smartAccountAddress}`);

      // Redirect to dashboard
      router.push('/dashboard');

      return smartAccountAddress;
    } catch (err) {
      console.error(err);
      toast.error('Error creating SmartAccount');
    }
  };

  // 🔁 Load Smart Account from localStorage
  useEffect(() => {
    const storedAccount = localStorage.getItem('smartAccount');
    if (storedAccount) {
      setSmartAccount(storedAccount);
      console.log(`Loaded Smart Account: ${storedAccount}`);
      router.push('/dashboard'); // ✅ redirect if already exists
    }
  }, []);

  // 🔁 Handle wallet & network changes
  useEffect(() => {
    if (!window.ethereum) return;

    const handleAccountsChanged = (accounts) => {
      if (accounts.length === 0) {
        disconnectWallet();
      } else {
        connectWallet();
      }
    };

    const handleChainChanged = () => {
      connectWallet();
    };

    window.ethereum.on('accountsChanged', handleAccountsChanged);
    window.ethereum.on('chainChanged', handleChainChanged);

    return () => {
      window.ethereum.removeListener('accountsChanged', handleAccountsChanged);
      window.ethereum.removeListener('chainChanged', handleChainChanged);
    };
  }, []);

  return (
    <FlowletContext.Provider
      value={{
        provider,
        signer,
        walletAddress,
        networkName,
        isConnecting,
        smartAccount,
        connectWallet,
        disconnectWallet,
        createSmartAccount,
      }}
    >
      {children}
    </FlowletContext.Provider>
  );
};

export const useFlowletState = () => useContext(FlowletContext);
