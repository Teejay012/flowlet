import React from 'react';
import ConnectWalletBtn from '@/components/ui/ConnectWalletBtn';

const Navbar = () => {
  return (
    <nav className="w-full px-6 py-4 bg-[#0F172A] flex items-center justify-between shadow-md backdrop-blur z-50">
      {/* Logo */}
      <div className="text-[#F1F5F9] text-2xl font-bold tracking-wide">
        Flowlet
      </div>

      {/* Optional Center Nav - Can be expanded later */}
      {/* <div className="hidden md:flex gap-6 text-[#F1F5F9]">
        <a href="/dashboard" className="hover:text-[#2DD4BF] transition">
          Dashboard
        </a>
        <a href="/send" className="hover:text-[#2DD4BF] transition">
          Send
        </a>
        <a href="/transactions" className="hover:text-[#2DD4BF] transition">
          Transactions
        </a>
      </div> */}

      {/* Connect Wallet Button */}
      <ConnectWalletBtn />
    </nav>
  );
};

export default Navbar;