---
name: cierra
description: Cierra y limpia el worktree de trabajo actual ("limpia y cierra") - verifica estado, borra worktree y env, resume. Trigger /cierra [slug].
---

# cierra

El "ya está, limpia y cierra" en un comando. Argumento opcional: `<slug>` del worktree; si no se pasa, deduce del contexto de la sesión en qué worktree se estaba trabajando (o `git worktree list` y pregunta).

Pasos:

1. **Comprobación de seguridad (nunca saltársela):**
   - `git status --porcelain` en el worktree. Si hay cambios sin commitear → PARA y pregunta (commitear, descartar o abortar). Nunca borrar trabajo sin confirmación explícita.
   - `git log origin/<rama-default>..HEAD --oneline`: si hay commits sin pushear ni PR, avisa y pregunta.
   - Si hay PR asociada: `gh pr view --json state,mergedAt` — informa si está mergeada, abierta o cerrada.
2. Limpieza (solo si el paso 1 está limpio o el usuario confirmó):
   - Borra los `.env*` descargados en el worktree.
   - Sal del worktree; `git worktree remove "<ruta>"` (con `--force` solo si el usuario descartó cambios a sabiendas).
   - Si la rama local está mergeada: `git branch -d feature/<slug>`. Si no, déjala y dilo.
   - `git worktree prune` en el repo principal.
3. Resumen de UNA línea: qué se cerró, estado de la PR, qué quedó pendiente (si algo).

Regla: esta skill borra carpetas — ante cualquier duda sobre el estado, pregunta antes de borrar.
