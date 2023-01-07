const scriptUrl = "src.py"

var pyodide = null
var mainFn = null

function def(code) {
  return pyodide.runPython(code)
}

async function init() {
  if (pyodide == null) {
    console.info("start init ...")
    pyodide = await loadPyodide()
    console.info("pyodide loaded ...")
    let code = await (await fetch(scriptUrl, { cache: "no-cache" })).text()
    console.info("code loaded")
    mainFn = def(code)
    console.info("init done")
  }
}

function toJs(x) {
  if (typeof x == "object")
    return x.toJs()
  else
    return x
}

function toPy(x) {
  return pyodide.toPy(x)
}

function runMainFn(data, callback) {
  init().then(() => {
    let result = toJs(mainFn(toPy(data)))
    callback(result)
  })
}

// ------ main 
init()