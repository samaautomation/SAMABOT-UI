import type { Metadata } from "next";
import { Inter } from "next/font/google";
import "./globals.css";
import Header from "@/components/ui/Header";
import PLCPanel from "@/components/ui/PLCPanel";

const inter = Inter({ subsets: ["latin"] });

export const metadata: Metadata = {
  title: "SAMABOT UI",
  description: "Interfaz para control de PLC Siemens",
};

export default function RootLayout({
  children,
}: Readonly<{
  children: React.ReactNode;
}>) {
  return (
    <html lang="es">
      <body className={inter.className}>
        <Header />
        <main className="container mx-auto px-4 py-8">
          <PLCPanel />
          {children}
        </main>
      </body>
    </html>
  );
}
