import Cocoa

// Native data/state only. No BIOS or original interrupt code executes.
struct OriginalKeyboardQueue<Element> {
    private(set) var values: [Element] = []
    mutating func append(_ value: Element) { values.append(value) }
    mutating func read() -> Element? { values.isEmpty ? nil : values.removeFirst() }
    //1b9d:0361 repeatedly reads03ad until03c3 is empty, returning ONLY last.
    mutating func drainLatest() -> Element? { defer { values.removeAll() };return values.last }
    mutating func flush() { values.removeAll() } //037f reads0350, no03ad side effects.
}

struct OriginalHeldKeyboard {
    var left = false,right = false,up = false,space = false
    var leftFlip = false,rightFlip = false
    private var spaceDown = false
    static let movement: Set<UInt16> = [123,124,126,49,115,116,111]
    mutating func press(_ key: UInt16,repeatKey: Bool = false) {
        switch key {
        case 123: left = true
        case 124: right = true
        case 126: up = true
        case 115,111: leftFlip = true //Home/F12 original scan47/58
        case 116: rightFlip = true //PageUp original scan49
        case 49:
            space = !spaceDown && !repeatKey;spaceDown = true
        default: break
        }
        latchFlips()
    }
    mutating func release(_ key: UInt16) {
        switch key {
        case 123: left = false;leftFlip = false
        case 124: right = false;rightFlip = false
        case 126: up = false;leftFlip = false;rightFlip = false
        case 115,111: leftFlip = false
        case 116: rightFlip = false
        case 49: space = false;spaceDown = false
        default: break
        }
        latchFlips()
    }
    private mutating func latchFlips() {
        leftFlip = leftFlip || (up && left)
        rightFlip = rightFlip || (up && right)
    }
}

extension NativeGameView {
    override func keyDown(with event: NSEvent) {
        physicalKeyboard.press(event.keyCode,repeatKey: event.isARepeat)
        if screen == .world {
            //The source IRQ consumes movement in gameplay mode11a9=1;
            //other make codes chain to BIOS and are polled by the world loop.
            if !OriginalHeldKeyboard.movement.contains(event.keyCode) { keyboard.append(event) }
            return
        }
        if screen == .practice,let practice {
            if [.response,.waitingForSound].contains(practice.presentation) { keyboard.append(event);return }
            if practice.presentation == .introduction || (practice.presentation == .questions && practice.drill.phase != .asking) { return }
        }
        if screen == .drill,let drill = session?.activeDrill {
            if let stage = drill.presentation?.stage,[.capture,.rejection,.result].contains(stage) { keyboard.append(event);return }
            if drill.presentation?.stage == .introduction || drill.phase != .asking && drill.phase != .finished { return }
        }
        //Activity drawing precedes the editor's explicit input flush.
        if isActivityPresenting { return }
        handleKeyDown(event)
    }
    override func keyUp(with event: NSEvent) {
        physicalKeyboard.release(event.keyCode);held.remove(event.keyCode)
    }
    override func resignFirstResponder() -> Bool {
        //macOS focus loss has no DOS equivalent; avoid stuck held keys.
        physicalKeyboard = OriginalHeldKeyboard();keyboard.flush();held.removeAll();return true
    }
    func pollWorldKeyboard() {
        guard screen == .world,!isTransitioning,session?.activeZap == nil,session?.activeFountain == nil else { return }
        if let event = keyboard.drainLatest(),[48,53,122,120,99].contains(event.keyCode) { handleKeyDown(event) }
        guard screen == .world else { return }
        if physicalKeyboard.left { held.insert(123) }
        if physicalKeyboard.right { held.insert(124) }
        //170d:0007 selects walking left THEN right, so right wins both-held.
        //The raw dispatcher writes facing for right flip THEN left flip,
        //even when13b9 rejects restarting an active animation.
        if physicalKeyboard.rightFlip { beginJump(direction: 1) }
        if physicalKeyboard.leftFlip { beginJump(direction: -1) }
        if physicalKeyboard.up { interact() }
        if screen == .world,!isTransitioning,session.activeFountain == nil,physicalKeyboard.space,playerMotion.settled { beginZap() }
    }
    func pollPracticeContinue() {
        guard screen == .practice,practice?.presentation == .continuePrompt else { return }
        //The original result wait reads03ad until Enter, without a flush.
        while let event = keyboard.read() {
            if event.keyCode == 36 { practiceKey(event);keyboard.flush();return }
        }
    }
}
