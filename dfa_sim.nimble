# Package

version       = "0.0.1"
author        = "hamidb80"
description   = "DFA (Deterministic Finite Automata) simulator"
license       = "MIT"
srcDir        = "src"
bin           = @["dfa"]


# Dependencies

requires "nim >= 1.6.6"
requires "karax"

task gen, "generates 'script.js' file":
    exec "nim js -o:build/script.js src/webapp.nim"
