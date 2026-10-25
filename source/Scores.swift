import Foundation

struct NativeHighGameScore: Codable {
    let name: String
    let score: UInt16
    let rank: VerifiedRank
    let runID: UUID
}

enum OriginalScoreTable {
    //1a01:026a replaces slot9 only for a strictly greater score, then swaps
    // upward only past smaller values. Rank is captured before lifetime addition.
    static func adding(_ entry: NativeHighGameScore,to scores: [NativeHighGameScore]) -> [NativeHighGameScore] {
        guard entry.score > 0, !scores.contains(where: { $0.runID == entry.runID }),
              scores.count < 10 || entry.score > scores[9].score else { return scores }
        var result = scores
        if result.count == 10 { result[9] = entry } else { result.append(entry) }
        var index = result.count-1
        while index > 0 && result[index].score > result[index-1].score {
            result.swapAt(index,index-1); index -= 1
        }
        return result
    }
    //1a01:03cc uses this pairwise swap order, including its non-stable ties.
    // Native profiles can exceed the original ten slots; the UI paginates them.
    static func lifetimeOrder(_ profiles: [NativeProfile]) -> [NativeProfile] {
        var result = profiles
        for i in result.indices {
            for j in result.indices where j > i {
                if (result[j].lifetimePoints ?? 0) > (result[i].lifetimePoints ?? 0) { result.swapAt(i,j) }
            }
        }
        return result
    }
    static func formatted(_ value: Int) -> String {
        let digits = Array(String(max(0,value)))
        return digits.enumerated().map { index,digit in
            (index > 0 && (digits.count-index)%3 == 0 ? "," : "")+String(digit)
        }.joined()
    }
}
