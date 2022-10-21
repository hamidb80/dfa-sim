import std/[random, strutils, sequtils]

let chs = toseq IdentChars
proc randomStr*(size: Positive): string =
    result = newStringOfCap size
    for i in 1..size:
        result.add chs[rand 0..<chs.len]
