import std/[random, strutils, sequtils, math]
import domain


let chs = toseq IdentChars
proc randomStr*(size: Positive): string =
    result= newStringOfCap size
    for i in 1..size:
        result.add chs[rand 0..<chs.len]


func distance*(p1, p2: Position): float = 
    sqrt((p1.x - p2.x)^2 + (p1.y - p2.y)^2)