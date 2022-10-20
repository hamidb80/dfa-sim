type 
    Position* = tuple[x, y: float]
    Line* = Slice[Position]

func `+`*(p1, p2: Position): Position =
    (p1.x+p2.x, p1.y+p2.y)

func `/`*(p: Position, d: int): Position =
    (p.x / d.toFloat, p.y / d.toFloat)

func `*`*(l: Line, factor: float): Position = 
    let 
        dx = l.b.x - l.a.x
        dy = l.b.y - l.a.y

    (l.a.x + dx * factor, l.a.y + dy * factor)