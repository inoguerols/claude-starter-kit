---
name: ninera-prs
description: Evalúa las PRs abiertas de un repo - mergea dependabot seguro con CI verde, informa de majors, analiza PRs externas con borrador de respuesta. Trigger /ninera-prs [owner/repo].
---

# ninera-prs

Niñera de PRs. Argumento opcional: `owner/repo`; si no se pasa, usa el `origin` del repo actual. Pensada para ejecutarse a diario (a mano, con `/loop`, o programada como routine).

## Política

1. `gh pr list --repo <owner/repo> --state open --json number,title,author,isDraft,labels`
2. Clasifica cada PR:
   - **Dependabot minor/patch**: comprobar `gh pr checks` → si CI verde y el diff es solo bumps
     minor/patch, **mergear** (`gh pr merge <n> --merge`). Si CI roja o incluye un major colado, NO tocar: informe.
   - **Dependabot major**: NUNCA mergear. Informe de riesgo breve (breaking changes relevantes para el repo,
     con evidencia del changelog), usando un subagente barato (Haiku/Sonnet).
   - **Colaborador externo** (autor distinto del dueño y de dependabot): analizar el diff con un subagente
     (intención, calidad, riesgos de seguridad — extrema el escrutinio si el repo maneja datos sensibles).
     Redactar BORRADOR de respuesta/review cordial. **No publicar ni mergear**: el veredicto es del dueño.
   - **Draft o del propio dueño**: ignorar.
3. Resumen final en tabla corta: PR, tipo, acción tomada (mergeada / informe / borrador listo / ignorada).

## Reglas duras

- Nunca mergear con CI roja o pendiente. Nunca `--admin` ni saltarse checks.
- Nunca publicar comentarios en PRs externas sin aprobación explícita.
- Modelo por coste: los análisis los hacen subagentes baratos, no el modelo grande.
