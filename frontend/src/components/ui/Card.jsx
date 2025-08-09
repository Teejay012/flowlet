
export function Card({ className, ...props }) {
  return (
    <div
      className={(
        "bg-[#111827] border border-[#2f2f2f] rounded-2xl shadow-md p-4",
        className
      )}
      {...props}
    />
  );
}