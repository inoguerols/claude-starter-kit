#!/usr/bin/env bash
# claude-starter-kit — instala (y actualiza) el setup completo de Claude Code.
# Re-ejecutar esta misma línea ACTUALIZA todo. Es idempotente.
set -euo pipefail

# --- estilo / helpers --------------------------------------------------------
b() { printf '\033[1m%s\033[0m\n' "$*"; }
ok() { printf '  \033[32m✔\033[0m %s\n' "$*"; }
warn() { printf '  \033[33m!\033[0m %s\n' "$*"; }
die() { printf '\033[31m✖ %s\033[0m\n' "$*" >&2; exit 1; }

CLAUDE_DIR="$HOME/.claude"
HOOKS_DIR="$CLAUDE_DIR/hooks"
SKILLS_DIR="$CLAUDE_DIR/skills"
RAW_BASE="https://raw.githubusercontent.com/inoguerols/claude-starter-kit/main"

mkdir -p "$HOOKS_DIR" "$SKILLS_DIR"

# --- 0. requisitos -----------------------------------------------------------
command -v git >/dev/null 2>&1 || die "Necesitas git instalado."
HAVE_JQ=1; command -v jq >/dev/null 2>&1 || HAVE_JQ=0

# --- 1. Claude Code ----------------------------------------------------------
b "1/6  Claude Code"
if ! command -v claude >/dev/null 2>&1; then
  warn "no encontrado; instalando…"
  if curl -fsSL https://claude.ai/install.sh | bash; then :;
  elif command -v npm >/dev/null 2>&1; then npm install -g @anthropic-ai/claude-code;
  else die "No pude instalar Claude Code. Instálalo con: npm install -g @anthropic-ai/claude-code"; fi
  export PATH="$HOME/.local/bin:$PATH"
fi
command -v claude >/dev/null 2>&1 || die "Claude Code instalado pero no está en PATH. Abre una terminal nueva y vuelve a correr esto."
ok "$(claude --version 2>/dev/null | head -1)"

# --- 2. marketplaces + plugins ----------------------------------------------
b "2/6  Plugins"
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
b "3/6  Hooks de seguridad (txampa/claude-code-security-kit)"
SEC_DIR="$CLAUDE_DIR/.cache/claude-code-security-kit"
if [ -d "$SEC_DIR/.git" ]; then git -C "$SEC_DIR" pull --quiet || true
else git clone --quiet https://github.com/txampa/claude-code-security-kit.git "$SEC_DIR"; fi
for f in "$SEC_DIR"/hooks/*.sh; do install -m 0755 "$f" "$HOOKS_DIR/$(basename "$f")"; done
ok "hooks copiados a $HOOKS_DIR"

# hook de auto-actualización (corre al iniciar Claude, en background, 1×/día)
curl -fsSL "$RAW_BASE/hooks/autoupdate.sh" -o "$HOOKS_DIR/starter-kit-autoupdate.sh" \
  && chmod +x "$HOOKS_DIR/starter-kit-autoupdate.sh" && ok "auto-actualización instalada" \
  || warn "no pude instalar el hook de auto-actualización"

# merge de settings: permisos + hooks de seguridad (rutas → \$HOME) + SessionStart de auto-update
TPL="$(sed 's#\$CLAUDE_PROJECT_DIR/.claude/hooks#$HOME/.claude/hooks#g' "$SEC_DIR/settings.template.json")"
SETTINGS="$CLAUDE_DIR/settings.json"
SU='[{"hooks":[{"type":"command","command":"bash \"$HOME/.claude/hooks/starter-kit-autoupdate.sh\"","async":true}]}]'
if [ "$HAVE_JQ" -eq 0 ]; then
  warn "jq no instalado: no fusiono settings ni activo la auto-actualización."
  warn "Instala jq y re-ejecuta. Plantilla a mano: $SEC_DIR/settings.template.json"
else
  [ -f "$SETTINGS" ] && cp "$SETTINGS" "$SETTINGS.bak" || echo '{}' > "$SETTINGS.bak"
  printf '%s' "$TPL" | jq -s --argjson su "$SU" '
    .[0] as $cur | .[1] as $tpl | $cur
    | .permissions.deny   = (((.permissions.deny   // []) + ($tpl.permissions.deny   // [])) | unique)
    | .permissions.ask    = (((.permissions.ask    // []) + ($tpl.permissions.ask    // [])) | unique)
    | .permissions.allow  = (((.permissions.allow  // []) + ($tpl.permissions.allow  // [])) | unique)
    | .hooks.PreToolUse   = (((.hooks.PreToolUse   // []) + ($tpl.hooks.PreToolUse   // [])) | unique)
    | .hooks.SessionStart = (((.hooks.SessionStart // []) + $su) | unique)
  ' "$SETTINGS.bak" /dev/stdin > "$SETTINGS"
  ok "settings.json fusionado + auto-actualización activada (backup en settings.json.bak)"
fi

# --- 4. segundo cerebro Obsidian --------------------------------------------
b "4/6  Segundo cerebro (obsidian-second-brain)"
OBS_DIR="$SKILLS_DIR/obsidian-second-brain"
if [ -d "$OBS_DIR/.git" ]; then git -C "$OBS_DIR" pull --quiet || true
else git clone --quiet https://github.com/eugeniughelbur/obsidian-second-brain.git "$OBS_DIR"; fi
bash "$OBS_DIR/install.sh" >/dev/null 2>&1 && ok "skill + comandos instalados" || warn "revisa $OBS_DIR/install.sh"

# --- 5. CLAUDE.md con buenas prácticas --------------------------------------
b "5/6  Buenas prácticas (CLAUDE.md)"
if [ -f "$CLAUDE_DIR/CLAUDE.md" ]; then
  warn "Ya tienes ~/.claude/CLAUDE.md; no lo toco. Plantilla en $RAW_BASE/templates/CLAUDE.md"
else
  curl -fsSL "$RAW_BASE/templates/CLAUDE.md" -o "$CLAUDE_DIR/CLAUDE.md" && ok "CLAUDE.md instalado" \
    || warn "no pude descargar la plantilla CLAUDE.md"
fi

# --- 6. listo ----------------------------------------------------------------
b "6/6  Listo 🎉"
cat <<'EOF'

  Para ACTUALIZAR en el futuro: vuelve a correr la misma línea de instalación.

  Arranca:
    claude            # abre Claude Code
    /ponytail         # activa el modo vago (código mínimo)
    /obsidian-init    # prepara tu segundo cerebro

EOF
