;Tscan license grabber
#Persistent
#noenv
OnExit, exitApplication
#Include, class_EasyIni.ahk
SetBatchLines, -1


Grab_TS_license(licType) { ;4 = Tmatch / 5 = Tmodeler / 8 = Tphoto Lite / 11 = Tscan
	SetWorkingDir, C:\terra\license

	Tclass := "TerraLicenseManager"
	IfWinExist, ahk_class %Tclass%
	{
		WinGet, TSID, PID, ahk_class %Tclass%
		WinMinimize, ahk_pid %TSID%
	}	
	IfWinNotExist, ahk_class %Tclass%
	{
		Run, license_manager.exe , , , TSID
		WinWait, ahk_pid %TSID%
		WinMinimize, ahk_pid %TSID%
	}
	WinMenuSelectItem, ahk_pid %TSID%, , 3&, 3&
	SendMessage, 0x185, 0, -1, ListBox1, ahk_pid %TSID%
	sleep, 20
	control, Choose, %licType%, ListBox1, ahk_pid %TSID%
	WinMenuSelectItem, ahk_pid %TSID%, , 2&, 1&
	WinWait, Get from server
	WinGetClass, getClass, Get from server
	;interact with "get from server" window
	control, ChooseString, 014, ComboBox1, ahk_class %getClass%
	ControlSetText, Edit4, 2, ahk_class %getClass%
	controlsend, Button1, {Enter}, ahk_class %getClass%
	sleep, 20
}

Return_TS_license(licType) { ;4 = Tmatch / 5 = Tmodeler / 8 = Tphoto Lite / 11 = Tscan
	SetWorkingDir, C:\terra\license

	Tclass := "TerraLicenseManager"
	IfWinExist, ahk_class %Tclass%
	{
		WinGet, TSID, PID, ahk_class %Tclass%
		WinMinimize, ahk_pid %TSID%
	}	
	IfWinNotExist, ahk_class %Tclass%
	{
		Run, license_manager.exe , , , TSID
		WinWait, ahk_pid %TSID%
		WinMinimize, ahk_pid %TSID%
	}
	WinMenuSelectItem, ahk_pid %TSID%, , 3&, 3&
	SendMessage, 0x185, 0, -1, ListBox1, ahk_pid %TSID%
	sleep, 20
	control, Choose, %licType%, ListBox1, ahk_pid %TSID%
	WinMenuSelectItem, ahk_pid %TSID%, , 2&, 3&
	sleep, 20
	return
}

Read_TS_license(licType) { ;4 = Tmatch / 5 = Tmodeler / 8 = Tphoto Lite / 11 = Tscan
	SetWorkingDir, C:\terra\license
	licObj := []
	
	if (licType = 4)
		filePath := "tmatch.lic"
	else if (licType = 5)
		filePath := "tmodel.lic"
	else if (licType = 8)
		filePath := "tphotolite.lic"
	else if (licType = 11)
		filePath := "tscan.lic"
	tsFile := fileopen(filePath, "rw")
	if (tsFile = 0)
		return 0
	
	RegExMatch(tsFile.ReadLine(), "=(.*)$", number),
	RegExMatch(tsFile.ReadLine(), "=(.*)$", name),
	RegExMatch(tsFile.ReadLine(), "=(.*)$", pcName),
	RegExMatch(tsFile.ReadLine(), "=(.*)$", computerID),
	RegExMatch(tsFile.ReadLine(), "=(.*)$", check),
	RegExMatch(tsFile.ReadLine(), "=(.*)$", type),
	RegExMatch(tsFile.ReadLine(), "=(.*)$", validUntil),
	RegExMatch(tsFile.ReadLine(), "=(.*)$", code)
	
	licObj.number := number1,
	licObj.name := name1,
	licObj.pcName := pcName1,
	licObj.computerID := computerID,
	licObj.check := check1,
	licObj.type := type1,
	licObj.validUntil := validUntil1,
	licObj.code := code1
	
	tformat := substr(validUntil1, 7, 4) . substr(validUntil1, 4, 2) . substr(validUntil1, 1, 2) . 000000, 
	licObj.tFormat := tFormat
	
	return (licObj)
}

validate_License(license_tFormat) {
	FormatTime, nowDate, %a_now%, yyyyMMdd
	FormatTime, licDate, %license_tFormat%, yyyyMMdd
	
	If (nowDate <= licDate)
		return 1
	else if (nowDate > licDate)
		return 0
}
Close_TS_license() {
	SetWorkingDir, C:\terra\license

	Tclass := "TerraLicenseManager"
	IfWinExist, ahk_class %Tclass%
	{
		WinGet, TSID, PID, ahk_class %Tclass%
	}
	IfWinNotExist, ahk_class %Tclass%
	{
		return 1
	}
	process, waitclose, %TSID%, 1
	return
}

Ustation_running() {
	SetWorkingDir, C:\terra\license
	Process, Exist, ustation.exe
	PID := errorLevel
	
	if (PID = 0)
		return 0
	else
		oPID := []
		winget, mstn, List, ahk_class MstnTop
		Loop % mstn {
			hWnd := mstn%A_Index%
			WinGet, mPID, PID, ahk_id %hWnd%
			oPID[a_index] := mPID
		}
	return oPID
}
getTime() {
	FormatTime, R, %A_Now%, MM-dd-yyyy HH:mm:ss
	return R
}
;********************************TEST_AREA******************************************************************
;write/read the INI file for default values

if !FileExist("licDefaults.ini") {
	ini := class_EasyIni("licDefaults.ini")
	
	ini.AddSection("lookLic"),
	ini.AddKey("lookLic","tMatch",0),
	ini.AddKey("lookLic","tScan",0),
	ini.AddKey("lookLic","tModel",0),
	ini.AddKey("lookLic","tPhoto",0),
	ini.AddKey("lookLic","Default",0)
	ini.AddKey("lookLic","reTry",10)
	
	ini.Save()
} else {
	ini := class_EasyIni("licDefaults.ini")
}

tscan := ini.lookLic.tScan
tmatch := ini.lookLic.tMatch
tmodel := ini.lookLic.tModel
tphoto := ini.lookLic.tPhoto
state := ini.lookLic.Default
retryNum := ini.lookLic.reTry

;Open Logfile
log := fileopen("LicenseCaddy.log", "rw")
log.Write(getTime() . " --- Caddy initialized.")

;build tray GUI
scriptStart:
Menu, Tray, NoStandard
Menu, subLicSelect, Add, TerraScan
Menu, subLicSelect, Add, TerraModeler
Menu, subLicSelect, Add, TerraPhotoLite
Menu, subLicSelect, Add, TerraMatch
Menu, Tray, Add, Select License(s), :subLicSelect
Menu, Tray, Add, Start Looking, startLooking
Menu, Tray, Add, Stop Looking, stopLooking
Menu, Tray, Add, Exit, exitApplication

;generate default functions based on "Defaults.ini"
if (tscan = 1)
	Menu, subLicSelect, Check, TerraScan
else
	Menu, subLicSelect, UnCheck, TerraScan
if (tmatch = 1)
	Menu, subLicSelect, Check, TerraMatch
else
	Menu, subLicSelect, UnCheck, TerraMatch
if (tmodel = 1)
	Menu, subLicSelect, Check, TerraModeler
else
	Menu, subLicSelect, UnCheck, TerraModeler
if (tphoto = 1)
	Menu, subLicSelect, Check, TerraPhotoLite
else
	Menu, subLicSelect, UnCheck, TerraPhotoLite

;Launch default "look state"
if (state = 0)
	gosub, stopLooking
if (state = 1)
	gosub, startLooking

return

TerraScan:
Menu, subLicSelect, ToggleCheck, TerraScan
tscan := tscan=1 ? 0 : 1
return

TerraModeler:
Menu, subLicSelect, ToggleCheck, TerraModeler
tmodel := tmodel=1 ? 0 : 1
return

TerraPhotoLite:
Menu, subLicSelect, ToggleCheck, TerraPhotoLite
tphoto := tphoto=1 ? 0 : 1
return

TerraMatch:
Menu, subLicSelect, ToggleCheck, TerraMatch
tmatch := tmatch=1 ? 0 : 1
return

exitApplication:
log.Write(getTime() . " --- Exiting Caddy.")
if (runLoop = 1) {
	state := 0
	gosub, scriptStart
	runLoop := 1
}

ini.DeleteKey("lookLic","tscan")
ini.DeleteKey("lookLic","tmatch")
ini.DeleteKey("lookLic","tmodel")
ini.DeleteKey("lookLic","tphoto")
ini.DeleteKey("lookLic","Default")
ini.DeleteKey("lookLic","reTry")

ini.AddKey("lookLIc","tscan",tscan)
ini.AddKey("lookLIc","tmatch",tmatch)
ini.AddKey("lookLIc","tmodel",tmodel)
ini.AddKey("lookLIc","tphoto",tphoto)
ini.AddKey("lookLIc","Default",runLoop)
ini.AddKey("lookLIc","reTry",state)

ini.Save()
ExitApp

stopLooking:
log.Write(getTime() . " --- Caddy stopped.")
Menu, Tray, Check, Stop Looking
Menu, Tray, UnCheck, Start Looking
Menu, subLicSelect, Enable, TerraScan
Menu, subLicSelect, Enable, TerraModeler
Menu, subLicSelect, Enable, TerraPhotoLite
Menu, subLicSelect, Enable, TerraMatch
runLoop := 0
return

startLooking:
log.Write(getTime() . " --- Caddy started.")
Menu, Tray, UnCheck, Stop Looking
Menu, Tray, Check, Start Looking
Menu, subLicSelect, Disable, TerraScan
Menu, subLicSelect, Disable, TerraModeler
Menu, subLicSelect, Disable, TerraPhotoLite
Menu, subLicSelect, Disable, TerraMatch
runLoop := 1

;check license types and return what isn't wanted
lic := []

if tscan {
	lic[11] := "c:\terra\license\tscan.lic"
} else {
	if fileexist("c:\terra\license\tscan.lic")
	Return_TS_license(11)
	log.Write(getTime() . " --- Tscan returned.")
}
if tmodel {
	lic[5] := "c:\terra\license\tmodel.lic"
} else {
	if fileexist("c:\terra\license\tmodel.lic")
	Return_TS_license(5)
	log.Write(getTime() . " --- Tmodel returned.")
}
if tmatch {
	lic[4] := "c:\terra\license\tmatch.lic"
} else {
	if fileexist("c:\terra\license\tmatch.lic")
	Return_TS_license(4)
	log.Write(getTime() . " --- Tmatch returned.")
}
if tphoto {
	lic[8] := "c:\terra\license\tphotolite.lic"
} else {
	if fileexist("c:\terra\license\tphotolite.lic")
	Return_TS_license(8)
	log.Write(getTime() . " --- Tphoto returned.")
}

;validate licenses upon 'start looking'
test := {}
for licType, licPath in lic {
	tsObj := Read_TS_license(licType)
	test[licType] := validate_License(tsObj.tFormat)
	
	if !test[licType]
		filedelete, %licPath%
}

;adjust licenses to reflect user settings


;running checker script
Loop {
	if runLoop {
		sleep, 3000
		; Loop through licenses in "lic" object
		for licType, licPath in lic {
			; Get license name for logging events
			licName := licType=11 ? "TerraScan" : licType=5 ? "TerraModeler" : licType=4 ? "TerraMatch" : "TerraPhotoLite"
			; Is UStation Running?  If it isn't running...
			if !Ustation_running() {
				; If not, does the license exist?  If no, then continue / If yes, return the license
				if !fileexist(licPath) {
					continue
				} else {
					Return_TS_license(licType)
					log.Write(getTime() . " --- " . licName . " returned.  MicroStation not running.")
					TrayTip, TS License Caddy, %licName% Returned, 3
					continue
				}
			}
			; Is UStation Running?  If it IS running...
			else if Ustation_running() {
				; If the license file exists AND it is 1:30am AND it does not pass validation, THEN grab new license.
				if fileexist(licPath) {
					if (a_hour = 01 && a_min = 30) {
						tsObj := ""
						tsObj := Read_TS_license(licType)
						if !validate_License(tsObj.tFormat) {
							Grab_TS_license(licType)
							log.Write(getTime() . " --- " . licName . " updated.  Microstation running.")
						}
					}
					continue
				; If the license file DOES NOT exist, attempt to accquire license
				} else {
					Grab_TS_license(licType)
					; If license READs as valid, license is acquire successfully
					if Read_TS_license(licType) {
						log.Write(getTime() . " --- " . licName . " acquired.  Microstation running.")
						TrayTip, TS License Caddy, %licName% acquired, 3
						licSuccess := 0
					; However, if it is not successful, Caddy will retry %retryNum% amount of times.
					} else {
						licSuccess += 1
						log.Write(getTime() . " --- " . licName . " unavailable...attempt " . licSuccess . "\" . retryNum)
						TrayTip, TS License Caddy, %licName% Unavailable...attempt %licSuccess%\%retryNum%, 1
						; If Caddy cannot acquire license after several retrys, Caddy will deselect license from list and continue monitoring.
						if (licSuccess >= retryNum) {
							log.Write(getTime() . " --- " . licName . " unavailable.  Deselecting license.")
							TrayTip, TS License Caddy, License Unavailable.  Deselecting license..., 1
							gosub, %licName%
							lic.Remove(licType)
							continue
						}
						continue
					}
					continue
				}
			}
		}
	}
	else 
		break
}
return
