import Foundation

//1fc6:0061 and00cf. These data-only schedules run in native Swift.
//Optional on NativeDrill so an older in-progress drill keeps its saved timing.
struct NativeDrillPresentation: Codable {
    enum Stage: String, Codable { case introduction, questions, capture, rejection, result }
    enum Sound: Equatable { case play(Int), stop }
    var stage = Stage.introduction
    var elapsedIRQTicks = 0
    var started = false
    var frameTicks: Int { stage == .capture ? 50 : 20 }
    var duration: Int { stage == .capture ? 350 : 160 }
    var animated: Bool { [.introduction,.capture,.rejection].contains(stage) }
    var sprite: Int {
        if stage == .capture { return 3+elapsedIRQTicks/50 }
        if stage == .introduction || stage == .rejection { return 10+(elapsedIRQTicks/20)%2 }
        return stage == .result ? 2 : 12
    }
    mutating func beginResult(success: Bool) {
        stage = success ? .capture : .rejection; elapsedIRQTicks = 0; started = false
    }
    //Report consumed time so a coarse native pulse cannot lose time at a
    //presentation/question/result boundary. A saved started flag prevents
    //reissuing the current frame's sound after restore.
    mutating func advance(irqTicks: Int) -> (consumed: Int,sounds: [Sound]) {
        guard animated else { return (0,[]) }
        var sounds: [Sound] = []
        let sound = stage == .capture ? 48 : 23
        if !started { sounds.append(.play(sound));started = true }
        let consumed = min(max(0,irqTicks),duration-elapsedIRQTicks)
        let end = elapsedIRQTicks+consumed
        var boundary = (elapsedIRQTicks/frameTicks+1)*frameTicks
        while boundary < duration && boundary <= end {
            sounds.append(.play(sound));boundary += frameTicks
        }
        elapsedIRQTicks = end
        if end == duration {
            if stage != .capture { sounds.append(.stop) }
            stage = stage == .introduction ? .questions : .result
            elapsedIRQTicks = 0;started = false
        }
        return (consumed,sounds)
    }
    var valid: Bool {
        animated ? (0..<duration).contains(elapsedIRQTicks) : elapsedIRQTicks == 0 && !started
    }
}
