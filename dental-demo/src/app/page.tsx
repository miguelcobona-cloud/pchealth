import Link from "next/link";
import { HeroSlideshow } from "@/components/HeroSlideshow";
import { ResultsCarousel } from "@/components/ResultsCarousel";
import { SERVICES } from "@/lib/data";

export default function Home() {
  return (
    <>
      <HeroSlideshow />

      <section className="bg-[#eef4fc] px-4 py-10">
        <div className="mx-auto grid max-w-6xl gap-4 md:grid-cols-3">
          <div className="rounded-3xl bg-white p-6 shadow-sm">
            <h3 className="text-lg font-bold text-[#0055e3]">Primera consulta en $499</h3>
            <p className="mt-2 text-sm text-slate-600">Evaluación completa con plan de tratamiento personalizado.</p>
          </div>
          <div className="rounded-3xl bg-white p-6 shadow-sm">
            <h3 className="text-lg font-bold text-[#0055e3]">3 meses sin intereses</h3>
            <p className="mt-2 text-sm text-slate-600">En tratamientos seleccionados con tarjetas participantes.</p>
          </div>
          <div className="rounded-3xl bg-white p-6 shadow-sm">
            <h3 className="text-lg font-bold text-[#0055e3]">Agenda en minutos</h3>
            <p className="mt-2 text-sm text-slate-600">Reserva en línea y recibe recordatorio por correo y WhatsApp.</p>
          </div>
        </div>
      </section>

      <section className="px-4 py-14" id="servicios">
        <div className="mx-auto max-w-6xl">
          <div className="mx-auto max-w-3xl text-center">
            <h2 className="text-3xl font-bold md:text-4xl">Nuestros servicios</h2>
            <p className="mt-3 text-slate-600">Agenda en línea el servicio que necesitas. Precios transparentes desde el primer clic.</p>
          </div>
          <div className="mt-10 grid gap-6 sm:grid-cols-2 lg:grid-cols-3">
            {SERVICES.map((service) => (
              <article key={service.id} className="rounded-3xl border border-blue-100 bg-white p-6 shadow-sm">
                <div className="mb-4 grid h-14 w-14 place-items-center rounded-2xl bg-[#dee8f8] text-2xl">{service.icon}</div>
                <h3 className="text-xl font-semibold">{service.name}</h3>
                <p className="mt-2 text-sm leading-7 text-slate-600">{service.description}</p>
                <div className="mt-4 flex items-center justify-between text-sm">
                  <span className="text-slate-500">{service.duration} min</span>
                  <strong className="text-[#0055e3]">{service.price === 0 ? "Gratis" : `$${service.price} MXN`}</strong>
                </div>
              </article>
            ))}
          </div>
        </div>
      </section>

      <ResultsCarousel />

      <section className="px-4 py-16">
        <div className="mx-auto max-w-4xl rounded-[32px] bg-[#0055e3] px-8 py-12 text-center text-white shadow-sm">
          <h2 className="text-3xl font-bold">Agenda tu cita hoy</h2>
          <p className="mx-auto mt-4 max-w-2xl text-blue-100">
            Selecciona sucursal, servicio, día y hora. Te enviaremos confirmación por correo y recordatorio por WhatsApp.
          </p>
          <Link href="/agendar" className="mt-8 inline-block rounded-full bg-white px-8 py-3 font-semibold text-[#0055e3]">Ir al calendario de citas</Link>
        </div>
      </section>
    </>
  );
}
