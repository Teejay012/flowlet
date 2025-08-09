"use client";
import { useEffect } from "react";
import { motion, AnimatePresence } from "framer-motion";
import { X, Copy } from "lucide-react";
import Button from "./Button";
import Input from "./Input";

export default function TransactionModal({ open, onClose, token, walletAddress = "0x1234...abcd" }) {
  useEffect(() => {
    const handleEsc = (e) => {
      if (e.key === "Escape") onClose();
    };
    document.addEventListener("keydown", handleEsc);
    return () => document.removeEventListener("keydown", handleEsc);
  }, [onClose]);

  const copyToClipboard = () => {
    navigator.clipboard.writeText(walletAddress);
  };

  return (
    <AnimatePresence>
      {open && token && (
        <motion.div
          className="fixed inset-0 bg-black/60 z-50 flex items-center justify-center"
          initial={{ opacity: 0 }}
          animate={{ opacity: 1 }}
          exit={{ opacity: 0 }}
        >
          <motion.div
            className="bg-gray-900 text-white p-6 rounded-xl w-[90%] max-w-md shadow-lg relative"
            initial={{ y: 100, opacity: 0 }}
            animate={{ y: 0, opacity: 1 }}
            exit={{ y: 100, opacity: 0 }}
          >
            <button onClick={onClose} className="absolute top-4 right-4">
              <X size={20} />
            </button>
            <h2 className="text-xl font-semibold mb-2">
              {token.name} ({token.symbol})
            </h2>
            <p className="text-sm text-gray-400 mb-4">Balance: {token.balance}</p>

            {/* Deposit */}
            <div className="mb-4">
              <h3 className="text-lg font-medium mb-2">Deposit</h3>
              <div className="flex items-center bg-gray-800 px-4 py-2 rounded-md justify-between">
                <span className="text-sm break-all">{walletAddress}</span>
                <button onClick={copyToClipboard}>
                  <Copy size={16} />
                </button>
              </div>
            </div>

            {/* Send */}
            <div>
              <h3 className="text-lg font-medium mb-2">Send</h3>
              <div className="flex flex-col gap-3">
                <Input placeholder="Recipient Address" />
                <Input placeholder="Amount" />
                <Button className="bg-[#2DD4BF] hover:bg-[#2DD4BF]">Send</Button>
              </div>
            </div>
          </motion.div>
        </motion.div>
      )}
    </AnimatePresence>
  );
}
