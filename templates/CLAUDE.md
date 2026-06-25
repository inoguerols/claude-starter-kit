# Cómo trabajo (instrucciones globales)

Estas reglas aplican a todos los proyectos. Bórralas o adáptalas a tu gusto.

## Buenas prácticas

- **Código mínimo (ponytail).** Antes de escribir algo, sube la escalera: ¿hace falta?
  ¿lo cubre la librería estándar? ¿una feature nativa de la plataforma? ¿una dependencia
  ya instalada? ¿una línea? Solo entonces, el mínimo código que funcione. Nunca recortar
  seguridad, validación de entradas ni accesibilidad. (El plugin `/ponytail` lo refuerza.)
- **GitHub es la fuente de verdad.** Refleja el trabajo en commits/issues/PRs. Si tocaste
  algo, que quede en git, no solo en tu cabeza.
- **Confirma antes de acciones irreversibles o hacia fuera.** Deploys, borrados,
  sobrescrituras, envíos de correo/mensajes: pregunta primero salvo permiso explícito.
- **Sé frugal con recursos de pago.** Bases de datos facturadas por uso, APIs con cuota:
  evita escaneos de tabla completa, recálculos masivos y refrescos totales innecesarios.
- **Una sesión por worktree.** Si abres varias sesiones de Claude en el mismo repo a la vez,
  cada una en su propio `git worktree` para no pisaros.
- **Pregunta cuando no esté claro** en vez de asumir. Una pregunta corta ahorra un rehacer largo.

## Memoria persistente

Tienes memoria de archivos en `~/.claude/projects/<proyecto>/memory/`. Un hecho por archivo,
con frontmatter:

```markdown
---
name: <slug-en-kebab-case>
description: <resumen de una línea — sirve para decidir si es relevante al recordar>
metadata:
  type: user | feedback | project | reference
---

<el hecho. Enlaza memorias relacionadas con [[nombre-de-otra]].>
```

- `user`: quién eres (rol, preferencias). `feedback`: cómo quieres que trabaje (con el porqué).
  `project`: trabajo en curso, objetivos, restricciones que no se deducen del código.
  `reference`: punteros a recursos externos (URLs, tickets, dashboards).
- Tras guardar un archivo, añade una línea en `MEMORY.md` (el índice): `- [Título](archivo.md) — gancho`.
- Antes de crear, revisa si ya existe un archivo que lo cubra y actualízalo. Borra lo que resulte falso.
- No guardes lo que el repo ya registra (estructura del código, historial de git, este CLAUDE.md).
