import std/[random, strutils, sequtils]

let chs = toseq IdentChars
proc randomStr*(size: Positive): string =
    result = newStringOfCap size
    for i in 1..size:
        result.add chs[rand 0..<chs.len]

func toSlice*[T](a: openArray[T]): Slice[T] = 
    assert a.len == 2
    a[0] .. a[1]

func `==`*[T](s: Slice[T], a: openArray[T]): bool = 
    (a.len == 2) and (s == a[0]..a[1])
