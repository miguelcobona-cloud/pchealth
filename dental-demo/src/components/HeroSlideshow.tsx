"use client";

import Image from "next/image";
import Link from "next/link";
import { useCallback, useEffect, useState } from "react";
import { CLINIC, HERO_SLIDES } from "@/lib/data";

export function HeroSlideshow() {
  const [active, setActive] = useState(0);
  const total = HERO_SLIDES.length;

  const goTo = useCallback((index: number) => {
    setActive((index + total) % total);
  }, [total]);

  const goNext = useCallback(() => goTo(active + 1), [active, goTo]);
  const goPrev = useCallback(() => goTo(active - 1), [active, goTo]);

  useEffect(() => {
    const timer = setInterval(goNext, 6000);
    return () => clearInterval(timer);
  }, [goNext]);

  return (
    <section className="relative overflow-hidden bg-[#0a2f7a]">
      <div className="relative min-h-[480px] md:min-h-[560px]">
        {HERO_SLIDES.map((slide, index) => (
          <div
            key={slide.id}
            className={`absolute inset-0 transition-opacity duration-700 ${index === active ? "opacity-100" : "pointer-events-none opacity-0"}`}
            aria-hidden={index !== active}
          >
            <Image
              src={slide.image}
              alt={slide.title}
              fill
              priority={index === 0}
              className="object-cover"
              sizes="100vw"
            />
            <div className="absolute inset-0 bg-gradient-to-b from-black/45 via-black/35 to-black/55" />
          </div>
        ))}

        <div className="relative z-10 mx-auto flex min-h-[480px] max-w-4xl flex-col items-center justify-center px-6 py-16 text-center text-white md:min-h-[560px] md:px-8">
          <span className="rounded-full bg-[#0055e3] px-5 py-2 text-sm font-semibold tracking-wide">
            {CLINIC.promo}
          </span>
          <h1 className="mt-6 text-4xl font-bold leading-tight md:text-6xl">
            {HERO_SLIDES[active].title}
          </h1>
          <p className="mt-5 max-w-2xl text-base leading-8 text-blue-50 md:text-lg">
            {HERO_SLIDES[active].subtitle}
          </p>
          <div className="mt-8 flex flex-wrap items-center justify-center gap-4">
            <Link
              href="/agendar"
              className="rounded-full bg-white px-8 py-3 font-semibold text-[#0055e3] transition hover:bg-blue-50"
            >
              Agendar cita en línea
            </Link>
            <a
              href={`https://wa.me/${CLINIC.phone}`}
              target="_blank"
              rel="noopener noreferrer"
              className="rounded-full border-2 border-white px-8 py-3 font-semibold text-white transition hover:bg-white/10"
            >
              WhatsApp
            </a>
          </div>
        </div>

        <button
          type="button"
          onClick={goPrev}
          aria-label="Slide anterior"
          className="absolute left-4 top-1/2 z-20 grid h-11 w-11 -translate-y-1/2 place-items-center rounded-full bg-white/90 text-xl text-slate-700 shadow-md transition hover:bg-white md:left-8"
        >
          ‹
        </button>
        <button
          type="button"
          onClick={goNext}
          aria-label="Slide siguiente"
          className="absolute right-4 top-1/2 z-20 grid h-11 w-11 -translate-y-1/2 place-items-center rounded-full bg-white/90 text-xl text-slate-700 shadow-md transition hover:bg-white md:right-8"
        >
          ›
        </button>

        <div className="absolute bottom-6 left-1/2 z-20 flex -translate-x-1/2 gap-2">
          {HERO_SLIDES.map((slide, index) => (
            <button
              key={slide.id}
              type="button"
              aria-label={`Ir al slide ${index + 1}`}
              aria-current={index === active}
              onClick={() => goTo(index)}
              className={`h-2.5 rounded-full transition-all ${index === active ? "w-8 bg-white" : "w-2.5 bg-white/50"}`}
            />
          ))}
        </div>
      </div>
    </section>
  );
}
