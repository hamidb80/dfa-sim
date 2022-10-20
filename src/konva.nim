import std/[jsffi, dom]

type
  KNode* = object of JsObject

  KStage* = object of KNode
  KLayer* = object of KNode
  KShape* = object of KNode

  KCircle* = object of KShape
  KText* = object of KShape

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



func newStage*(container: cstring): KStage
  {.importcpp: "new Konva.Stage({container: #})".}

func newLayer*(): KLayer
  {.importcpp: "new Konva.Layer()".}

func newCircle*(): KCircle
  {.importcpp: "new Konva.Circle()".}

func add*(s, n: Knode)
  {.importcpp: "#.add(#)".}

func addTo*(n, s: Knode) = 
  s.add n


func `x=`*(k: KNode, n: Number)
  {.importcpp: "#.x(#)".}

func `x`*(k: KNode)
  {.importcpp: "#.x()".}


func `y=`*(k: KNode, n: Number)
  {.importcpp: "#.y(#)".}

func `y`*(k: KNode)
  {.importcpp: "#.y()".}


func `width=`*(k: KNode, n: Number)
  {.importcpp: "#.width(#)".}

func `width`*(k: KNode)
  {.importcpp: "#.width()".}


func `height=`*(k: KNode, n: Number)
  {.importcpp: "#.height(#)".}

func `height`*(k: KNode)
  {.importcpp: "#.height()".}


func `id=`*(k: KNode, n: Number)
  {.importcpp: "#.id(#)".}

func `id`*(k: KNode)
  {.importcpp: "#.id()".}


func `radius=`*(k: KNode, v: Number)
 {.importcpp: "#.radius(#)".}

func `radius`*(k: KNode): Number
  {.importcpp: "#.radius()".}


func `fill=`*(k: KNode, v: cstring)
  {.importcpp: "#.fill(#)".}

func `fill`*: cstring
  {.importcpp: "#.radius()".}


func `onclick=`*(k: KNode, cb: proc(ev: KMouseEvent))
  {.importcpp: "#.on('click', #)".}

# func `stroke=`(k: KNode, v: Number)
# func `stroke`

# func `strokeWidth=`(k: KNode, v: Number)
# func `strokeWidth`

# TODO define getter and setter

proc cancel*(e: KEvent)
  {.importcpp: "#.cancelBubble = true".}
