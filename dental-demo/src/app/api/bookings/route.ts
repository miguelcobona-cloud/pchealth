import { NextResponse } from "next/server";
import { LOCATIONS, SERVICES } from "@/lib/data";

export async function POST(request: Request) {
  const body = await request.json();
  const required = ["locationId", "serviceId", "date", "time", "firstName", "lastName", "email", "phone"];
  for (const field of required) {
    if (!body[field]) {
      return NextResponse.json({ error: `Campo requerido: ${field}` }, { status: 400 });
    }
  }
  if (!LOCATIONS.find((l) => l.id === body.locationId) || !SERVICES.find((s) => s.id === body.serviceId)) {
    return NextResponse.json({ error: "Datos de cita inválidos" }, { status: 400 });
  }
  const booking = {
    ...body,
    id: `SD-${Date.now().toString(36).toUpperCase()}`,
    status: "confirmed",
    createdAt: new Date().toISOString(),
  };
  return NextResponse.json({ booking });
}
