#!/usr/bin/env bash
# Auto-actualiza el starter-kit: corre al iniciar Claude Code, en segundo plano,
# en silencio, y como mucho una vez al día. Nunca bloquea ni rompe el arranque.
set -u
CLAUDE_DIR="$HOME/.claude"
STAMP="$CLAUDE_DIR/.starter-kit-last-update"
LOG="$CLAUDE_DIR/.starter-kit-update.log"

# throttle: salir si se actualizó hace menos de 24h
if [ -f "$STAMP" ]; then
  now=$(date +%s); last=$(cat "$STAMP" 2>/dev/null || echo 0)
  [ $((now - last)) -lt 86400 ] && exit 0
fi
date +%s > "$STAMP"

# el trabajo pesado va a un subproceso en background; el hook devuelve al instante
{
  echo "=== $(date) starter-kit autoupdate ==="
  for p in ponytail@ponytail ecc@ecc vercel@claude-plugins-official security-guidance@claude-plugins-official; do
    command -v claude >/dev/null 2>&1 && claude plugin update "$p" 2>&1 || true
  done
  for d in "$CLAUDE_DIR/skills/obsidian-second-brain" "$CLAUDE_DIR/.cache/claude-code-security-kit"; do
    [ -d "$d/.git" ] && git -C "$d" pull --quiet 2>&1 || true
  done
  SEC="$CLAUDE_DIR/.cache/claude-code-security-kit/hooks"
  [ -d "$SEC" ] && for f in "$SEC"/*.sh; do install -m 0755 "$f" "$CLAUDE_DIR/hooks/$(basename "$f")" 2>&1 || true; done
  echo "=== fin ==="
} >> "$LOG" 2>&1 &

exit 0
