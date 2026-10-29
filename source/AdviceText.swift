import Foundation

//Original DS data; no DOS code is loaded or executed.
enum OriginalDecoderDialog {
    static let ineligible = "You must collect all four\npieces of the secret code\nand all four clues for at\nleast one room, or all clues\nfor all rooms and one piece\nof the secret code, before\nyou can decide.\n"
    static let confirmPrefix = "Are you sure the\nMaster of Mischief's\nhideout is in the\n"
    static let matchLines = [
        ["MATCH RULE: The hideout room has the same","pictures and the same pattern as the secret code."],
        ["MATCH RULE: The hideout room has the same pictures","but a different pattern from the secret code."],
        ["MATCH RULE: The hideout room has different pictures","but the same pattern as the secret code."],
    ]
}
