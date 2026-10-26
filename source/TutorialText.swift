import Foundation

// Original DS136b far-pointer table. Text and keycaps retained verbatim.
enum OriginalNewUserText {
    static func accessible(_ text: String) -> String {
        let names = ["Up","Down","Right","Left","Esc","Enter","Tab","Space","F1","F2","F3","Del","="]
        return text.reduce(into: "") { result,character in
            let value = character.unicodeScalars.first!.value
            result += (0x80...0x8c).contains(value) ? "["+names[Int(value)-0x80]+"]" : String(character)
        }
    }
    static let messages: [String] = [
        "Now the search begins!\nUse , , and  to move\naround the TV station.\n\nGo into rooms to look for\nmath challenges that the\nMaster of Mischief has\nleft for you.",
        "Oops!  Telly the robot got you\nwith a trick.  That cost you\ntime on the clock.\n\nYou can jump or flip over Telly\nand the things it throws by\npressing   together,  \ntogether, or .",
        "Telly the robot crashed into\nyou, and you lost some energy\nfrom your zapper.\n\nPressing the  makes\nenergy come out of your zapper\nand can stop Telly.  If Telly\nis lit up when you zap it, you\nwill get drill questions.  If\nnot, Telly will disappear.",
        "The piece of secret code you\nhave just collected has been placed\nin your decoder.  It will help\nyou figure out which room the\nMaster of Mischief's hideout is in.\n\nWhen you want to see the\nsecret code you have collected,\nuse  to bring up your decoder.\nRemember, the clock always stops\nwhen you use your decoder.",
        "Before you can get energy from\nthis energy supply machine, you\nmust find and solve a math\nchallenge.",
        "Use  to move close to large\nobjects in the room to see if\nthey contain math challenges.",
        "LiveWire got you, and it cost you\nsome energy from your zapper.\n\nYou can move away by using ,\n, or .  You can also flip over\nLiveWire using   or  .\n\nLiveWire will disappear if energy\nfrom your zapper touches it.\nPress  when you want\nto use your zapper.",
        "Because you have solved a math\nchallenge, you have been given\nclues about this room.  The clues\nhave been put in your decoder\nand will help you figure out if\nthe Master of Mischief's hideout\nis in this room.\n\nWhen you want to see the clues\nyou have collected, use  to\nbring up your decoder.",
        "Use the keyboard to type in\nyour answer.  (Use  to erase\ntyping mistakes.)  Then press\n. The clock is running\nas you answer drill questions,\nso work quickly.",
        "In a math challenge, the clock is\non PAUSE (stopped).  Take your\ntime to read and work carefully.\n\nSolve the problem in your head\nor on paper, and then type in\nyour answer.  When the answer\nyou want to give is showing,\npress .",
        "In a math challenge, the clock is\non PAUSE (stopped).  Take your\ntime to read and work carefully.\n\nUse the keyboard to type numbers\nand symbols (+,-,*,/), and then\ntype  to have the calculator\nwork the problem.  When the\ncalculator shows the answer\nyou want to give, press .",
        "Your zapper is running low on\nenergy.  Look for the energy\nsupply in the hall.  Then use\n to get more energy.",
        "Do you need any help\nplaying the game?\n\nIf so, use  to see the\nHelp menu.",
        "When you use your decoder, the\nclock stops, and you can decide\nwhich room the Master of\nMischief's hideout is in.\n\nSelect the Match Rule button\nto learn how to match the clues\nfor each room with the secret\ncode.  When you know where the\nhideout is, use  and  to\nhighlight that room.  Then select\nthe Decide button.",
        "Because you tried to solve this\nmath challenge, you have been\ngiven clues about this room,\neven though you did not earn\nany points.  The clues have been\nplaced in your decoder and will\nhelp you figure out if the\nMaster of Mischief's hideout is\nin this room.\n\nWhen you want to see the clues\nyou have collected, use  to\nbring up your decoder.",
        "To change the level, problem\ntypes, and numbers used in a\ngame, use , , ,  to\ncycle and  to select.\n\nWhen you are done, select OK.\nUse UNDO to change settings\nback to the way they were\nbefore changes were made.",
        "To change the problem types\nand numbers used in a game,\nuse , , , to cycle\nand  to select.\n\nWhen you are done, select OK.\nUse UNDO to change settings\nback to the way they were\nbefore changes were made.",
        "As a Trainee, you will see New\nUser Messages pop up from\ntime to time.  These will help\nyou learn to play the game.\n\n(You can turn them off from\nthe menu bar, , when you\nget into the game.)",
    ]
}
