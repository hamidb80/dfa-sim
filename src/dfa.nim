import std/[tables, hashes, sets]
import domain

type
  Terminal* = string
  State* = string

  Dfa* = object
    states*: Table[State, Position]
    alphabet*: seq[Terminal]
    transitionsFns*: Table[(State, Terminal), State]
    initialState*: State
    finalStates*: Hashset[State]

# func hash(s: State): Hash {.borrow.}
# func hash(t: Terminal): Hash {.borrow.}

func step*(dfa: Dfa, s: State, input: Terminal): State =
  dfa.transitionsFns[(s, input)]

func isAcceptable*(dfa: Dfa, s: State): bool =
  s in dfa.finalStates

