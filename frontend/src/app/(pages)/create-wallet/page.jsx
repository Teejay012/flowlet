"use client"
import { useState } from "react";
import { motion } from "framer-motion";
import Input from "@/components/ui/Input";
import Button from "@/components/ui/Button";

export default function CreateWalletPage() {
  const [salt, setSalt] = useState("");

  const handleCreateWallet = () => {
    // Placeholder functionality
    console.log("Create wallet with salt:", salt);
  };

  const handleRetrieveWallet = () => {
    // Placeholder functionality
    console.log("Retrieve wallet with salt:", salt);
  };

  return (
    <main className="min-h-screen bg-gradient-to-b from-[#02050e] to-[#0f172a] flex items-center justify-center px-4 py-16">
      <motion.div
        initial={{ opacity: 0, y: 50 }}
        animate={{ opacity: 1, y: 0 }}
        transition={{ duration: 0.5 }}
        className="w-full max-w-md bg-[#0f172a] rounded-2xl shadow-xl p-8 border border-[#1e293b]"
      >
        <h1 className="text-2xl font-bold text-white mb-6 text-center">Create or Retrieve Wallet</h1>
        <p className="text-sm text-slate-300 text-center mb-4">
          Use a unique salt (like a pin or passphrase). You can either create a new wallet or retrieve an existing one.
        </p>
        <Input
          value={salt}
          onChange={(e) => setSalt(e.target.value)}
          placeholder="Enter your salt (pin/passphrase)"
          className="mb-4 bg-[#1e293b] text-white placeholder:text-slate-400 border border-slate-700 focus-visible:ring-2 focus-visible:ring-[#2DD4BF]"
        />
        <div className="flex gap-4 mb-6">
          <Button
            onClick={handleCreateWallet}
            className="w-full bg-gradient-to-r from-[#7C3AED] to-[#8B5CF6] hover:bg-[#2DD4BF] text-white cursor-pointer"
          >
            Create Wallet
          </Button>
          <Button
            onClick={handleRetrieveWallet}
            variant="outline"
            className="w-full border border-[#2DD4BF] text-[#2DD4BF] hover:bg-[#2DD4BF] hover:text-white cursor-pointer"
          >
            Retrieve Wallet
          </Button>
        </div>
        <div className="text-xs text-center text-slate-400">
          ⚠️ Note: <span className="text-white font-medium">USDC</span> is used as gas, deposit <span className="text-white font-medium">USDC</span> to the generated wallet address.
        </div>
      </motion.div>
    </main>
  );
}
