import std/[strformat, with]

import std/[dom, jsconsole]
include karax/prelude
import ui
import konva

import dfa


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
    state: AppState
    dfa: Dfa

# ----------------------------

var
  app = AppObject(
    state: asInitial,
    layer: newLayer(),

    )

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

    app.state = asStateSelected
    redraw()

  else:
    discard

proc enterPlaceState =
  app.state = asPlaceNewState

proc setName =
  assert app.state == asStateSelected
  let name = getVNodeById("name-of-state").dom.value
  echo name

proc resetState =
  app.state = asInitial

proc rebuild =
  discard

proc rerender =
  destroyChildren app.layer


# ----------------------------

proc createDom: VNode =
  buildHtml main:
    navbar:
      tdiv:
        case app.state
        of asStateSelected:
          navbtn "add transition", bccSuccess, resetState
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
      text $app.state

    extra:
      case app.state
      of asStateSelected:
        input(class = "form-control", id = "name-of-state",
            placeholder = "name of the state")
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
  discard setTimeout(initBoard, 500)
