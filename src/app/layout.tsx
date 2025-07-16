import type { Metadata } from "next";
import { Inter, VT323 } from "next/font/google";
import "./globals.css";

const inter = Inter({ subsets: ["latin"] });
const vt323 = VT323({ 
  weight: "400",
  subsets: ["latin"],
  variable: "--font-vt323"
});

export const metadata: Metadata = {
  title: "SAMABOT Industrial",
  description: "Sistema de Monitoreo Industrial con SAMITA AI",
};

export default function RootLayout({
  children,
}: Readonly<{
  children: React.ReactNode;
}>) {
  return (
    <html lang="es">
      <body className={`${inter.className} ${vt323.className}`}>
        {children}
      </body>
    </html>
  );
} 