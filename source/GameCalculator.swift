import Cocoa

extension NativeGameView {
    var usesCalculator: Bool { session.calculatorEnabled ?? true }
    func ensureCalculator() {
        guard session.calculator == nil, let challenge = session.activeChallenge else { return }
        var calculator = NativeCalculator()
        for digit in (session.attempts[challenge.hotspot]?.input ?? "").compactMap(\.wholeNumberValue) { _ = calculator.press(.digit(digit)) }
        session.calculator = calculator
    }
    func calculatorNotice(_ id: Int,completion: @escaping () -> Void = {}) {
        guard NativeCalculator.notices.indices.contains(id) else { return }
        showOriginalNotice(OriginalNotice(text: NativeCalculator.notices[id],title: nil)) { _ in completion() }
    }
    func calculatorKey(_ key: NativeCalculator.Key) {
        guard originalNotice == nil,confirmation == nil,!isActivityPresenting, let challenge = session.activeChallenge, session.attempts[challenge.hotspot]?.result == .editing,
              session.attempts[challenge.hotspot]?.awaitingHintAcknowledgement != true else { return }
        let previous = session.calculator ?? NativeCalculator()
        var calculator = previous
        let event = calculator.press(key)
        let resetAfterAdvice: Bool
        switch event {
        case .notice(let id): resetAfterAdvice = [1,2,4].contains(id)
        case .remainder: resetAfterAdvice = true
        default: resetAfterAdvice = false
        }
        //1efa4 resets arithmetic errors AFTER the notice. The pure arithmetic
        //model returns its final reset state; keep the visible editor until then.
        if resetAfterAdvice {
            session.calculator = previous
            if case .remainder(let quotient,let remainder)? = event { calculatorRemainder = (quotient,remainder) }
            let id: Int
            if case .notice(let value)? = event { id = value } else { id = 3 }
            calculatorNotice(id) { [weak self] in
                guard let self,self.session?.activeChallenge?.hotspot == challenge.hotspot else { return }
                self.calculatorRemainder = nil;self.session.calculator = calculator
                self.session.attempts[challenge.hotspot]?.input = calculator.entry;self.save()
            }
            return
        }
        session.calculator = calculator
        session.attempts[challenge.hotspot]?.input = calculator.entry
        save(); needsDisplay = true
        switch event {
        case .beep: effect(26)
        case .notice(let id): calculatorNotice(id)
        case .remainder: break //Handled above with the original footer feedback.
        case nil: break
        }
    }
    func questionCharacter(_ text: String) {
        guard originalNotice == nil,confirmation == nil,!isActivityPresenting, let challenge = session.activeChallenge else { return }
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
        guard originalNotice == nil,confirmation == nil,!isActivityPresenting, let challenge = session.activeChallenge else { return }
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
        guard session != nil,originalNotice == nil,confirmation == nil,settingsEditor == nil,optionsMenu == nil,screen != .practice else { return }
        chooseCalculator(!usesCalculator)
    }
}
