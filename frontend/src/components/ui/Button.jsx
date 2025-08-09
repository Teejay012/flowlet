// components/ui/Button.tsx
import React from "react";
import { motion } from "framer-motion";

const Button = ({ children, className = "", variant = "primary", ...props }) => {
  const baseStyles =
    "px-6 py-2 rounded-xl font-semibold transition-all focus:outline-none";
  const variants = {
    primary: "bg-gradient-to-r from-[#7C3AED] to-[#8B5CF6] text-white hover:bg-[#2DD4BF] dark:bg-[#2DD4BF] dark:text-white dark:hover:bg-[#2DD4BF]",
    secondary: "bg-gray-100 text-gray-800 hover:bg-gray-200 dark:bg-gray-800 dark:text-white dark:hover:bg-gray-700",
  };

  return (
    <motion.button
      whileTap={{ scale: 0.96 }}
      whileHover={{ scale: 1.02 }}
      className={`${baseStyles} ${variants[variant]} ${className}`}
      {...props}
    >
      {children}
    </motion.button>
  );
};

export default Button;
