import std/[jsffi, dom]

type
  KNode* = ref object of JsObject

  KStage* = ref object of KNode
  KLayer* = ref object of KNode
  KShape* = ref object of KNode

  KGroup* = ref object of KShape
  KTag* = ref object of KShape
  KLabel* = ref object of KShape
  KArrow* = ref object of KShape
  KCircle* = ref object of KShape
  KText* = ref object of KShape
  KLine* = ref object of KShape

  KTransformer* = ref object of KNode

  KEvent* = ref object of JsObject
  KMouseEvent* = ref object of KEvent
    currentTarget*: KStage
    evt*: MouseEvent
    pointerId*: int
    target*: KNode
    `type`*: string
    cancelBubble*: bool

  Number* = float



func newStage*(container: cstring | Element): KStage
  {.importcpp: "new Konva.Stage({container: #})".}

func newLayer*: KLayer
  {.importcpp: "new Konva.Layer()".}

func newTransformer*: KTransformer
  {.importcpp: "new Konva.Transformer()".}

func newLabel*: KLabel
  {.importcpp: "new Konva.Label()".}

func newTag*: KTag
  {.importcpp: "new Konva.Tag()".}

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

func moveTo*(n, s: Knode)
  {.importcpp: "#.moveTo(#)".}


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


func `fontSize=`*(k: KNode, n: Number)
  {.importcpp: "#.fontSize(#)".}

func `fontSize`*(k: KNode): Number
  {.importcpp: "#.fontSize()".}


func `strokeWidth=`*(k: KNode, n: Number)
  {.importcpp: "#.strokeWidth(#)".}

func `strokeWidth`*(k: KNode): Number
  {.importcpp: "#.strokeWidth()".}


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


func `listening=`*(k: KNode, n: bool)
  {.importcpp: "#.listening(#)".}

func `listening`*(k: KNode): bool
  {.importcpp: "#.listening()".}


func `draggable=`*(k: KNode, n: bool)
  {.importcpp: "#.draggable(#)".}

func `draggable`*(k: KNode): bool
  {.importcpp: "#.draggable()".}


func `points=`*(k: KNode, cs: seq[Number])
  {.importcpp: "#.points(#)".}

func `points`*(k: KNode): seq[Number]
  {.importcpp: "#.points()".}


func `nodes=`*(k: KNode, cs: seq[KNode])
  {.importcpp: "#.nodes(#)".}

func `nodes`*(k: KNode): seq[KNode]
  {.importcpp: "#.nodes()".}


func `onclick=`*(k: KNode, cb: proc(ev: KMouseEvent))
  {.importcpp: "#.on('click', #)".}

func `dragend=`*(k: KNode, cb: proc)
  {.importcpp: "#.on('dragend', #)".}

func `dragmove=`*(k: KNode, cb: proc)
  {.importcpp: "#.on('dragend', #)".}

# func `strokeWidth=`(k: KNode, v: Number)
# func `strokeWidth`

proc cancel*(e: KEvent)
  {.importcpp: "#.cancelBubble = true".}
