/**
 * This class contains various Control interaction methods
 * Parameters described here are available for most methods
 * thus only explained once here
 *
 * @Parameters
 *    @out             - [string] The name of the variable in which to store the result of SubCommand.
 *    @Cmd/Value       - [string] These are dependent upon each other and their usage is described at 
 *                                https://www.autohotkey.com/docs/commands/ControlGet.htm#SubCommands.
 *    @Control         - [string] Can be either ClassNN (the classname and instance number of the control) 
 *                                or the control's text, both of which can be determined via Window Spy. 
 *                                When using text, the matching behavior is determined by SetTitleMatchMode. 
 *                                If this parameter is blank, the target window's topmost control will be used.
 *
 *                                To operate upon a control's HWND (window handle), leave the Control parameter blank 
 *                                and specify ahk_id %ControlHwnd% for the WinTitle parameter (this also works on 
 *                                hidden controls even when DetectHiddenWindows is Off). The HWND of a control is 
 *                                typically retrieved via ControlGet Hwnd, MouseGetPos, or DllCall.
 *    @WinTitle        - [string] A window title or other criteria identifying the target window.
 *    @WinText         - [string] If present, this parameter must be a substring from a single text element of the target window 
 *                                (as revealed by the included Window Spy utility). Hidden text elements are detected 
 *                                if DetectHiddenText is ON.
 *    @ExcludeTitle    - [string] Windows whose titles include this value will not be considered.
 *    @ExcludeText     - [string] Windows whose text include this value will not be considered.
 *
*/
Class Control {

    static init := ("".base.base := Control)
    static __Set := Func("Control_Set")

/**
 * Retrieves various types of information about a control.
 *
 * @Parameters
 *    @Cmd
 *    @Value
 *    @Control
 *    @WinTitle
 *    @WinText
 *    @ExcludeTitle
 *    @ExcludeText
 *
 * @Return
 *    string
*/
    get(Cmd, Value:="", Control:="", WinTitle:="", WinText:="", ExcludeTitle:="", ExcludeText:="") {
        ControlGet, out, %Cmd%, %Value%, %Control%, %WinTitle%, %WinText%, %ExcludeTitle%, %ExcludeText%
        return out
    }

/**
 * Retrieves which control of the target window has input focus, if any.
 *
 * @Parameters
 *    @WinTitle
 *    @WinText
 *    @ExcludeTitle
 *    @ExcludeText
 *
 * @Return
 *    string
*/
    getFocus(WinTitle:="", WinText:="", ExcludeTitle:="", ExcludeText:="") {
        ControlGetFocus, out, %WinTitle%, %WinText%, %ExcludeTitle%, %ExcludeText%
        return out
    }

/**
 * Retrieves text from a control.
 *
 * @Parameters
 *    @Control
 *    @WinTitle
 *    @WinText
 *    @ExcludeTitle
 *    @ExcludeText
 *
 * @Return
 *    string
*/
    getText(Control:="", WinTitle:="", WinText:="", ExcludeTitle:="", ExcludeText:="") {
        ControlGetText, out, %Control%, %WinTitle%, %WinText%, %ExcludeTitle%, %ExcludeText%
        return out
    }
}

Control_Set(byref this, key, value){
    StringReplace, this, this, %key%, %value%, all
}