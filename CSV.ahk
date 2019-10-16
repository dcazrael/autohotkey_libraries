/**
 * reads csv and loads data in arrays
 * can be used to only read columns or rows
 *
 * @Parameters
 *    @csv_data             - [array] array to hold the complete csv data
 *    @error                - [bool] if data couldn't be loaded error turns true
 *    @passed_csv_data      - [string][array] can be string or array
 *                            file_path is a considered a string
 *    @delimiter            - [string] delimiter used for creating the 
 *                            csv data (optional)
 *
 * @Source    - https://autohotkey.com/board/topic/51681-csv-library-lib/
 * 
 * @Remarks
 * strings have to use a different variable declaration
 * Instead of the usual "var := " we have to use "var = "
 * "var := " expects expressions, thus strings have to be wrapped with
 * double quotes. 
 * Double-quotes are escaped using double quotes """"
 * "var = " expects a string 
 * because we have a hard time escaping commas, we will use a literal declaration
 * var = a,b,c,"d,e","f"","",g",,i
 * would return
 * "a", "b", "c", "d,e", "f`",`",g", , "i"
*/
class CSV
{
    csv_data := []

    __New(passed_csv_data, delimiter:=","){
        if passed_csv_data is not Number
        {
            this.selectMethodByType(passed_csv_data, delimiter)
        }
    }

/**
 * automatically uses proper method to load passed_csv_data
 * checks if the data is an array, a csv string or a file path
 * file paths are checked for file existence
 *
 * @Parameters
 *    @data    - [string][array] expects either a string or 3D array
 *    @delimiter    - [string] delimiter used for creating the 
 *                             csv data (optional)
 *
 * @Return
 *    no return value
*/
    selectMethodByType(data, delimiter:=","){
        if (IsObject(data)){
            this.loadFromArray(data, delimiter)
            return
        } else if (FileExist(data)){
            this.loadFromFile(data, delimiter)
            return
        } else if (InStr(data, delimiter)){
            this.load(data, delimiter)
            return
        }

        MsgBox, No valid CSV data or array was passed. Aborting further actions.
        this.error := true
        return
    }


/**
 * loads csv data into memory for future processing
 *
 * @Parameters
 *    @file_path    - [string] expects a valid file path
 *    @delimiter    - [string] delimiter used for creating the 
 *                             csv data (optional)
 *
 * @Return
 *    Return
*/
    loadFromFile(file_path, delimiter:=","){
        if (!FileExist(file_path)) {
            MsgBox, No file found using this path.
            return
        }

        FileRead, read_csv_data, % file_path
        this.load(read_csv_data, delimiter)

    }

/**
 * creates csv data from 3D array, checking for data type and 
 * encapsulating it if necessary.
 *
 * @Parameters
 *    @csv_array    - [array] expects proper 3D array with same
 *                           index count for 3rd dimension
 *    @delimiter    - [string] delimiter used for creating the 
 *                             csv data (optional)
 *
 * @Return
 *    Return
*/
    loadFromArray(csv_array, delimiter:=","){
        for row, column in csv_array {
            for index, value in column {
                if value is not Number
                {
                    value := StrReplace(value, """", """""")
                    value := """" . value . """"
                }
                column_data .= value . delimiter
            }
            column_data := RTrim(column_data, delimiter)
            if (row != csv_array.Length()) {
                column_data .= "`r`n"
            }
        }
        this.load(column_data, delimiter)
    }



/**
 * loads csv into csv_data array for further use
 * skips empty lines
 *
 * @Parameters
 *    @raw_data     - [string] raw csv data
 *    @delimiter    -
 *
 * @Return
 *    Return
*/
    load(raw_data, delimiter:="`,"){
        raw_data := StrReplace(raw_data, "`r`n`r`n", "`r`n")

        ; fix for last newline and not importing all columns
        new_line_check := SubStr(raw_data, 0, 1)
        if (new_line_check == "`n") {
            raw_data := SubStr(raw_data, 1, -1)
        }

        Loop, Parse, raw_data, `n, `r
        {
            ; added to skip emtpy lines
            If (A_LoopField == "") {
                Continue
            }
            this.csv_data.push(this.returnDsvArray(A_LoopField, delimiter))
            Row := A_Index
        }
        this.csv_total_rows := Row
        this.csv_total_cols := this.csv_data[Row].Length()
    }


/**
 * reads data from specified column in column_data
 * headers can be skipped if not needed
 *
 * @Parameters
 *    @col_number    - [int] expects number of column for reading values
 *    @skip_headers  - [int] number of rows to skip (optional)
 *    @array         - [boolean] true for return as array, false for string
 *
 * @Return
 *    no return value
*/
    readCol(col_number, skip_headers:=0, array=false){
        col_data := (array ? [] : "")
        Loop, % this.csv_total_rows {
            if (A_Index <= skip_headers) {
                continue
            }
            if (array) {
                col_data.push(this.csv_data[A_Index][col_number])
            } else {
                col_data .= this.csv_data[A_Index][col_number]
                if (A_Index != this.csv_total_rows) {
                    col_data .= "`,"
                }
            }
        }
        return col_data
    }

/**
 * reads data from specified row in column_data
 *
 * @Parameters
 *    @row_number    - [int] expects number of row for reading values
 *    @array         - [boolean] true for return as array, false for string
 *
 * @Return
 *    no return value
*/
    readRow(row_number, array:=false) {
        row_data := array ? [] : ""
        Loop, this.csv_total_cols {
            if (array) {
                row_data.push(this.csv_data[row_number][A_Index])
            } else {
                row_data .= this.csv_data[row_number][A_Index]
                if (A_Index != this.csv_total_cols) {
                    row_data .= "`,"
                }
            }
        }
        return row_data
    }


/**
 * returns delimiter seperated value array for a line
 *
 * @Parameters
 *    @current_DSV_Line      - [string] expects string
 *    @delimiter             - [string] character by which values are seperated (optional)
 *    @encapsulator          - [string] character in which values are wrapped (optional)
 *
 * @Return
 *    array
*/
    returnDsvArray(current_DSV_Line, delimiter:=",", encapsulator:=""""){
        if ((StrLen(delimiter) != 1) || (StrLen(encapsulator) != 1)) {
            ; return -1 indicating an error
            return -1
        }
        ; needed for escaping the reg_ex_needle properly
        SetFormat,integer,H

        ; used as hex notation in the reg_ex_needle
        d := SubStr(ASC(delimiter)+0,2)

        ; used as hex notation in the reg_ex_needle
        e := SubStr(ASC(encapsulator)+0,2)

        ; no need for Hex values anymore
        SetFormat,integer,D

        ; Start of search at char p0 in DSV line
        p0 := 1

        return_array := []

        ; Add delimiter, otherwise last field won't get recognized
        current_DSV_Line .= delimiter

        Loop {
            reg_ex_needle := "\" d "(?=(?:[^\" e "]*\" e "[^\" e "]*\" e ")*(?![^\" e "]*\" e "))"

            p1 := RegExMatch(current_DSV_Line,reg_ex_needle,tmp,p0)
            ; p1 contains now the position of our current delimitor in a 1-based index

            field := SubStr(current_DSV_Line,p0,p1-p0)


            ; This is the exception handling for removing any doubled encapsulators and
            ; leading/trailing encapsulator chars
            if (SubStr(field,1,1) == encapsulator) {
                field := RegExReplace(field,"^\" e "|\" e "$")
                field := StrReplace(field, encapsulator encapsulator, encapsulator)
            }

            ; p1 is 0 when no more delimitor chars have been found
            if (p1 == 0) {
                ; need to exit loop otherwise we loop endlessly
                break
            } else {
                return_array.push(field)

                ; set the start of our RegEx Search to last result
                p0 := p1 + 1
            }
        }
        return return_array
    }
}