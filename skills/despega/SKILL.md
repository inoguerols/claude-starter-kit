---
name: despega
description: Arranca un worktree nuevo del repo actual listo para trabajar (worktree + rama + deps + env). Trigger /despega <slug> [issue].
---

# despega

Ritual de arranque de una feature en un solo comando. Argumentos: `<slug>` (obligatorio, kebab-case corto) y opcionalmente un número de issue del repo.

Pasos, en orden y sin preguntar salvo error:

1. Sitúate en la raíz del repo actual (`git rev-parse --show-toplevel`). Si no hay repo, para y dilo.
   `W="<carpeta padre>/<nombre-repo>-<slug>"`. Si `W` ya existe, informa y para (no reutilizar worktrees viejos).
2. `git fetch origin`
3. Detecta la rama por defecto (`git remote show origin` o `origin/HEAD`) y:
   `git worktree add "$W" -b feature/<slug> origin/<rama-default>`
4. Instala dependencias en `$W` según el lockfile que exista: `npm ci` / `pnpm install --frozen-lockfile` /
   `yarn install --immutable` / `bun install`. Si no hay lockfile JS, sáltatelo y dilo.
5. Si el proyecto está enlazado a Vercel (existe `.vercel/` o `vercel.json`): `npx vercel env pull .env.local`
   y comprueba que `.env.local` está ignorado por git.
6. Si se pasó issue: `gh issue view <n>` y resume el objetivo en 2 líneas.
7. Informe final de una línea: ruta del worktree, rama, deps y env listos, y (si hay issue) el objetivo.

Reglas:
- Nunca trabajar directamente en el checkout principal si hay (o va a haber) varias sesiones a la vez: una sesión, un worktree.
- Los `.env*` descargados no se commitean nunca.
