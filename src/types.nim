import std/[tables]
import konva, dfa, coordination

type
  AppState* = enum
    asInitial = "initial"

    asPlaceNewState = "place new state"
    asTransitionSelectSecondState = "select second state to connect with"
    asTransitionEnterTerminals = "enter terminals of transition"

    asStateSelected = "state is selected"
    asTransitionSelected = "transition is selected"

    asPlayEnterInput = "enter input terminals"
    asPlayResult = "result"

    asLoad = "select file to load"

  AppData* = object
    layer*: KLayer
    stage*: AppState
    dfa*: Dfa
    diagram*: Diagram
    selectedStates*: seq[State]
    selectedTerminals*: seq[Terminal]
    mistakes*: seq[DfaMistake]
    steps*: seq[Step]
    inp*: string

  Diagram* = Table[State, Vector]
