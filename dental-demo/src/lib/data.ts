export const CLINIC = {
  name: "Sonríe Dental",
  tagline: "Clínica dental en Monterrey",
  phone: "528112345678",
  email: "citas@sonriedental.demo",
  promo: "¡PRIMERA CONSULTA EN $499!",
} as const;

export const NAV_LINKS = [
  { href: "/nosotros", label: "Nosotros" },
  { href: "/proceso", label: "Proceso" },
  { href: "/guia-pacientes", label: "Guía para pacientes" },
  { href: "/#servicios", label: "Servicios" },
] as const;

export const SERVICES = [
  { id: "consulta", name: "Consulta general", duration: 30, price: 499, icon: "🦷", description: "Evaluación completa y plan de tratamiento." },
  { id: "limpieza", name: "Limpieza dental", duration: 45, price: 890, icon: "✨", description: "Profilaxis y eliminación de placa." },
  { id: "blanqueamiento", name: "Blanqueamiento", duration: 60, price: 3500, icon: "😁", description: "Tratamiento estético en consultorio." },
  { id: "ortodoncia", name: "Valoración ortodoncia", duration: 45, price: 0, icon: "📐", description: "Primera valoración sin costo." },
  { id: "urgencia", name: "Urgencia dental", duration: 30, price: 750, icon: "🚨", description: "Atención el mismo día según disponibilidad." },
] as const;

export const LOCATIONS = [
  { id: "centro", name: "Centro", address: "Av. Constitución 450, Monterrey" },
  { id: "san-pedro", name: "San Pedro", address: "Calz. del Valle 402, San Pedro" },
  { id: "cumbres", name: "Cumbres", address: "Paseo de los Leones 2201, Cumbres" },
] as const;

export const PROVIDERS = [
  { id: "any", name: "Cualquier dentista disponible" },
  { id: "ana", name: "Dra. Ana Martínez" },
  { id: "carlos", name: "Dr. Carlos López" },
  { id: "patricia", name: "Dra. Patricia Ruiz" },
] as const;

export const TIME_SLOTS = ["09:00", "09:30", "10:00", "10:30", "11:00", "11:30", "12:00", "14:00", "14:30", "15:00", "15:30", "16:00", "16:30", "17:00", "17:30", "18:00"] as const;

export const HERO_SLIDES = [
  {
    id: "s1",
    title: "Tu sonrisa merece lo mejor",
    subtitle: "Clínica dental en Monterrey con tecnología de vanguardia y atención humana.",
    image: "/images/hero-clinic.png",
  },
  {
    id: "s2",
    title: "Resultados que se notan",
    subtitle: "Consulta, limpieza, blanqueamiento, ortodoncia y urgencias con una experiencia clara y profesional.",
    image: "/images/hero-smile.png",
  },
] as const;

export const RESULT_SLIDES = [
  { id: "r1", treatment: "Blanqueamiento dental", name: "María G.", quote: "Llevaba años queriendo blanquear mis dientes. El cambio fue increíble.", accent: "from-sky-100 to-blue-200", image: "/images/result-whitening.png" },
  { id: "r2", treatment: "Limpieza dental", name: "Roberto S.", quote: "Agendé en línea en 2 minutos y me llegó el recordatorio por WhatsApp.", accent: "from-cyan-100 to-blue-200", image: "/images/result-cleaning.png" },
  { id: "r3", treatment: "Ortodoncia", name: "Laura M.", quote: "Mi sonrisa cambió por completo y el proceso fue muy claro desde el inicio.", accent: "from-blue-100 to-indigo-200", image: "/images/result-ortho.png" },
] as const;

export const ABOUT_VALUES = [
  { title: "Atención humana", icon: "🤝", description: "Explicamos cada paso del tratamiento para que llegues tranquilo y salgas con claridad." },
  { title: "Tecnología actualizada", icon: "🖥️", description: "Radiografía digital, diagnóstico preciso y protocolos de esterilización modernos." },
  { title: "Precios transparentes", icon: "🏷️", description: "Presupuesto claro desde la primera consulta. Sin sorpresas al momento de pagar." },
] as const;

export const TEAM = [
  { name: "Dra. Ana Martínez", role: "Odontología general y estética", credential: "Cédula profesional demo 12345678" },
  { name: "Dr. Carlos López", role: "Ortodoncia y alineadores", credential: "Cédula profesional demo 87654321" },
  { name: "Dra. Patricia Ruiz", role: "Endodoncia y urgencias", credential: "Cédula profesional demo 11223344" },
] as const;

export const PROCESS_STEPS = [
  { step: "1", title: "Agenda en línea", description: "Elige sucursal, servicio, día y hora desde la web o por WhatsApp." },
  { step: "2", title: "Primera consulta", description: "Valoración clínica, radiografía si es necesaria y plan de tratamiento personalizado." },
  { step: "3", title: "Tratamiento", description: "Sesiones programadas con el especialista indicado y recordatorios automáticos." },
  { step: "4", title: "Seguimiento", description: "Revisiones periódicas y recomendaciones de cuidado en casa." },
] as const;

export const GUIDE_FLOW = {
  title: "¿Cómo prepararte?",
  steps: [
    {
      step: "1",
      title: "Antes de tu cita",
      intro: "Puedes agendar tu cita de forma sencilla. Recibirás confirmación por correo con opción de agregarla a tu calendario.",
      highlights: [
        { title: "Disponibilidad inmediata", description: "Buscamos horario el mismo día o dentro de la misma semana según sucursal." },
        { title: "Qué traer", description: "Identificación oficial, estudios previos si los tienes y una lista de medicamentos." },
      ],
      side: "left" as const,
      theme: "one",
    },
    {
      step: "2",
      title: "Acude a la clínica",
      intro: "Después de agendar, acudirás a clínica donde nuestro equipo te acompañará para la valoración y el mejor plan de tratamiento.",
      highlights: [
        { title: "Revisión clínica", description: "Evaluación bucal completa y explicación del diagnóstico en lenguaje claro." },
        { title: "Radiografía digital", description: "Solo si tu caso lo requiere, con presupuesto por escrito antes de iniciar." },
      ],
      side: "right" as const,
      theme: "two",
    },
  ],
  bannerTitle: "Tu plan de tratamiento será explicado por tu dentista",
  bannerText: "Después de la valoración, tu especialista definirá el tratamiento recomendado, el número de sesiones y los cuidados en casa.",
  finalStep: {
    step: "3",
    title: "Después de tu visita",
    subtitle: "¡Tu sonrisa en buenas manos!",
    intro: "Al terminar tu cita recibirás indicaciones personalizadas y, si requieres seguimiento, te contactaremos para tu próxima revisión.",
    highlights: [
      { title: "Indicaciones de cuidado", description: "Te entregamos recomendaciones de higiene oral y qué esperar en los días siguientes." },
      { title: "Próxima revisión", description: "Agenda tu seguimiento antes de salir o en línea para mantener continuidad." },
    ],
  },
} as const;
