#!/usr/bin/env bash
# claude-starter-kit — instala (y actualiza) el setup completo de Claude Code.
# Re-ejecutar esta misma línea ACTUALIZA todo. Es idempotente.
set -euo pipefail

# --- estilo / helpers --------------------------------------------------------
b() { printf '\033[1m%s\033[0m\n' "$*"; }
ok() { printf '  \033[32m✔\033[0m %s\n' "$*"; }
warn() { printf '  \033[33m!\033[0m %s\n' "$*"; }
die() { printf '\033[31m✖ %s\033[0m\n' "$*" >&2; exit 1; }

# la instalación nativa deja el binario en ~/.local/bin; persiste ese dir en el
# PATH del shell del usuario (idempotente) para que 'claude' funcione en terminales nuevas.
persist_path() {
  local bindir="$HOME/.local/bin"
  [ -x "$bindir/claude" ] || return 0
  case ":$PATH:" in *":$bindir:"*) ;; *) export PATH="$bindir:$PATH";; esac
  local line='export PATH="$HOME/.local/bin:$PATH"'
  for rc in "$HOME/.zshrc" "$HOME/.bashrc" "$HOME/.profile"; do
    [ -f "$rc" ] || continue
    grep -qF '.local/bin' "$rc" 2>/dev/null && continue
    printf '\n# claude-starter-kit\n%s\n' "$line" >> "$rc"
    ok "PATH añadido a $(basename "$rc") (reinicia la terminal o: source $rc)"
  done
}

CLAUDE_DIR="$HOME/.claude"
HOOKS_DIR="$CLAUDE_DIR/hooks"
SKILLS_DIR="$CLAUDE_DIR/skills"
RAW_BASE="https://raw.githubusercontent.com/inoguerols/claude-starter-kit/main"

mkdir -p "$HOOKS_DIR" "$SKILLS_DIR"

# --- 0. requisitos -----------------------------------------------------------
command -v git >/dev/null 2>&1 || die "Necesitas git instalado."
HAVE_JQ=1; command -v jq >/dev/null 2>&1 || HAVE_JQ=0

# --- 1. Claude Code ----------------------------------------------------------
b "1/7  Claude Code"
if ! command -v claude >/dev/null 2>&1; then
  warn "no encontrado; instalando…"
  if curl -fsSL https://claude.ai/install.sh | bash; then :;
  elif command -v npm >/dev/null 2>&1; then npm install -g @anthropic-ai/claude-code;
  else die "No pude instalar Claude Code. Instálalo con: npm install -g @anthropic-ai/claude-code"; fi
fi
persist_path  # asegura ~/.local/bin en el PATH (este shell y los futuros)
command -v claude >/dev/null 2>&1 || die "Claude Code instalado pero no está en PATH. Abre una terminal nueva y vuelve a correr esto."
ok "$(claude --version 2>/dev/null | head -1)"

# --- 2. marketplaces + plugins ----------------------------------------------
b "2/7  Plugins"
mkt() { # nombre  fuente
  if claude plugin marketplace list 2>/dev/null | grep -q "$1"; then
    claude plugin marketplace update "$1" >/dev/null 2>&1 || true
  else
    claude plugin marketplace add "$2" >/dev/null 2>&1 || warn "no pude añadir marketplace $1"
  fi
}
plug() { # plugin@marketplace
  if claude plugin list 2>/dev/null | grep -q "${1%@*}"; then
    claude plugin update "$1" >/dev/null 2>&1 || true; ok "actualizado $1"
  else
    claude plugin install "$1" -s user >/dev/null 2>&1 && ok "instalado $1" || warn "no pude instalar $1"
  fi
}
mkt ponytail                  "DietrichGebert/ponytail"
mkt ecc                       "https://github.com/affaan-m/ECC.git"
mkt claude-plugins-official   "anthropics/claude-plugins-official"
plug ponytail@ponytail
plug ecc@ecc
plug vercel@claude-plugins-official
plug security-guidance@claude-plugins-official

# --- 3. kit de seguridad de txampa (hooks) ----------------------------------
b "3/7  Hooks de seguridad (txampa/claude-code-security-kit)"
SEC_DIR="$CLAUDE_DIR/.cache/claude-code-security-kit"
if [ -d "$SEC_DIR/.git" ]; then git -C "$SEC_DIR" pull --quiet || true
else git clone --quiet https://github.com/txampa/claude-code-security-kit.git "$SEC_DIR"; fi
for f in "$SEC_DIR"/hooks/*.sh; do install -m 0755 "$f" "$HOOKS_DIR/$(basename "$f")"; done
ok "hooks copiados a $HOOKS_DIR"

# hook de auto-actualización (corre al iniciar Claude, en background, 1×/día)
curl -fsSL "$RAW_BASE/hooks/autoupdate.sh" -o "$HOOKS_DIR/starter-kit-autoupdate.sh" \
  && chmod +x "$HOOKS_DIR/starter-kit-autoupdate.sh" && ok "auto-actualización instalada" \
  || warn "no pude instalar el hook de auto-actualización"

# hook de aviso de fin de tarea larga (Stop, >90s → notificación del sistema)
curl -fsSL "$RAW_BASE/hooks/notify-long-task.sh" -o "$HOOKS_DIR/notify-long-task.sh" \
  && chmod +x "$HOOKS_DIR/notify-long-task.sh" && ok "aviso de fin de tarea instalado" \
  || warn "no pude instalar el hook de aviso"

# merge de settings: permisos + hooks de seguridad (rutas → \$HOME) + SessionStart de auto-update
TPL="$(sed 's#\$CLAUDE_PROJECT_DIR/.claude/hooks#$HOME/.claude/hooks#g' "$SEC_DIR/settings.template.json")"
SETTINGS="$CLAUDE_DIR/settings.json"
SU='[{"hooks":[{"type":"command","command":"bash \"$HOME/.claude/hooks/starter-kit-autoupdate.sh\"","async":true}]}]'
STOP='[{"matcher":"","hooks":[{"type":"command","command":"bash \"$HOME/.claude/hooks/notify-long-task.sh\"","timeout":10,"async":true}]}]'
if [ "$HAVE_JQ" -eq 0 ]; then
  warn "jq no instalado: no fusiono settings ni activo la auto-actualización."
  warn "Instala jq y re-ejecuta. Plantilla a mano: $SEC_DIR/settings.template.json"
else
  [ -f "$SETTINGS" ] && cp "$SETTINGS" "$SETTINGS.bak" || echo '{}' > "$SETTINGS.bak"
  printf '%s' "$TPL" | jq -s --argjson su "$SU" --argjson stop "$STOP" '
    .[0] as $cur | .[1] as $tpl | $cur
    | .permissions.deny   = (((.permissions.deny   // []) + ($tpl.permissions.deny   // [])) | unique)
    | .permissions.ask    = (((.permissions.ask    // []) + ($tpl.permissions.ask    // [])) | unique)
    | .permissions.allow  = (((.permissions.allow  // []) + ($tpl.permissions.allow  // [])) | unique)
    | .hooks.PreToolUse   = (((.hooks.PreToolUse   // []) + ($tpl.hooks.PreToolUse   // [])) | unique)
    | .hooks.SessionStart = (((.hooks.SessionStart // []) + $su) | unique)
    | .hooks.Stop         = (((.hooks.Stop         // []) + $stop) | unique)
  ' "$SETTINGS.bak" /dev/stdin > "$SETTINGS"
  ok "settings.json fusionado + auto-actualización activada (backup en settings.json.bak)"
fi

# --- 4. segundo cerebro Obsidian --------------------------------------------
b "4/7  Segundo cerebro (obsidian-second-brain)"
OBS_DIR="$SKILLS_DIR/obsidian-second-brain"
if [ -d "$OBS_DIR/.git" ]; then git -C "$OBS_DIR" pull --quiet || true
else git clone --quiet https://github.com/eugeniughelbur/obsidian-second-brain.git "$OBS_DIR"; fi
bash "$OBS_DIR/install.sh" >/dev/null 2>&1 && ok "skill + comandos instalados" || warn "revisa $OBS_DIR/install.sh"

# --- 5. graphify (grafo de conocimiento del repo) ----------------------------
b "5/7  Graphify (grafo de conocimiento)"
if ! command -v uv >/dev/null 2>&1; then
  curl -LsSf https://astral.sh/uv/install.sh | sh >/dev/null 2>&1 || true
  case ":$PATH:" in *":$HOME/.local/bin:"*) ;; *) export PATH="$HOME/.local/bin:$PATH";; esac
fi
if command -v uv >/dev/null 2>&1; then
  (uv tool install graphifyy >/dev/null 2>&1 || uv tool upgrade graphifyy >/dev/null 2>&1) \
    && command -v graphify >/dev/null 2>&1 \
    && graphify install --platform claude >/dev/null 2>&1 \
    && ok "graphify instalado (/graphify)" \
    || warn "no pude instalar graphify (opcional)"
else
  warn "no pude instalar 'uv'; graphify omitido (opcional). Instálalo a mano: https://astral.sh/uv"
fi

# --- 6. CLAUDE.md con buenas prácticas + skills de flujo ----------------------
b "6/7  Buenas prácticas (CLAUDE.md) y skills de flujo"
# skills genéricas de flujo de trabajo — solo si no las tienes ya (respeta tus versiones personalizadas)
for s in despega cierra ninera-prs; do
  if [ -f "$SKILLS_DIR/$s/SKILL.md" ]; then ok "skill /$s ya existe; no la toco"
  else
    mkdir -p "$SKILLS_DIR/$s"
    curl -fsSL "$RAW_BASE/skills/$s/SKILL.md" -o "$SKILLS_DIR/$s/SKILL.md" && ok "skill /$s instalada" \
      || warn "no pude instalar la skill $s"
  fi
done
if [ -f "$CLAUDE_DIR/CLAUDE.md" ]; then
  warn "Ya tienes ~/.claude/CLAUDE.md; no lo toco. Plantilla en $RAW_BASE/templates/CLAUDE.md"
else
  curl -fsSL "$RAW_BASE/templates/CLAUDE.md" -o "$CLAUDE_DIR/CLAUDE.md" && ok "CLAUDE.md instalado" \
    || warn "no pude descargar la plantilla CLAUDE.md"
fi

# --- 7. listo ----------------------------------------------------------------
b "7/7  Listo 🎉"
cat <<'EOF'

  Para ACTUALIZAR en el futuro: vuelve a correr la misma línea de instalación.

  Arranca:
    claude            # abre Claude Code
    /ponytail         # activa el modo vago (código mínimo)
    /obsidian-init    # prepara tu segundo cerebro

EOF
