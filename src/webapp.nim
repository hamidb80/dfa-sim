import std/[strformat, with, tables, strutils, sets, sugar, macros]

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
    # --- data
    step: AppState
    dfa: Dfa

    selectedStates: seq[string]

# ----------------------------

const stateRadius = 30.0

var
  app = AppObject(
    step: asInitial,
    layer: newLayer(),
    selectedStates: @[],
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

  let
    p = (e.evt.offsetX.float, e.evt.offsetY.float)
    s = findState(p)

  case app.step
  of asInitial, asStateSelected:
    app.selectedStates = @[s]
    app.step = asStateSelected

  of asTransitionSelectOtherState:
    if app.selectedStates[0] != s: # loop
      app.selectedStates.add s
      app.step = asTransitionEnterTerminals
    else:
      app.step = asInitial

  else: discard

  redraw()

proc backgroundClick(e: KMouseEvent) =
  case app.step
  of asPlaceNewState:
    app.step = asInitial
    app.dfa.states[randomStr(10).State] =
      (e.evt.offsetX.float, e.evt.offsetY.float)

  else:
    app.step = asInitial

  rerender()
  redraw()

proc enterPlaceState =
  app.step = asPlaceNewState

proc enterNewTranstion =
  app.step = asTransitionSelectOtherState

proc setTerminals =
  let terminals = $getVNodeById("terminals").dom.value

  for t in terminals.split ",":
    let
      term = t.strip
      s1 = app.selectedStates[0]
      s2 = app.selectedStates[1]

    if s1 in app.dfa.transitions:
      app.dfa.transitions[s1][term] = s2
    else:
      app.dfa.transitions[s1] = totable {term: s2}

  app.step = asInitial
  rerender()

proc setInitial(t: bool) =
  if t == true:
    app.dfa.initialState = app.selectedStates[0]

proc toggleAsFinal(t: bool) =
  if t:
    app.dfa.finalStates.incl app.selectedStates[0]
  else:
    app.dfa.finalStates.excl app.selectedStates[0]

proc setName =
  assert app.step == asStateSelected
  let
    newName = $getVNodeById("name-of-state").dom.value
    oldName = app.selectedStates[0]

  app.dfa.rename oldName, newName
  app.selectedStates = @[newname]
  rerender()

proc resetState =
  app.step = asInitial

proc resetState2(b: bool) =
  discard

proc removeState =
  app.dfa.remove app.selectedStates[0]
  app.step = asInitial
  reset app.selectedStates
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
      radius = stateRadius
      fill =
        if app.dfa.initialState == s: green
        else: pink

      onclick = stateClick
      addTo g

    if app.dfa.isFinal s:
      c.stroke = "black"

    with t:
      x = p.x - stateRadius/2
      y = p.y - stateRadius/2
      align = "center"
      text = $s
      fontsize = 20
      listening = false
      addTo g

    capture g, s, p:
      with g:
        draggable = true
        dragmove = proc =
          let mv = (g.x, g.y)
          app.dfa.states[s] = p + mv

        addto app.layer

  for s, p in app.dfa.states:
    for otherState, terms in app.dfa.reducedTerms(s):
      let
        pp = app.dfa.states[otherState]
        label = terms.join(", ")
        med = (p .. pp) * 0.4

      let a = newArrow()
      with a:
        points = block:
          let
            u = (p .. pp).unit
            diff = len p..pp
            ps = p - u*stateRadius
            pe = pp + u*stateRadius

          @[ps.x, ps.y, pe.x, pe.y]

        stroke = "black"
        addTo app.layer


      let txt = newText()
      with txt:
        text = label
        x = med.x
        y = med.y
        fill = "black"
        stroke = "white"
        strokeWidth = 0.4
        fontsize = 20
        addTo app.layer


  draw app.layer

proc createDom: VNode =
  buildHtml main:
    navbar:
      tdiv:
        case app.step

        of asStateSelected:
          navbtn "add transition", bccWarning, enterNewTranstion
          navToggle "initial state", bccSuccess,
            app.selectedStates[0] == app.dfa.initialState, setInitial
          navToggle "final state", bccSuccess,
              app.dfa.isFinal app.selectedStates[0], toggleAsFinal
          navbtn "delete", bccDanger, removeState

        of asInitial:
          navbtn "new state", bccPrimary, enterPlaceState
          navbtn "run", bccInfo, resetState
          # navbtn "save", bccDark, resetState

        else:
          navbtn "cancel", bccWarning, resetState

      h4:
        bold:
          text "DFA Simulation"

    konva "board"

    status:
      bold: text "STATUS: "
      text $app.step

      case app.step
      of asStateSelected:
        text " - "
        text app.selectedStates[0]

      else:
        discard

    extra:
      case app.step
      of asStateSelected:
        input(class = "form-control", id = "name-of-state",
          value = app.selectedStates[0],
          placeholder = "name of the state")

        navbtn "set", bccPrimary, setName

      of asTransitionEnterTerminals:
        input(class = "form-control", id = "terminals",
          value = "",
          placeholder = "terminals separated by (,)")

        navbtn "set", bccPrimary, setTerminals


      else: discard

    # TODO transition table

proc initBoard =
  let s = newStage document.getElementById "board"
  with s:
    width = window.innerWidth.toFloat
    height = window.innerHeight.toFloat / 2
    add app.layer
    onclick = backgroundClick


when isMainModule:
  setRenderer createDom
  discard setTimeout(initBoard, 100)
