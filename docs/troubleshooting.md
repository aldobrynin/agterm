# Troubleshooting

A guide to checking what agterm is doing, the most common problems, and how to report one that turns out to be a bug.

## Where things live

Paths assume the defaults. When `AGTERM_STATE_DIR` is set, the state files move under that directory instead of `~/Library/Application Support/agterm`.

- **Keymap**: `~/.config/agterm/keymap.conf` (or `$AGTERM_STATE_DIR/config/keymap.conf`, or a custom directory set in Settings ▸ Key Mapping).
- **Settings**: `~/Library/Application Support/agterm/settings.json`.
- **Window and session state**: `~/Library/Application Support/agterm/windows.json` plus one `windows/<id>.json` per window.
- **Control socket**: `~/Library/Application Support/agterm/agterm.sock` (or `$AGTERM_CONTROL_SOCKET` when set). A spawned shell sees the bound path in `$AGTERM_SOCKET`.
- **Logs**: the macOS unified logging system, under the subsystem `com.umputun.agterm`.

## Reading the logs

agterm logs to the unified logging system, so use `log` or Console:

```bash
# the last 30 minutes, all categories
log show --predicate 'subsystem == "com.umputun.agterm"' --info --last 30m

# follow live while you reproduce the problem
log stream --predicate 'subsystem == "com.umputun.agterm"' --info

# narrow to one area
log show --predicate 'subsystem == "com.umputun.agterm" && category == "CustomCommandRunner"' --info --last 30m
```

The categories are `CustomCommandRunner`, `SettingsModel`, `GhosttyApp`, `NotificationManager`, and `ControlServer`. In Console.app, filter on the same subsystem.

## Checking the keymap

After editing `keymap.conf`, nothing changes until you reload it.

- **Settings ▸ Key Mapping** shows a read-only list of parse problems (a malformed line, a dropped binding, a conflict). This is the first place to look when a binding does not behave.
- **File ▸ Reload Keymap** re-reads the file. A reload that found problems posts a banner with the count.
- **`agtermctl keymap reload`** does the same from the command line and prints the diagnostic count (`0` means a clean reload).

## The keymap editor will not open

**Edit Keymap** (File ▸ Edit Keymap…, or the `⌃⇧P` palette) opens `keymap.conf` in `$VISUAL`, else `$EDITOR`, else `vi`, inside a floating overlay over the active session. The overlay runs the editor through your login shell, so the editor resolves the same way it does in a normal terminal.

Common causes when nothing usable appears:

1. **A GUI editor without its blocking flag.** Editors like VS Code, Sublime, Zed, and TextMate launch a detached window and return immediately, so the overlay opens and closes in a flash. Set the editor's wait flag so the launcher blocks until you close the file:

   ```bash
   export EDITOR='code -w'     # VS Code; also: 'subl -w', 'zed -w', 'mate -w', 'cursor -w'
   ```

2. **`$EDITOR` unset.** You get `vi` inside the overlay. Press `i` to start typing, then `Esc` and `:wq` to save and quit; the keymap reloads when the editor exits.
3. **No active session, or an overlay is already open.** Edit Keymap is a no-op with no session selected, or while another overlay or the quick terminal is up. Select a session and close any overlay first.

Set `$EDITOR` or `$VISUAL` in your shell startup file (`~/.zshrc`, `~/.bashrc`), not just in the current shell. The overlay reads it from your login shell, so an export that only lives in one terminal session is not seen.

## A custom action does nothing

Work down this list:

1. **Read the diagnostics.** Open Settings ▸ Key Mapping. A malformed `command` line is listed there and skipped.
2. **Chord conflict.** If your chord collides with a built-in shortcut or with another custom command, the binding is dropped and the command becomes palette-only. It still runs from the action palette (`⌃⇧P`), where it is listed with a `custom` tag. Pick a free chord, or run it from the palette.
3. **Reserved chords.** `ctrl+tab` / `ctrl+shift+tab` (the session switcher) and `ctrl+1` / `ctrl+2` (pane focus) are reserved and cannot be bound.
4. **Modifier-less keys are rejected.** A custom chord needs at least one modifier so it cannot shadow a plain terminal key. `command "x" g …` is palette-only; `command "x" cmd+g …` binds.
5. **Focus.** A custom chord fires only while a terminal pane holds keyboard focus. When the sidebar, the inline rename field, a Settings field, or a palette has focus, the chord passes through. Click into the terminal first.
6. **The command runs in a plain `/bin/sh -c`, not your login shell.** It does not load `~/.zshrc` or `~/.bashrc`, so shell aliases and functions are not available and `PATH` may be shorter than in your terminal. Use absolute paths, or wrap the body in `$SHELL -lc '…'`.
7. **Exit status.** A non-zero exit posts a failure banner with the code. No banner and no effect usually means the chord never fired (causes above). A banner means it ran and failed, which points at the command itself, its `PATH`, or its arguments.
8. **Token quoting.** `{AGT_SELECTION}` and the other `{AGT_*}` tokens expand raw into the shell line. For content that may contain shell metacharacters, use the `$AGT_SELECTION` environment form, which is already quoted. The token list is in the keymap section of the README.

Reload after every edit (File ▸ Reload Keymap, or `agtermctl keymap reload`). Edits are not applied until you do.

## Other common issues

- **`agtermctl: command not found`.** Install it from Help ▸ Install Command Line Tool… (it symlinks into `/usr/local/bin`). You can also call it by its full path inside the app bundle: `agterm.app/Contents/MacOS/agtermctl`.
- **No desktop notifications.** macOS must have granted permission (System Settings ▸ Notifications ▸ agterm), and Settings ▸ General ▸ Notifications must be on. The unseen-count badge still tracks even when banners are off.
- **Agent-status glyph does not update.** Install the hooks from Help ▸ Install Agent Status Hooks…, then start a fresh shell so the `source` line added to your shell rc takes effect. The hooks call `agtermctl session status`, so `agtermctl` must resolve first (see above).

## Reporting a problem

Collect this before filing:

- agterm version (agterm ▸ About agterm).
- macOS version.
- The exact steps, what you expected, and what happened instead.
- A log excerpt from the `log show` command above, covering the moment you reproduced it.
- The relevant `keymap.conf` lines, if it is keymap-related.

Scrub anything private (tokens, internal hostnames, usernames embedded in paths) before sharing.

If you run a coding agent inside agterm (Claude Code or Codex with the agterm skill installed), it can help you write and file the report: it drafts an issue for a bug, or a Discussion for a feature request or question, shows it to you first, and never posts without your go-ahead.

Otherwise open one directly:

- Bug: <https://github.com/umputun/agterm/issues/new>
- Idea or question: <https://github.com/umputun/agterm/discussions/new>
