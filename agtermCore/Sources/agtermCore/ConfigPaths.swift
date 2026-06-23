import Foundation

/// Pure resolvers for the user-editable config directory and the keymap file path, mirroring
/// `ControlResolve`'s shape (an enum of static resolvers) so the app and any host-free caller agree
/// on where the keymap lives.
public enum ConfigPaths {
    /// Resolve the config directory holding `keymap.conf`. Precedence:
    /// - explicit `setting` (the `AppSettings.configDirectory` value, when non-nil/non-empty) wins.
    /// - else `<stateDir>/config` when `stateDir` (the `AGTERM_STATE_DIR` value) is set — test isolation.
    /// - else `<home>/.config/agterm`.
    public static func configDirectory(setting: String?, stateDir: String?, home: URL) -> URL {
        if let setting, !setting.isEmpty { return URL(fileURLWithPath: setting) }
        if let stateDir, !stateDir.isEmpty {
            return URL(fileURLWithPath: stateDir).appendingPathComponent("config")
        }
        return home.appendingPathComponent(".config").appendingPathComponent("agterm")
    }

    /// The keymap file path within a resolved config directory: `<dir>/keymap.conf`.
    public static func keymapPath(configDirectory: URL) -> URL {
        configDirectory.appendingPathComponent("keymap.conf")
    }

    /// The shell command that opens `keymapPath` in the user's editor: `$VISUAL` else `$EDITOR` else
    /// `vi`, with the path single-quoted for safe `/bin/sh` interpolation. Meant to run in the overlay's
    /// login shell, so an `$EDITOR`/`$VISUAL` exported from the user's login-shell startup is honored
    /// (one set only in `~/.zshrc` is not, since the overlay's inner shell is non-interactive).
    public static func editorCommand(forKeymapPath keymapPath: String) -> String {
        "${VISUAL:-${EDITOR:-vi}} '\(keymapPath.replacingOccurrences(of: "'", with: "'\\''"))'"
    }
}
