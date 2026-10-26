import Foundation

// Original5bd7..5be8:0 untriggered,1 queued,ff already acknowledged.
// This range and5bef are inside the103-byte saved adventure block at5b8a.
struct NativeNewUserMessages: Codable {
    var enabled: Bool
    private(set) var flags = Array(repeating: 0,count: 18)
    var timedMessage: Int?
    var deadlineIRQ: UInt64?
    var valid: Bool {
        (deadlineIRQ == nil || deadlineIRQ! <= UInt64.max/4) && flags.count == 18 && flags.allSatisfy { [-1,0,1].contains($0) } &&
        (timedMessage == nil) == (deadlineIRQ == nil) && (timedMessage == nil || (0..<18).contains(timedMessage!))
    }
    init(enabled: Bool) { self.enabled = enabled }
    mutating func chooseEnabled(_ enabled: Bool) {
        self.enabled = enabled
        if enabled { flags = Array(repeating: 0,count: 18) }
    }
    mutating func queue(_ message: Int) {
        guard flags.indices.contains(message), flags[message] == 0 else { return }
        flags[message] = 1
    }
    func canShow(_ message: Int) -> Bool { flags.indices.contains(message) && enabled && flags[message] != -1 }
    mutating func acknowledge(_ message: Int) { if flags.indices.contains(message) { flags[message] = -1 } }
    func nextQueued(actorsSettled: Bool) -> Int? {
        guard enabled && actorsSettled else { return nil }
        return (0..<13).first { flags[$0] == 1 }
    }
    mutating func schedule(_ message: Int,after ticks: UInt64,now: UInt64) {
        guard flags.indices.contains(message),now <= UInt64.max-ticks else { return }
        timedMessage = message; deadlineIRQ = now+ticks
    }
    mutating func cancelTimed() {
        if let timedMessage { acknowledge(timedMessage) }
        timedMessage = nil; deadlineIRQ = nil
    }
    mutating func takeExpired(now: UInt64) -> Int? {
        guard let timedMessage,let deadlineIRQ, now > deadlineIRQ else { return nil }
        self.timedMessage = nil; self.deadlineIRQ = nil
        return canShow(timedMessage) ? timedMessage : nil
    }
}
