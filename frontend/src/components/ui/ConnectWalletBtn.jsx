// components/ConnectWalletBtn.jsx
"use client"
import React, { useState } from 'react';
import { useFlowletState } from '@/hooks/contexts/FlowletProvider';

export default function ConnectWalletBtn({ className = '' }) {
  const {
    walletAddress,
    connectWallet,
    disconnectWallet,
    isConnecting,
    networkName,
  } = useFlowletState();

  const formatAddress = (addr) => addr.slice(0, 6) + '...' + addr.slice(-4);

  if (walletAddress) {
    return (
      <div className={`flex items-center space-x-2 ${className}`}>
        <span className="text-[#E4F3FF] font-semibold bg-[#00C0FF]/20 px-3 py-1 rounded-xl">
          {formatAddress(walletAddress)}
        </span>
        <span className="text-xs text-[#9CA3AF] italic">
          {networkName ? `(${networkName})` : '...'}
        </span>
        <button
          onClick={disconnectWallet}
          className="bg-red-500 hover:bg-red-600 text-white font-semibold px-3 py-2 rounded-xl cursor-pointer transition-colors"
        >
          Disconnect
        </button>
      </div>
    );
  }

  return (
    <button
      onClick={connectWallet}
      disabled={isConnecting}
      className={`bg-gradient-to-r from-[#7C3AED] to-[#8B5CF6] hover:from-[#6D28D9] hover:to-[#7C3AED] text-white font-semibold px-5 py-2 rounded-xl transition-all duration-300 cursor-pointer disabled:opacity-50 disabled:cursor-not-allowed ${className}`}
    >
      {isConnecting ? 'Connecting...' : 'Connect Wallet'}
    </button>
  );
}