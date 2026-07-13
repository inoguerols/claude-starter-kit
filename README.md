# claude-starter-kit

El setup completo de Claude Code en **un comando**: plugins, hooks de seguridad,
segundo cerebro y buenas prácticas. Pensado para empezar un proyecto bien desde el minuto cero.

## Instalar

```bash
curl -fsSL https://raw.githubusercontent.com/inoguerols/claude-starter-kit/main/install.sh | bash
```

Eso es todo. Si no tienes Claude Code, te lo instala. **Para actualizar en el futuro,
vuelve a correr la misma línea** (es idempotente: no duplica nada).

## Requisitos

- **`git`** (obligatorio). El instalador para si no lo encuentra.
- **`jq`** (recomendado). Sin él, el instalador **no fusiona `settings.json`** (ni permisos ni
  hooks de seguridad ni auto-actualización): instala el resto y te avisa. En Mac: `brew install jq`.
- **Claude Code**: si no está, el instalador lo instala (vía `claude.ai/install.sh`, o `npm` como
  respaldo) y añade `~/.local/bin` a tu `PATH`.

> En **macOS y Linux** funciona tal cual. En **Windows** necesitas una terminal tipo Linux:

<details>
<summary><b>Windows: prepara la terminal una vez</b></summary>

Elige **una** opción y, dentro de ella, pega el comando de instalación:

**Opción A — WSL (recomendada):**
1. Abre **PowerShell como administrador** (botón derecho → "Ejecutar como administrador").
2. Ejecuta: `wsl --install`
3. Reinicia el ordenador cuando lo pida.
4. Abre **"Ubuntu"** desde el menú Inicio y pega ahí el comando de instalación.

**Opción B — Git Bash:**
1. Descarga e instala Git desde **https://git-scm.com/download/win** (deja las opciones por defecto).
2. Abre **"Git Bash"** desde el menú Inicio y pega ahí el comando de instalación.
</details>

## Qué instala

| Pieza | Para qué |
|---|---|
| **ponytail** | Modo "vago": código mínimo, nada de sobre-ingeniería. Comando `/ponytail`. |
| **ecc** | Agentes de review, testing y orquestación (`/ecc:code-review`, `/ecc:plan`, loops…). |
| **vercel** | Desplegar en Vercel desde Claude. |
| **security-guidance** (oficial Anthropic) | Detecta vulnerabilidades mientras programas. |
| **claude-code-security-kit** (de [txampa](https://github.com/txampa/claude-code-security-kit)) | Hooks que bloquean comandos peligrosos y escanean secretos antes de cada acción. |
| **obsidian-second-brain** | Notas, board y research que se auto-mantienen. `/obsidian-init` para arrancar. |
| **graphify** ([graphifyy](https://pypi.org/project/graphifyy/) por PyPI/`uv`) | Convierte cualquier carpeta o repo en un grafo de conocimiento navegable. Comando `/graphify`. |
| **CLAUDE.md** | Buenas prácticas + memoria persistente (solo si no tienes ya uno). |
| **Skills de flujo** (`/despega`, `/cierra`, `/ninera-prs`) | El ritual de trabajar por worktrees en tres comandos: arrancar una feature lista (worktree + rama + deps + env), cerrarla limpia sin perder trabajo, y evaluar las PRs abiertas (dependabot seguro se mergea; externas, informe + borrador). Solo si no las tienes ya. |
| **Aviso de fin de tarea** | Hook `Stop`: notificación del sistema cuando una tarea de >90 s termina. Deja de preguntar "¿cómo vas?" — te avisa él. |

Los plugins se instalan **a nivel de usuario** (`-s user`), así que valen para todos tus proyectos.

## Qué cambia en tu sistema

Transparencia total — el instalador solo toca tu carpeta `~/.claude`:

| Ruta | Qué pasa |
|---|---|
| `~/.claude/settings.json` | **Se fusiona** (no se reemplaza): añade reglas de permiso `deny`/`ask`, los hooks de seguridad (`PreToolUse`), la auto-actualización (`SessionStart`) y el aviso de fin de tarea (`Stop`). Backup en `settings.json.bak`. |
| `~/.claude/hooks/*.sh` | Se copian los hooks de seguridad de txampa + el de auto-actualización + el de aviso de fin de tarea. |
| `~/.claude/skills/{despega,cierra,ninera-prs}/` | Skills de flujo de worktrees y PRs — **solo si no existen** (tus versiones personalizadas no se tocan). |
| `~/.claude/CLAUDE.md` | Se crea con las buenas prácticas **solo si no existe**. Si ya tienes uno, **no se toca**. |
| `~/.claude/skills/obsidian-second-brain/` | Skill + comandos del segundo cerebro. |
| `~/.claude/.cache/claude-code-security-kit/` | Copia de trabajo del kit de seguridad (para actualizarse). |
| `~/.claude/skills/graphify/` | Skill de graphify (opcional: requiere `uv`, se instala solo si falta). |

Nada fuera de `~/.claude` se modifica, salvo: `~/.local/bin` en tu `PATH` si tuvo que instalar
Claude Code, o `uv` (`~/.local/share/uv`) si faltaba y quieres graphify — esto último es opcional
y el instalador sigue sin morir si no puede instalarlo.

## Hooks de seguridad

El kit de [txampa](https://github.com/txampa/claude-code-security-kit) instala tres guardas que
corren **antes** de cada acción:

- **`pre-bash-safety`** — bloquea comandos de shell peligrosos (borrados masivos, etc.).
- **`secret-scan`** — escanea en busca de secretos/claves antes de actuar.
- **`pre-commit-secrets`** — evita que se cuelen secretos en un commit.

> Esto **puede añadir prompts de permiso** o bloquear comandos que antes pasaban sin más. Es el
> comportamiento esperado. Si te estorba, borra los `.sh` correspondientes de `~/.claude/hooks/`
> (ver [Desinstalar](#desinstalar)).

## Arrancar

```
claude            # abre Claude Code
/ponytail         # activa el modo vago (código mínimo)
/obsidian-init    # prepara tu segundo cerebro
```

> **La primera vez** que abras `claude` te pedirá iniciar sesión: se abre el navegador
> y entras con tu cuenta de Claude. Si no tienes, créala en https://claude.ai. Solo pasa una vez.

## Mantenimiento

- **Automático**: al abrir Claude Code, un hook `SessionStart` actualiza plugins y skills
  en segundo plano, en silencio, como mucho **una vez al día** (log en `~/.claude/.starter-kit-update.log`).
  No tienes que hacer nada.
- **Manual**: si quieres forzar una actualización ya, re-corre la línea de instalación.
- **El repo**: un GitHub Action semanal comprueba que las fuentes upstream siguen vivas
  y abre un issue si alguna se mueve o desaparece — así el instalador no se pudre en silencio.

## Desinstalar

No hay desinstalador automático (el kit solo añade cosas, no destruye). Para revertir a mano:

```bash
# 1. settings.json — restaura el backup que dejó el instalador
cp ~/.claude/settings.json.bak ~/.claude/settings.json

# 2. hooks de seguridad y auto-actualización
rm -f ~/.claude/hooks/pre-bash-safety.sh ~/.claude/hooks/pre-commit-secrets.sh \
      ~/.claude/hooks/secret-scan.sh ~/.claude/hooks/starter-kit-autoupdate.sh \
      ~/.claude/hooks/notify-long-task.sh

# 2b. skills de flujo (opcional)
rm -rf ~/.claude/skills/despega ~/.claude/skills/cierra ~/.claude/skills/ninera-prs

# 3. segundo cerebro (opcional)
rm -rf ~/.claude/skills/obsidian-second-brain

# 4. plugins (opcional) — cada uno por separado
claude plugin uninstall ponytail@ponytail
claude plugin uninstall ecc@ecc
claude plugin uninstall vercel@claude-plugins-official
claude plugin uninstall security-guidance@claude-plugins-official
```

El `~/.claude/CLAUDE.md` lo creó el kit solo si no tenías uno: bórralo o edítalo a tu gusto.

## Siguiente nivel

Cosas populares que **no** instala el kit a propósito, para no duplicar lo que ya trae:

- **Principios de Karpathy** (Think Before Coding · Simplicity First · Surgical Changes ·
  Goal-Driven Execution): ya van de serie vía **ponytail** + el `CLAUDE.md` de buenas prácticas.
  No hace falta el plugin aparte.
- **Loops autónomos**: cuando quieras que Claude trabaje solo sobre tu repo (triage diario,
  vigilar PRs, barrer CI…), mira [`cobusgreyling/loop-engineering`](https://github.com/cobusgreyling/loop-engineering).
  La mecánica (worktrees, sub-agentes, scheduling) ya la tienes vía **ecc** (`/ecc:loop-start`,
  `autonomous-loops`, …); ese repo aporta los patrones curados y las CLIs de coste/auditoría.
- **Orquestación multi-agente/multi-CLI** (p.ej. [`professorpalmer/Puppetmaster`](https://github.com/professorpalmer/Puppetmaster)):
  resuelve coordinar varios CLIs de agentes (Claude Code, Cursor, Codex…) a la vez. Si solo usas
  Claude Code, **ecc** ya cubre worktrees/sub-agentes/loops dentro de un único CLI — no hace falta.
- **Otro CLAUDE.md de "buenas prácticas de Karpathy"** (p.ej. [`multica-ai/andrej-karpathy-skills`](https://github.com/multica-ai/andrej-karpathy-skills)):
  mismo caso que el punto de arriba, redundante con **ponytail**.
- **Colecciones de subagentes de marketing/agencia** (p.ej. [`msitarzewski/agency-agents`](https://github.com/msitarzewski/agency-agents)):
  la parte de ingeniería solapa casi al 100% con **ecc**; el resto (ads programáticos, sales B2B,
  redes sociales de mercado chino) no aplica a la mayoría de proyectos.
- **ASR / transcripción self-hosted** (p.ej. [`achetronic/parakeet`](https://github.com/achetronic/parakeet)):
  requiere mantener un servidor propio con modelo dedicado. Si solo necesitas transcribir podcasts,
  vídeos o hilos, `/podcast`, `/youtube` y `/x-read` de **obsidian-second-brain** ya lo resuelven
  vía API, sin infraestructura.
- **Librerías de enmascarado de PII para LLMs** (p.ej. [`ploybot-ai/prompt-shield`](https://github.com/ploybot-ai/prompt-shield)):
  útiles como referencia de patrón de diseño (placeholder reversible tipo `~REDACTED:TIPO#HASH~`),
  pero evalúa el stack antes de añadir una dependencia — el mismo patrón suele ser un puñado de
  líneas nativas en tu lenguaje.
- **Buen gusto de diseño frontend**: si generas mucha UI (React/Vue/HTML) y quieres que deje de
  parecer genérica, mira [`Leonxlnx/taste-skill`](https://github.com/Leonxlnx/taste-skill)
  (60k+ ⭐, soporta Claude Code de forma nativa: `npx skills add Leonxlnx/taste-skill`). No lo
  instala el kit a propósito — es un instalador de terceros y cada quien debe decidir si confía
  en él antes de correrlo, en vez de que quede horneado en un script que ejecutan otros.

## Licencia

[MIT](LICENSE) © Ignacio Noguerol.
