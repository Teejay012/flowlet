"use client";

import { useState } from "react";
import { Copy, Home, PlusCircle, Settings } from "lucide-react";
import Button from "@/components/ui/Button";
import { Card } from "@/components/ui/Card";
import { toast } from "sonner";

export default function Sidebar() {
  const [walletAddress] = useState("0xAbCd...1234");

  const handleCopy = () => {
    navigator.clipboard.writeText(walletAddress);
    toast.success("Address copied!");
  };

  return (
    <div className="min-h-screen bg-gray-100 dark:bg-gray-900 border-r px-2 py-4 w-16 md:w-64 transition-all duration-300">
      {/* Wallet Address Card */}
      <div className="mb-6">
        <Card className="md:p-4 bg-white dark:bg-gray-800">
          <div className="md:flex md:items-center md:justify-between">
            <div className="hidden md:block">
              <p className="text-xs text-muted-foreground">Your Wallet Address</p>
              <p className="font-mono text-sm font-semibold">{walletAddress}</p>
            </div>
            <Button size="icon" onClick={handleCopy}>
              <Copy className="w-4 h-4" />
            </Button>
          </div>
        </Card>
      </div>

      {/* Navigation */}
      <nav className="space-y-2 flex flex-col items-center md:items-start">
        <Button className="w-full md:flex md:justify-start">
          <Home className="w-5 h-5 mr-0 md:mr-2" />
          <span className="hidden md:inline">Dashboard</span>
        </Button>
        <Button className="w-full md:flex md:justify-start">
          <PlusCircle className="w-5 h-5 mr-0 md:mr-2" />
          <span className="hidden md:inline">Add Token</span>
        </Button>
        <Button className="w-full md:flex md:justify-start">
          <Settings className="w-5 h-5 mr-0 md:mr-2" />
          <span className="hidden md:inline">Settings</span>
        </Button>
      </nav>
    </div>
  );
}
