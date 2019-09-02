/**
 * extends functionality for arrays on the base object
 * 
 * @Source    - https://autohotkey.com/board/topic/83081-ahk-l-customizing-object-and-array/
 * @Source    - https://gist.github.com/errorseven/559681eb1fa122c14a75455d272abbea (extended Objects)
*/
Class _Object {

/**
 * Deterimines if an Object is linear (associative Arrays are treated as objects, not arrays)
*/
    IsLinear[] {
        Get {
            While (A_Index != this.MaxIndex()) 
                If !(this.hasKey(A_Index)) 
                    Return False
            Return True
        }
    }

/**
 * creates a msgbox for the created print result
 *
 * @Usage
 *     obj := [1, 2, 3, {a: 1, b: 2}]
 *     obj.print ; --> [1, 2, 3, {a:1, b:2}]
 *     arr := [1, 2, "ape"]
 *     arr.print()
 *     
        */
*/
    Print[] {
        
        Get {
            msgbox(this.createPrintResult(this, level:=0))
        }
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
    createPrintResult(array, level:=0) {
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

    Reverse[] {
        /*
        Returns a reverse ordered Array/Object
        
        Usage: 
            obj := [1, 2, 3].reverse
            obj.print ; --> [3, 2, 1]
        */
        
        Get {
            x := []
            loop % this.count
                x.push(this.pop())
            return x
        }
    }
    
    
    IsCircle(Objs=0) {
        /*
        Function by GeekDude
        Returns True if Object contains a reference to itself
        Intended for internal use, but have at it if you find a use
        */
        
        if !Objs
            Objs := {}
        For Key, Val in this
            if (IsObject(Val)&&(Objs[&Val]||Val.IsCircle((Objs,Objs[&Val]:=1))))
                return 1
        return 0
    }
    
    Contains(x, y:="") {
        /*
        Returns a Str index (True) or False  
        
        Usage: 
            obj := [1, 3, 2, [5, 4]] 
            obj.contains(4) ; --> [4][2]
        */
        
        If this.IsCircle()
            return 0
    
        For k, v in this {         

            if (v == x)
                return y "[" k "]"

            if (IsObject(v) && v != this) 
                z := this[k].contains(x, y "[" k "]" )
        
            if (z)
                return z
        }

        return 0
    }   

    Sort(options:="", delim:="`n") {
        /*    
        Use Sort Command documentation to interpret options. The deliminator is 
        seperate for ease of implementation.
        
        Usage: 
            obj := [c, d, b, a].sort()
            obj.print ; --> [a, b, c, d]
        */
        
        For e, v in this
            r .= v delim
        Sort, r, % options "D" delim
        return StrSplit(trim(r, delim), delim)
    }
}

class _Array Extends _Object {
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
        if (key == "rmDupe") || (key == "rmDuplicate") {
            ; removes duplicate values from array
            this.removeDuplicate()
        }
        return out
    }

/**
 * Used to merge two or more arrays. This method does not change the existing arrays, but instead returns a new array.
 *
 * @Parameters
 *    @arrays    - [array] 1 or more arrays to merge
 *
 * @Return
 *    array
*/
    concat(arrays*) {
        
        results := []

        ; First add the values from the instance being called on
        for index, value in this {
            results.push(value)
        }

        ; Second, add arrays given in parameter
        for index, array in arrays {
            for index, element in array {
                results.push(element)
            }
        }

        return results
    }


/**
 * joins parameters into string seperated by user defined seperator
 *
 * @Parameters
 *    @delimiter      - [string] expects any string input
 *
 * @Return
 *    string
*/
    join(delimiter=",") {
        for i,value in this {
            result := value (i < this.Length() ? delimiter : "")
        }
        return result
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
    sort(order:="A") {
        ;Order A: Ascending, D: Descending, R: Reverse
        max_index := ObjMaxIndex(this)
        if (order == "R") {
            count := 0
            Loop, % max_index {
                ObjInsert(this, ObjRemove(this, max_index - count++))
            }
            Return
        }
        partitions := "|" ObjMinIndex(this) "," max_index
        Loop {
            comma := InStr(this_partition := SubStr(partitions, InStr(partitions, "|", False, 0)+1), ",")
            spos := pivot := SubStr(this_partition, 1, comma-1) , epos := SubStr(this_partition, comma+1)    
            if (order == "A") {
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
            partitions := SubStr(partitions, 1, InStr(partitions, "|", False, 0)-1)
            if (pivot - spos) > 1 {                     ;if more than one element
                partitions .= "|" spos "," pivot-1      ;the left partition
            }
            if (epos - pivot) > 1 {                     ;if more than one element
                partitions .= "|" pivot+1 "," epos      ;the right partition
            }
        } Until !partitions
        return this
    }

/**
 * changes the contents of an array by removing or replacing existing elements and/or adding new elements in place
 *
 * @Parameters
 *    @start            - [] index to insert at
 *    @delete_count      - [] replacement count
 *    @args             - [string][int]element to be replaced or elements to be added
 *
 * @Return
 *    array
*/
    splice(start, delete_count:=-1, args*) {

        array_length := this.Length()
        exiting := []

        ; Determine starting index
        if (start > array_length) {
            start := array_length
        }

        if (start < 0) {
            start := array_length + start
        }

        ; delete_count unspecified or out of bounds, set count to start through end
        if ((delete_count < 0) || (array_length <= (start + delete_count))) {
            delete_count := array_length - start + 1
        }

        ; Remove elements
        Loop, % delete_count {
            exiting.push(this[start])
            this.removeAt(start)
        }

        ; Inject elements
        Loop, % args.Length() {
            current_index := start + (A_Index - 1)

            this.insertAt(current_index, args[1])
            args.removeAt(1)
        }

        return exiting
    }

/**
 * removed duplicates by creating an object using the values as keys
 *
 * @Source    - https://stackoverflow.com/questions/46432447/how-do-i-remove-duplicates-from-an-autohotkey-array
 * 
 * @Return
 *    no return value
*/
    removeDuplicate() { ; Hash O(n) - Linear
        hash := {}

        for index, value in this {
            if (!hash[value]) {
                hash[(value)] := 1
            } else {
                this.removeAt(index)
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

Object(prm*) {
    /*
        Create a new object derived from _Object.
    */
    obj := new _Object
    ; For each pair of parameters, store a key-value pair.
    Loop % prm.MaxIndex()//2 
        obj[prm[A_Index*2-1]] := prm[A_Index*2]
    ; Return the new object.
    return obj
}

StrSplit(x, dlm:="", opt:="") {
    /* 
    Use help documentation definition to determine options. This override 
    is here to properly intialize an Extended Object using our class.
    
    Usage:
        Obj := StrSplit("abc")
        Obj.print ; --> ["a", "b", "c"]
    */
    
    r := []
    StringSplit, o, x, %dlm%, %opt%
    
    loop, %o0% 
        r.push(o%A_index%)
 
    return r
}