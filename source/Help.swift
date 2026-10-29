import Foundation

struct OriginalHelpBook: Decodable {
    struct Run: Decodable { let x: Int,y: Int,text: String }
    struct Illustration: Decodable {
        let sourceOffset: Int,x: Int,y: Int,resource: String,width: Int,height: Int,sha256: String
    }
    struct Page: Decodable { let sourceOffset: Int,sourceText: String,runs: [Run],illustration: Illustration? }
    struct Topic: Decodable { let title: String,pages: [Page] }
    let sourceSHA256: String
    let topics: [Topic]
    var valid: Bool {
        sourceSHA256 == "e12419e3d15436f8370583ff459982fec236986791318bf7c9ca4555e90f22c1" &&
        topics.map { $0.pages.count } == [3,5,3,3,2,2,3,1] && topics.allSatisfy { topic in
            !topic.title.isEmpty && topic.pages.allSatisfy { page in
                (96..<10951).contains(page.sourceOffset) && !page.runs.isEmpty && page.runs.allSatisfy { (0..<320).contains($0.x) && (0..<200).contains($0.y) && !$0.text.contains("~") }
            }
        }
    }
}

struct NativeHelpBrowser {
    let practice: Bool
    var selectedTopic = 0
    var topic: Int?
    var page = 0
    var selectedButton = 1
    var availableTopics: [Int] { practice ? [7] : Array(0..<8) }
    mutating func cycleTopic(_ direction: Int) { selectedTopic = (selectedTopic+availableTopics.count+direction)%availableTopics.count }
    mutating func cycleButton() { selectedButton = page == 0 ? 1 : 1-selectedButton }
    //True means Done: the original helper returns1 and REOPENS Help topics.
    mutating func activate(book: OriginalHelpBook) -> Bool {
        guard let topic else { self.topic = availableTopics[selectedTopic]; page = 0; selectedButton = 1; return false }
        if selectedButton == 0 && page > 0 { page -= 1; if page == 0 { selectedButton = 1 }; return false }
        if page+1 == book.topics[topic].pages.count { return true }
        page += 1; selectedButton = 1; return false
    }
    mutating func returnToTopics() { topic = nil; page = 0; selectedButton = 1 }
}

extension NativeCanvas {
    //1862:05f9, the two source panel forms used by the Help menu/viewer.
    func originalHelpPanel(left: Int,top: Int,right: Int,bottom: Int,title: String?,footer: String?,font: OriginalFont,bottomSeparator: Int = 21,raisedTop: Bool? = nil) {
        let raised = raisedTop ?? (title != nil)
        fill(left,top,right-left+1,bottom-top+1,15)
        fill(left+2,top,2,bottom-top-3,1)
        fill(right-5,top+2,4,bottom-top-3,1)
        fill(left+4,bottom-5,right-left-5,4,1)
        fill(left+2,top,right-left-(raised ? 5 : 3),2,1)
        if raised { fill(left,top-2,right-left+1,2,15) }
        if let title {
            fill(left+3,top+15,right-left-5,1,1)
            text(title,font: font,x: right-(right-left)/2-font.width(of: title)/2,y: top+4,color: 1)
        }
        if title != nil || footer != nil { fill(left+3,bottom-bottomSeparator,right-left-5,1,1) }
        if let footer { text(footer,font: font,x: right-(right-left)/2-font.width(of: footer)/2,y: bottom-16,color: 1) }
    }
    func invert(_ x: Int,_ y: Int,_ width: Int,_ height: Int) {
        for row in max(0,y)..<min(200,y+height) {
            for column in max(0,x)..<min(320,x+width) { pixel(column,row,pixels[row*320+column]^14) }
        }
    }
    // Original1862:000e and0174. Coordinates are the button's text-area origin.
    func originalHelpButton(_ title: String,font: OriginalFont,x: Int,y: Int,selected: Bool) {
        let measure = font.width(of: title), width = measure < 40 ? 40 : 100
        var top = y+(width == 100 ? 2 : 4)
        fill(x-3,top-2,width+7,y+12-(top-2)+1,1)
        fill(x-4,top-1,1,y+11-top+2,1); fill(x+width+4,top-1,1,y+11-top+2,1)
        fill(x-2,top-1,width+5,y+11-(top-1)+1,15)
        fill(x-3,top,1,y+11-top,15); fill(x+width+3,top,1,y+11-top,15)
        if width == 100 { top += 1 }
        text(title,font: font,x: x+(width-measure)/2,y: top-1,color: 1)
        if selected {
            let start = y+(width == 100 ? 2 : 4)
            invert(x-3,start,width+7,y+10-start+1)
            invert(x-2,start-1,width+5,1); invert(x-2,y+11,width+5,1)
        }
    }
}
