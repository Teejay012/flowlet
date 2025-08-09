import React from 'react';

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
      <button
        className="bg-gradient-to-r from-[#7C3AED] to-[#8B5CF6] text-white px-5 py-2 rounded-xl font-semibold shadow-lg hover:scale-105 transition-transform backdrop-blur-md cursor-pointer"
      >
        Connect Wallet
      </button>
    </nav>
  );
};

export default Navbar;
