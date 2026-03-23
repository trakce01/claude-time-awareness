#!/bin/bash
# Time awareness hook for Claude Code
# Usage: time-awareness.sh inject-json | inject-text

BUDGET_FILE="/tmp/claude-time-budget-$PPID"
MODE="$1"

# No budget file = no injection
[ ! -f "$BUDGET_FILE" ] && exit 0

DEADLINE=$(cat "$BUDGET_FILE" 2>/dev/null)
[ -z "$DEADLINE" ] && exit 0

NOW=$(date +%s)
CURRENT_TIME=$(date +"%l:%M %p" | sed 's/^ //')
DIFF=$((DEADLINE - NOW))

if [ "$DIFF" -le 0 ]; then
  MSG="[$CURRENT_TIME | budget expired]"
else
  # Convert to human-readable
  HOURS=$((DIFF / 3600))
  MINS=$(( (DIFF % 3600) / 60 ))

  if [ "$HOURS" -gt 0 ] && [ "$MINS" -gt 0 ]; then
    REMAINING="~${HOURS}h ${MINS}m remaining"
  elif [ "$HOURS" -gt 0 ]; then
    REMAINING="~${HOURS}h remaining"
  else
    REMAINING="~${MINS}m remaining"
  fi

  MSG="[$CURRENT_TIME | $REMAINING]"
fi

case "$MODE" in
  inject-json)
    printf '{"hookSpecificOutput":{"hookEventName":"PreToolUse","additionalContext":"%s"}}' "$MSG"
    ;;
  inject-text)
    echo "$MSG"
    ;;
  *)
    exit 0
    ;;
esac
