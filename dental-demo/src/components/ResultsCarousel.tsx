"use client";

import Image from "next/image";
import { useEffect, useState } from "react";
import { RESULT_SLIDES } from "@/lib/data";

export function ResultsCarousel() {
  const [active, setActive] = useState(0);

  useEffect(() => {
    const timer = setInterval(() => {
      setActive((current) => (current + 1) % RESULT_SLIDES.length);
    }, 5500);
    return () => clearInterval(timer);
  }, []);

  return (
    <section className="overflow-hidden bg-[#fffffa] px-4 py-14" id="testimonios">
      <div className="mx-auto max-w-6xl">
        <div className="mx-auto max-w-3xl text-center">
          <h2 className="text-3xl font-bold md:text-4xl">Resultados reales, sonrisas reales</h2>
          <p className="mt-3 text-slate-600">
            Casos de blanqueamiento, limpieza y ortodoncia con una presentación clara y premium.
          </p>
        </div>

        <div className="mt-10 grid gap-6 lg:grid-cols-[1.1fr_0.9fr]">
          <div className={`min-h-[360px] rounded-[32px] bg-gradient-to-br ${RESULT_SLIDES[active].accent} p-8 shadow-sm`}>
            <div className="inline-block rounded-full bg-white/70 px-4 py-2 text-sm font-semibold text-[#0055e3]">
              {RESULT_SLIDES[active].treatment}
            </div>
            <div className="relative mt-8 h-[260px] overflow-hidden rounded-[28px] border-4 border-white/60 bg-white/30">
              <Image
                src={RESULT_SLIDES[active].image}
                alt={RESULT_SLIDES[active].treatment}
                fill
                className="object-contain"
                sizes="(max-width: 1024px) 100vw, 620px"
              />
            </div>
          </div>

          <div className="flex flex-col justify-between gap-4">
            {RESULT_SLIDES.map((slide, index) => (
              <button
                key={slide.id}
                type="button"
                onClick={() => setActive(index)}
                className={`rounded-[28px] border p-6 text-left shadow-sm transition ${index === active ? "border-[#0055e3] bg-blue-50" : "border-blue-100 bg-white"}`}
              >
                <div className="text-sm font-semibold uppercase tracking-[0.15em] text-[#0055e3]">
                  {slide.treatment}
                </div>
                <p className="mt-3 text-yellow-500">★★★★★</p>
                <p className="mt-3 leading-7 text-slate-600">“{slide.quote}”</p>
                <p className="mt-4 font-semibold">{slide.name}</p>
              </button>
            ))}
          </div>
        </div>
      </div>
    </section>
  );
}
