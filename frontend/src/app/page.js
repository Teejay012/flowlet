'use client';

import React from 'react';
import { motion } from 'framer-motion';
import Link from 'next/link';

const Home = () => {
  return (
    <section className="flex flex-col items-center justify-center text-center h-[80vh] px-6">
      {/* Hero Heading */}
      <motion.h1
        initial={{ opacity: 0, y: 40 }}
        animate={{ opacity: 1, y: 0 }}
        transition={{ duration: 0.8 }}
        className="text-4xl md:text-6xl font-extrabold text-[#F1F5F9] leading-tight"
      >
        Flowlet
        <span className="block text-transparent bg-clip-text bg-gradient-to-r from-[#2DD4BF] to-[#8B5CF6] mt-2">
          Smart Wallets. Gasless. Secure.
        </span>
      </motion.h1>

      {/* Subtext */}
      <motion.p
        initial={{ opacity: 0 }}
        animate={{ opacity: 1 }}
        transition={{ delay: 0.4, duration: 0.8 }}
        className="text-[#94A3B8] mt-6 max-w-xl text-lg md:text-xl"
      >
        Flowlet lets you create and control smart contract wallets that pay gas in USDC — powered by a seamless Web3 UX.
      </motion.p>

      {/* Buttons */}
      <motion.div
        initial={{ opacity: 0, y: 20 }}
        animate={{ opacity: 1, y: 0 }}
        transition={{ delay: 0.7, duration: 0.6 }}
        className="mt-10 flex flex-col md:flex-row gap-4"
      >
        {/* Get Started */}
        <Link
          href="/create-wallet"
          className="inline-block px-8 py-3 text-lg font-semibold rounded-xl shadow-lg
          bg-gradient-to-r from-[#7C3AED] to-[#8B5CF6] text-white hover:scale-105 transition-transform"
        >
          Get Started
        </Link>

        {/* Read Guide */}
        <Link
          href="/onboarding"
          className="inline-block px-8 py-3 text-lg font-semibold rounded-xl border border-[#2DD4BF] text-[#2DD4BF] hover:bg-[#2DD4BF]/10 transition"
        >
          Read Guide
        </Link>
      </motion.div>
    </section>
  );
};

export default Home;
