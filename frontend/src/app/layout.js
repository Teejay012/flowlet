import './globals.css';
import Navbar from '@/components/layout/Navbar';
import Footer from '@/components/layout/Footer';

export const metadata = {
  title: 'Flowlet',
  description: 'Smart Wallet. Gasless. Beautiful.',
};

export default function RootLayout({ children }) {
  return (
    <html lang="en">
      <body className="bg-[#0F172A] text-[#F1F5F9] min-h-screen">
        <Navbar />
        <main className="px-4 sm:px-6 md:px-12 lg:px-20 py-8">{children}</main>
        <Footer />
      </body>
    </html>
  );
}