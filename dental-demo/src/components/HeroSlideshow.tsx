"use client";

import Image from "next/image";
import Link from "next/link";
import { useEffect, useState } from "react";
import { HERO_SLIDES } from "@/lib/data";

export function HeroSlideshow() {
  const [active, setActive] = useState(0);

  useEffect(() => {
    const timer = setInterval(() => {
      setActive((current) => (current + 1) % HERO_SLIDES.length);
    }, 5000);
    return () => clearInterval(timer);
  }, []);

  return (
    <section className="relative overflow-hidden bg-[#fffffa] px-4 pt-8 md:pt-10">
      <div className="mx-auto max-w-6xl overflow-hidden rounded-[32px] border border-blue-100 shadow-sm">
        <div className={`relative bg-gradient-to-br ${HERO_SLIDES[active].theme} min-h-[420px] text-white md:min-h-[520px]`}>
          <Image
            src={HERO_SLIDES[active].image}
            alt={HERO_SLIDES[active].title}
            fill
            priority
            className="object-cover opacity-55"
            sizes="(max-width: 1024px) 100vw, 1120px"
          />
          <div className="absolute inset-0 bg-[radial-gradient(circle_at_top_left,rgba(255,255,255,0.25),transparent_30%),radial-gradient(circle_at_bottom_right,rgba(255,255,255,0.18),transparent_28%)]" />
          <div className="absolute inset-0 bg-slate-950/18" />
          <div className="relative z-10 grid min-h-[420px] gap-8 p-8 md:min-h-[520px] md:grid-cols-[1.1fr_0.9fr] md:p-12">
            <div className="flex flex-col justify-center">
              <span className="inline-block w-fit rounded-full bg-white/20 px-4 py-2 text-sm font-semibold backdrop-blur">
                Agenda online 24/7
              </span>
              <h1 className="mt-5 text-4xl font-bold leading-tight md:text-6xl">
                {HERO_SLIDES[active].title}
              </h1>
              <p className="mt-5 max-w-2xl text-base leading-8 text-blue-50 md:text-lg">
                {HERO_SLIDES[active].subtitle}
              </p>
              <div className="mt-8 flex flex-wrap gap-3">
                <Link href="/agendar" className="rounded-full bg-white px-8 py-3 font-semibold text-[#0055e3]">
                  Agendar cita en línea
                </Link>
                <Link href="/guia-pacientes" className="rounded-full border-2 border-white px-8 py-3 font-semibold text-white">
                  Guía para pacientes
                </Link>
              </div>
            </div>

            <div className="grid content-end gap-3 md:grid-cols-2">
              <div className="rounded-3xl bg-white/16 p-5 backdrop-blur">
                <div className="text-3xl font-bold">3</div>
                <div className="mt-1 text-sm text-blue-50">Sucursales</div>
              </div>
              <div className="rounded-3xl bg-white/16 p-5 backdrop-blur">
                <div className="text-3xl font-bold">24/7</div>
                <div className="mt-1 text-sm text-blue-50">Agenda online</div>
              </div>
              <div className="rounded-3xl bg-white/16 p-5 backdrop-blur">
                <div className="text-3xl font-bold">WA</div>
                <div className="mt-1 text-sm text-blue-50">Recordatorios</div>
              </div>
              <div className="rounded-3xl bg-white/16 p-5 backdrop-blur">
                <div className="text-3xl font-bold">1 clic</div>
                <div className="mt-1 text-sm text-blue-50">Calendario</div>
              </div>
            </div>
          </div>

          <div className="absolute bottom-5 left-1/2 z-10 flex -translate-x-1/2 gap-2">
            {HERO_SLIDES.map((slide, index) => (
              <button
                key={slide.id}
                type="button"
                aria-label={`Ir al slide ${index + 1}`}
                onClick={() => setActive(index)}
                className={`h-2.5 rounded-full transition-all ${index === active ? "w-8 bg-white" : "w-2.5 bg-white/45"}`}
              />
            ))}
          </div>
        </div>
      </div>
    </section>
  );
}
