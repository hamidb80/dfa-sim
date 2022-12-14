import std/[strformat, with, tables, strutils, sets, sugar, macros, math, json, sequtils]

include karax/prelude
import std/[dom, jsconsole, jsffi, asyncjs]
import web, ui, konva

import coordination, dfa, utils, types, serializer

# app states -------------------

var app = AppData(
    stage: asInitial,
    layer: newLayer(),
    selectedStates: @[])

# forward declaration ---------

proc rerender

# state switches ------------------------

proc switchState(s: AppState) =
  case s:
  of asInitial:
    app.inp = app.dfa.terminals.join(", ")
  else:
    discard

  app.stage = s

proc enterPlaceState =
  switchState asPlaceNewState

proc enterNewTranstion =
  switchState asTransitionSelectSecondState

proc resetAppState =
  switchState asInitial

proc enterPlayTerms =
  switchState asPlayEnterInput

proc enterLoadState =
  switchState asLoad

# konva events -----------------------

proc findState(pos: Vector): State =
  for name in app.dfa.states:
    let center = app.diagram[name]
    if distance(pos, center) <= stateRadius:
      return name

  raise newException(ValueError, "not found")

proc backgroundClick(e: KMouseEvent) =
  case app.stage
  of asPlaceNewState:
    switchState asInitial

    let name = randomStr(10).State
    app.dfa.states.incl name
    app.diagram[name] =
      (e.evt.offsetX.float, e.evt.offsetY.float)

  else:
    reset app.selectedStates
    switchState asInitial

  rerender()
  redraw()

proc stateClick(e: KMouseEvent) =
  e.cancel

  let
    p = (e.evt.offsetX.float, e.evt.offsetY.float)
    s = findState(p)

  case app.stage
  of asInitial, asStateSelected:
    app.selectedStates = @[s]
    switchState asStateSelected

  of asTransitionSelectSecondState:
    app.selectedStates.add s
    switchState asTransitionEnterTerminals

  else: discard

  rerender()
  redraw()

proc genTransitionClick(dir: Slice[State], terminals: seq[Terminal]):
  proc(e: KMouseEvent) =

  return proc(e: KMouseEvent) =
    switchState asTransitionSelected
    app.selectedStates = @[dir.a, dir.b]
    app.selectedTerminals = terminals
    app.inp = terminals.join(", ")

    rerender()
    redraw()

# actions ---------------------------

proc setTerminals =
  let terminals = splitTerms $getVNodeById("input").dom.value

  case app.stage
    of asInitial:
      app.dfa.terminals = terminals

    of asTransitionEnterTerminals, asTransitionSelected:
      let rel = toSlice app.selectedStates
      if app.stage == asTransitionSelected:
        for t in app.selectedTerminals:
          del app.dfa.transitions[rel.a], t

      for term in terminals:
        if rel.a in app.dfa.transitions:
          app.dfa.transitions[rel.a][term] = rel.b
        else:
          app.dfa.transitions[rel.a] = totable {term: rel.b}

    else:
      assert false

  switchState asInitial
  rerender()

proc setInitialState(state: bool) =
  if state == true:
    app.dfa.initialState = app.selectedStates[0]

proc toggleAsFinal(add: bool) =
  if add:
    app.dfa.finalStates.incl app.selectedStates[0]
  else:
    app.dfa.finalStates.excl app.selectedStates[0]

proc setName =
  let
    newName = $getVNodeById("input").dom.value
    oldName = app.selectedStates[0]

  if oldName != newName:
    app.dfa.rename oldName, newName

    let p = app.diagram[oldname]
    app.diagram[newName] = p
    del app.diagram, oldname

    app.selectedStates = @[newname]
    rerender()

proc removeState =
  app.dfa.remove app.selectedStates[0]
  switchState asInitial
  reset app.selectedStates
  rerender()

proc deleteTransitions =
  for t in app.selectedTerminals:
    del app.dfa.transitions[app.selectedStates[0]], t

  switchState asInitial
  rerender()
  redraw()

proc getResult =
  app.selectedTerminals = splitTerms $getVNodeById("input").dom.value
  app.mistakes = mistakes(app.dfa) & inputErrors(app.dfa, app.selectedTerminals)

  if app.mistakes.len == 0:
    app.steps = app.dfa.process(app.selectedTerminals)
    switchState asPlayResult
  else:
    switchState asInitial

  redraw()

proc save =
  download "dfa.json", $ %*{"dfa": app.dfa, "diagram": app.diagram}

proc loadImpl(e: Event, _: VNode) =
  discard e.target.files[0].readfile.then proc(r: cstring) =
    fillAppData app, ($r).parseJson
    switchState asInitial
    rerender()
    redraw()

# main --------------------------

proc rerender =
  destroyChildren app.layer # clear

  for s in app.dfa.states: # states
    let
      p = app.diagram[s]
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
          app.diagram[s] = p + mv
          rerender()

        addto app.layer

  for s in app.dfa.states: # transition lines
    let p = app.diagram[s]

    for s2, terms in app.dfa.reducedTerms(s):
      let pp = app.diagram[s2]

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
          if (app.stage == asTransitionSelected) and (s..s2 ==
              app.selectedStates):
            "red"
          else:
            "black"
        addTo app.layer

  for s in app.dfa.states: # transition lables
    let p = app.diagram[s]
    for s2, terms in app.dfa.reducedTerms(s):
      let
        pp = app.diagram[s2]
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
        case app.stage

        of asStateSelected:
          navbtn "add transition", bccWarning, enterNewTranstion
          navToggle "initial state", bccSuccess,
            app.selectedStates[0] == app.dfa.initialState, setInitialState
          navToggle "final state", bccSuccess,
              app.dfa.isFinal app.selectedStates[0], toggleAsFinal
          navbtn "delete", bccDanger, removeState

        of asInitial:
          navbtn "new state", bccPrimary, enterPlaceState
          navbtn "run", bccSuccess, enterPlayTerms
          spacex 2
          navbtn "save", bccDark, save
          navbtn "load", bccInfo, enterLoadState

        of asTransitionSelected:
          navbtn "delete", bccDanger, deleteTransitions

        else:
          navbtn "cancel", bccWarning, resetAppState

      h4:
        bold:
          text "DFA Simulation"

    konva "board"

    status:
      bold: text "STATUS: "
      text $app.stage

    controller:
      case app.stage
      of asStateSelected:
        input(class = "form-control", id = "input",
          value = app.selectedStates[0],
          placeholder = "name of the state")

        navbtn "set name", bccPrimary, setName

      of asTransitionEnterTerminals, asTransitionSelected, asInitial:
        input(class = "form-control", id = "input",
          value = app.inp,
          placeholder = "terminals separated by (,)")

        navbtn "set terminals", bccPrimary, setTerminals

      of asPlayEnterInput:
        input(class = "form-control", id = "input",
          placeholder = "terminals separated by (,)")

        navbtn "go!", bccPrimary, getResult

      of asLoad:
        input(class = "form-control", type = "file", accept = "text/json",
            onchange = loadImpl)

      else: discard

    sec "Transition Table":
      table(class = "table table-striped"):
        thead:
          tr:
            th(scope = "col"): text "state/terminal"
            for t in app.dfa.terminals:
              th(scope = "col"): text t
        tbody:
          for s in app.dfa.states:
            tr:
              th(scope = "row"):
                if s == app.dfa.initialState: styledText("->" & s, bccDanger)
                elif s in app.dfa.finalStates: styledText(s, bccPrimary)
                else: text s

              for t in app.dfa.terminals:
                td:
                  if s in app.dfa.transitions and (
                    t in app.dfa.transitions[s] or "*" in app.dfa.transitions[s]):
                    text app.dfa.next(s, t)
                  else:
                    span(class = "text-primary"):
                      styledText "?", bccDanger

    if app.mistakes.len != 0:
      sec "Errors":
        ul:
          for e in app.mistakes:
            li:
              bold:
                text $e.kind, ": "

              case e.kind:
              of dmkInvalidTransition:
                text e.states.a, " -> ", e.states.a, " | ", e.term

              of dmkMissingTransition:
                text $'"', e.state, $'"', " :: ", e.missingTerm

              of dmkInvalidInputTerminal:
                text e.invalidTerm

              else: discard

    elif app.stage == asPlayResult:
      sec "Result":
        table(class = "table table-striped"):
          thead:
            tr:
              for t in ["#", "state 1", "terminal", "state 2"]:
                th(scope = "col"): text t
          tbody:
            for i, s in app.steps:
              tr:
                th(scope = "row"):
                  text $(i+1)

                for t in [s.states.a, s.term, s.states.b]:
                  td:
                    text t

        h4(class = "p-3"):
          let
            lastState = app.steps[^1].states.b
            cond = isFinal(app.dfa, lastState)

          text "is accepted? "
          case cond:
          of true: styledText "Yes", bccSuccess
          of false: styledText "No", bccDanger

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
