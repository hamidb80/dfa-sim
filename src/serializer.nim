import std/[json, sequtils, sets, tables]
import types, dfa, coordination


func `%`*(v: Vector): JsonNode =
  %*[v.x, v.y]

func `%`*[T](hs: HashSet[T]): JsonNode =
  % toseq hs


proc parseVector*(j: JsonNode): Vector =
  (j[0].getFloat, j[1].getFloat)

proc fillAppData*(app: var AppData, j: JsonNode) =
  reset app.dfa
  reset app.diagram

  for s, p in j["diagram"]:
    app.diagram[s] = parseVector(p)

  for s in j["dfa"]["states"]:
    app.dfa.states.incl s.getstr

  for s in j["dfa"]["finalStates"]:
    app.dfa.finalStates.incl s.getstr

  app.dfa.terminals = j["dfa"]["terminals"].to(seq[Terminal])
  app.dfa.initialState = j["dfa"]["initialState"].getstr
  app.dfa.transitions = j["dfa"]["transitions"].to(
      Table[State, Table[Terminal, State]])
