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
      q = dfa.step(q, t)
      unfocus last state
      focus new state

    if dfa.isFinal q:
      discard
    else:
      discard

