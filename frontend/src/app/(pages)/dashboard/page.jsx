"use client";
import { useState } from "react";
import Button from "@/components/ui/Button";
import Input from "@/components/ui/Input";
import { Card } from "@/components/ui/Card";
import { CardContent } from "@/components/ui/CardContent";
import { Plus } from "lucide-react";
import { motion } from "framer-motion";
import Sidebar from "@/components/layout/Sidebar";
import TransactionModal from "@/components/ui/TransactionModal";

const tokens = [
  { name: "USDC", balance: "250.00", symbol: "USDC" },
  { name: "ETH", balance: "0.123", symbol: "ETH" },
];

const usdRates = {
  USDC: 1,
  ETH: 1800,
};

export default function Dashboard() {
  const [tokenAddress, setTokenAddress] = useState("");
  const [userTokens, setUserTokens] = useState(tokens);
  const [selectedToken, setSelectedToken] = useState(null);
  const [modalOpen, setModalOpen] = useState(false);

  const addToken = () => {
    if (!tokenAddress) return;
    setUserTokens((prev) => [
      ...prev,
      { name: "New Token", balance: "0.00", symbol: "NEW" },
    ]);
    setTokenAddress("");
  };

  const totalUsd = userTokens.reduce((acc, t) => {
    const rate = usdRates[t.symbol] || 0;
    return acc + parseFloat(t.balance) * rate;
  }, 0);

  const handleTokenClick = (token) => {
    setSelectedToken(token);
    setModalOpen(true);
  };

  return (
    <div className="flex min-h-screen">
      <Sidebar />

      <main className="flex-1 p-8 bg-gray-100 dark:bg-gray-950 text-white">
        <motion.h1
          className="text-3xl font-bold mb-4"
          initial={{ opacity: 0, y: -10 }}
          animate={{ opacity: 1, y: 0 }}
        >
          Dashboard
        </motion.h1>

        {/* Total Balance + Actions */}
        <div className="mb-8">
          <p className="text-lg text-gray-300 mb-4">
            Total Balance: ${totalUsd.toFixed(2)} USD
          </p>
          <div className="flex flex-wrap gap-4">
            <Button className="bg-[#2DD4BF] hover:bg-[#2DD4BF] flex items-center gap-2 px-4 py-2 rounded-lg">
              <svg xmlns="http://www.w3.org/2000/svg" className="h-4 w-4" fill="none"
                   viewBox="0 0 24 24" stroke="currentColor"><path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2}
                   d="M17 8l4 4m0 0l-4 4m4-4H3"/></svg>
              Send
            </Button>

            <Button className="bg-[#2DD4BF] hover:bg-[#2DD4BF] flex items-center gap-2 px-4 py-2 rounded-lg">
              <svg xmlns="http://www.w3.org/2000/svg" className="h-4 w-4 rotate-180" fill="none"
                   viewBox="0 0 24 24" stroke="currentColor"><path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2}
                   d="M17 8l4 4m0 0l-4 4m4-4H3"/></svg>
              Receive
            </Button>

            <Button className="bg-[#2DD4BF] hover:bg-[#2DD4BF] flex items-center gap-2 px-4 py-2 rounded-lg">
              <svg xmlns="http://www.w3.org/2000/svg" className="h-4 w-4" fill="none"
                   viewBox="0 0 24 24" stroke="currentColor"><path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2}
                   d="M4 4v6h6M20 20v-6h-6M4 20l6-6M20 4l-6 6"/></svg>
              Swap
            </Button>
          </div>
        </div>

        {/* Token List */}
        <section className="mb-8">
          <h2 className="text-xl font-semibold mb-4">Your Tokens</h2>
          <div className="grid grid-cols-1 sm:grid-cols-2 md:grid-cols-3 gap-4">
            {userTokens.map((token, index) => (
              <Card
                key={index}
                className="bg-gray-800 text-white cursor-pointer hover:bg-gray-700"
                onClick={() => handleTokenClick(token)}
              >
                <CardContent className="p-4">
                  <p className="text-lg font-semibold">{token.name}</p>
                  <p className="text-sm text-gray-400">Balance: {token.balance}</p>
                  <p className="text-sm text-gray-400">Symbol: {token.symbol}</p>
                </CardContent>
              </Card>
            ))}
          </div>
        </section>

        {/* Add Token */}
        <section className="mb-12">
          <h2 className="text-xl font-semibold mb-4">Add Token</h2>
          <div className="flex flex-col sm:flex-row items-center gap-4">
            <Input
              placeholder="Enter Token Address"
              value={tokenAddress}
              onChange={(e) => setTokenAddress(e.target.value)}
              className="bg-gray-800 text-white placeholder:text-gray-400"
            />
            <Button
              onClick={addToken}
              className="bg-[#2DD4BF] flex items-center justify-center hover:bg-[#2DD4BF] cursor-pointer"
            >
              <Plus size={16} className="mr-2" /> Add Token
            </Button>
          </div>
        </section>

        {/* Note */}
        <div className="text-sm text-gray-400">
          Note: You can only add supported ERC20 tokens manually for now.
        </div>
      </main>

      {/* Modal */}
      <TransactionModal
        open={modalOpen}
        onClose={() => setModalOpen(false)}
        token={selectedToken}
        walletAddress="0xYourWalletAddressHere"
      />
    </div>
  );
}
