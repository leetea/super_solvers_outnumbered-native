import Cocoa

func nativeCalculatorChecks(root: URL,output: URL) throws -> [String:Bool] {
    var checks: [String:Bool] = [:]
    func digits(_ value: Int,_ calculator: inout NativeCalculator) {
        for digit in String(value).compactMap(\.wholeNumberValue) { _ = calculator.press(.digit(digit)) }
    }
    func expression(_ left: Int,_ operation: NativeCalculator.Operation,_ right: Int) -> (NativeCalculator,NativeCalculator.Event?) {
        var value = NativeCalculator(); digits(left,&value); _ = value.press(.operation(operation)); digits(right,&value)
        let event = value.press(.equals); return (value,event)
    }
    for (name,a,op,b,expected) in [("addition",12,NativeCalculator.Operation.add,34,46),("subtraction",82,.subtract,14,68),("multiplication",25,.multiply,40,1000),("division",144,.divide,12,12),("zero_dividend",0,.divide,6,0)] {
        let (calculator,event) = expression(a,op,b)
        checks["calculator_original_\(name)"] = calculator.valid && calculator.phase == .result && calculator.display == String(expected) && event == nil
    }
    checks["calculator_overflow_resets"] = expression(9999,.add,1).1 == .notice(1) && expression(9999,.multiply,9999).0.phase == .empty
    checks["calculator_negative_subtraction_resets"] = expression(1,.subtract,2).1 == .notice(2)
    checks["calculator_zero_divisor_resets"] = expression(12,.divide,0).1 == .notice(4)
    checks["calculator_remainder_retains_original_notice_semantics"] = expression(13,.divide,5).1 == .remainder(2,3) && expression(13,.divide,5).0.phase == .empty
    var value = NativeCalculator()
    checks["calculator_blank_enter_does_not_submit"] = value.submission().value == nil && value.submission().notice == 0
    for digit in [0,0,0,7] { _ = value.press(.digit(digit)) }
    checks["calculator_original_zero_replacement"] = value.entry == "7"
    _ = value.press(.clear); digits(1234,&value)
    checks["calculator_four_digit_limit_beeps_without_change"] = value.press(.digit(5)) == .beep && value.entry == "1234"
    _ = value.press(.operation(.add))
    checks["calculator_missing_second_operand_notice"] = value.submission().notice == 5 && value.display == "1234"
    checks["calculator_cannot_replace_operator_without_delete"] = value.press(.operation(.divide)) == .beep && value.operation == .add
    _ = value.press(.digit(9))
    checks["calculator_enter_requires_equals_for_expression"] = value.submission().notice == 6 && value.phase == .second
    checks["calculator_next_operation_requires_equals_notice"] = value.press(.operation(.multiply)) == .notice(7)
    _ = value.press(.delete)
    checks["calculator_delete_second_operand_restores_left_display"] = value.phase == .operation && value.display == "1234" && value.entry.isEmpty
    _ = value.press(.delete)
    checks["calculator_delete_operator_restores_first_operand"] = value.phase == .first && value.entry == "1234" && value.operation == nil
    value = expression(12,.add,3).0
    _ = value.press(.operation(.multiply)); digits(2,&value); _ = value.press(.equals)
    checks["calculator_original_left_to_right_chaining"] = value.display == "30" && value.valid
    _ = value.press(.delete)
    checks["calculator_delete_edits_displayed_result"] = value.entry == "3" && value.phase == .first
    _ = value.press(.delete)
    checks["calculator_deleting_last_result_digit_stays_valid"] = value.phase == .empty && value.valid
    value = expression(12,.add,3).0; _ = value.press(.digit(7))
    checks["calculator_digit_after_result_starts_new_number"] = value.entry == "7" && value.valid
    for (index,bounds) in NativeCalculator.buttonBounds.enumerated() {
        checks["original_calculator_button_\(index)_maps"] = NativeCalculator.button(atX: (bounds.0+bounds.2)/2,y: (bounds.1+bounds.3)/2) == index
    }
    var propertyCases = 0, identities = true
    for a in 0...30 { for b in 0...30 {
        for op in [NativeCalculator.Operation.add,.subtract,.multiply,.divide] {
            let (calculator,event) = expression(a,op,b)
            identities = identities && calculator.valid
            if op == .add { identities = identities && Int(calculator.display) == a+b }
            if op == .multiply { identities = identities && Int(calculator.display) == a*b }
            if op == .subtract { identities = identities && (a >= b ? Int(calculator.display) == a-b : event == .notice(2)) }
            if op == .divide { identities = identities && (b == 0 ? event == .notice(4) : (a%b == 0 ? Int(calculator.display) == a/b : event == .remainder(a/b,a%b))) }
            propertyCases += 1
        }
    } }
    checks["calculator_3844_arithmetic_and_error_cases"] = identities && propertyCases == 3844
    value = NativeCalculator(); digits(832,&value); _ = value.press(.operation(.subtract)); digits(123,&value)
    let restored = try JSONDecoder().decode(NativeCalculator.self,from: JSONEncoder().encode(value))
    checks["calculator_partial_expression_persistence"] = restored.valid && restored.left == 832 && restored.entry == "123" && restored.phase == .second
    let directory = FileManager.default.temporaryDirectory.appendingPathComponent("outnumbered-calculator-"+UUID().uuidString)
    defer { try? FileManager.default.removeItem(at: directory) }
    let view = try NativeGameView(root: root,saveDirectory: directory,automaticallyPresentMessages: false)
    view.timer?.invalidate(); view.zapTimer?.invalidate(); view.soundEnabled = false; view.referenceQuestion()
    // Exercise real NSView key routing, including the shifted-character path
    // used by '=' and the original alternate E key.
    for (text,keyCode) in [("8",UInt16(28)),("+",UInt16(24)),("2",UInt16(19)),("=",UInt16(24))] {
        let event = NSEvent.keyEvent(with: .keyDown,location: .zero,modifierFlags: [],timestamp: 0,windowNumber: 0,context: nil,characters: text,charactersIgnoringModifiers: text,isARepeat: false,keyCode: keyCode)!
        view.keyDown(with: event)
    }
    checks["native_equals_keyboard_event_routes_to_calculator"] = view.session.calculator?.display == "10" && view.session.calculator?.phase == .result
    view.referenceQuestion()
    for character in "832-123=-65=" { view.questionCharacter(String(character)) }
    checks["native_recorded_rainfall_calculation_644"] = view.session.calculator?.display == "644" && view.session.calculator?.valid == true
    try view.render(); try view.canvas.writePNG(to: output.appendingPathComponent("native-calculator-rainfall-result.png"))
    view.submitQuestion()
    checks["native_calculated_answer_submits_once_for_300"] = view.session.score == 300 && view.session.attempts[0]?.result == .correct && view.session.attempts[0]?.input == "644"
    view.referenceQuestion(); view.session.calculatorEnabled = false
    for character in "644" { view.questionCharacter(String(character)) }; view.submitQuestion()
    checks["native_calculator_off_direct_answer_path"] = view.session.score == 300 && view.session.attempts[0]?.result == .correct
    view.referenceQuestion(); view.questionCharacter("1"); view.submitQuestion()
    checks["native_wrong_answer_resets_calculator"] = view.session.attempts[0]?.wrongAnswers == 1 && view.session.calculator?.phase == .empty
    for character in "832-123" { view.questionCharacter(String(character)) }
    try view.saves.save(view.session)
    let session = try view.saves.load(view.session.profileID)!
    checks["native_partial_calculator_save_valid"] = session.valid && session.calculator?.phase == .second && session.calculator?.left == 832 && session.calculator?.entry == "123"
    view.referenceQuestion(); view.session.calculator = nil; view.session.attempts[0]?.input = "644"; view.ensureCalculator()
    checks["version04_partial_number_migrates_to_calculator"] = view.session.calculator?.entry == "644" && view.session.valid
    let bank = try JSONDecoder().decode(ChallengeBank.self,from: Data(contentsOf: root.appendingPathComponent("challenges.json")))
    let bar = bank.cases.first { $0.id == 9010 && $0.seed == 1 && $0.variant == 0 }!
    view.open(bar);try view.advanceActivityPresentation(irqTicks: 10_000); try view.render(); try view.canvas.writePNG(to: output.appendingPathComponent("native-interviews-bar-chart.png"))
    checks["bar_chart_original_fixture_values"] = try (3...6).map { try bar.originalWord(at: $0) } == [6,3,9,3] && bar.originalWord(at: 8) == 0 && bar.originalWord(at: 9) == 3
    return checks
}
