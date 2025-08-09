// "use client";

// import { Dialog, DialogContent, DialogHeader, DialogTitle } from "@/components/ui/dialog";
// import Button from "@/components/ui/Button";
// import { Wallet, ArrowUpRight, ArrowDownLeft } from "lucide-react";

// export default function TokenModal({ open, onClose, token }) {
//   if (!token) return null;

//   return (
//     <Dialog open={open} onOpenChange={onClose}>
//       <DialogContent className="bg-white dark:bg-gray-900 text-black dark:text-white">
//         <DialogHeader>
//           <DialogTitle className="text-lg font-semibold">
//             {token.name} ({token.symbol}) Actions
//           </DialogTitle>
//         </DialogHeader>

//         <div className="space-y-4 mt-2">
//           <p className="text-sm text-gray-500 dark:text-gray-400">Balance: {token.balance}</p>

//           <div className="flex justify-between gap-4">
//             <Button className="w-full flex items-center justify-center gap-2 bg-blue-600 hover:bg-blue-700 text-white">
//               <ArrowUpRight size={16} />
//               Send
//             </Button>

//             <Button className="w-full flex items-center justify-center gap-2 bg-green-600 hover:bg-green-700 text-white">
//               <ArrowDownLeft size={16} />
//               Receive
//             </Button>
//           </div>
//         </div>
//       </DialogContent>
//     </Dialog>
//   );
// }
