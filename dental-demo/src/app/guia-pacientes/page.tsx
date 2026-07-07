import Link from "next/link";
import { GUIDE_FLOW } from "@/lib/data";

function Split({
  step,
  title,
  intro,
  highlights,
  reverse,
  theme,
  subtitle,
}: {
  step: string;
  title: string;
  intro: string;
  subtitle?: string;
  highlights: readonly { title: string; description: string }[];
  reverse?: boolean;
  theme: string;
}) {
  const media = (
    <div className={`min-h-[320px] w-full md:w-1/2 ${theme === "one" ? "bg-gradient-to-br from-[#0055e3] to-[#75baff]" : theme === "two" ? "bg-gradient-to-br from-[#d6ebff] to-[#8dc1ff]" : "bg-gradient-to-br from-[#cfe5ff] to-[#5fa4ff]"} p-8 text-white`}>
      <div className="flex h-full flex-col justify-end">
        <div className="inline-block rounded-full bg-white/20 px-4 py-2 text-sm font-semibold">Paso {step}</div>
        <h3 className="mt-4 text-3xl font-bold">{title}</h3>
        <p className="mt-3 max-w-md text-white/90">{subtitle ?? "Experiencia clara y acompañamiento profesional."}</p>
      </div>
    </div>
  );

  const content = (
    <div className="w-full bg-white p-8 md:w-1/2 md:p-12">
      <h3 className="text-3xl font-bold">{step}. {title}</h3>
      {subtitle && <p className="mt-2 text-lg font-semibold text-[#0055e3]">{subtitle}</p>}
      <p className="mt-4 leading-8 text-slate-600">{intro}</p>
      <div className="mt-6 space-y-5">
        {highlights.map((item) => (
          <div key={item.title}>
            <h4 className="font-semibold">{item.title}</h4>
            <p className="mt-1 text-slate-600">{item.description}</p>
          </div>
        ))}
      </div>
    </div>
  );

  return (
    <section className="flex flex-col md:min-h-[400px] md:flex-row">
      {reverse ? <>{content}{media}</> : <>{media}{content}</>}
    </section>
  );
}

export const metadata = {
  title: "Guía para pacientes | Sonríe Dental",
};

export default function GuiaPacientesPage() {
  return (
    <>
      <section className="bg-[#fffffa] px-4 py-12">
        <div className="mx-auto max-w-6xl text-center">
          <h1 className="text-4xl font-bold md:text-5xl">{GUIDE_FLOW.title}</h1>
        </div>
      </section>

      <Split
        step={GUIDE_FLOW.steps[0].step}
        title={GUIDE_FLOW.steps[0].title}
        intro={GUIDE_FLOW.steps[0].intro}
        highlights={GUIDE_FLOW.steps[0].highlights}
        theme={GUIDE_FLOW.steps[0].theme}
      />

      <Split
        step={GUIDE_FLOW.steps[1].step}
        title={GUIDE_FLOW.steps[1].title}
        intro={GUIDE_FLOW.steps[1].intro}
        highlights={GUIDE_FLOW.steps[1].highlights}
        reverse
        theme={GUIDE_FLOW.steps[1].theme}
      />

      <section className="bg-[#0055e3] px-4 py-16 text-center text-white">
        <div className="mx-auto max-w-3xl">
          <h2 className="text-3xl font-bold">{GUIDE_FLOW.bannerTitle}</h2>
          <p className="mt-4 text-lg text-blue-100">{GUIDE_FLOW.bannerText}</p>
        </div>
      </section>

      <Split
        step={GUIDE_FLOW.finalStep.step}
        title={GUIDE_FLOW.finalStep.title}
        subtitle={GUIDE_FLOW.finalStep.subtitle}
        intro={GUIDE_FLOW.finalStep.intro}
        highlights={GUIDE_FLOW.finalStep.highlights}
        theme="three"
      />

      <section className="bg-[#dee8f8] px-4 py-16 text-center">
        <div className="mx-auto max-w-3xl">
          <h2 className="text-3xl font-bold">Agenda tu cita de seguimiento</h2>
          <p className="mt-4 text-lg text-slate-600">
            La constancia es clave y te ayudará a lograr una sonrisa saludable.
          </p>
          <div className="mt-8 flex flex-wrap justify-center gap-3">
            <Link href="/agendar" className="rounded-full bg-[#0055e3] px-8 py-3 font-semibold text-white">Agendar cita</Link>
            <a href="https://wa.me/528112345678" target="_blank" rel="noopener noreferrer" className="rounded-full border-2 border-[#0055e3] px-8 py-3 font-semibold text-[#0055e3]">WhatsApp urgencias</a>
          </div>
        </div>
      </section>

      <section className="px-4 py-12">
        <div className="mx-auto max-w-4xl rounded-[28px] border border-blue-100 bg-white p-8 shadow-sm">
          <h2 className="text-2xl font-bold">Urgencias dentales</h2>
          <p className="mt-4 leading-8 text-slate-600">
            Si presentas dolor intenso, inflamación o fractura dental, escríbenos por WhatsApp para prioridad el mismo día. Si se fracturó un diente, guarda el fragmento en leche o suero y acude lo antes posible.
          </p>
        </div>
        <p className="mx-auto mt-8 max-w-3xl text-center text-xs text-slate-500">
          Esta guía es informativa y no sustituye la indicación médica de tu dentista.
        </p>
      </section>
    </>
  );
}
