"use client";

import Link from "next/link";
import { usePathname } from "next/navigation";
import { CLINIC, NAV_LINKS } from "@/lib/data";

export function SiteHeader() {
  const pathname = usePathname();

  return (
    <>
      <div className="bg-[#0055e3] px-4 py-2 text-center text-sm font-semibold text-white">
        {CLINIC.promo}{" "}
        <Link href="/agendar" className="underline">AGENDAR AHORA</Link>
        {" · "}
        <a href={`https://wa.me/${CLINIC.phone}`} target="_blank" rel="noopener noreferrer" className="underline">
          WHATSAPP
        </a>
      </div>
      <header className="sticky top-0 z-30 border-b border-blue-100 bg-[rgba(255,255,250,0.95)] backdrop-blur">
        <div className="mx-auto flex max-w-6xl items-center justify-between gap-6 px-4 py-4">
          <Link href="/" className="flex items-center gap-3">
            <div className="grid h-10 w-10 place-items-center rounded-full bg-[#0055e3] font-bold text-white">S</div>
            <div>
              <div className="text-lg font-bold text-[#0055e3]">{CLINIC.name}</div>
              <div className="text-xs text-slate-500">{CLINIC.tagline}</div>
            </div>
          </Link>
          <nav className="hidden items-center gap-5 text-sm font-semibold text-slate-700 lg:flex">
            {NAV_LINKS.map((link) => (
              <Link key={link.href} href={link.href} className={pathname === link.href ? "text-[#0055e3]" : "hover:text-[#0055e3]"}>
                {link.label}
              </Link>
            ))}
            <Link href="/agendar" className="rounded-full bg-[#0055e3] px-5 py-2.5 text-white">Agendar cita</Link>
          </nav>
        </div>
      </header>
    </>
  );
}

export function SiteFooter() {
  return (
    <footer className="mt-auto bg-[#0055e3] text-white">
      <div className="mx-auto grid max-w-6xl gap-8 px-4 py-12 md:grid-cols-4">
        <div>
          <h4 className="text-xl font-bold">{CLINIC.name}</h4>
          <p className="mt-2 text-sm text-blue-100">Sonrisas saludables para todos</p>
        </div>
        <div>
          <h4 className="font-semibold">Clínica</h4>
          <ul className="mt-2 space-y-1 text-sm text-blue-100">
            {NAV_LINKS.map((link) => (
              <li key={link.href}><Link href={link.href}>{link.label}</Link></li>
            ))}
            <li><Link href="/agendar">Agendar cita</Link></li>
          </ul>
        </div>
        <div>
          <h4 className="font-semibold">Contacto</h4>
          <p className="mt-2 text-sm text-blue-100">{CLINIC.email}</p>
          <p className="text-sm text-blue-100">+52 81 1234 5678</p>
        </div>
        <div>
          <h4 className="font-semibold">Legal</h4>
          <p className="mt-2 text-sm text-blue-100">Aviso de privacidad</p>
          <p className="text-sm text-blue-100">Términos y condiciones</p>
        </div>
      </div>
      <div className="border-t border-blue-400 px-4 py-4 text-center text-xs text-blue-100">
        Demo educativa — no es un sitio médico real
      </div>
    </footer>
  );
}

export function WhatsAppButton() {
  return (
    <a
      href={`https://wa.me/${CLINIC.phone}`}
      target="_blank"
      rel="noopener noreferrer"
      className="fixed bottom-6 right-6 z-40 grid h-14 w-14 place-items-center rounded-full bg-[#25D366] text-2xl text-white shadow-lg"
      aria-label="WhatsApp"
    >
      ✆
    </a>
  );
}
