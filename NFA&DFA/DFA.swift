//
//  DFA.swift
//  NFA&DFA
//
//  Created by yasic on 2019/7/12.
//  Copyright © 2019 yasic. All rights reserved.
//

import Cocoa

class DFA: NSObject {
    let startState : Set<State>
    var transitions = [Set<State>:[Edge:Set<State>]]()
    var finalState = Set<Set<State>>.init()
    var defaultTransitions = [Set<State>:Set<State>]()
    var stateHub = [Set<State>:Set<Edge>].init()
    
    init(startState:Set<State>) {
        self.startState = startState
        super.init()
        self.addSrcToStateHub(src: startState, edge: nil)
    }
    
    func addSrcToStateHub(src:Set<State>, edge:Edge?) {
        if !self.stateHub.keys.contains(src) {
            self.stateHub[src] = Set<Edge>.init()
        }
        if let edge = edge {
            self.stateHub[src]?.insert(edge)
        }
    }
    
    func addDestToStateHub(dest:Set<State>) {
        if !stateHub.keys.contains(dest) {
            stateHub[dest] = Set<Edge>.init()
        }
    }
    
    func edges(state:Set<State>) -> Set<Edge> {
        var res = Set<Edge>.init()
        self.transitions[state]?.forEach({ (key, value) in            
            res.insert(key)
        })
        return res
    }
    
    func addTransition(src:Set<State>, input:Edge, dest:Set<State>) {
        if self.transitions[src] == nil {
            self.transitions[src] = [Edge:Set<State>]()
        }
        self.addSrcToStateHub(src: src, edge: input)
        self.addDestToStateHub(dest: dest)
        self.transitions[src]?[input] = dest
    }
    
    func addFinalState(finalState:Set<State>) {
        self.finalState.insert(finalState)
    }
    
    func setDefaultTransition(src:Set<State>, dest:Set<State>) {
        self.addSrcToStateHub(src: src, edge: Edge.ANY)
        self.addDestToStateHub(dest: dest)
        self.defaultTransitions[src] = dest
    }
    
    func isFinalState(state:Set<State>) -> Bool {
        return self.finalState.contains(state)
    }
    
    func nextState(src:Set<State>, input:Edge) -> Set<State>? {
        if let r = self.transitions[src]?[input] {
            return r
        }
        return self.defaultTransitions[src]
    }
    
    static func match(dfa1:DFA, dfa2:DFA) -> Bool {
        var stack = [dfa1.startState, dfa2.startState]
        while !stack.isEmpty {
            let state1:Set<State>? = stack.remove(at: 0)
            let state2:Set<State>? = stack.remove(at: 0)
            let set = dfa1.edges(state: state1 ?? Set<State>.init()).intersection(dfa2.edges(state: state2 ?? Set<State>.init()))
            for symbol in set {
                let s1 = dfa1.nextState(src: state1 ?? Set<State>.init(), input: symbol)
                let s2 = dfa2.nextState(src: state2 ?? Set<State>.init(), input: symbol)
                if let s1 = s1, let s2 = s2 {
                    stack.append(s1)
                    stack.append(s2)
                    if dfa1.isFinalState(state: s1) && dfa2.isFinalState(state: s2) {
                        return true
                    }
                }
            }
        }
        return false
    }
}
