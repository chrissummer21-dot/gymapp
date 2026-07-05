# 🏋️ Gym Quest

Checklist gamificada del plan **Recomposición y Postura**, optimizada para TDA: un ejercicio a la vez, circuitos rotando máquina por máquina, registro de peso por serie, XP/niveles/rachas, y datos guardados para analizar tu rendimiento.

**Stack 100 % gratis:** GitHub (código + datos) + Vercel (hosting). Sin servidor, sin SQL.

---

## 1 · Publicar la web (GitHub + Vercel)

1. Crea un repositorio en [github.com](https://github.com) (privado o público, como prefieras).
2. Sube estos archivos (`index.html`, `README.md`).
   ```bash
   git init
   git add .
   git commit -m "Gym Quest"
   git branch -M main
   git remote add origin https://github.com/TU_USUARIO/gymapp.git
   git push -u origin main
   ```
3. Entra a [vercel.com](https://vercel.com) → **Add New → Project** → importa el repo → **Deploy** (sin configuración extra; es un sitio estático).
4. Listo: tendrás una URL tipo `https://gymapp.vercel.app` accesible desde cualquier dispositivo. Cada `git push` redespliega solo.

## 2 · Guardar tus datos en la nube (GitHub Gist — sin SQL)

En vez de una base de datos con servidor, la app guarda todo en un **Gist privado** de tu propia cuenta de GitHub: un archivo JSON (para sincronizar entre dispositivos) y un archivo CSV (para abrir directo en Excel o Google Sheets).

1. Abre la app → menú **☰ → Ajustes**.
2. Click en **"🔑 Crear token en GitHub"** (te lleva a GitHub con el permiso correcto — **"gist"** — ya marcado). Ponle un nombre, dale **Generate token**, y cópialo (empieza con `ghp_` o `github_pat_`).
3. Pega el token en el campo de la app → deja el "Gist ID" vacío → **Guardar y sincronizar**.
4. La primera vez que completes una serie, se crea el Gist automáticamente. Verás el enlace **"📄 Ver mis datos en GitHub"** — ábrelo para ver tu JSON y tu CSV en vivo.

> Guarda ese token en un lugar seguro (ej. tu gestor de contraseñas) — GitHub no te lo vuelve a mostrar. Si lo pierdes, simplemente crea uno nuevo desde el mismo enlace.

## 3 · Usarla en varios dispositivos

1. En tu primer dispositivo, después de crear el Gist: **☰ → Ajustes** → copia el **Gist ID** (está en la URL del enlace: `gist.github.com/TU_USUARIO/`**`ESTE_ID`**).
2. En el otro dispositivo (o navegador) abre la misma URL de Vercel → **☰ → Ajustes** → pega el mismo token (o crea uno nuevo) y ese mismo **Gist ID** → **Guardar y sincronizar**.
3. Se hace un pull inmediato: tu progreso (XP, racha, semana, pesos, historial completo) se trae desde el Gist. De ahí en adelante, cada cambio se sube solo (con un pequeño retraso de ~2.5 s) y gana el más reciente si editas desde dos dispositivos a la vez.

## 4 · Qué se guarda (para análisis)

Todo vive en el archivo `gymquest-data.json` de tu Gist:

| Sección | Contenido |
|---|---|
| `sessions` | Cada entrenamiento: día, semana, inicio/fin, duración, series planeadas vs hechas, veces que pospusiste máquinas |
| `sets` | **Cada serie**: ejercicio, bloque/circuito, número de serie, reps objetivo, peso + unidad + peso normalizado a kg, si fue récord, timestamp |
| `events` | Omisiones por máquina ocupada, swaps gym↔descanso, récords, subidas de nivel, días/semanas completados |
| `state` | XP, nivel, racha, semana actual, último peso por ejercicio |

El archivo `gymquest-series.csv` en el mismo Gist trae solo las series, listas para abrir en Excel/Sheets sin tocar nada.

También puedes exportar sin nube en cualquier momento: **☰ → Ajustes → Exportar** (CSV de series o JSON completo), útil como respaldo local.

## 5 · Analizar tus datos

**En Excel / Google Sheets:** abre tu Gist (el enlace de "Ver mis datos en GitHub") → entra al archivo `.csv` → botón **Raw** → copia la URL → en Sheets: `Archivo → Importar → Insertar por URL`, o en Excel: `Datos → Desde web`. Con eso puedes hacer tablas dinámicas de peso por ejercicio, volumen semanal, etc.

**Con código (Python/Node) — ejemplo rápido:**
```python
import requests, pandas as pd
gist = requests.get("https://api.github.com/gists/TU_GIST_ID").json()
data = pd.read_json(gist["files"]["gymquest-data.json"]["content"])
sets = pd.DataFrame(data["sets"])
print(sets.groupby("exercise")["weight_kg"].max())   # récord por ejercicio
print(sets.groupby("week_number")["weight_kg"].sum()) # volumen semanal
```

## ¿Y si más adelante quiero SQL de verdad?

Si el proyecto crece (varios usuarios, dashboards en vivo, queries complejas), la alternativa gratuita es **Supabase** (Postgres gratis con editor SQL en el navegador). Es más potente pero requiere crear un proyecto aparte y correr un script de esquema. Pregúntame cuando llegue ese momento y migramos la capa de sincronización — el resto de la app (ejercicios, circuitos, XP) no cambia.

## Notas

- La app es **local-first**: sin internet todo se guarda en el dispositivo (localStorage) y se sube después.
- El token de GitHub vive solo en el `localStorage` de tu navegador, nunca en el código del repo.
- Es un Gist **privado** (no aparece en tu perfil público), pero cualquiera con el enlace directo o el ID puede verlo — no lo compartas si no quieres que otros vean tus datos.
