//
//  NFA.swift
//  NFA&DFA
//
//  Created by yasic on 2019/7/11.
//  Copyright © 2019 yasic. All rights reserved.
//

import Foundation

enum Edge : Hashable {
    case EPSILON // 删除
    case ANY // 替换 or 插入
    case Symbol(s:String) // 匹配
}

struct State : Hashable {
    var i:Int
    var e:Int
}

class NFA : NSObject {
    let startState:State
    var transitions = [State:[Edge:Set<State>]]()
    var finalTransitions = Set<State>.init()
    
    init(startState:State) {
        self.startState = startState
        super.init()
    }
    
    func addTransition(src:State, input:Edge, destination:State) {
        if self.transitions[src] == nil {
            self.transitions[src] = [Edge:Set<State>]()
        }
        if self.transitions[src]?[input] == nil {
            self.transitions[src]?[input] = Set<State>.init()
        }
        self.transitions[src]?[input]?.insert(destination)
    }
    
    func addFinalState(finalState:State) {
        self.finalTransitions.insert(finalState)
    }
    
    func nextState(src:State, input:Edge) -> Set<State> {
        var res = Set<State>()
        // 直接匹配
        if let a = self.transitions[src]?[input] {
            a.forEach { (s) in
                res.insert(s)
            }
        }
        // 替换 or 插入
        if let a = self.transitions[src]?[Edge.ANY] {
            a.forEach { (s) in
                res.insert(s)
            }
        }
        return res
    }
    
    func nextDeletState(src:State) -> Set<State> {
        var res = Set<State>()
        if let a = self.transitions[src]?[Edge.EPSILON] {
            a.forEach { (s) in
                res.insert(s)
            }
        }
        return res
    }
    
    func isFinalState(state:State) -> Bool {
        return self.finalTransitions.contains(state)
    }
    
    func match(currentState:State, target:String) -> (Bool, Int) {
        var isFinishState = false
        var distance = Double.infinity
        if target.isEmpty {
            if self.isFinalState(state: currentState) {
                return (true, currentState.e)
            }
        }
        // 正常的替换 or 插入
        let nextStates = self.nextState(src: currentState, input: Edge.Symbol(s: target.isEmpty ? "" : String.init(target[target.startIndex])))
        if !nextStates.isEmpty {
            nextStates.forEach { (s) in
                let (x, y) = self.match(currentState: s, target: target.isEmpty ? "" : String(target[target.index(target.startIndex, offsetBy: 1)..<target.endIndex]))
                if x {
                    isFinishState = true
                    distance = min(distance, Double(y))
                }
            }
        }
        // 尝试进行删除操作的状态转移
        let nextDeleteStates = self.nextDeletState(src: currentState)
        if !nextDeleteStates.isEmpty {
            nextDeleteStates.forEach { (s) in
                let (x, y) = self.match(currentState: s, target: target.isEmpty ? "" : target)
                if x {
                    isFinishState = true
                    distance = min(distance, Double(y))
                }
            }
        }
        return (isFinishState, isFinishState ? Int(distance) : 0)
    }
    
    static func createAutoma(str:String, distance:Int) -> NFA {
        let nfa = NFA.init(startState: State.init(i: 0, e: 0))
        for index in str.indices {
            let c = str[index]
            for e in 0...distance {
                nfa.addTransition(src: State.init(i: index.encodedOffset, e: e), input: Edge.Symbol(s: String.init(c)), destination: State.init(i: index.encodedOffset+1, e: e))
                if e < distance {
                    // 删除操作
                    nfa.addTransition(src: State.init(i: index.encodedOffset, e: e), input: Edge.ANY, destination: State.init(i: index.encodedOffset, e: e+1))
                    // 插入操作
                    nfa.addTransition(src: State.init(i: index.encodedOffset, e: e), input: Edge.EPSILON, destination: State.init(i: index.encodedOffset + 1, e: e+1))
                    // 替换操作
                    nfa.addTransition(src: State.init(i: index.encodedOffset, e: e), input: Edge.ANY, destination: State.init(i: index.encodedOffset + 1, e: e+1))
                }
            }
        }
        for e in 0...distance {
            if e < distance {
                nfa.addTransition(src: State.init(i: str.count, e: e), input: Edge.ANY, destination: State.init(i: str.count, e: e+1))
            }
            nfa.addFinalState(finalState: State.init(i: str.count, e: e))
        }
        return nfa
    }
    
    func getInputs(states:Set<State>) -> [Edge] {
        var res = [Edge]()
        states.forEach { (s) in
            self.transitions[s]?.keys.forEach({ (symbol) in
                res.append(symbol)
            })
        }
        return res
    }
    
    func toDFA() -> DFA {
        var subsets = [self.epsilonStateSet(stateSet: Set.init(arrayLiteral: self.startState))]
        let dfa = DFA.init(startState: subsets.first ?? Set.init())
        var seenCache = Set<Set<State>>.init()
        while !subsets.isEmpty {
            if let currentSubSet = subsets.popLast() {
                var allSymbols = Set<Edge>.init()
                currentSubSet.forEach { (s) in
                    self.transitions[s]?.keys.forEach({ (symbol) in
                        if symbol != Edge.EPSILON {
                            allSymbols.insert(symbol)
                        }
                    })
                }
                allSymbols.forEach { (symbol) in
                    let moveStates = self.moveStates(currentSet: currentSubSet, symbol: symbol)
                    if !seenCache.contains(moveStates) {
                        seenCache.insert(moveStates)
                        subsets.append(moveStates)
                        if !moveStates.intersection(self.finalTransitions).isEmpty {
                            dfa.addFinalState(finalState: moveStates)
                        }
                    }
                    if symbol != Edge.ANY {
                        dfa.addTransition(src: currentSubSet, input: symbol, dest: moveStates)
                    } else {
                        dfa.setDefaultTransition(src: currentSubSet, dest: moveStates)
                    }
                }
            }
        }
        return dfa
    }
    
    func moveStates(currentSet:Set<State>, symbol:Edge) -> Set<State> {
        var res = Set<State>()
        currentSet.forEach { (s) in
            if let dic = self.transitions[s] {
                dic.forEach({ (key, value) in
                    if (key != Edge.EPSILON) && (key == symbol || key == Edge.ANY) {
                        value.forEach({ (s) in
                            res.insert(s)
                        })
                    }
                })
            }
        }
        return self.epsilonStateSet(stateSet: res)
    }

    func epsilonStateSet(stateSet:Set<State>) -> Set<State> {
        var queue = stateSet
        var res = stateSet
        while !queue.isEmpty {
            if let state = queue.popFirst(), var newStates = self.transitions[state]?[Edge.EPSILON] {
                newStates.subtract(stateSet)
                newStates.forEach { (s) in
                    queue.insert(s)
                    res.insert(s)
                }
            }
        }
        return res
    }
}
