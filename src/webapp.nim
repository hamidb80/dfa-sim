include karax/prelude


when false:
  newGrammer.onclick = proc = 
    input termianls
  
  state.onclick = proc =
    select state
    show buttons:
      -add_transition
      -set/unset as final
      -remove
      -rename 
    
  add_transition.onclick = proc = 
    enter inputs [sparated_by_comma]
    select other_state

    if there was another line between them already:
      add newstates to the line text
    else:
      draw_line state .. other_state


  run.onclick:
    input = enter seq[Terminal]

    var q = dfa.initialState

    for t in input:
      q  = dfa.step(q, t)
      unfocus last state
      focus new state
      
    if dfa.isAcceptable q:
      discard
    else:
      discard


proc createDom(): VNode =
  buildHtml tdiv:
    header:
      button(class="btn btn-primary"):
        text "new"

    tdiv(id = "mainframe")


setRenderer createDom, "root"
