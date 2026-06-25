# claude-starter-kit

El setup completo de Claude Code en **un comando**: plugins, hooks de seguridad,
segundo cerebro y buenas prácticas. Pensado para empezar un proyecto bien desde el minuto cero.

## Instalar

```bash
curl -fsSL https://raw.githubusercontent.com/inoguerols/claude-starter-kit/main/install.sh | bash
```

Eso es todo. Si no tienes Claude Code, te lo instala. **Para actualizar en el futuro,
vuelve a correr la misma línea** (es idempotente).

> En **macOS y Linux** funciona tal cual (la terminal ya trae todo).
> Recomendado tener `jq` (`brew install jq` en Mac). Si falta, el instalador avisa y sigue.

### Windows: prepara la terminal una vez

El comando de arriba necesita una terminal tipo Linux. Elige **una** opción y, dentro de ella, pega el comando de instalación:

**Opción A — WSL (recomendada):**
1. Abre **PowerShell como administrador** (botón derecho → "Ejecutar como administrador").
2. Ejecuta: `wsl --install`
3. Reinicia el ordenador cuando lo pida.
4. Abre **"Ubuntu"** desde el menú Inicio y pega ahí el comando de instalación.

**Opción B — Git Bash:**
1. Descarga e instala Git desde **https://git-scm.com/download/win** (deja las opciones por defecto).
2. Abre **"Git Bash"** desde el menú Inicio y pega ahí el comando de instalación.

## Qué instala

| Pieza | Para qué |
|---|---|
| **ponytail** | Modo "vago": código mínimo, nada de sobre-ingeniería. |
| **ecc** | Agentes de review, testing y orquestación (`/ecc:code-review`, `/ecc:plan`, …). |
| **vercel** | Desplegar en Vercel desde Claude. |
| **security-guidance** (oficial Anthropic) | Detecta vulnerabilidades mientras programas. |
| **claude-code-security-kit** (de [txampa](https://github.com/txampa/claude-code-security-kit)) | Hooks que bloquean comandos peligrosos y escanean secretos antes de cada acción. |
| **obsidian-second-brain** | Notas, board y research que se auto-mantienen. `/obsidian-init` para arrancar. |
| **CLAUDE.md** | Buenas prácticas + memoria persistente (no sobrescribe si ya tienes uno). |

## Arrancar

```
claude            # abre Claude Code
/ponytail         # modo vago
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
