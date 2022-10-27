import std/[tables, hashes, sets]

type
  Terminal* = string
  State* = string

  Step* = object
    states*: Slice[State]
    term*: Terminal

  DfaMistakeKind* = enum
    dmkInitialStateHasNotSet = "initial state has not set"
    dmkMissingTransition = "missing transition"
    dmkInvalidTransition = "invalid transition"
    dmkInvalidInputTerminal = "invalid input terminal"

  DfaMistake* = object
    case kind*: DfaMistakeKind
    of dmkInvalidInputTerminal:
      invalidTerm*: Terminal

    of dmkMissingTransition:
      missingTerm*: Terminal
      state*: State

    of dmkInvalidTransition:
      states*: Slice[State]
      term*: Terminal

    else: nil

  Dfa* = object
    states*: Hashset[State]
    terminals*: seq[Terminal]
    transitions*: Table[State, Table[Terminal, State]]
    initialState*: State
    finalStates*: Hashset[State]

# func hash(s: State): Hash {.borrow.}
# func hash(t: Terminal): Hash {.borrow.}

func next*(dfa: Dfa, currentState: State, term: Terminal): State =
  let tab = dfa.transitions[currentState]
  if term in tab: tab[term]
  else: tab["*"]

func reducedTerms*(dfa: Dfa, s: State): Table[State, seq[Terminal]] =
  for t, so in dfa.transitions.getOrDefault s:
    if so in result:
      result[so].add t
    else:
      result[so] = @[t]

func isFinal*(dfa: Dfa, s: State): bool =
  s in dfa.finalStates

func rename*(dfa: var Dfa, oldState, newState: State) =
  dfa.states.excl oldState
  dfa.states.incl newState

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
  dfa.states.excl old

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

func inputErrors*(dfa: Dfa, input: seq[Terminal]): seq[DfaMistake] =
  for term in input:
    if term notin dfa.terminals:
      result.add DfaMistake(kind: dmkInvalidInputTerminal, invalidTerm: term)

func mistakes*(dfa: Dfa): seq[DfaMistake] =
  if dfa.initialState notin dfa.states:
    result.add DfaMistake(kind: dmkInitialStateHasNotSet)

  for s1 in dfa.states:
    if s1 in dfa.transitions:
      let ttab = dfa.transitions[s1]
      for term in dfa.terminals:
        if not(term in ttab or "*" in ttab):
          result.add DfaMistake(kind: dmkMissingTransition, state: s1,
              missingTerm: term)

      for term, s2 in ttab:
        if (term != "*") and (term notin dfa.terminals):
          result.add DfaMistake(kind: dmkInvalidTransition, term: term,
              states: s1..s2)

    else:
      result.add DfaMistake(kind: dmkMissingTransition, missingTerm: "*", state: s1)

func process*(dfa: Dfa, input: seq[Terminal]): seq[Step] =
  var state = dfa.initialState
  for t in input:
    let nextState = dfa.next(state, t)
    result.add Step(states: state..nextState, term: t)
    state = nextState
