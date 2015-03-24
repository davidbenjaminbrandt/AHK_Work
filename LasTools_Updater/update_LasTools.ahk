SetBatchlines, -1

GetRawHtml(Url){
	static Var := ""
	Var := ComObjCreate("WinHttp.WinHttpRequest.5.1")
	OUT:=Var.open("GET",Url,False)
	try
	{
		Var.Send()
		return, Var.ResponseText
	}
	catch
		return, 1
}

Return_Month_Num(threeCharMonth)
{
	If (threeCharMonth = "Jan" OR threeCharMonth = "jan")
		OutMonthNum:=01
	else If (threeCharMonth = "Feb" OR threeCharMonth = "feb")
		OutMonthNum:=02
	else If (threeCharMonth = "Mar" OR threeCharMonth = "mar")
		OutMonthNum:=03
	else If (threeCharMonth = "Apr" OR threeCharMonth = "apr")
		OutMonthNum:=04
	else If (threeCharMonth = "May" OR threeCharMonth = "may")
		OutMonthNum:=05
	else If (threeCharMonth = "Jun" OR threeCharMonth = "jun")
		OutMonthNum:=06
	else If (threeCharMonth = "Jul" OR threeCharMonth = "jul")
		OutMonthNum:=07
	else If (threeCharMonth = "Aug" OR threeCharMonth = "aug")
		OutMonthNum:=08
	else If (threeCharMonth = "Sep" OR threeCharMonth = "sep")
		OutMonthNum:=09
	else If (threeCharMonth = "Oct" OR threeCharMonth = "oct")
		OutMonthNum:=10
	else If (threeCharMonth = "Nov" OR threeCharMonth = "nov")
		OutMonthNum:=11
	else If (threeCharMonth = "Dec" OR threeCharMonth = "dec")
		OutMonthNum:=12
	else
		OutMonthNum:=00
	return OutMonthNum
}

;##############################################################################################################################################################

;~ Sleep, 60000

TrayTip, LasTools, Checking for Updates..., 11, 1

FileGetTime, CurrentLT, C:\install\lastools.zip
If ErrorLevel
	GoTo, DEandI

Latest_Version := GetRawHtml("http://www.cs.unc.edu/~isenburg/lastools/download/")
Loop, parse, Latest_Version, `r`n
{
	If InStr(A_Loopfield, "lastools.zip")
	{
		RegExMatch(A_LoopField, "O)\d\d-\D\D\D-\d\d\d\d \d\d:\d\d", DateM)
		firstM:=StrSplit(DateM.Value(), "-", " ")
		Day:=firstM[1]
		Mon:=Return_Month_Num(firstM[2])
		SecondM:=StrSplit(firstM[3], " ")
		Year:=SecondM[1]
		ThirdM:=StrSplit(SecondM[2], ":")
		Hour:=ThirdM[1]
		Min:=ThirdM[2]
		UpdateLT:=Year . Mon . Day . Hour . Min . "00"
	}
}

If (UpdateLT >= CurrentLT)
{
TrayTip, LasTools, Downloading Updates..., 11, 1

URLDownloadToFile, http://www.cs.unc.edu/~isenburg/lastools/download/lastools.zip, C:\install\lastools.zip
If errorlevel
{
	TrayTip, LasTools, There was a problem downloading updates`nClosing..., 11, 1
	sleep, 3000
	ExitApp
}
test:=FileExist("C:\install\lastools")
;~ msgbox % test
If FileExist("C:\install\lastools")
{
	;~ msgbox, removing
	FileRemoveDir, C:\install\lastools, 1
}

TrayTip, LasTools, Extracting Updates..., 11, 1

If FileExist("C:\Program Files (x86)\7-Zip\7z.exe")
	Run, "C:\Program Files (x86)\7-Zip\7z.exe" x "C:\install\lastools.zip" -o"C:\install\" -y, , Hide, 7zip
Else If FileExist("C:\Program Files\7-Zip\7z.exe")
	Run, "C:\Program Files\7-Zip\7z.exe" x "C:\install\lastools.zip" -o"C:\install\" -y, , Hide, 7zip
Process, Wait, %7zip%
Process, Waitclose, %7zip%
If FileExist("C:\install\lastoolslicense.txt")
{
	FileCopy, C:\install\lastoolslicense.txt, C:\install\lastools\bin
	if errorlevel
		TrayTip, LasTools, There was a problem applying LasTools License updates`nClosing..., 11, 1
	sleep, 2000
}
else
{
	TrayTip, LasTools, License TXT file not found!`nPlease put lastoolslicense.txt in Start Folder and restart updater!, 11, 1
	sleep, 2000
	ExitApp
}
TrayTip, LasTools, Applying License..., 11, 1

Run, "C:\install\lastools\bin\lasground_new.exe" -license, , Hide, lascolor
Process, Wait, %lascolor%
Process, Waitclose, %lascolor%
TrayTip, LasTools, LasTools is Up to Date!, 11, 1
Sleep, 10000
exitapp
}

else
{
	TrayTip, LasTools, LasTools is Up to Date!, 11, 1
	sleep, 5000
	ExitApp
}

;#########################Sub-Routines#################################

DEandI:
TrayTip, LasTools, Downloading Updates..., 11, 1
URLDownloadToFile, http://www.cs.unc.edu/~isenburg/lastools/download/lastools.zip, C:\install\lastools.zip
If errorlevel
{
	TrayTip, LasTools, There was a problem downloading updates`nClosing..., 11, 1
	sleep, 3000
	ExitApp
}
test:=If FileExist("C:\install\lastools")
	FileRemoveDir, C:\install\lastools, 1
msgbox % test . " " . errorlevel
TrayTip, LasTools, Extracting Updates..., 11, 1
If FileExist("C:\Program Files (x86)\7-Zip\7z.exe")
	Run, "C:\Program Files (x86)\7-Zip\7z.exe" x "C:\install\lastools.zip" -o"C:\install\" -y, , Hide, 7zip
Else If FileExist("C:\Program Files\7-Zip\7z.exe")
	Run, "C:\Program Files\7-Zip\7z.exe" x "C:\install\lastools.zip" -o"C:\install\" -y, , Hide, 7zip
Process, Wait, %7zip%
Process, Waitclose, %7zip%
If FileExist("C:\install\lastoolslicense.txt")
{
	FileCopy, C:\install\lastoolslicense.txt, C:\install\lastools\bin
	if errorlevel
		TrayTip, LasTools, There was a problem applying LasTools License updates`nClosing..., 11, 1
	sleep, 2000
}
else
{
	TrayTip, LasTools, License TXT file not found!`nPlease put lastoolslicense.txt in Start Folder and restart updater!, 11, 1
	sleep, 2000
	ExitApp
}
TrayTip, LasTools, Applying License..., 11, 1

Run, "C:\install\lastools\bin\lascolor.exe" -license, , Hide, lascolor
Process, Wait, %lascolor%
Process, Waitclose, %lascolor%
TrayTip, LasTools, LasTools is Up to Date!, 11, 1
Sleep, 10000
exitapp

