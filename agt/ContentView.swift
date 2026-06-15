import agtCore
import AppKit
import SwiftUI

/// Top-level layout: the workspace/session sidebar on the left, the active
/// session's terminal surface on the right. The detail pane swaps surfaces via
/// `.id(session.id)` — each session gets its own `TerminalView` identity, so the
/// session-owned surfaces survive switching.
///
/// The sidebar is an AppKit `NSOutlineView` (`WorkspaceSidebar`) so cross-workspace
/// drag-and-drop works natively. The bottom bar holds two add affordances: a
/// workspace button and a session menu (New Session / Open Directory…).
struct ContentView: View {
    @Bindable var store: AppStore
    let makeSurface: (Session) -> GhosttySurfaceView

    var body: some View {
        NavigationSplitView {
            WorkspaceSidebar(store: store)
                .navigationSplitViewColumnWidth(min: 180, ideal: 220)
                .safeAreaInset(edge: .bottom) { bottomBar }
        } detail: {
            if let active = store.activeSession {
                TerminalView(session: active, makeSurface: makeSurface)
                    .id(active.id)
            } else {
                Text("No session selected")
                    .foregroundStyle(.secondary)
            }
        }
    }

    /// Two distinct add controls, source-list style: add a workspace, and a menu
    /// to add a session to the current workspace (default cwd) or a picked directory.
    private var bottomBar: some View {
        HStack(spacing: 2) {
            Button {
                store.addWorkspace(name: defaultWorkspaceName)
            } label: {
                Image(systemName: "rectangle.stack.badge.plus")
                    .frame(width: 24, height: 22)
                    .contentShape(Rectangle())
            }
            .buttonStyle(.borderless)
            .help("New Workspace")
            .accessibilityLabel("New Workspace")

            Menu {
                Button("New Session") { addSessionToCurrentWorkspace() }
                Button("Open Directory…") { openDirectoryThenAddSession() }
            } label: {
                Image(systemName: "plus.rectangle")
                    .frame(width: 24, height: 22)
                    .contentShape(Rectangle())
            }
            .menuStyle(.borderlessButton)
            .menuIndicator(.hidden)
            .fixedSize()
            .help("New Session")
            .accessibilityLabel("Add session")
            .accessibilityIdentifier("add-session")

            Spacer()
        }
        .padding(.horizontal, 6)
        .padding(.vertical, 4)
        .background(.bar)
    }

    private var defaultWorkspaceName: String {
        "workspace \(store.workspaces.count + 1)"
    }

    /// The workspace a new session should land in: the selected session's
    /// workspace, else the last workspace. (Empty/specific workspaces can still be
    /// targeted via the workspace row's right-click menu.)
    private var currentWorkspaceID: UUID? {
        if let selected = store.selectedSessionID, let workspace = store.workspace(forSession: selected) {
            return workspace.id
        }
        return store.workspaces.last?.id
    }

    private func addSessionToCurrentWorkspace() {
        guard let workspaceID = currentWorkspaceID,
              let session = store.addSession(toWorkspace: workspaceID, cwd: FileManager.default.homeDirectoryForCurrentUser.path)
        else { return }
        store.selectSession(session.id)
    }

    private func openDirectoryThenAddSession() {
        guard let workspaceID = currentWorkspaceID else { return }
        let panel = NSOpenPanel()
        panel.canChooseDirectories = true
        panel.canChooseFiles = false
        panel.allowsMultipleSelection = false
        panel.prompt = "Open"
        panel.message = "Choose a directory for the new session"
        guard panel.runModal() == .OK, let url = panel.url,
              let session = store.addSession(toWorkspace: workspaceID, cwd: url.path)
        else { return }
        store.selectSession(session.id)
    }
}
