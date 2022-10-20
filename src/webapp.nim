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

    asTransitionSelectOtherState
    asTransitionEnterTerminals

    asN

  AppObject = object
    # --- canvas
    layer: KLayer
    transformer: KTransformer
    # --- data
    step: AppState
    dfa: Dfa

    selectedState: string

# ----------------------------

const stateRadius = 30

var
  app = AppObject(
    step: asInitial,
    layer: newLayer(),
    selectedState: "",
    )

# ----------------------------

proc rerender

proc findState(pos: Position): State =
  for name, center in app.dfa.states:
    if distance(pos, center) <= stateRadius:
      return name

  raise newException(ValueError, "not found")

proc stateClick(e: KMouseEvent) =
  e.cancel

  let s = findState((e.evt.offsetX.float, e.evt.offsetY.float))
  case app.step
  of asInitial:
    app.selectedState = s
    app.step = asStateSelected
    redraw()

  of asTransitionSelectOtherState:
    app.step = asTransitionEnterTerminals

  else: discard

proc backgroundClick(e: KMouseEvent) =
  case app.step
  of asPlaceNewState:
    app.step = asInitial
    app.dfa.states[randomStr(10).State] =
      (e.evt.offsetX.float, e.evt.offsetY.float)

  of asStateSelected:
    app.step = asInitial

  else:
    discard

  rerender()
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
  # FIXME use `rename` & from `dfa` module

  rerender()

proc resetState =
  app.step = asInitial

proc resetState2(b: bool) =
  discard

proc removeState =
  app.dfa.remove app.selectedState
  app.step = asInitial
  app.selectedState = ""
  rerender()

# ----------------------------

proc rerender =
  destroyChildren app.layer

  for s, p in app.dfa.states:
    let
      g = newGroup()
      c = newCircle()
      t = newText()

    with c:
      x = p.x
      y = p.y
      fill = pink
      radius = stateRadius
      onclick = stateClick
      addTo g

    with t:
      x = p.x - stateRadius/2
      y = p.y - stateRadius/2
      align = "center"
      text = $s
      listening = false
      addTo g


    if s == app.dfa.initialState:
      discard

    if app.dfa.isAcceptable s:
      discard

    g.addto app.layer

  draw app.layer

proc createDom: VNode =
  buildHtml main:
    navbar:
      tdiv:
        case app.step
        of asStateSelected:
          navbtn "add transition", bccWarning, resetState
          navToggle "initial state", bccSuccess,
            app.selectedState == app.dfa.initialState, resetState2
          navToggle "final state", bccSuccess,
              app.dfa.isAcceptable app.selectedState, resetState2
          navbtn "delete", bccDanger, removeState
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
  let s = newStage document.getElementById "board"
  with s:
    width = window.innerWidth
    height = window.innerHeight / 2
    add app.layer
    onclick = backgroundClick


when isMainModule:
  setRenderer createDom
  discard setTimeout(initBoard, 100)
