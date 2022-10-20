import std/[jscore, jsffi]
import std/[tables, hashes]

type
  State* = string
  Terminal* = string

  Dfa* = object
    states*: seq[State]
    alphabet*: seq[Terminal]
    transitionsFns*: Table[(State, Terminal), State]
    initialState*: State
    finalStates*: seq[State]

# func hash(s: State): Hash {.borrow.}
# func hash(t: Terminal): Hash {.borrow.}

func step*(dfa: Dfa, s: State, input: Terminal): State =
  dfa.transitionsFns[(s, input)]

func isAcceptable*(dfa: Dfa, s: State): bool =
  s in dfa.finalStates

