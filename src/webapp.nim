import std/[strformat, with, dom, jsconsole]

include karax/prelude
import uicomponents
import konva

import dfa


# ----------------------------

type
  AppState = enum
    asInitial

    asPlaceNewState
    asReanmeState
    asStateSelected

  AppObject = object
    state: AppState
    layer: KLayer
    transformer: KTransformer

    dfa: Dfa

# ----------------------------

var
  lastState: AppState
  forceUpdate: bool

  app = AppObject(
    state: asInitial,
    layer: newLayer())

# ----------------------------

proc stateClick(e: KMouseEvent) =
  e.cancel

proc backgroundClick(e: KMouseEvent) =
  case app.state
  of asPlaceNewState:
    let c = newCircle()
    with c:
      x = e.evt.offsetX
      y = e.evt.offsetY
      fill = "red"
      radius = 30
      onclick = stateClick
      addTo app.layer

    app.state = asReanmeState
    redraw()

  else:
    discard

proc enterPlaceState =
  app.state = asPlaceNewState

proc doNothing = discard

# ----------------------------

proc createDom: VNode =
  buildHtml main:
    navbar:
      tdiv:
        navbtn "new state", bccPrimary, enterPlaceState
        navbtn "add transition", bccSuccess, doNothing
        navbtn "rename", bccWarning, doNothing
        navbtn "delete", bccDanger, doNothing
        navbtn "run", bccInfo, doNothing
        navbtn "save", bccDark, doNothing

      h4:
        bold:
          text "DFA Simulation"

    tdiv(id = "board")

    case app.state
    of asReanmeState: 
      discard

    else: 
      discard

proc initBoard =
  let
    w = window.innerWidth
    h = window.innerHeight / 2
    s = newStage("board")

  with s:
    width = w
    height = h

  s.add app.layer
  s.onclick = backgroundClick


when isMainModule:
  setRenderer createDom, "root"
  discard setTimeout(initBoard, 500)
