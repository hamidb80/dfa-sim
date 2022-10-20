import std/[jscore, jsffi]
import std/[tables]

type
  State* = distinct kstring
  Terminal* = distinct kstring

  Dfa* = object
    states*: seq[State]
    alphabet*: seq[Terminal]
    transitionsFns*: Table[(State, Terminal), State]
    initialState*: State
    finalStates*: seq[State]


func step*(dfa: Dfa, s: State, input: Terminal): State =
  dfa.transitionsFns[(s, input)]

func isAcceptable*(dfa: Dfa, s: State): bool =
  s in dfa.finalStates

