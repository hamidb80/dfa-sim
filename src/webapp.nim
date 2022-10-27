import std/[strformat, with, tables, strutils, sets, sugar, macros, math]

include karax/prelude
import std/[dom, jsconsole]
import ui
import konva

import coordination, dfa, utils


# ----------------------------

type
  AppState = enum
    asInitial = "initial"

    asPlaceNewState = "place new state"
    asTransitionSelects
    asTransitionEnterTerminals

    asStateSelected = "state is selected"
    asTransitionSelected = "transition is selected"


  AppObject = object
    layer: KLayer
    step: AppState
    dfa: Dfa
    diagram: Diagram
    selectedStates: seq[State]
    selectedTerminals: seq[Terminal]
    inp: string

  Diagram = object
    statesPos: Table[State, Position]

# ----------------------------

const
  stateRadius = 30.0
  loopUpper = stateRadius*2.3

var
  app = AppObject(
    step: asInitial,
    layer: newLayer(),
    selectedStates: @[],
    )

# ----------------------------

proc rerender

proc findState(pos: Position): State =
  for name in app.dfa.states:
    let center = app.diagram.statespos[name]
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

  of asTransitionSelects:
    app.selectedStates.add s
    app.step = asTransitionEnterTerminals

  else: discard

  rerender()
  redraw()

proc backgroundClick(e: KMouseEvent) =
  case app.step
  of asPlaceNewState:
    app.step = asInitial

    let name = randomStr(10).State
    app.dfa.states.incl name
    app.diagram.statesPos[name] =
      (e.evt.offsetX.float, e.evt.offsetY.float)

  else:
    reset app.selectedStates
    app.step = asInitial

  rerender()
  redraw()

proc enterPlaceState =
  app.step = asPlaceNewState

proc enterNewTranstion =
  app.step = asTransitionSelects

proc setTerminals =
  let
    terminals = $getVNodeById("terminals").dom.value
    rel = toSlice app.selectedStates

  if app.step == asTransitionSelected:
    for t in app.selectedTerminals:
      del app.dfa.transitions[rel.a], t

  for t in terminals.split ",":
    let term = t.strip
    if rel.a in app.dfa.transitions:
      app.dfa.transitions[rel.a][term] = rel.b
    else:
      app.dfa.transitions[rel.a] = totable {term: rel.b}

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

  let p = app.diagram.statesPos[oldname]
  app.diagram.statesPos[newName] = p
  del app.diagram.statesPos, oldname

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

proc deleteTransitions =
  for t in app.selectedTerminals:
    del app.dfa.transitions[app.selectedStates[0]], t

  app.step = asInitial
  rerender()
  redraw()

proc genTransitionClick(dir: Slice[State], terminals: seq[Terminal]):
  proc(e: KMouseEvent) =

  return proc(e: KMouseEvent) =
    app.step = asTransitionSelected
    app.selectedStates = @[dir.a, dir.b]
    app.selectedTerminals = terminals
    app.inp = terminals.join(", ")

    rerender()
    redraw()

proc run =
  echo app.dfa.terminals

# ----------------------------

proc rerender =
  destroyChildren app.layer # clear

  for s in app.dfa.states: # states
    let
      p = app.diagram.statespos[s]
      g = newGroup()
      c = newCircle()
      t = newText()

    with c:
      x = p.x
      y = p.y
      radius = stateRadius
      fill =
        if s in app.selectedStates: green
        elif s == app.dfa.initialState: lemon
        else: pink
      stroke =
        if app.dfa.isFinal s: "black"
        else: "transparent"
      strokeWidth =
        if s in app.dfa.finalStates: 2
        else: 0
      onclick = stateClick
      addTo g

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
          app.diagram.statespos[s] = p + mv
          rerender()

        addto app.layer

  for s in app.dfa.states: # transition lines
    let p = app.diagram.statespos[s]

    for s2, terms in app.dfa.reducedTerms(s):
      let pp = app.diagram.statespos[s2]

      let a = newArrow()
      with a:
        points =
          if s == s2:
            let
              diff = 14.0
              x1 = p.x - diff
              x2 = p.x + diff
              yoffset = sqrt(stateRadius^2 - diff^2)
              y1 = p.y - yoffset
              y2 = p.y - loopUpper

            @[x1, y1, x1, y2, x2, y2, x2, y1]

          else:
            let
              u = (p .. pp).unit
              diff = len p..pp
              ps = p - u*stateRadius
              pe = pp + u*stateRadius

            @[ps.x, ps.y, pe.x, pe.y]
        stroke =
          if (app.step == asTransitionSelected) and (s..s2 ==
              app.selectedStates):
            "red"
          else:
            "black"
        addTo app.layer

  for s in app.dfa.states: # transition lables
    let p = app.diagram.statespos[s]
    for s2, terms in app.dfa.reducedTerms(s):
      let
        pp = app.diagram.statespos[s2]
        label = terms.join(", ")
        med = (p .. pp) * 0.3

        lbl = newLabel()
        txt = newText()
        tag = newTag()

      with tag:
        fill = "white"
        addTo lbl

      capture s, s2, terms:
        with txt:
          text = label
          fill = "black"
          fontsize = 20
          onclick = genTransitionClick(s .. s2, terms)
          addTo lbl

      with lbl:
        x = med.x
        y =
          if s == s2: med.y - loopUpper
          else: med.y
        addTo app.layer

  draw app.layer # update

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
          navbtn "run", bccSuccess, run
          navbtn "save", bccDark, resetState

        of asTransitionSelected:
          navbtn "delete", bccDanger, deleteTransitions

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

      of asTransitionEnterTerminals, asTransitionSelected:
        input(class = "form-control", id = "terminals",
          value = app.inp,
          placeholder = "terminals separated by (,)")

        navbtn "set", bccPrimary, setTerminals

      else: discard

    output:
      discard

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
