import std/[dom, jscore, jsffi, asyncjs, sugar]

proc download*(filename, text: cstring) =
    # from stackoverfloa
    var element = document.createElement("a")
    element.setAttribute("href", "data:text/plaincharset=utf-8," & encodeURIComponent(text))
    element.setAttribute("download", filename)
    element.style.display = "none"
    document.body.appendChild(element)
    element.click()
    document.body.removeChild(element)

proc text(f: dom.File): Future[cstring] {.importcpp, async.}

proc files*(n: Node): seq[dom.File] {.importcpp: "#.files".}

proc readFile*(file: dom.File): Future[cstring] {.async.} = 
    return await file.text()
