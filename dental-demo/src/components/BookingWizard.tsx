"use client";

import { useMemo, useState } from "react";
import { LOCATIONS, PROVIDERS, SERVICES, TIME_SLOTS } from "@/lib/data";

type Step = "location" | "service" | "datetime" | "patient" | "confirm" | "success";

const order: Step[] = ["location", "service", "datetime", "patient", "confirm", "success"];

function nextDays() {
  const items: string[] = [];
  const now = new Date();
  for (let i = 1; i <= 14; i += 1) {
    const d = new Date(now);
    d.setDate(now.getDate() + i);
    if (d.getDay() !== 0) items.push(d.toISOString().slice(0, 10));
  }
  return items;
}

export function BookingWizard() {
  const days = useMemo(() => nextDays(), []);
  const [step, setStep] = useState<Step>("location");
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState("");
  const [successId, setSuccessId] = useState("");
  const [data, setData] = useState({
    locationId: "",
    serviceId: "",
    providerId: "any",
    date: "",
    time: "",
    firstName: "",
    lastName: "",
    email: "",
    phone: "",
  });

  const active = order.indexOf(step);

  const update = (key: keyof typeof data, value: string) => {
    setData((prev) => ({ ...prev, [key]: value }));
    setError("");
  };

  const validate = () => {
    if (step === "location" && !data.locationId) return "Selecciona una sucursal";
    if (step === "service" && !data.serviceId) return "Selecciona un servicio";
    if (step === "datetime" && (!data.date || !data.time)) return "Selecciona fecha y hora";
    if (step === "patient" && (!data.firstName || !data.lastName || !data.email || !data.phone)) return "Completa tus datos";
    return "";
  };

  const next = () => {
    const issue = validate();
    if (issue) {
      setError(issue);
      return;
    }
    setStep(order[active + 1]);
  };

  const back = () => setStep(order[active - 1]);

  const submit = async () => {
    setLoading(true);
    setError("");
    try {
      const res = await fetch("/api/bookings", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify(data),
      });
      const json = await res.json();
      if (!res.ok) throw new Error(json.error || "No se pudo confirmar");
      setSuccessId(json.booking.id);
      setStep("success");
    } catch (e) {
      setError(e instanceof Error ? e.message : "Error inesperado");
    } finally {
      setLoading(false);
    }
  };

  if (step === "success") {
    return (
      <div className="rounded-3xl border border-green-200 bg-green-50 p-8 text-center shadow-sm">
        <div className="mx-auto grid h-16 w-16 place-items-center rounded-full bg-green-500 text-2xl text-white">✓</div>
        <h2 className="mt-4 text-2xl font-bold">¡Cita confirmada!</h2>
        <p className="mt-3 text-slate-600">Te enviaremos confirmación por correo y recordatorio por WhatsApp.</p>
        <p className="mt-2 text-xs text-slate-500">ID demo: {successId}</p>
      </div>
    );
  }

  return (
    <div className="rounded-3xl border border-blue-100 bg-white p-6 shadow-sm md:p-8">
      <div className="mb-6 flex flex-wrap gap-2">
        {order.slice(0, -1).map((item, i) => (
          <span key={item} className={`rounded-full px-3 py-1 text-xs font-semibold ${i <= active ? "bg-[#0055e3] text-white" : "bg-slate-100 text-slate-500"}`}>
            {i + 1}. {item}
          </span>
        ))}
      </div>

      {step === "location" && (
        <div className="grid gap-3">
          <h2 className="text-xl font-bold">¿En qué sucursal quieres tu cita?</h2>
          {LOCATIONS.map((loc) => (
            <button key={loc.id} onClick={() => update("locationId", loc.id)} className={`rounded-2xl border p-4 text-left ${data.locationId === loc.id ? "border-[#0055e3] bg-blue-50" : "border-slate-200"}`}>
              <div className="font-semibold">{loc.name}</div>
              <div className="text-sm text-slate-500">{loc.address}</div>
            </button>
          ))}
        </div>
      )}

      {step === "service" && (
        <div>
          <h2 className="text-xl font-bold">¿Qué servicio necesitas?</h2>
          <div className="mt-4 grid gap-3">
            {SERVICES.map((svc) => (
              <button key={svc.id} onClick={() => update("serviceId", svc.id)} className={`rounded-2xl border p-4 text-left ${data.serviceId === svc.id ? "border-[#0055e3] bg-blue-50" : "border-slate-200"}`}>
                <div className="flex items-center justify-between gap-4">
                  <div><span className="mr-2">{svc.icon}</span><strong>{svc.name}</strong></div>
                  <div className="font-semibold text-[#0055e3]">{svc.price === 0 ? "Gratis" : `$${svc.price}`}</div>
                </div>
                <p className="mt-2 text-sm text-slate-500">{svc.description}</p>
              </button>
            ))}
          </div>
          <select className="mt-4 w-full rounded-2xl border border-slate-200 px-4 py-3" value={data.providerId} onChange={(e) => update("providerId", e.target.value)}>
            {PROVIDERS.map((provider) => <option key={provider.id} value={provider.id}>{provider.name}</option>)}
          </select>
        </div>
      )}

      {step === "datetime" && (
        <div>
          <h2 className="text-xl font-bold">Elige día y hora</h2>
          <div className="mt-4 flex gap-2 overflow-auto pb-2">
            {days.map((day) => (
              <button key={day} onClick={() => update("date", day)} className={`min-w-24 rounded-2xl border px-4 py-3 text-sm ${data.date === day ? "border-[#0055e3] bg-[#0055e3] text-white" : "border-slate-200"}`}>
                {day}
              </button>
            ))}
          </div>
          <div className="mt-5 grid grid-cols-4 gap-2 md:grid-cols-6">
            {TIME_SLOTS.map((slot) => (
              <button key={slot} onClick={() => update("time", slot)} className={`rounded-xl border px-3 py-2 text-sm ${data.time === slot ? "border-[#0055e3] bg-[#0055e3] text-white" : "border-slate-200"}`}>
                {slot}
              </button>
            ))}
          </div>
        </div>
      )}

      {step === "patient" && (
        <div>
          <h2 className="text-xl font-bold">Tus datos de contacto</h2>
          <div className="mt-4 grid gap-3 md:grid-cols-2">
            <input className="rounded-2xl border border-slate-200 px-4 py-3" placeholder="Nombre" value={data.firstName} onChange={(e) => update("firstName", e.target.value)} />
            <input className="rounded-2xl border border-slate-200 px-4 py-3" placeholder="Apellido" value={data.lastName} onChange={(e) => update("lastName", e.target.value)} />
            <input className="rounded-2xl border border-slate-200 px-4 py-3 md:col-span-2" placeholder="Correo electrónico" value={data.email} onChange={(e) => update("email", e.target.value)} />
            <input className="rounded-2xl border border-slate-200 px-4 py-3 md:col-span-2" placeholder="WhatsApp / teléfono" value={data.phone} onChange={(e) => update("phone", e.target.value)} />
          </div>
        </div>
      )}

      {step === "confirm" && (
        <div>
          <h2 className="text-xl font-bold">Confirma tu cita</h2>
          <div className="mt-4 rounded-2xl bg-slate-50 p-4 text-sm text-slate-600">
            <p><strong>Sucursal:</strong> {LOCATIONS.find((l) => l.id === data.locationId)?.name}</p>
            <p><strong>Servicio:</strong> {SERVICES.find((s) => s.id === data.serviceId)?.name}</p>
            <p><strong>Profesional:</strong> {PROVIDERS.find((p) => p.id === data.providerId)?.name}</p>
            <p><strong>Fecha:</strong> {data.date} · {data.time}</p>
            <p><strong>Paciente:</strong> {data.firstName} {data.lastName}</p>
            <p><strong>Contacto:</strong> {data.email} · {data.phone}</p>
          </div>
        </div>
      )}

      {error && <p className="mt-4 rounded-xl bg-red-50 px-4 py-3 text-sm text-red-600">{error}</p>}

      <div className="mt-8 flex justify-between">
        {step !== "location" ? (
          <button onClick={back} className="rounded-full border border-slate-300 px-6 py-2.5 font-semibold text-slate-700">Atrás</button>
        ) : <span />}
        {step === "confirm" ? (
          <button onClick={submit} disabled={loading} className="rounded-full bg-[#0055e3] px-8 py-2.5 font-semibold text-white">
            {loading ? "Confirmando..." : "Confirmar cita"}
          </button>
        ) : (
          <button onClick={next} className="rounded-full bg-[#0055e3] px-8 py-2.5 font-semibold text-white">Continuar</button>
        )}
      </div>
    </div>
  );
}
