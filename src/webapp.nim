import std/[strformat, with, tables]

import std/[dom, jsconsole]
include karax/prelude
import ui
import konva

import domain, dfa, utils


# ----------------------------

type
  AppState = enum
    asInitial = "initial"

    asPlaceNewState = "place new state"
    asStateSelected = "state is selected"

  AppObject = object
    # --- canvas
    layer: KLayer
    transformer: KTransformer
    # --- data
    step: AppState
    dfa: Dfa

    selectedState: string

# ----------------------------

var
  app = AppObject(
    step: asInitial,
    layer: newLayer(),
    selectedState: "",
    )

# ----------------------------

const stateRadius = 30

proc rerender

proc findState(pos: Position): State =
  for name, center in app.dfa.states:
    if distance(pos, center) <= stateRadius:
      return name

  raise newException(ValueError, "not found")

proc stateClick(e: KMouseEvent) =
  e.cancel
  app.selectedState = findState((e.evt.offsetX.float, e.evt.offsetY.float))
  app.step = asStateSelected
  redraw()

proc backgroundClick(e: KMouseEvent) =
  case app.step
  of asPlaceNewState:
    let
      c = newCircle()
      x = e.evt.offsetX.float
      y = e.evt.offsetY.float

    with c:
      x = x
      y = y
      fill = pink
      radius = stateRadius
      onclick = stateClick
      addTo app.layer

    app.selectedState = randomStr(10).State
    app.dfa.states[app.selectedState] = (x, y)
    app.step = asStateSelected

  of asStateSelected:
    app.step = asInitial

  else:
    discard

  redraw()

proc enterPlaceState =
  app.step = asPlaceNewState

proc setName =
  assert app.step == asStateSelected
  let 
    newname = $getVNodeById("name-of-state").dom.value
    oldname = app.selectedState
    pos = app.dfa.states[oldname]

  app.selectedState = newname
  app.dfa.states[newname] = pos
  del app.dfa.states, oldname
  # TODO remove transitions too


proc resetState =
  app.step = asInitial

# ----------------------------

proc rerender =
  destroyChildren app.layer

proc createDom: VNode =
  buildHtml main:
    navbar:
      tdiv:
        case app.step
        of asStateSelected:
          navbtn "add transition", bccWarning, resetState
          navbtn "initial state", bccSuccess, resetState
          navbtn "final state", bccSuccess, resetState
          navbtn "delete", bccDanger, resetState
        else:
          navbtn "new state", bccPrimary, enterPlaceState
          navbtn "run", bccInfo, resetState
          navbtn "save", bccDark, resetState


      h4:
        bold:
          text "DFA Simulation"

    konva "board"

    status:
      bold: text "STATE: "
      text $app.step

      case app.step
      of asStateSelected:
        text " - "
        text app.selectedState

      else:
        discard

    extra:
      case app.step
      of asStateSelected:
        input(class = "form-control", id = "name-of-state",
            value = app.selectedState, placeholder = "name of the state")
        navbtn "set", bccPrimary, setName

      else: discard

proc initBoard =
  let
    w = window.innerWidth
    h = window.innerHeight / 2
    s = newStage document.getElementById "board"

  with s:
    width = w
    height = h

  s.add app.layer
  s.onclick = backgroundClick


when isMainModule:
  setRenderer createDom
  discard setTimeout(initBoard, 100)
