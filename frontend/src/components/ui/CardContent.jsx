
export function CardContent({ className, ...props }) {
  return (
    <div
      className={("p-2 text-sm text-gray-300", className)}
      {...props}
    />
  );
}