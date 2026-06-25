# claude-starter-kit

El setup completo de Claude Code en **un comando**: plugins, hooks de seguridad,
segundo cerebro y buenas prácticas. Pensado para empezar un proyecto bien desde el minuto cero.

## Instalar

```bash
curl -fsSL https://raw.githubusercontent.com/inoguerols/claude-starter-kit/main/install.sh | bash
```

Eso es todo. Si no tienes Claude Code, te lo instala. **Para actualizar en el futuro,
vuelve a correr la misma línea** (es idempotente).

> **Windows:** ejecútalo dentro de **WSL** o **Git Bash**. macOS y Linux funcionan tal cual.
> Recomendado tener `jq` instalado (para fusionar la config de seguridad sin pisar la tuya).

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

## Mantenimiento

- **Tú**: re-corre la línea de instalación cuando quieras actualizar todo.
- **El repo**: un GitHub Action semanal comprueba que las fuentes upstream siguen vivas
  y abre un issue si alguna se mueve o desaparece — así el instalador no se pudre en silencio.
