import Foundation

// Recovered17e4 calculator and1e98 question-input wrapper. No expression
// evaluator or precedence rules are substituted for the original state machine.
struct NativeCalculator: Codable {
    enum Phase: Int, Codable { case empty, first, operation, second, result }
    enum Operation: Int, Codable { case add = 11, subtract, multiply, divide
        var glyph: String { ["+","-","*","/"][rawValue-11] }
    }
    enum Key { case digit(Int), operation(Operation), equals, clear, delete }
    enum Event: Equatable { case beep, notice(Int), remainder(Int,Int) }
    private(set) var phase = Phase.empty
    private(set) var entry = ""
    private(set) var left = 0
    private(set) var operation: Operation?
    var display: String { phase == .operation ? String(left) : entry }
    var valid: Bool {
        guard entry.count <= 4, entry.utf8.allSatisfy({ (48...57).contains($0) }), entry.count < 2 || entry.first != "0", (0...9999).contains(left) else { return false }
        switch phase {
        case .empty: return entry.isEmpty && operation == nil && left == 0
        case .first: return !entry.isEmpty && operation == nil
        case .operation: return entry.isEmpty && operation != nil
        case .second: return !entry.isEmpty && operation != nil
        case .result: return Int(entry) == left && operation == nil
        }
    }
    mutating func press(_ key: Key) -> Event? {
        //1e98 normalizes a displayed result to first-operand state before
        //non-digit input, allowing chained operations and result editing.
        if phase == .result, case .digit = key {} else if phase == .result { phase = .first }
        switch key {
        case .clear: self = NativeCalculator()
        case .digit(let digit):
            guard (0...9).contains(digit) else { return nil }
            if phase == .result { self = NativeCalculator() }
            if phase == .empty { phase = .first }
            if phase == .operation { phase = .second }
            guard entry.count < 4 else { return .beep }
            if Int(entry) == 0 { entry = String(digit) } else { entry += String(digit) }
        case .operation(let value):
            if phase == .first { left = Int(entry)!; entry = ""; operation = value; phase = .operation }
            else if phase == .second { return .notice(7) }
            else if phase == .operation { return .beep }
        case .delete:
            if phase == .first || phase == .second {
                if !entry.isEmpty { entry.removeLast() }
                if entry.isEmpty {
                    if phase == .first { phase = .empty; left = 0 }
                    else { phase = .operation }
                }
            } else if phase == .operation { entry = String(left); operation = nil; phase = .first }
        case .equals:
            guard phase == .second, let operation, let right = Int(entry) else { return nil }
            let result: Int
            switch operation {
            case .add: result = left+right
            case .subtract:
                guard left >= right else { self = NativeCalculator(); return .notice(2) }
                result = left-right
            case .multiply: result = left*right
            case .divide:
                guard right != 0 else { self = NativeCalculator(); return .notice(4) }
                result = left/right
                if left%right != 0 { let remainder = left%right; self = NativeCalculator(); return .remainder(result,remainder) }
            }
            guard result <= 9999 else { self = NativeCalculator(); return .notice(1) }
            left = result; entry = String(result); self.operation = nil; phase = .result
        }
        return nil
    }
    // The question wrapper permits Enter only with a plain number/result.
    mutating func submission() -> (value: Int?,notice: Int?) {
        if phase == .result { phase = .first }
        if phase == .first, let value = Int(entry) { return (value,nil) }
        return (nil,phase == .operation ? 5 : (phase == .second ? 6 : 0))
    }
    static let notices = [
        "You must type in a number\nbefore you press Enter\nto solve the math challenge.",
        "The answer to the problem\nyou have typed in is too\nlarge for this calculator.",
        "This calculator cannot\nsubtract a larger number\nfrom a smaller one.",
        "In this game, all the\ncorrect answers are\nwhole numbers (cannot have\nremainders). Try again.",
        "The calculator cannot divide\na number by zero.",
        "Type in the next number. Then\ntype = to have the calculator\nwork out the problem you have\ntyped in.\n\nWhen the calculator shows your\nanswer, press Enter.",
        "Type = to have the calculator\nwork out the problem you have\ntyped in.\n\nWhen the calculator shows your\nanswer, press Enter.",
        "You must type = before the\ncalculator can do the next step\nof your problem."
    ]
    // Original DS3714/3738/375c/3780 button-glyph bounds, with the
    // surrounding three-pixel native button face included for mouse input.
    static let buttonBounds = [(257,184,263,190),(257,171,263,177),(269,171,276,177),(283,171,289,177),(257,158,263,164),(269,158,276,164),(283,158,289,164),(257,145,263,151),(269,145,276,151),(283,145,289,151),(202,184,232,190),(296,184,302,190),(296,171,302,177),(296,158,302,164),(296,145,302,151),(269,184,289,190),(202,171,209,177)]
    static func button(atX x: Int,y: Int) -> Int? {
        buttonBounds.firstIndex { left,top,right,bottom in (left-3...right+3).contains(x) && (top-3...bottom+3).contains(y) }
    }
}
