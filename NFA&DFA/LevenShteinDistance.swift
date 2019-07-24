//
//  LevenShteinDistance.swift
//  NFA&DFA
//
//  Created by yasic on 2019/7/11.
//  Copyright © 2019 yasic. All rights reserved.
//

import Foundation

class LevenShteinDistance {
    static func distance(word1:String, word2:String) -> Int {
        let l1 = word1.count
        let l2 = word2.count
        var dp = Array.init(repeating: Array.init(repeating: 0, count: l2+1), count: l1+1)
        for x in 0...l1 {
            dp[x][0] = x
        }
        for x in 0...l2 {
            dp[0][x] = x
        }
        if l1 >= 1 && l2 >= 1 {
            for i in 1...l1 {
                for j in 1...l2 {
                    let d1 = dp[i-1][j] + 1
                    let d2 = dp[i][j-1] + 1
                    let characterIsSame = word1[word1.index(word1.startIndex, offsetBy: i-1)] == word2[word2.index(word2.startIndex, offsetBy: j-1)]
                    let d3 = dp[i-1][j-1] + (characterIsSame ? 0 : 1)
                    dp[i][j] = min(d1, d2, d3)
                }
            }
        }
        return dp[l1][l2]
    }
}
