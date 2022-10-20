# Package

version       = "0.0.0"
author        = "hamidb80"
description   = "DFA ( deterministic finite automata ) simulator"
license       = "MIT"
srcDir        = "src"
bin           = @["dfa"]


# Dependencies

requires "nim >= 1.6.6"

task gen, "generates 'script.js' file":
    exec "nim js -o:build/script.js src/webapp.nim"
