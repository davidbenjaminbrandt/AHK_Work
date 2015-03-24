SetBatchLines, -1
#NoEnv

StringSort(a1, a2)
{
	splitpath, a1, , , , as1
	splitpath, a2, , , , as2
	asn1:=strsplit(as1, "_")
	asn2:=strsplit(as2, "_")
	
    return asn1[2] > asn2[2] ? 1 : asn1[2] < asn2[2] ? -1 : 0  ; Sorts alphabetically based on the setting of StringCaseSense.
}

;~ FileSelectFile, imugpsPath, 3, , Select imu_gps.txt file from mission directory
FileSelectFile, origPath, 3, , Select the original imu_gps.txt file from mission data
FileSelectFile, posPath, 3, , Select the ASCII Headwall file exported from POSpac containing mission data
FileSelectFile, indexPaths, M3, , Select all the frameIndex_*.txt files from mission folder
FileSelectFile, timePath, 3, , Select the gps_time.txt file from mission directory

If (origPath = "" || posPath = "" || indexPaths = "" || timePath = "")
{
	msgbox, You did not select a necessary input file`n`n%a_tab%Original imu_gps.txt: %origPath%`n%a_tab%POSpac generated ASCII file: posPath`n%a_tab%List of all frameIndex files: %indexPaths%`n%a_tab%gps_time.txt file: %timePath%`n`nExiting...
	ExitApp
}

; Set amount of latency in Spooler (in microseconds)
latPOS := 40000

;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
progress, 5 X0 Y0, Merging..., Merging all frameIndex files into one

file := object()

Loop, parse, indexPaths, `n
{
	If (a_index = 1)
		Dir := a_loopfield
	files .= Dir . "\" . a_loopfield . "`n"
}

Sort, files, F StringSort N

Loop, parse, files, `n
{
	file[a_index]:=A_LoopField
}

fileOut := ""

loop % file.MaxIndex()
{
	reading := file[a_index]
	loop, read, %reading%
	{
		if (a_index = 1)
			continue
		else
		{
			fileOut .= a_loopreadline . "`n"
		}
	}
	;~ filemove, %reading%, %Dir%\FILE_ORIGINALS, 1
	
}

;~ fileappend, Frame#%a_tab%Time`r`n, %Dir%\frameIndex.txt
;~ fileappend, %fileOut%, %Dir%\frameIndex.txt

indexPath = %Dir%\frameIndex.txt

imugpsOrig := Object()
imugpsPOS := Object()
indexOrig := Object()
timeOrig := Object()
imugpsSplit := ""

;~ Loop, Read, %imugpsPath%
;~ {
	;~ index := a_index - 1
	
	;~ If (a_index = 1)
		;~ continue
	;~ else
	;~ {
		;~ imugpsSplit := strsplit(A_LoopReadLine, a_tab, "`r`n")
		;~ imugpsOrig.Roll[index] 		:= imugpsSplit[1]
		;~ imugpsOrig.Pitch[index] 	:= imugpsSplit[2]
		;~ imugpsOrig.Yaw[index] 		:= imugpsSplit[3]
		;~ imugpsOrig.Lat[index] 		:= imugpsSplit[4]
		;~ imugpsOrig.Lon[index] 		:= imugpsSplit[5]
		;~ imugpsOrig.Alt[index] 		:= imugpsSplit[6]
		;~ imugpsTimeSplit := strsplit(imugpsSplit[7], [a_space,":"], "`r`n")
		;~ , imugpsOrig.TimeH[index] 		:= imugpsTimeSplit[1]
		;~ , imugpsOrig.TimeM[index] 		:= imugpsTimeSplit[2]
		;~ , imugpsOrig.TimeS[index] 		:= imugpsTimeSplit[3]
		;~ , imugpsOrig.TimeDec[index] 	:= imugpsTimeSplit[4]
	;~ }
;~ }
;~ imugpsOrig.total := index
;~ index := 0
;~ imugpsSplit := ""
;~ imugpsTimeSplit := ""
progress, 15 , Indexing..., Indexing POS-created imu_gps file

Loop , Read, %posPath%
{
	if (A_LoopReadLine = "`r`n" || A_LoopReadLine = "`r" || A_LoopReadLine = "`n")
		continue
	
	If (a_index = 1)
		continue
	else
	{
		++index
		imugpsSplit := strsplit(A_LoopReadLine, a_tab, "`r`n")
		imugpsPOS.Roll[index] 		:= imugpsSplit[1]
		imugpsPOS.Pitch[index] 		:= imugpsSplit[2]
		imugpsPOS.Yaw[index] 		:= imugpsSplit[3]
		imugpsPOS.Lat[index] 		:= imugpsSplit[4]
		imugpsPOS.Lon[index] 		:= imugpsSplit[5]
		imugpsPOS.Alt[index] 		:= imugpsSplit[6]
		imugpsTimeSplit := strsplit(imugpsSplit[7], [".",":"], "`r`n")
		, imugpsPOS.TimeH[index] 		:= imugpsTimeSplit[1]
		, imugpsPOS.TimeM[index] 		:= imugpsTimeSplit[2]
		, imugpsPOS.TimeS[index] 		:= imugpsTimeSplit[3]
		, imugpsPOS.TimeDec[index] 		:= imugpsTimeSplit[4]
	}
}
imugpsPOS.total := index
index := 0
progress, 25, Indexing..., Indexing fileIndex.txt

Loop, Parse, fileOut, `n
{
	If (a_loopfield = "")
		break
	index := a_index

		indexSplit := strsplit(A_LoopField, a_tab, "`r`n")
		indexOrig.Frame[index]		:= indexSplit[1]
		indexTimeSplit := strsplit(indexSplit[2], [a_space,":"], "`r`n")
		, indexOrig.TimeH[index]		:= indexTimeSplit[1]
		, indexOrig.TimeM[index]		:= indexTimeSplit[2]
		, indexOrig.TimeS[index]		:= indexTimeSplit[3]
		, indexOrig.TimeDec[index]		:= indexTimeSplit[4]
		
}
indexOrig.total := index
index := 0
progress, 35, Indexing..., Indexing gps_time.txt

Loop, Read, %timePath%
{
	index := a_index - 1
	
	If (a_index = 1)
		continue
	else
	{
		timeSplit := strsplit(A_LoopReadLine, a_tab, "`r`n")
		
		pctimeSplit := strsplit(timeSplit[1], [a_space,":"], "`r`n")
		, timeOrig.pcTimeDec[index] 	:= pctimeSplit[4]
		, timeOrig.pcTimeS[index] 		:= pctimeSplit[3]
		, timeOrig.pcTimeM[index] 		:= pctimeSplit[2]
		, timeOrig.pcTimeH[index] 		:= pctimeSplit[1] 
		postimeSplit := strsplit(timeSplit[2], [a_space,":","."], "`r`n")
		, timeOrig.posTimeDec[index] 	:= postimeSplit[5]
		, timeOrig.posTimeS[index] 		:= postimeSplit[4]
		, timeOrig.posTimeM[index] 		:= postimeSplit[3]
		, timeOrig.posTimeH[index] 		:= postimeSplit[2]
		, timeOrig.posDate[index] 		:= postimeSplit[1]
	}
}
timeOrig.total := index
index := 0

;~ msgbox % timeOrig.total . "," . indexOrig.total . "," . imugpsPOS.total . "," . imugpsOrig.total
;~ msgbox % imugpsOrig.Roll[5] . "," . imugpsOrig.Pitch[5] . "," . imugpsOrig.Yaw[5] . "," . imugpsOrig.Lat[5] . "," . imugpsOrig.Lon[5] . "," . imugpsOrig.Alt[5] . "," . imugpsOrig.Time[5]
;~ msgbox % imugpsPOS.Roll[5] . "," . imugpsPOS.Pitch[5] . "," . imugpsPOS.Yaw[5] . "," . imugpsPOS.Lat[5] . "," . imugpsPOS.Lon[5] . "," . imugpsPOS.Alt[5] . "," . imugpsPOS.Time[5]
;~ msgbox % indexOrig.Frame[5] . "," . indexOrig.Time[5] 
;~ msgbox % timeOrig.pcTimeDec[5] . "," . timeOrig.pcTimeH[5] . "," . timeOrig.pcTimeM[5] . "," . timeOrig.pcTimeS[5] . "," . timeOrig.posDate[5] . "," . timeOrig.posTimeDec[5] . "," . timeOrig.posTimeH[5] . "," . timeOrig.posTimeM[5] . "," . timeOrig.posTimeS[5]

; filter gps_time.txt for only times found in frameIndex.txt
progress, 55, Filtering..., Filtering gps_time.txt for common records with frameIndex.txt

fiStart		:= A_YYYY . A_MM . A_DD . indexOrig.TimeH[1] . indexOrig.TimeM[1] . indexOrig.TimeS[1]
fiStart += 0, Seconds
formattime, fiStart, %fiStart%, HHmmss
fiEnd		:= A_YYYY . A_MM . A_DD . indexOrig.TimeH[indexOrig.total] . indexOrig.TimeM[indexOrig.total] . indexOrig.TimeS[indexOrig.total]
fiEnd += 0, Seconds
formattime, fiEnd, %fiEnd%, HHmmss
timeOrigF	:= object()

loop % timeOrig.total
{
	gtTest	:= timeOrig.pcTimeH[a_index] . timeOrig.pcTimeM[a_index] . timeOrig.pcTimeS[a_index]
	gtDec	:= timeOrig.pcTimeDec[a_index]
	gtDecRate := gtDec-pregtDec
	If (gtTest = fiStart AND gtStartindex = "")
	{
		If (gtDecRate > 1000 AND gtDecRate > 0) 		;Finds best SYNC point given a packet delay in "computer Time"
		{
			gtStartindex := A_Index-1
			gtStartlog := A_Index-1
		}
	}
	Else If (gtTest >= fiEnd AND gtEndindex = "")
	{
		gtEndindex := A_Index	
	;~ ListVars
	;~ msgbox
	}
	
	pregtDec := gtDec
}

If (gtEndindex = "" or gtStartindex = "")
{
	msgbox, Umm, something doesn't add up.  check to make sure all files are coming from the same flight or mission.  Times in your gps_time & frameIndex files are not reconciling.`nframeIndex Start = %fiStart%, gps_time start index = %gtStartindex%`nframeIndex End = %fiEnd%, gps_time end index = %gtEndindex%
	ExitApp
}

Loop
{
	timeOrigF.pcTimeDec[a_index] := timeOrig.pcTimeDec[gtStartlog]
	, timeOrigF.pcTimeH[a_index] := timeOrig.pcTimeH[gtStartlog]
	, timeOrigF.pcTimeM[a_index] := timeOrig.pcTimeM[gtStartlog]
	, timeOrigF.pcTimeS[a_index] := timeOrig.pcTimeS[gtStartlog]
	, timeOrigF.posTimeDec[a_index] := timeOrig.posTimeDec[gtStartlog]
	, timeOrigF.posTimeH[a_index] := timeOrig.posTimeH[gtStartlog]
	, timeOrigF.posTimeM[a_index] := timeOrig.posTimeM[gtStartlog]
	, timeOrigF.posTimeS[a_index] := timeOrig.posTimeS[gtStartlog]
	, timeOrigF.posDate[a_index] := timeOrig.posDate[gtStartlog]
	
	++gtStartlog
	filteredIndex := a_index

} Until (gtStartlog = gtEndindex)

timeOrigF.total := filteredIndex

;filter EXPORTED imu_gps file with NEW filterd gps_time info
progress, 85, Filtering..., Filtering POS export with filtered gps_time.txt data

tofStart := timeOrigF.posTimeH[1] . timeOrigF.posTimeM[1] . timeOrigF.posTimeS[1] . timeOrigF.posTimeDec[1], tofStart += 0
tofEnd := timeOrigF.posTimeH[timeOrigF.total] . timeOrigF.posTimeM[timeOrigF.total] . timeOrigF.posTimeS[timeOrigF.total] . timeOrigF.posTimeDec[timeOrigF.total], tofEnd += 0

Loop % imugpsPOS.total
{
	igTest	:= imugpsPOS.TimeH[a_index] . imugpsPOS.TimeM[a_index] . imugpsPOS.TimeS[a_index] . imugpsPOS.TimeDec[a_index], igTest :=igTest+0

	If (abs(tofStart-igTest) <= 1 && igStartindex = "" && igTest != "") {
		igStartindex := A_Index
		igStartlog := A_Index
	} Else If (abs(tofEnd-igTest) <= 1 && igEndindex = "" && igTest != "") {
		igEndindex := A_Index
	}
}

If (igStartindex = "" or igEndindex = "")
{
	msgbox, I think there is something wrong.  The refined IMU_GPS times don't seem to exist in the filtered gps_time file.  Double check the exported imu_gps file from POSpac and the gps_time file have similiar GPS times.
	exitapp
}

;spit out brand new imu_gps file
progress, 95, Outputting..., Outputting new imu_gps.txt

FileMove, %origPath%, %Dir%\imu_gps_orig.txt

imugpsPath := Dir . "\imu_gps_interp.txt"
FileDelete, %imugpsPath%
imugpsOut := fileopen(Dir . "\imu_gps_interp.txt", "w")
imugpsOut.Write("Roll	Pitch	Yaw	Lat	Lon	Alt	Time`r`n")

; interpolate PC time from POS time:  amount := preDec < postDec ? (postDec-preDec) : ((1000-preDec)+postDec)
; Then:  	addDec := preDec < postDec ? (postDec-preDec) : ((1000-preDec)+postDec)
;			newDec := (addDec + currentDec) > 1000 ? (addDec + currentDec - 1000) : (addDec + currentDec)
;			addSec := (addDec + currentDec) > 1000 ? 1 : 0
;			currentTime += addSec, seconds
;			Now, newTime = currentTime

Loop
{	
	If (A_Index = 1)
	{
		; Set sync time from closest PC time, given the packet delay
		currentTime := 0,		currentTime := A_Year . A_MM . A_DD . timeOrigF.pcTimeH[a_index] . timeOrigF.pcTimeM[a_index] . timeOrigF.pcTimeS[a_index]
		currentDec := 0,		currentDec := timeOrigF.pcTimeDec[a_index]
		; Add constant to sync time to make up for any latency in the Spooler
		LnewDec := (currentDec - latPOS) <= 0 ? (1000000 + (currentDec - latPOS)) : (currentDec - latPOS)
		LaddSec := (currentDec - latPOS) <= 0 ? -1 : 0
		currentTime += LaddSec, seconds
		currentDec := LnewDec


		;Write 200 extra imu_gps lines to buffer start of first line
		buffStartTime := currentTime
		buffStartDec := currentDec
		preigStartlog := igStartlog
		loop % 200 {
			preigStartlog -= 1
			
			preDec := 0,			preDec := imugpsPOS.TimeDec[preigStartlog]
			, postDec := 0,			postDec := imugpsPOS.TimeDec[preigStartlog+1]
			, subSec := 0
			, subDec := 0
			, newDec := 0
			, newTimeF := ""
			
			subDec := preDec < postDec ? ((postDec-preDec)*1000) : (((1000-preDec)+postDec)*1000)
			, newDec := (buffStartDec - subDec) < 0 ? (buffStartDec - subDec + 1000000) : (buffStartDec - subDec)
			, subSec := (buffStartDec - subDec) < 0 ? (-1) : 0
			buffStartTime += subSec, seconds
			newTime := buffStartTime
			
			formattime, newTimeF, %newTime%, HH:mm:ss
			
			startLogBuff := imugpsPOS.Roll[preigStartlog] . a_tab . imugpsPOS.Pitch[preigStartlog] . a_tab . imugpsPOS.Yaw[preigStartlog] . a_tab . imugpsPOS.Lat[preigStartlog] . a_tab . imugpsPOS.Lon[preigStartlog] . a_tab . imugpsPOS.Alt[preigStartlog] . a_tab . newTimeF . " " . newDec . "`r`n" . startLogBuff
			
			buffStartTime := newTime
			buffStartDec := newDec
		}
		imugpsOut.Write(startLogBuff)
		; End of extra 200 line buffer section
		
		continue
	}
	
	preDec := 0,			preDec := imugpsPOS.TimeDec[igStartlog-1]
	, postDec := 0,			postDec := imugpsPOS.TimeDec[igStartlog]
	, addSec := 0
	, addDec := 0
	, newDec := 0
	
	imugpsOut.Write(imugpsPOS.Roll[igStartlog] . a_tab . imugpsPOS.Pitch[igStartlog] . a_tab . imugpsPOS.Yaw[igStartlog] . a_tab . imugpsPOS.Lat[igStartlog] . a_tab . imugpsPOS.Lon[igStartlog] . a_tab . imugpsPOS.Alt[igStartlog] . a_tab)
	
	addDec := preDec < postDec ? ((postDec-preDec)*1000) : (((1000-preDec)+postDec)*1000)
	, newDec := (addDec + currentDec) > 1000000 ? (addDec + currentDec - 1000000) : (addDec + currentDec)
	, addSec := (addDec + currentDec) > 1000000 ? 1 : 0
	currentTime += addSec, seconds
	newTime := currentTime
	newTimeF := ""
	formattime, newTimeF, %newTime%, HH:mm:ss
	
	imugpsOut.Write(newTimeF . " " . newDec . "`r`n")
	
	++igStartlog
	currentTime := newTime
	currentDec := newDec
} Until (igStartlog = igEndindex)

imugpsOut.close()
progress, 2000, DONE!

exitapp
