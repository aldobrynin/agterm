import Foundation
import Testing
@testable import agtCore

struct ControlResolveTests {
    private let a = UUID(uuidString: "9F3CAAAA-0000-0000-0000-000000000001")!
    private let b = UUID(uuidString: "9FABBBBB-0000-0000-0000-000000000002")!
    private let c = UUID(uuidString: "1234CCCC-0000-0000-0000-000000000003")!

    @Test func activeResolvesToActiveID() {
        let result = ControlResolve.resolve("active", candidates: [a, b, c], active: b)
        #expect(result == .resolved(b))
    }

    @Test func activeWithNilActiveIsNotFound() {
        let result = ControlResolve.resolve("active", candidates: [a, b, c], active: nil)
        #expect(result == .notFound)
    }

    @Test func exactUUIDResolves() {
        let result = ControlResolve.resolve(a.uuidString, candidates: [a, b, c], active: nil)
        #expect(result == .resolved(a))
    }

    @Test func exactUUIDIsCaseInsensitive() {
        let result = ControlResolve.resolve(a.uuidString.lowercased(), candidates: [a, b, c], active: nil)
        #expect(result == .resolved(a))
    }

    @Test func uniquePrefixResolves() {
        // "1234" is unique to c
        let result = ControlResolve.resolve("1234", candidates: [a, b, c], active: nil)
        #expect(result == .resolved(c))
    }

    @Test func ambiguousPrefixListsHits() {
        // "9f" matches both a and b
        let result = ControlResolve.resolve("9f", candidates: [a, b, c], active: nil)
        #expect(result == .ambiguous([a, b]))
    }

    @Test func noMatchIsNotFound() {
        let result = ControlResolve.resolve("deadbeef", candidates: [a, b, c], active: nil)
        #expect(result == .notFound)
    }

    @Test func emptyCandidatesIsNotFound() {
        let result = ControlResolve.resolve("9f", candidates: [], active: nil)
        #expect(result == .notFound)
    }

    @Test func emptyTargetIsNotFound() {
        // an empty prefix would otherwise match every candidate — guard it to .notFound.
        #expect(ControlResolve.resolve("", candidates: [a, b, c], active: a) == .notFound)
        #expect(ControlResolve.resolve("", candidates: [a], active: nil) == .notFound)
    }

    @Test func socketPathWithStateDir() {
        let path = ControlResolve.socketPath(stateDir: "/tmp/agt-state", appSupport: "/Users/x/Library/Application Support/agt")
        #expect(path == "/tmp/agt-state/agt.sock")
    }

    @Test func socketPathWithoutStateDirUsesAppSupport() {
        let path = ControlResolve.socketPath(stateDir: nil, appSupport: "/Users/x/Library/Application Support/agt")
        #expect(path == "/Users/x/Library/Application Support/agt/agt.sock")
    }
}
