import Link from "next/link";
import { PROCESS_STEPS } from "@/lib/data";

export const metadata = {
  title: "Proceso | Sonríe Dental",
};

export default function ProcesoPage() {
  return (
    <>
      <section className="bg-gradient-to-b from-[#dee8f8] to-[#fffffa] px-4 py-14">
        <div className="mx-auto max-w-3xl text-center">
          <p className="text-sm font-semibold uppercase tracking-[0.2em] text-[#0055e3]">Proceso</p>
          <h1 className="mt-3 text-4xl font-bold md:text-5xl">Tu tratamiento, paso a paso</h1>
          <p className="mt-4 text-lg leading-8 text-slate-600">
            Un flujo simple y transparente: agenda en minutos, recibe recordatorios automáticos y sigue tu plan con el mismo equipo.
          </p>
        </div>
      </section>

      <section className="px-4 py-14">
        <div className="mx-auto max-w-3xl">
          {PROCESS_STEPS.map((item, index) => (
            <div key={item.step} className="relative flex gap-5 pb-10 last:pb-0">
              {index < PROCESS_STEPS.length - 1 && <span className="absolute left-5 top-12 h-[calc(100%-2rem)] w-px bg-blue-200" />}
              <div className="relative z-10 grid h-10 w-10 shrink-0 place-items-center rounded-full bg-[#0055e3] font-bold text-white">{item.step}</div>
              <div>
                <h2 className="text-xl font-bold">{item.title}</h2>
                <p className="mt-2 text-slate-600">{item.description}</p>
              </div>
            </div>
          ))}
        </div>
      </section>

      <section className="bg-[#dee8f8] px-4 py-14">
        <div className="mx-auto max-w-4xl rounded-[28px] bg-white p-8 shadow-sm md:p-10">
          <h2 className="text-2xl font-bold">Recordatorios automáticos</h2>
          <p className="mt-3 leading-8 text-slate-600">
            Al confirmar tu cita recibirás un correo con los detalles y un enlace para agregarla a tu calendario. También te enviaremos recordatorio por WhatsApp.
          </p>
          <ul className="mt-6 space-y-2 text-sm text-slate-600">
            <li>✓ Confirmación inmediata por correo</li>
            <li>✓ Recordatorio 24 h antes por WhatsApp</li>
            <li>✓ Opción de cancelar o reagendar desde el mensaje</li>
          </ul>
          <Link href="/agendar" className="mt-8 inline-block rounded-full bg-[#0055e3] px-8 py-3 font-semibold text-white">
            Iniciar mi proceso
          </Link>
        </div>
      </section>
    </>
  );
}
