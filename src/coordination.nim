import std/[math]

type
    Vector* = tuple[x, y: float]
    Position* = Vector
    Line* = Slice[Vector]


func `+`*(p1, p2: Vector): Vector =
    (p1.x+p2.x, p1.y+p2.y)

func `+`*(p: Vector, c: float): Vector =
    (p.x+c, p.y+c)

func `-`*(p: Vector, c: float): Vector =
    p + -c

func `-`*(p: Vector): Vector =
    (-p.x, -p.y)

func `-`*(p1, p2: Vector): Vector =
    p1 + -p2

func `/`*(p: Vector, d: float): Vector =
    (p.x / d, p.y / d)

func `*`*(v: Vector, factor: float): Vector =
    (v.x * factor, v.y * factor)

func `*`*(l: Line, factor: float): Vector =
    let
        dx = l.b.x - l.a.x
        dy = l.b.y - l.a.y

    (l.a.x + dx * factor, l.a.y + dy * factor)

func distance*(p1, p2: Vector): float =
    sqrt((p1.x - p2.x)^2 + (p1.y - p2.y)^2)

func distance*(l: Line): float =
    distance l.a, l.b

func len*(l: Line): Vector =
    l.a - l.b

func unit*(l: Line): Vector =
    len(l) / distance(l)

