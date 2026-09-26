import type { Metadata } from "next";
import { Inter } from "next/font/google";
import "./globals.css";
import { QueryProvider } from "@/components/provider/query-provider";
import { Toaster } from "sonner";

const inter = Inter({
  subsets: ["latin"],
  variable: "--font-inter",
});

export const metadata: Metadata = {
  title: "SaaS Starter Platform | Spring Boot 4 + Next.js 16",
  description: "Cross-stack SaaS boilerplate with Spring Boot 4, JWT OAuth2 RSA, and Next.js 16 App Router",
};

export default function RootLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  return (
    <html lang="vi" className={`${inter.variable} dark antialiased`}>
      <body className="min-h-screen bg-slate-950 text-slate-100 font-sans">
        <QueryProvider>
          {children}
          <Toaster richColors position="top-right" theme="dark" />
        </QueryProvider>
      </body>
    </html>
  );
}
