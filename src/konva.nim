type
  KNode* = object of RootObj

  KStage* = object of KNode
  KLayer* = object of KNode
  KShape* = object of KNode

  KCircle* = object of KShape
  KText* = object of KShape

  Number* = int or float


func newStage*(container: string): KStage
  {.importcpp: "new Stage({container: #})".}

func newLayer*(): KLayer
  {.importcpp: "new Layer()".}

func add*(s, n: Knode)
  {.importcpp: "#.add(#)".}


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
