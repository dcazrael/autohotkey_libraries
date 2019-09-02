/**
 * Counts seconds; usually run for displaying Unit test runtimes or testing speed of functions
*/
class Counter {
    __New(interval:=1000) {
        this.interval := interval
        this.count := 0
        ; Tick() has an implicit parameter "this" which is a reference to
        ; the object, so we need to create a function which encapsulates
        ; "this" and the method to call:
        this.timer := ObjBindMethod(this, "Tick")
    }
    Start() {
        ; Known limitation: SetTimer requires a plain variable reference.
        timer := this.timer
        SetTimer % timer, % this.interval
        ToolTip % "Run started"
    }
    Stop() {
        ; To turn off the timer, we must pass the same object as before:
        timer := this.timer
        SetTimer % timer, Off
        ToolTip
        MsgBox, % "Run finished after " this.count " ms."
    }
    Tick() {
        ToolTip % "Runtime: " ++this.count
    }
}