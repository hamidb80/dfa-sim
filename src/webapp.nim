import std/[strformat, with, dom, jsconsole]

include karax/prelude
import konva


type
  AppState = enum
    asNormal
    asStateSelected

  AppObject = object
    state: AppState
    layer: KLayer
    transformer: KTransformer


  BootstrapColorClass = enum
    bccPrimary = "primary"
    bccSecondary = "secondary"
    bccSuccess = "success"
    bccInfo = "info"
    bccWarning = "warning"
    bccDanger = "danger"
    bccLight = "light"
    bccDark = "dark"


func navbar(): VNode =
  buildHtml nav(class = "navbar navbar-expand-lg navbar-light bg-light px-3 d-flex justify-content-between align-items-center")

proc navbtn(t: string, color: BootstrapColorClass, action: proc): VNode =
  # let ext =
  #   if disabled: "disabled"
  #   else: ""

  buildHtml button(class = fmt"btn mx-1 btn-outline-{color}"):
    proc onclick = action()
    text t


var app = AppObject(
  layer: newLayer())

proc stageClick(e: KMouseEvent) =
  discard

proc stateClick(e: KMouseEvent) =
  e.cancel
  e.target.fill = "black"


proc newState =
  let c = newCircle()
  with c:
    x = 100
    y = 100
    fill = "red"
    radius = 10

  c.onclick = stateClick

  app.layer.add c

# func bold(t: string): VNode =
#   buildHtml span(class = "font-weight-bold"):
#     text t

proc createDom(): VNode =
  buildHtml main:
    navbar:
      tdiv:
        navbtn "new state", bccPrimary, newState
        navbtn "add transition", bccSuccess, newState
        navbtn "rename", bccWarning, newState
        navbtn "delete", bccDanger, newState
        navbtn "run", bccInfo, newState
        navbtn "save", bccDark, newState

      h4:
        bold:
          text "DFA Simulation"

    tdiv(id = "board")


when isMainModule:
  setRenderer createDom, "root"

  proc setTimeout(ms: int, action: proc ()) =
    discard setTimeout(action, ms)

  setTimeout 500, proc =
    let
      w = window.innerWidth
      h = window.innerHeight / 2
      s = newStage("board")

    with s:
      width = w
      height = h

    s.add app.layer
    s.onclick = stageClick
