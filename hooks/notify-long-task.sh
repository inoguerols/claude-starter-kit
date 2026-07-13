#!/bin/bash
# claude-starter-kit — hook Stop: notificación del sistema si el turno duró >90s.
# Fin de la supervisión por sondeo: deja de preguntar "¿cómo vas?", te avisa él.
input=$(cat)
tp=$(echo "$input" | jq -r '.transcript_path // empty')
[ -f "$tp" ] || exit 0
# último prompt humano ≈ último mensaje user con content string (los pegados con imagen no cuentan)
last=$(jq -r 'select(.type=="user") | select(.message.content|type=="string") | .timestamp' "$tp" 2>/dev/null | tail -1)
[ -n "$last" ] || exit 0
last_s=$(TZ=UTC date -j -f "%Y-%m-%dT%H:%M:%S" "${last%%.*}" +%s 2>/dev/null || date -u -d "${last%%.*}" +%s 2>/dev/null)
[ -n "$last_s" ] || exit 0
now_s=$(date -u +%s)
[ $((now_s - last_s)) -gt 90 ] || exit 0
if command -v osascript >/dev/null 2>&1; then
  osascript -e 'display notification "Tarea terminada — listo para revisar" with title "Claude Code" sound name "Glass"' >/dev/null 2>&1
elif command -v notify-send >/dev/null 2>&1; then
  notify-send "Claude Code" "Tarea terminada — listo para revisar" >/dev/null 2>&1
fi
exit 0
