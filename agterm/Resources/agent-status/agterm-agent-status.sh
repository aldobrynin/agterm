#!/usr/bin/env bash
# agterm-agent-status — set the current agterm session's agent-status indicator.
#
#   agterm-agent-status.sh active           # agent is busy
#   agterm-agent-status.sh completed         # agent finished a turn
#   agterm-agent-status.sh blocked  --blink  # agent is waiting on you (pulse for attention)
#   agterm-agent-status.sh idle              # clear the indicator
#
# States: idle | active | completed | blocked. An optional --blink (and any
# further args) is forwarded verbatim to `agtermctl session status`.
#
# Outside agterm this is a silent no-op, so it is safe to call from any hook.
#
# agtermctl resolution order (the binary that talks to the control socket):
#   1. $AGTERMCTL — an explicit override the caller set.
#   2. the absolute bundled-binary path the installer bakes in (Task 9): the
#      installer rewrites the AGTERMCTL default below to agterm.app's
#      Contents/MacOS/agtermctl, so the hook fires even when the CLI was never
#      symlinked into PATH.
#   3. `agtermctl` on PATH — the fallback when nothing above resolved.
set -u

[ -n "${AGTERM_SESSION_ID:-}" ] || exit 0   # not inside agterm: nothing to do

exec "${AGTERMCTL:-agtermctl}" --socket "${AGTERM_SOCKET:-}" \
  session status "$1" --target "$AGTERM_SESSION_ID" "${@:2}"
