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


func navbar*: VNode =
  buildHtml nav(class = "navbar navbar-expand-lg navbar-light bg-light px-3 d-flex justify-content-between align-items-center")

proc navbtn*(t: string, color: BootstrapColorClass, action: proc): VNode =
  buildHtml button(class = fmt"btn mx-1 btn-outline-{color}"):
    proc onclick = action()
    text t
