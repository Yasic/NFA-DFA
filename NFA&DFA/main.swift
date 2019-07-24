//
//  main.swift
//  NFA&DFA
//
//  Created by yasic on 2019/7/11.
//  Copyright © 2019 yasic. All rights reserved.
//

import Foundation

func main() {
    var arr = ["ab", "abd", "acd", "abccd", "abcde", "aabcde", "abed", "a@cd", "abcf", "a3b4", "b2cd", "dcba", "abcd"]
    arr = ["acd", "abccd"]
    arr = ["food", "fxod"]
    var testCases = [(String, String)]()
    for i in 0..<arr.count {
        for j in i+1..<arr.count {
            testCases.append((arr[i], arr[j]))
        }
    }
    testCases.forEach { (tuple) in        
        testDFA(word1: tuple.0, word2: tuple.1)
    }
}

func testTime(word1:String, word2:String) {
    let nfa = NFA.createAutoma(str: word1, distance: max(word1.count, word2.count))
    let res = nfa.match(currentState:nfa.startState, target: word2)
    let levenshteinDistance = LevenShteinDistance.distance(word1: word1, word2: word2)
    print("\(word1) \(word2) \(levenshteinDistance) \(res.1)")
}

func testJudge(word1:String, word2:String) {
    let k = 2
    let nfa = NFA.createAutoma(str: word1, distance: k)
    let res = nfa.match(currentState:nfa.startState, target: word2)
    let levenshteinDistance = LevenShteinDistance.distance(word1: word1, word2: word2)
    if res.0 && res.1 <= k {
        print("\(word1) \(word2) \(levenshteinDistance <= k) \(res.1 <= k)")
    }
}

func testDFA(word1:String, word2:String) {
    let k = 1
    let nfa1 = NFA.createAutoma(str: word1, distance: k)
    let dfa1 = nfa1.toDFA()
    let nfa2 = NFA.createAutoma(str: word2, distance: k)
    let dfa2 = nfa2.toDFA()
    let levenshteinDistance = LevenShteinDistance.distance(word1: word1, word2: word2)
    let dfaRes = DFA.match(dfa1: dfa1, dfa2: dfa2)
    let _ = nfa1.match(currentState:nfa1.startState, target: word2)
    print("\(word1) \(word2) \(dfaRes) \(levenshteinDistance <= k)")
    assert(dfaRes == (levenshteinDistance <= k))
}

main()

