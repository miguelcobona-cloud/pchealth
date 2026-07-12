"use client";

import Image from "next/image";
import { useCallback, useEffect, useRef, useState } from "react";
import { RESULT_SLIDES } from "@/lib/data";

export function ResultsCarousel() {
  const sectionRef = useRef<HTMLElement>(null);
  const trackRef = useRef<HTMLDivElement>(null);
  const [active, setActive] = useState(0);
  const [isVisible, setIsVisible] = useState(false);
  const total = RESULT_SLIDES.length;

  const goTo = useCallback((index: number) => {
    const next = (index + total) % total;
    setActive(next);
    const track = trackRef.current;
    if (!track) return;
    const slideWidth = track.clientWidth;
    track.scrollTo({ left: slideWidth * next, behavior: "smooth" });
  }, [total]);

  const goNext = useCallback(() => goTo(active + 1), [active, goTo]);
  const goPrev = useCallback(() => goTo(active - 1), [active, goTo]);

  useEffect(() => {
    const node = sectionRef.current;
    if (!node) return;

    const observer = new IntersectionObserver(
      ([entry]) => setIsVisible(entry.isIntersecting),
      { threshold: 0.35 },
    );
    observer.observe(node);
    return () => observer.disconnect();
  }, []);

  useEffect(() => {
    if (!isVisible) return;
    const timer = setInterval(goNext, 5500);
    return () => clearInterval(timer);
  }, [goNext, isVisible]);

  useEffect(() => {
    const track = trackRef.current;
    if (!track) return;

    const onScroll = () => {
      const slideWidth = track.clientWidth;
      if (slideWidth === 0) return;
      const index = Math.round(track.scrollLeft / slideWidth);
      setActive(index);
    };

    track.addEventListener("scroll", onScroll, { passive: true });
    return () => track.removeEventListener("scroll", onScroll);
  }, []);

  return (
    <section ref={sectionRef} className="overflow-hidden bg-[#fffffa] px-4 py-14" id="testimonios">
      <div className="mx-auto max-w-6xl">
        <div className="mx-auto max-w-3xl text-center">
          <h2 className="text-3xl font-bold md:text-4xl">Resultados reales, sonrisas reales</h2>
          <p className="mt-3 text-slate-600">
            Casos de blanqueamiento, limpieza y ortodoncia con una presentación clara y premium.
          </p>
        </div>

        <div className="relative mt-10">
          <div
            ref={trackRef}
            className="flex snap-x snap-mandatory overflow-x-auto scroll-smooth [-ms-overflow-style:none] [scrollbar-width:none] [&::-webkit-scrollbar]:hidden"
          >
            {RESULT_SLIDES.map((slide) => (
              <article
                key={slide.id}
                className="w-full shrink-0 snap-center px-1"
              >
                <div className="grid gap-6 lg:grid-cols-2 lg:items-center">
                  <div className={`rounded-[32px] bg-gradient-to-br ${slide.accent} p-6 shadow-sm md:p-8`}>
                    <div className="inline-block rounded-full bg-white/80 px-4 py-2 text-sm font-semibold text-[#0055e3]">
                      {slide.treatment}
                    </div>
                    <div className="relative mt-6 aspect-[4/3] overflow-hidden rounded-[24px] border-4 border-white/70 bg-white/40">
                      <Image
                        src={slide.image}
                        alt={slide.treatment}
                        fill
                        className="object-cover"
                        sizes="(max-width: 1024px) 100vw, 560px"
                      />
                    </div>
                  </div>

                  <div className="flex flex-col justify-center rounded-[32px] border border-blue-100 bg-white p-8 shadow-sm">
                    <p className="text-2xl text-yellow-500">★★★★★</p>
                    <blockquote className="mt-5 text-xl leading-8 text-slate-700 md:text-2xl">
                      “{slide.quote}”
                    </blockquote>
                    <p className="mt-6 text-lg font-semibold text-[#0055e3]">{slide.name}</p>
                    <p className="mt-2 text-sm text-slate-500">{slide.treatment}</p>
                  </div>
                </div>
              </article>
            ))}
          </div>

          <button
            type="button"
            onClick={goPrev}
            aria-label="Testimonio anterior"
            className="absolute -left-2 top-1/2 z-10 hidden h-11 w-11 -translate-y-1/2 place-items-center rounded-full bg-white text-xl text-slate-700 shadow-md transition hover:bg-blue-50 md:grid lg:-left-5"
          >
            ‹
          </button>
          <button
            type="button"
            onClick={goNext}
            aria-label="Testimonio siguiente"
            className="absolute -right-2 top-1/2 z-10 hidden h-11 w-11 -translate-y-1/2 place-items-center rounded-full bg-white text-xl text-slate-700 shadow-md transition hover:bg-blue-50 md:grid lg:-right-5"
          >
            ›
          </button>

          <div className="mt-8 flex justify-center gap-2">
            {RESULT_SLIDES.map((slide, index) => (
              <button
                key={slide.id}
                type="button"
                aria-label={`Ver testimonio ${index + 1}`}
                aria-current={index === active}
                onClick={() => goTo(index)}
                className={`h-2.5 rounded-full transition-all ${index === active ? "w-8 bg-[#0055e3]" : "w-2.5 bg-blue-200"}`}
              />
            ))}
          </div>
        </div>

        <p className="mx-auto mt-8 max-w-3xl text-center text-xs text-slate-500">
          *Los resultados de cada paciente pueden variar según diagnóstico, hábitos y seguimiento del tratamiento.
        </p>
      </div>
    </section>
  );
}
