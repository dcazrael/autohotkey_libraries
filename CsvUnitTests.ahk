#SingleInstance, force

#Include Yunit\Yunit.ahk
#Include Yunit\Window.ahk
#Include Yunit\StdOut.ahk
#Include Yunit\JUnit.ahk
#Include Yunit\OutputDebug.ahk
#Include CSV.ahk


Yunit.Use(YunitStdOut, YunitWindow, YunitJUnit, YunitOutputDebug).Test(CsvUnitTests)

class CsvUnitTests
{
    class TestReadColRow
    {

/**
 * reads column from loaded csv data
 *
 * @Expected values
 *     "c","i","d,e"
 * 
 * @Expected result 
 *     1Row 4Col, 2Row 3Col; mismatched columns, reject data/clear array
*/
        readColumns(){
            test_data = a,b,c,"d,e"`n"f"","",g",,i,a`nb,c,"d,e",f

            read_csv := new CSV(test_data)
            read_csv.csvReadCol(3)

        }

/**
 * rejects data, if columns don't match
 *
 * @Expected values
 *     "c","d,e","f"
 * 
 * @Expected result 
 *     1Row 4Col, 2Row 3Col; mismatched columns, reject data/clear array
*/
        readRows(){
            test_data = a,b,c,"d,e"`n"f"","",g",,i,a`nb,c,"d,e",f

            read_csv := new CSV(test_data)
            read_csv.csvReadRow(3)
        }

    }

    class TestCsvLoad ; using strings
    {
/**
 * rejects data, if columns don't match
 *
 * @Expected values
 *     "a","b","c","d,e"
 *     "f"","",g","","i"
 * 
 * @Expected result 
 *     1Row 4Col, 2Row 3Col; mismatched columns, reject data/clear array
*/
        rejectData(){
            test_data = a,b,c,"d,e"`n"f"","",g",,i

            string_csv := new CSV(test_data)
            Yunit.assert(string_csv.csv_data.length() == 0, "Array wasn't cleared")
        }

/**
 * accepts data, if columns match
 *
 * @Expected values
 *     "a","b","c","d,e"
 *     "f"","",g","","i",1
 * 
 * @Expected result 
 *     1Row 4Col, 2Row 4Col; matched columns, accept data
*/
        acceptData(){
            test_data = a,b,c,"d,e"`n"f"","",g",,i,1

            string_csv := new CSV(test_data)
            Yunit.assert(string_csv.csv_data.length() != 0, "Data not accepted")
        }

/**
 * compares input array to expected results
 *
 * @Expected values
 *     "a","b","c","d,e","f"","",g","","i",1
 * 
 * @Expected result 
 *     1Row 8Col; matched columns, accept data
*/
        sameArray(){
            test_data = a,b,c,"d,e","f"","",g",,i,1
            expected_values_array := [["a","b","c","d,e","f"","",g","","i",1]]
            
            string_csv := new CSV(test_data)
            Yunit.assert(string_csv.csv_total_rows == 1, "Rows don't match")
            Yunit.assert(string_csv.csv_total_cols == 8, "Columns don't match")
            Yunit.CompareArray(expected_values_array, string_csv.csv_data, "Created Array is not as expected")
        }

/**
 * checks if mismatched colums are properly found
 *
 * @Expected values
 *     "a","b","c","d,e"
 *     "f"","",g","","i"
 * 
 * @Expected result 
 *     1Row 4Col, 2Row 3Col; mismatched columns, reject data
*/
        mismatched_columns(){
            test_data = a,b,c,"d,e"`n"f"","",g",,i

            string_csv := new CSV(test_data)
            Yunit.assert(string_csv.mismatched_columns == True, "Columns matched")
        }

    }

    class TestLoadFromArray
    {
/**
 * rejects data, if columns don't match
 *
 * @Expected values
 *     "a","b","c","d,e"
 *     "f"","",g","","i"
 * 
 * @Expected result 
 *     1Row 4Col, 2Row 3Col; mismatched columns, reject data/clear array
*/
        rejectData(){
            test_data := [["a","b","c","d,e"],["f"","",g","","i"]]

            array_csv := new CSV(test_data)
            Yunit.assert(array_csv.csv_data.length() == 0, "Array wasn't cleared")
        }

/**
 * accepts data, if columns match
 *
 * @Expected values
 *     "a","b","c","d,e"
 *     "f"","",g","","i",1
 * 
 * @Expected result 
 *     1Row 4Col, 2Row 4Col; matched columns, accept data
*/
        acceptData(){
            test_data := [["a","b","c","d,e"],["f"","",g","","i",1]]

            array_csv := new CSV(test_data)
            Yunit.assert(array_csv.csv_data.length() != 0, "Data not accepted")
        }

/**
 * compares input array to expected results
 *
 * @Expected values
 *     "a","b","c","d,e","f"","",g","","i",1
 * 
 * @Expected result 
 *     1Row 8Col; matched columns, accept data
*/
        sameArray(){
            test_data := [["a","b","c","d,e","f"","",g","","i", 1]]
            expected_values_array := [["a","b","c","d,e","f"","",g","","i", 1]]
            
            array_csv := new CSV(test_data)
            Yunit.assert(array_csv.csv_total_rows == 1, "Rows don't match")
            Yunit.assert(array_csv.csv_total_cols == 8, "Columns don't match")
            Yunit.CompareArray(expected_values_array, array_csv.csv_data, "Created Array is not as expected")
        }

/**
 * checks if mismatched colums are properly found
 *
 * @Expected values
 *     "a","b","c","d,e"
 *     "f"","",g","","i"
 * 
 * @Expected result 
 *     1Row 4Col, 2Row 3Col; mismatched columns, reject data
*/
        mismatched_columns(){
            test_data := [["a","b","c","d,e"],["f"","",g","","i"]]

            array_csv := new CSV(test_data)
            Yunit.assert(array_csv.mismatched_columns == True, "Columns matched")
        }

    }

class TestLoadFromFile
    {
/**
 * rejects data, if columns don't match
 * 
 * @Test data in file
 *     "a","b","c","d,e"
 *     "f"","",g","","i"
 *     
 * @Expected values
 *     "a","b","c","d,e"
 *     "f"","",g","","i"
 * 
 * @Expected result 
 *     1Row 4Col, 2Row 3Col; mismatched columns, reject data/clear array
*/
        rejectData(){
            file_csv := new CSV(A_ScriptDir . "\b.csv")
            Yunit.assert(file_csv.csv_data.length() == 0, "Array wasn't cleared")
        }

/**
 * accepts data, if columns match
 *
 * @Test data in file
 *     "a","b","c","d,e"
 *     "f"","",g","","i",1
 *
 * @Expected values
 *     "a","b","c","d,e"
 *     "f"","",g","","i",1
 * 
 * @Expected result 
 *     1Row 4Col, 2Row 4Col; matched columns, accept data
*/
        acceptData(){
            file_csv := new CSV(A_ScriptDir . "\a.csv")
            Yunit.assert(file_csv.csv_data.length() != 0, "Data not accepted")
        }

/**
 * compares input array to expected results
 *
 * @Test data in file
 *     "a","b","c","d,e"
 *     "f"","",g","","i",1
 *
 * @Expected values
 *     "a","b","c","d,e"
 *     "f"","",g","","i",1
 * 
 * @Expected result 
 *     1Row 8Col; matched columns, accept data
*/
        sameArray(){
            expected_values_array := [["a","b","c","d,e"],["f"","",g","","i"]]
            
            file_csv := new CSV(A_ScriptDir . "\c.csv")
            Yunit.assert(file_csv.csv_total_rows == 2, "Rows don't match")
            Yunit.assert(file_csv.csv_total_cols == 4, "Columns don't match")
            
            Yunit.CompareArray(expected_values_array, file_csv.csv_data, "Created Array is not as expected")
        }

/**
 * checks if mismatched colums are properly found
 *
 * @Test data in file
 *     "a","b","c","d,e"
 *     "f"","",g","","i"
 *
 * @Expected values
 *     "a","b","c","d,e"
 *     "f"","",g","","i"
 * 
 * @Expected result 
 *     1Row 4Col, 2Row 3Col; mismatched columns, reject data
*/
        mismatched_columns(){
            file_csv := new CSV(A_ScriptDir . "\b.csv")
            Yunit.assert(file_csv.mismatched_columns == True, "Columns matched")
        }

    }
}