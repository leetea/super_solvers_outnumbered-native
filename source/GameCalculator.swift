import Cocoa

extension NativeGameView {
    var usesCalculator: Bool { session.calculatorEnabled ?? true }
    func ensureCalculator() {
        guard session.calculator == nil, let challenge = session.activeChallenge else { return }
        var calculator = NativeCalculator()
        for digit in (session.attempts[challenge.hotspot]?.input ?? "").compactMap(\.wholeNumberValue) { _ = calculator.press(.digit(digit)) }
        session.calculator = calculator
    }
    func calculatorNotice(_ id: Int,title: String = "Calculator") {
        let alert = NSAlert(); alert.messageText = title; alert.informativeText = NativeCalculator.notices[id]; alert.runModal()
    }
    func calculatorKey(_ key: NativeCalculator.Key) {
        guard let challenge = session.activeChallenge, session.attempts[challenge.hotspot]?.result == .editing,
              session.attempts[challenge.hotspot]?.awaitingHintAcknowledgement != true else { return }
        var calculator = session.calculator ?? NativeCalculator()
        let event = calculator.press(key)
        session.calculator = calculator
        session.attempts[challenge.hotspot]?.input = calculator.entry
        save(); needsDisplay = true
        switch event {
        case .beep: effect(26)
        case .notice(let id): calculatorNotice(id)
        case .remainder(let quotient,let remainder): calculatorNotice(3,title: "\(quotient) r\(remainder)")
        case nil: break
        }
    }
    func questionCharacter(_ text: String) {
        guard let challenge = session.activeChallenge else { return }
        if let digit = Int(text), text.count == 1, (0...9).contains(digit) {
            if usesCalculator { calculatorKey(.digit(digit)) }
            else { session.attempts[challenge.hotspot]?.digit(digit) }
        } else if usesCalculator {
            switch text.lowercased() {
            case "+": calculatorKey(.operation(.add))
            case "-","_": calculatorKey(.operation(.subtract))
            case "*": calculatorKey(.operation(.multiply))
            case "/": calculatorKey(.operation(.divide))
            case "=","e": calculatorKey(.equals)
            case "c": calculatorKey(.clear)
            default: break
            }
        }
    }
    func submitQuestion() {
        guard let challenge = session.activeChallenge else { return }
        if session.attempts[challenge.hotspot]?.awaitingHintAcknowledgement == true {
            session.attempts[challenge.hotspot]?.awaitingHintAcknowledgement = false; save(); return
        }
        if session.attempts[challenge.hotspot]?.result != .editing { leaveQuestion(); return }
        if usesCalculator {
            var calculator = session.calculator ?? NativeCalculator()
            let submission = calculator.submission(); session.calculator = calculator
            guard let value = submission.value else { calculatorNotice(submission.notice!); return }
            session.attempts[challenge.hotspot]?.input = String(value)
        }
        if let correct = session.resolve(challenge) {
            effect(correct ? 7 : 9)
            if !correct { session.calculator = NativeCalculator() }
            save()
        }
    }
    @objc func toggleCalculator(_ sender: NSMenuItem) {
        guard session != nil else { return }
        session.calculatorEnabled = !usesCalculator; sender.state = usesCalculator ? .on : .off
        session.calculator = NativeCalculator()
        if let challenge = session.activeChallenge, session.attempts[challenge.hotspot]?.result == .editing { session.attempts[challenge.hotspot]?.input = "" }
        save(); needsDisplay = true
    }
}
