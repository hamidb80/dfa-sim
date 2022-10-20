import std/[strformat, with]

import std/[dom, jsconsole]
include karax/prelude
import ui
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

    dfa: DFa

# ----------------------------

var
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
      fill = pink
      radius = 30
      onclick = stateClick
      addTo app.layer

    app.state = asReanmeState
    redraw()

  else:
    discard

proc enterPlaceState =
  app.state = asPlaceNewState

proc doNothing =
  discard

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

    verbatim "<div id='board'></div>"

    text $app.state

    case app.state
    of asReanmeState:
      footer(class = "px-2 navbar navbar-expand-lg navbar-light bg-light d-flex justify-content-between align-items-center"):
        input()
        navbtn "submit", bccPrimary, doNothing

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
  discard setTimeout(initBoard, 500)
