import type { Metadata } from "next";
import "./globals.css";
import { SiteFooter, SiteHeader, WhatsAppButton } from "@/components/SiteChrome";

export const metadata: Metadata = {
  title: "Sonríe Dental",
  description: "Clínica dental demo con agenda online, proceso y guía para pacientes.",
};

export default function RootLayout({
  children,
}: Readonly<{
  children: React.ReactNode;
}>) {
  return (
    <html lang="es">
      <body className="min-h-screen bg-[#fffffa] text-slate-900">
        <div className="flex min-h-screen flex-col">
          <SiteHeader />
          <main className="flex-1">{children}</main>
          <SiteFooter />
          <WhatsAppButton />
        </div>
      </body>
    </html>
  );
}
