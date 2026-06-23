#!/usr/bin/env bash
# agterm-agent-status — Codex notify chain.
#
# Codex fires its `notify` program when a turn completes, passing a single JSON
# argument describing the event. Point Codex at this script to set the agterm
# session's agent-status indicator each turn, then forward the exact arguments
# to whatever notify program you had before (so existing integrations keep
# working).
#
#   ~/.codex/config.toml:
#   notify = ["/path/to/agterm-agent-status/codex-notify.sh"]
#
# If you already had a notify program, keep it running by setting its path:
#   export AGTERM_NOTIFY_FORWARD="/path/to/old/notify"
#
# State: a completed turn sets `completed --auto-reset` (the indicator clears
# once you visit the session); if the payload indicates Codex is awaiting your
# input (a permission/approval prompt) it sets `blocked --blink` instead, which
# is kept until the next state change. Outside agterm the underlying wrapper is a
# no-op, so this is safe to wire unconditionally.
set -u

_dir="$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")" >/dev/null 2>&1 && pwd)"
_bin="${AGTERM_AGENT_BIN:-$_dir/agterm-agent-status.sh}"

# the JSON payload Codex passes as the first argument (empty when invoked bare).
_payload="${1:-}"

# treat the turn as "blocked" when the payload mentions awaiting input — an
# approval/permission request. plain string match keeps this dependency-free
# (no jq); Codex's own completed-turn events don't carry these tokens.
if printf '%s' "$_payload" | grep -qiE 'input[-_ ]?needed|awaiting[-_ ]?input|approval|permission|requires?[-_ ]?(input|approval)'; then
  "$_bin" blocked --blink
else
  "$_bin" completed --auto-reset
fi

FORWARD="${AGTERM_NOTIFY_FORWARD:-}"
[ -n "$FORWARD" ] && [ -x "$FORWARD" ] && exec "$FORWARD" "$@"
exit 0
