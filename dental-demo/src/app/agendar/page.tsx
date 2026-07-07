import { BookingWizard } from "@/components/BookingWizard";

export const metadata = {
  title: "Agendar cita | Sonríe Dental",
};

export default function AgendarPage() {
  return (
    <section className="px-4 py-12 md:py-16">
      <div className="mx-auto max-w-3xl">
        <div className="mb-8 text-center">
          <h1 className="text-3xl font-bold md:text-4xl">Agendar cita</h1>
          <p className="mt-3 text-slate-600">
            Elige sucursal, servicio y horario disponible.
          </p>
        </div>
        <BookingWizard />
      </div>
    </section>
  );
}
