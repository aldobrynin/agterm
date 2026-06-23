import Foundation

/// AgentStatus is the per-session agent state driven over the control channel (`session.status`).
/// `idle` means nothing is shown; the other cases each render a tinted sidebar glyph.
public enum AgentStatus: String, Codable, Sendable, CaseIterable {
    case idle, active, completed, blocked
}

/// AgentIndicator is the per-session agent status value: the state plus an optional blink flag (pulse
/// the glyph for attention) and an optional autoReset flag (clear back to idle once the session is
/// visited). It is ephemeral (never persisted) and set only via the control API.
public struct AgentIndicator: Equatable, Sendable {
    /// status is the current agent state; `.idle` renders no glyph.
    public var status: AgentStatus = .idle
    /// blink makes the visible glyph pulse for attention.
    public var blink: Bool = false
    /// autoReset, when true, the indicator resets to idle once the session is visited (selected) — a
    /// caller-set, status-agnostic flag, like blink.
    public var autoReset: Bool = false

    public init(status: AgentStatus = .idle, blink: Bool = false, autoReset: Bool = false) {
        self.status = status
        self.blink = blink
        self.autoReset = autoReset
    }
}
