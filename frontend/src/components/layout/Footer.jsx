import React from 'react';
import Link from 'next/link';

const Footer = () => {
  return (
    <footer className="w-full bg-[#0F172A] border-t border-[#1E293B] px-6 py-10 backdrop-blur-sm">
      <div className="max-w-7xl mx-auto grid grid-cols-1 md:grid-cols-3 gap-10 text-[#F1F5F9]">
        {/* About Flowlet */}
        <div>
          <h3 className="text-xl font-semibold mb-4 text-[#2DD4BF]">About Flowlet</h3>
          <p className="text-[#94A3B8] text-sm leading-relaxed">
            Flowlet is a smart contract wallet platform that enables secure, gasless, and modern Web3 interactions. Built for developers and users who want control and seamless UX.
          </p>
        </div>

        {/* Important Links */}
        <div>
          <h3 className="text-xl font-semibold mb-4 text-[#2DD4BF]">Important Links</h3>
          <ul className="space-y-2 text-sm">
            <li>
              <Link href="/" className="text-[#94A3B8] hover:text-[#2DD4BF] transition">
                Home
              </Link>
            </li>
            <li>
              <Link href="/create-wallet" className="text-[#94A3B8] hover:text-[#2DD4BF] transition">
                Create Wallet
              </Link>
            </li>
            <li>
              <Link href="/dashboard" className="text-[#94A3B8] hover:text-[#2DD4BF] transition">
                Dashboard
              </Link>
            </li>
            <li>
              <Link href="/send" className="text-[#94A3B8] hover:text-[#2DD4BF] transition">
                Send
              </Link>
            </li>
            <li>
              <Link href="/onboarding" className="text-[#94A3B8] hover:text-[#2DD4BF] transition">
                Guide
              </Link>
            </li>
          </ul>
        </div>

        {/* Newsletter or Socials */}
        <div>
          <h3 className="text-xl font-semibold mb-4 text-[#2DD4BF]">Stay Updated</h3>
          <p className="text-[#94A3B8] text-sm mb-3">
            Join our newsletter to get the latest updates and releases.
          </p>
          <form className="flex flex-col sm:flex-row items-center gap-2">
            <input
              type="email"
              placeholder="Your email"
              className="w-full px-4 py-2 rounded-lg bg-[#1E293B] text-white placeholder-[#94A3B8] focus:outline-none"
            />
            <button
              type="submit"
              className="px-5 py-2 bg-gradient-to-r from-[#7C3AED] to-[#8B5CF6] rounded-lg text-white font-medium hover:scale-105 transition"
            >
              Subscribe
            </button>
          </form>
        </div>
      </div>

      {/* Bottom */}
      <div className="mt-12 text-center text-xs text-[#94A3B8]">
        &copy; {new Date().getFullYear()} Flowlet. All rights reserved.
      </div>
    </footer>
  );
};

export default Footer;
