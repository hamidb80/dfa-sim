import std/strformat
include karax/prelude


type
  BootstrapColorClass* = enum
    bccPrimary = "primary"
    bccSecondary = "secondary"
    bccSuccess = "success"
    bccInfo = "info"
    bccWarning = "warning"
    bccDanger = "danger"
    bccLight = "light"
    bccDark = "dark"


const
  pink* = "#f8969b"
  green* = "#78c2ad"
  lemon* = "#e4ed0f"


func navbar*: VNode =
  buildHtml nav(class = "navbar navbar-expand-lg navbar-light bg-light px-3 d-flex justify-content-between align-items-center")

proc navToggle*(t: string, color: BootstrapColorClass, active: bool,
    action: proc(s: bool)): VNode =
  let style =
    if active: ""
    else: "-outline"

  buildHtml button(class = fmt"btn mx-1 btn{style}-{color}"):
    proc onclick = action(not active)
    text t

proc navbtn*(t: string, color: BootstrapColorClass, action: proc): VNode =
  buildHtml button(class = fmt"btn mx-1 btn-outline-{color}"):
    proc onclick = action()
    text t

func styledText*(t: string, c: BootstrapColorClass): VNode =
  buildHtml span(class = "text-" & $c):
    italic:
      text t

func spacex*(i: int): VNode =
  buildHtml span(class = "mx-" & $i)

func sec*(title: string): VNode =
  buildHtml tdiv(class = "mt-4"):
    h3(class = "text-center"):
      text title

func status*: VNode =
  buildHtml tdiv(class = "navbar-expand-lg navbar-dark bg-black text-white px-2 py-1")

func extra*: VNode =
  buildHtml footer(class = "px-2 navbar navbar-expand-lg navbar-light bg-light d-flex justify-content-between align-items-center")

func output*: VNode =
  buildHtml footer(class = "px-2 navbar navbar-expand-lg navbar-light bg-light d-flex justify-content-between align-items-center")

func konva*(id: string): VNode =
  # `konva` creates elements, and `karax` is so mad about it
  buildHtml verbatim fmt"<div id='{id}'></div>"
