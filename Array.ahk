/**
 * extends functionality for arrays on the base object
 * 
 * @Source    - https://autohotkey.com/board/topic/83081-ahk-l-customizing-object-and-array/
*/
class _Array
{
/**
 * Getter meta function
 * this allows to interact on given object directly using keywords
 *
 * @Parameters
 *    @Key     - [string][int] identifier to trigger different functions/routines
 *
 * @Return
 *    string
*/
    __Get(key) {
        if (key == "print") {
            ; displays values of an array in a message box
            out := this.createPrintResult(this)
            MsgBox, % out
        }
        return out
    }

/**
 * joins parameters into string seperated by user defined seperator
 *
 * @Parameters
 *    @sep      - [string] expects any string input
 *    @params   - [string][array][object] accepts arrays, objects or several strings
 *
 * @Return
 *    string
*/
    join(sep=","){
        for i,value in this {
            str .= sep . value
        }
        return SubStr(str, StrLen(sep)+1)
    }

/**
 * sorts a 2D array 
 *
 * @Parameters
 *    @order    - [string] expects following inputs "A", "D", "R"
 *
 * @Source    - https://sites.google.com/site/ahkref/custom-functions/sortarray
 *
 * @Return
 *    array
*/
    sort(order:="A"){
        ;Order A: Ascending, D: Descending, R: Reverse
        MaxIndex := ObjMaxIndex(this)
        if (order == "R"){
            count := 0
            Loop, % MaxIndex {
                ObjInsert(this, ObjRemove(this, MaxIndex - count++))
            }
            Return
        }
        Partitions := "|" ObjMinIndex(this) "," MaxIndex
        Loop {
            comma := InStr(this_partition := SubStr(Partitions, InStr(Partitions, "|", False, 0)+1), ",")
            spos := pivot := SubStr(this_partition, 1, comma-1) , epos := SubStr(this_partition, comma+1)    
            if (order == "A"){
                Loop, % epos - spos {
                    if (this[pivot] > this[A_Index+spos])
                        ObjInsert(this, pivot++, ObjRemove(this, A_Index+spos))    
                }
            } else {
                Loop, % epos - spos {
                    if (this[pivot] < this[A_Index+spos]) {
                        ObjInsert(this, pivot++, ObjRemove(this, A_Index+spos))
                    }
                }
            }
            Partitions := SubStr(Partitions, 1, InStr(Partitions, "|", False, 0)-1)
            if (pivot - spos) > 1 { ;if more than one element
                Partitions .= "|" spos "," pivot-1        ;the left partition
            }
            if (epos - pivot) > 1 { ;if more than one element
                Partitions .= "|" pivot+1 "," epos        ;the right partition
            }
        } Until !Partitions
    }

/**
 * creates the output for displaying the array. Recursively goes over the array 
 * and indents if array has depth
 *
 * @Parameters
 *    @array    - [array] array to be sorted, the recursive call will take care of nested arrays
 *    @level    - [int] for nested arrays
 *
 * @Source    - http://autohotkey.com/board/topic/70490-print-array/?p=492815
 *
 * @Return
 *    string
*/
    createPrintResult(array, level:=0){
        Loop, % 4 + (level*4) {
            Tabs .= A_Space
        
            out := "Array ("
        
            for key, value in array {
                if (IsObject(value)) {
                    level++
                        value := this.createPrintResult(value, level)
                        level--
                }
                
                out .= "`r`n" . Tabs . "[" . key . "] => " . value
            }
        out .= "`r`n" . SubStr(Tabs, 5) . ")"
        }
        return out
    }


/**
 * removed duplicates by creating an object using the values as keys
 *
 * @Source    - https://stackoverflow.com/questions/46432447/how-do-i-remove-duplicates-from-an-autohotkey-array
 * 
 * @Return
 *    no return value
*/
    rmDupe(){ ; Hash O(n) - Linear
        hash := {}

        for e, v in this {
            if (!hash[v]){
                hash[(v)] := 1
            } else {
                this.removeAt(e)
            }
        }
    }
}

/**
 * redefines Array().
 *
 * @Parameters
 *    @prm    - [string]  keyword to trigger the 
 *
 * @Return
 *    array
*/
Array(prm*) {
    ; Since prm is already an array of the parameters, just give it a
    ; new base object and return it. Using this method, _Array.__New()
    ; is not called and any instance variables are not initialized.
    prm.base := _Array
    return prm
}


