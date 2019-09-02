/**
 * retrieves info from a specific explorer window (if window handle not specified, 
 * the currently active window will be used).  Requires AHK_L or similar.  
 * Works with the desktop.  Does not currently work with save dialogs and such.
 *
 * @Source
 *     https://autohotkey.com/board/topic/60985-get-paths-of-selected-items-in-an-explorer-window/
 *
*/
class ExplorerInfo {
    __New(){

    }

/**
 * Retrieves paths for file/s from the target Window
 *
 * @Parameters
 *    @hwnd         - [object] Window ID
 *    @selection    - [boolean] used to retrieve info from selected files only
 *
 * @Return
 *    string
*/
    get(hwnd:="", selection:=false) {
        if !(window := this.getWindow(hwnd)) {
            return ErrorLevel := "ERROR"
        }
        if (window == "desktop") {
            ControlGet, hwWindow, HWND,, SysListView321, ahk_class Progman
            if (!hwWindow) { ; #D mode
                ControlGet, hwWindow, HWND,, SysListView321, A
            }
            ControlGet, files, List, % ( selection ? "Selected":"") "Col1",,ahk_id %hwWindow%
            base := SubStr(A_Desktop, 0, 1) == "\" ? SubStr(A_Desktop, 1, -1) : A_Desktop
            Loop, Parse, files, `n, `r
            {
                path := base . "\" . A_LoopField
                IfExist %path% ; ignore special icons like Computer (at least for now)
                    ret .= path "`n"
            }
        } else {
            if selection {
                collection := window.document.SelectedItems
            } else {
                collection := window.document.Folder.Items
            }
            for item in collection {
                ret .= item.path "`n"
            }
        }
        return Trim(ret,"`n")
    }


/**
 *Retrieves paths for all files from the target Window
 *
 * @Parameters
 *    @hwnd         - [object] Window ID
 *
 * @Return
 *    string
*/
    getAll(hwnd:="") {
        return this.get(hwnd)
    }

/**
 * Retrieves paths for target Window
 *
 * @Parameters
 *    @hwnd         - [object] Window ID
 *
 * @Return
 *    string
*/
    getPath(hwnd:="") {
        if !(window := this.getWindow(hwnd)) {
            return ErrorLevel := "ERROR"
        }
        if (window == "desktop") {
            return A_Desktop
        }
        path := window.LocationURL
        path := RegExReplace(path, "ftp://.*@","ftp://")
        path := StrReplace(path, "file:///")
        path := StrReplace(path, "/" , "\")
        
        ; thanks to polyethene
        Loop {
            if (RegExMatch(path, "i)(?<=%)[\da-f]{1,2}", hex)) {
                StringReplace, path, path, `%%hex%, % Chr("0x" . hex), All
            } else {
                break
            }
        }
        return path
    }

/**
 * Retrieves paths for selected file/s from the target Window
 *
 * @Parameters
 *    @hwnd         - [object] Window ID
 *
 * @Return
 *    string
*/
    getSelected(hwnd:="") {
        return this.get(hwnd,true)
    }


/**
 * Retrieves information of the target window
 *
 * @Parameters
 *    @hwnd         - [object] Window ID
 *
 * @Return
 *    object or string
*/
    getWindow(hwnd:="") {
        ; thanks to jethrow for some pointers here
        WinGet, process, processName, % "ahk_id" hwnd := hwnd? hwnd:WinExist("A")
        WinGetClass class, ahk_id %hwnd%
        
        if (process != "explorer.exe") {
            return
        }
        if (class ~= "(Cabinet|Explore)WClass") {
            for window in ComObjCreate("Shell.Application").Windows {
                if (window.hwnd == hwnd) {
                    return window
                }
            }
        }
        else if (class ~= "Progman|WorkerW") 
            return "desktop" ; desktop found
    }


}