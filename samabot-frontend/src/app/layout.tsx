import type { Metadata } from "next";
import "./globals.css";

export const metadata: Metadata = {
  title: "SAMABOT Industrial",
  description: "Sistema de Monitoreo Industrial con IA",
};

export default function RootLayout({
  children,
}: Readonly<{
  children: React.ReactNode;
}>) {
  return (
    <html lang="es">
      <body className="antialiased">
        {children}
      </body>
    </html>
  );
}
