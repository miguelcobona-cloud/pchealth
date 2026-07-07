import { ABOUT_VALUES, CLINIC, LOCATIONS, TEAM } from "@/lib/data";

export const metadata = {
  title: "Nosotros | Sonríe Dental",
};

export default function NosotrosPage() {
  return (
    <>
      <section className="bg-gradient-to-b from-[#dee8f8] to-[#fffffa] px-4 py-14">
        <div className="mx-auto max-w-3xl text-center">
          <p className="text-sm font-semibold uppercase tracking-[0.2em] text-[#0055e3]">Nosotros</p>
          <h1 className="mt-3 text-4xl font-bold md:text-5xl">Cuidamos sonrisas con calidez y precisión</h1>
          <p className="mt-4 text-lg leading-8 text-slate-600">
            En {CLINIC.name} combinamos experiencia clínica, tecnología y un trato cercano para que cada paciente se sienta acompañado.
          </p>
        </div>
      </section>

      <section className="px-4 py-14">
        <div className="mx-auto grid max-w-6xl gap-8 md:grid-cols-3">
          {ABOUT_VALUES.map((value) => (
            <article key={value.title} className="rounded-3xl bg-white p-6 shadow-sm">
              <div className="grid h-14 w-14 place-items-center rounded-2xl bg-[#dee8f8] text-2xl">{value.icon}</div>
              <h3 className="mt-4 text-xl font-bold text-[#0055e3]">{value.title}</h3>
              <p className="mt-3 text-slate-600">{value.description}</p>
            </article>
          ))}
        </div>
      </section>

      <section className="bg-[#dee8f8] px-4 py-14">
        <div className="mx-auto max-w-6xl">
          <div className="text-center">
            <h2 className="text-3xl font-bold">Nuestro equipo</h2>
            <p className="mt-3 text-slate-600">Especialistas certificados en odontología general, estética, ortodoncia y urgencias.</p>
          </div>
          <div className="mt-10 grid gap-6 md:grid-cols-3">
            {TEAM.map((member) => (
              <article key={member.name} className="rounded-3xl border border-blue-100 bg-white p-6 text-center shadow-sm">
                <div className="mx-auto grid h-16 w-16 place-items-center rounded-full bg-[#0055e3] text-xl font-bold text-white">
                  {member.name.charAt(member.name.indexOf(" ") + 1)}
                </div>
                <h3 className="mt-4 text-xl font-semibold">{member.name}</h3>
                <p className="mt-2 text-sm text-[#0055e3]">{member.role}</p>
                <p className="mt-2 text-xs text-slate-500">{member.credential}</p>
              </article>
            ))}
          </div>
        </div>
      </section>

      <section className="px-4 py-14">
        <div className="mx-auto max-w-6xl">
          <div className="text-center">
            <h2 className="text-3xl font-bold">Sucursales</h2>
          </div>
          <div className="mt-8 grid gap-6 md:grid-cols-3">
            {LOCATIONS.map((loc) => (
              <article key={loc.id} className="rounded-3xl bg-white p-6 shadow-sm">
                <h3 className="text-xl font-semibold">{loc.name}</h3>
                <p className="mt-3 text-slate-600">{loc.address}</p>
              </article>
            ))}
          </div>
        </div>
      </section>
    </>
  );
}
