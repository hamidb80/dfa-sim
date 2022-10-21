import std/[tables, hashes, sets]
import coordination

type
  Terminal* = string
  State* = string

  Dfa* = object
    states*: Table[State, Position]
    alphabet*: seq[Terminal]
    transitions*: Table[State, Table[Terminal, State]]
    initialState*: State
    finalStates*: Hashset[State]

# func hash(s: State): Hash {.borrow.}
# func hash(t: Terminal): Hash {.borrow.}

func step*(dfa: Dfa, s: State, input: Terminal): State =
  dfa.transitions[s][input]

func reducedTerms*(dfa: Dfa, s: State): Table[State, seq[Terminal]] =
  for t, so in dfa.transitions.getOrDefault s:
    if so in result:
      result[so].add t
    else:
      result[so] = @[t]

func isFinal*(dfa: Dfa, s: State): bool =
  s in dfa.finalStates

func rename*(dfa: var Dfa, oldState, newState: State) =
  let pos = dfa.states[oldState]
  dfa.states[newState] = pos
  del dfa.states, oldState

  if oldState in dfa.transitions:
    let ts = dfa.transitions[oldState]
    del dfa.transitions, oldState
    dfa.transitions[newState] = ts

  for _, ts in dfa.transitions.mpairs:
    for t, s in ts.mpairs:
      if s == oldState:
        s = newState

  if oldState in dfa.finalStates:
    dfa.finalStates.excl oldState
    dfa.finalStates.incl newState

  if dfa.initialState == oldState:
    dfa.initialState = newState


func remove*(dfa: var Dfa, old: State) =
  del dfa.states, old

  for _, ts in dfa.transitions.mpairs:
    var acc: seq[string]
    for t, s in ts.mpairs:
      if s == old:
        acc.add t

    for a in acc:
      ts.del a

  if dfa.initialState == old:
    reset dfa.initialState

  dfa.finalStates.excl old

