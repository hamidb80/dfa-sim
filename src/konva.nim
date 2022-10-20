import std/[jsffi, dom]

type
  KNode* = object of JsObject

  KStage* = object of KNode
  KLayer* = object of KNode
  KShape* = object of KNode

  KGroup* = object of KShape
  KArrow* = object of KShape
  KCircle* = object of KShape
  KText* = object of KShape
  KLine* = object of KShape

  KTransformer* = object of JsObject

  KEvent* = object of JsObject
  KMouseEvent* = object of KEvent
    currentTarget*: KStage
    evt*: MouseEvent
    pointerId*: int
    target*: KNode
    `type`*: string
    cancelBubble*: bool

  Number* = int or float



func newStage*(container: cstring | Element): KStage
  {.importcpp: "new Konva.Stage({container: #})".}

func newLayer*: KLayer
  {.importcpp: "new Konva.Layer()".}

func newGroup*: KGroup
  {.importcpp: "new Konva.Group()".}

func newCircle*: KCircle
  {.importcpp: "new Konva.Circle()".}

func newText*: KText
  {.importcpp: "new Konva.Text()".}

func newArrow*: KArrow
  {.importcpp: "new Konva.Arrow()".}


func destroyChildren*(l: KLayer)
  {.importcpp: "#.destroyChildren()".}

func draw*(l: KLayer)
  {.importcpp: "#.draw()".}

func add*(s, n: Knode)
  {.importcpp: "#.add(#)".}

func addTo*(n, s: Knode) =
  s.add n


func `x=`*(k: KNode, n: Number)
  {.importcpp: "#.x(#)".}

func `x`*(k: KNode): Number
  {.importcpp: "#.x()".}


func `y=`*(k: KNode, n: Number)
  {.importcpp: "#.y(#)".}

func `y`*(k: KNode): Number
  {.importcpp: "#.y()".}


func `width=`*(k: KNode, n: Number)
  {.importcpp: "#.width(#)".}

func `width`*(k: KNode): Number
  {.importcpp: "#.width()".}


func `height=`*(k: KNode, n: Number)
  {.importcpp: "#.height(#)".}

func `height`*(k: KNode): Number
  {.importcpp: "#.height()".}


func `id=`*(k: KNode, n: Number)
  {.importcpp: "#.id(#)".}

func `id`*(k: KNode): cstring
  {.importcpp: "#.id()".}


func `radius=`*(k: KNode, v: Number)
 {.importcpp: "#.radius(#)".}

func `radius`*(k: KNode): Number
  {.importcpp: "#.radius()".}


func `fill=`*(k: KNode, v: cstring)
  {.importcpp: "#.fill(#)".}

func `fill`*: cstring
  {.importcpp: "#.radius()".}


func `text=`*(k: KText, n: cstring)
  {.importcpp: "#.text(#)".}

func `text`*(k: KText): cstring
  {.importcpp: "#.text()".}


func `align=`*(k: KText, n: cstring)
  {.importcpp: "#.align(#)".}

func `align`*(k: KText): cstring
  {.importcpp: "#.align()".}


func `stroke=`*(k: KNode, n: cstring)
  {.importcpp: "#.stroke(#)".}

func `stroke`*(k: KNode): cstring
  {.importcpp: "#.stroke()".}


func `listening=`*(k: KText, n: bool)
  {.importcpp: "#.listening(#)".}

func `listening`*(k: KText): bool
  {.importcpp: "#.listening()".}


func `points=`*(k: KNode, cs: seq[Number])
  {.importcpp: "#.points(#)".}

func `points`*(k: KNode): seq[Number]
  {.importcpp: "#.points()".}


func `onclick=`*(k: KNode, cb: proc(ev: KMouseEvent))
  {.importcpp: "#.on('click', #)".}

# func `stroke=`(k: KNode, v: Number)
# func `stroke`

# func `strokeWidth=`(k: KNode, v: Number)
# func `strokeWidth`

# TODO define getter and setter

proc cancel*(e: KEvent)
  {.importcpp: "#.cancelBubble = true".}
