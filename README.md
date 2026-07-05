# 🏋️ Gym Quest

Checklist gamificada del plan **Recomposición y Postura**, optimizada para TDA: un ejercicio a la vez, circuitos rotando máquina por máquina, registro de peso por serie, XP/niveles/rachas, y base de datos para analizar tu rendimiento.

**Stack 100 % gratis:** GitHub (código) + Vercel (hosting) + Supabase (Postgres en la nube).

---

## 1 · Publicar la web (GitHub + Vercel)

1. Crea un repositorio en [github.com](https://github.com) (recomendado: **privado**, porque la anon key de Supabase se guarda solo en tu navegador, pero por higiene general).
2. Sube estos archivos (`index.html`, `schema.sql`, `README.md`).
   ```bash
   git init
   git add .
   git commit -m "Gym Quest"
   git branch -M main
   git remote add origin https://github.com/TU_USUARIO/gymquest.git
   git push -u origin main
   ```
3. Entra a [vercel.com](https://vercel.com) → **Add New → Project** → importa el repo → **Deploy** (sin configuración extra; es un sitio estático).
4. Listo: tendrás una URL tipo `https://gymquest.vercel.app` accesible desde cualquier dispositivo. Cada `git push` redespliega solo.

## 2 · Crear la base de datos (Supabase)

1. Crea cuenta gratis en [supabase.com](https://supabase.com) → **New project** (elige región cercana y una contraseña de BD cualquiera).
2. En el proyecto: **SQL Editor** → pega todo el contenido de [`schema.sql`](schema.sql) → **Run**.
3. Copia tus credenciales desde **Settings → API**:
   - **Project URL** (ej. `https://abcd1234.supabase.co`)
   - **anon public** key
4. Abre la app → menú **☰ → Ajustes → Base de datos en la nube** → pega URL y key → **Guardar y probar conexión**. Si sale 🟢, todo lo que hagas se sube automáticamente (y lo pendiente se reintenta cada 30 s; la app funciona offline y sincroniza al volver la conexión).

## 3 · Usarla en varios dispositivos

1. En tu primer dispositivo: **☰ → Ajustes → ID de perfil → Copiar mi ID**.
2. En el otro dispositivo abre la misma URL de Vercel, configura la misma URL/key de Supabase, pega el ID en *"Pegar ID de otro dispositivo"* → **Usar ese ID**.
3. El progreso (XP, racha, semana, pesos) se sincroniza vía la tabla `app_state` (gana el último cambio).

## 4 · Qué se guarda (para análisis)

| Tabla | Contenido |
|---|---|
| `sessions` | Cada entrenamiento: día, semana, inicio/fin, duración, series planeadas vs hechas, veces que pospusiste máquinas |
| `sets` | **Cada serie**: ejercicio, bloque/circuito, número de serie, reps objetivo, peso + unidad + peso normalizado a kg, si fue récord, timestamp |
| `events` | Omisiones por máquina ocupada, swaps gym↔descanso, récords, subidas de nivel, días/semanas completados |
| `app_state` | Snapshot del progreso para multi-dispositivo |

También puedes exportar sin nube: **☰ → Ajustes → Exportar** (CSV de series o JSON completo).

## 5 · Queries de ejemplo (Supabase → SQL Editor)

**Progresión de peso por ejercicio:**
```sql
select exercise, date_trunc('week', logged_at) as semana,
       max(weight_kg) as max_kg, round(avg(weight_kg),1) as prom_kg
from sets where weight_kg is not null
group by 1,2 order by 1,2;
```

**Volumen semanal (series × kg):**
```sql
select week_number, count(*) as series, round(sum(weight_kg),0) as volumen_kg
from sets group by 1 order by 1;
```

**Adherencia (¿completas lo planeado?):**
```sql
select week_number, day_title, sets_done, sets_planned, duration_min, postpones
from sessions where completed order by started_at;
```

**¿Qué máquinas están siempre ocupadas?** (para reordenar tu circuito):
```sql
select detail->>'exercise' as maquina, count(*) as veces_pospuesta
from events where type='postpone' group by 1 order by 2 desc;
```

**Tus récords:**
```sql
select logged_at::date as fecha, exercise, weight, unit
from sets where is_pr order by logged_at desc;
```

## Notas

- La app es **local-first**: sin internet todo se guarda en el dispositivo y se sube después.
- La anon key vive solo en el `localStorage` de tu navegador, no en el código.
- Datos personales: las políticas RLS del esquema son abiertas para la anon key (app personal). No compartas la key.
