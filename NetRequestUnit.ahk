#SingleInstance, force

#Include vendor\Yunit\Yunit.ahk
#Include vendor\Yunit\Window.ahk
#Include vendor\Yunit\StdOut.ahk
#Include vendor\Yunit\JUnit.ahk
#Include vendor\Yunit\OutputDebug.ahk
#Include NetRequest.ahk

Yunit.Use(YunitStdOut, YunitWindow, YunitJUnit, YunitOutputDebug).Test(NetRequestTests)

class NetRequestTests {
    begin() {
        this.nr := new NetRequest()
    }

    Test_A_apiRequest() {
        this.nr.apiSetup("https://www.careercross.com/api/", "job")
        Yunit.assert(this.nr.apiRequest(931459).result.employer_ID == 251135, "This is not the correct employer for this Job.")
    }
    
    Test_A_apiRequestWrongURLFail() {
        this.nr.apiSetup("https://www.careercross.de/api/", "job")
        Yunit.assert(InStr(this.nr.apiRequest(931459), "0x80072EE7") == 1, "This should result in an incorrect URL")
    }
    
    Test_A_apiRequestJobNoResult() {
        this.nr.apiSetup("https://www.careercross.com/api/", "job")
        Yunit.assert(this.nr.apiRequest(90031459).result == 0, "Try a different ID")
    }
    
    Test_A_apiRequestCompanyNoResult() {
        this.nr.apiSetup("https://www.careercross.com/api/", "company")
        Yunit.assert(InStr(this.nr.apiRequest(90031459).result, "No result found") == 1, "This should result in an not found. Try a different ID")
    }

    end() {
    }
}