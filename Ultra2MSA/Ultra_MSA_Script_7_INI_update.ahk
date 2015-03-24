SetBatchLines, -1
#noenv

Read_FLT4Array_Object(FLTvarPATH) {
	aSpace := A_space
	DEM := Object()
	splitpath, FLTvarPATH, FLTwEXT, FLTDir, FLTExt, FLTnoExt
	HDRpath := FLTDir . "\" . FLTnoEXT . ".hdr", FLTpath := FLTDir . "\" . FLTnoEXT . ".flt"	
	HDRobj := fileopen(HDRpath, "rw")
	FLTobj := fileopen(FLTpath, "rw")
	DEMlen := FLTobj.Length
	fltCapacity := DEMlen/4
	
	If (DEMlen > 3617587200)
	{
		msgbox, Whoa!  That's a big GRID...try a smaller one before you burn the place down.
		ExitApp
	}
	;~ progress, R0-%DEMlen%, , Building DEM Array, INS 2 Swath
	
	Loop
	{
		HDRline := HDRobj.ReadLine()
		StringReplace HDRline, HDRline, %A_Space%    %A_Space%, %A_Space%, All 
		StringReplace HDRline, HDRline, %A_Space% %A_Space%, %A_Space%, All 
		StringReplace HDRline, HDRline, %A_Space%%A_Space%, %A_Space%, All 
		StringReplace HDRline, HDRline, %A_Space%%A_Space%, %A_Space%, All
		If (A_Index = 1)
		{
			StringSplit, COL, HDRline, %A_Space%, `r`n
			DEM.CLMN := Round(COL2)
			continue
		}
		Else If (A_Index = 2)
		{
			StringSplit, ROW, HDRline, %A_Space%, `r`n
			DEM.ROWS := Round(ROW2)
			continue
		}
		Else If (A_Index = 3)
		{
			StringSplit, XL, HDRline, %A_Space%, `r`n
			DEM.XLLC := Round(XL2)
			continue
		}
		Else If (A_Index = 4)
		{
			StringSplit, YL, HDRline, %A_Space%, `r`n
			DEM.YLLC := Round(YL2)
			continue
		}
		Else If (A_Index = 5)
		{
			StringSplit, CS, HDRline, %A_Space%, `r`n
			DEM.CSize := CS2+0, 
			DEM.XURC := DEM.XLLC+(DEM.CSize*DEM.CLMN), 
			DEM.YURC := DEM.YLLC+(DEM.CSize*DEM.ROWS)
			continue
		}
		Else If (A_Index = 6)
		{
			StringSplit, NOD, HDRline, %A_Space%, `r`n
			DEM.NODATA := NOD2+0
			continue
		}
		If (HDRobj.AtEOF != 0)
			Break
	}
	Loop % DEM.ROWS
	{
		;~ DEMpos := FLTobj.Pos
		;~ progress, %DEMpos%
		Row := A_Index
		Col = 0
		Loop % DEM.CLMN
		{
			Col += 1
			DEM.dem[Col,Row] := FLTobj.ReadFloat()
		}
			
	}
	DEM.SetCapacity(0)
	FLTobj.close()
	HDRobj.close()
	return DEM
}
Read_ASC4Array_Object(ASCvarPATH) {
	global
	
	aSpace := A_space
	DEM := Object()
	ASCobj := fileopen(ASCvarPATH, "rw")
	DEMlen := ASCobj.Length
	If (DEMlen > 3617587200)
	{
		msgbox, Whoa!  That's a big ASCII...try a smaller one before you burn the place down.
		ExitApp
	}
	progress, R0-%DEMlen%, , Building DEM Array, INS 2 Swath
	Loop
	{
		DEMline := ASCobj.ReadLine()
		DEMpos := ASCobj.Pos
		progress, %DEMpos%
		If (A_Index = 1)
		{
			StringReplace DEMline, DEMline, %A_Space%    %A_Space%, %A_Space%, All 
			StringReplace DEMline, DEMline, %A_Space% %A_Space%, %A_Space%, All 
			StringReplace DEMline, DEMline, %A_Space%%A_Space%, %A_Space%, All 
			StringReplace DEMline, DEMline, %A_Space%%A_Space%, %A_Space%, All
			StringSplit, COL, DEMline, %A_Space%
			CLMN := Round(COL2)
			continue
		}
		Else If (A_Index = 2)
		{
			StringReplace DEMline, DEMline, %A_Space%    %A_Space%, %A_Space%, All 
			StringReplace DEMline, DEMline, %A_Space% %A_Space%, %A_Space%, All 
			StringReplace DEMline, DEMline, %A_Space%%A_Space%, %A_Space%, All 
			StringReplace DEMline, DEMline, %A_Space%%A_Space%, %A_Space%, All
			StringSplit, ROW, DEMline, %A_Space%
			ROWS := Round(ROW2)
			continue
		}
		Else If (A_Index = 3)
		{
			StringReplace DEMline, DEMline, %A_Space%    %A_Space%, %A_Space%, All 
			StringReplace DEMline, DEMline, %A_Space% %A_Space%, %A_Space%, All 
			StringReplace DEMline, DEMline, %A_Space%%A_Space%, %A_Space%, All 
			StringReplace DEMline, DEMline, %A_Space%%A_Space%, %A_Space%, All
			StringSplit, XL, DEMline, %A_Space%
			XLLC := Round(XL2)
			continue
		}
		Else If (A_Index = 4)
		{
			StringReplace DEMline, DEMline, %A_Space%    %A_Space%, %A_Space%, All 
			StringReplace DEMline, DEMline, %A_Space% %A_Space%, %A_Space%, All 
			StringReplace DEMline, DEMline, %A_Space%%A_Space%, %A_Space%, All 
			StringReplace DEMline, DEMline, %A_Space%%A_Space%, %A_Space%, All
			StringSplit, YL, DEMline, %A_Space%
			YLLC := Round(YL2)
			continue
		}
		Else If (A_Index = 5)
		{
			StringReplace DEMline, DEMline, %A_Space%    %A_Space%, %A_Space%, All 
			StringReplace DEMline, DEMline, %A_Space% %A_Space%, %A_Space%, All 
			StringReplace DEMline, DEMline, %A_Space%%A_Space%, %A_Space%, All 
			StringReplace DEMline, DEMline, %A_Space%%A_Space%, %A_Space%, All
			StringSplit, CS, DEMline, %A_Space%
			CSize := Round(CS2), XURC := XLLC+(CSize*CLMN), YURC := YLLC+(CSize*ROWS)
			continue
		}
		Else If (A_Index = 6)
		{
			StringReplace DEMline, DEMline, %A_Space%    %A_Space%, %A_Space%, All 
			StringReplace DEMline, DEMline, %A_Space% %A_Space%, %A_Space%, All 
			StringReplace DEMline, DEMline, %A_Space%%A_Space%, %A_Space%, All 
			StringReplace DEMline, DEMline, %A_Space%%A_Space%, %A_Space%, All
			IfNotInString, DEMline, NODATA_value
			{
				Row := A_Index
				Loop, Parse, DEMline, %aSpace%
				{
					Col += 1
					DEM[Col, Row] := A_LoopField
				}
				If !First
				{
					First := True
					ColCount := Col
				}
				Col = 0, NODATA := ""
			}
			else
			{
				StringSplit, NOD, DEMline, %A_Space%
				NODATA := NOD2
				continue
			}
		}
		Else
		{
				Row := A_Index
				Loop, Parse, DEMline, %aSpace%
				{
					Col += 1
					DEM[Col, Row] := A_LoopField
				}
				If !First
				{
					First := True
					ColCount := Col
				}
				Col = 0
		}
		IsAtEOF := ASCobj.AtEOF
		If (ASCobj.AtEOF != 0)
			Break
	}

}

listSearch(termsArr,listArr) {
	searchOut := []
	Loop % listArr.maxindex()
	{
		listIndex := a_index
		loop % termsArr.maxindex()
		{
			termIndex := a_index
			If instr(listArr[listIndex], termsArr[termIndex])
			{
				inSearch := "Yes"
			}
			else 
			{
				inSearch := "No"
				break
			}
		}
		If (inSearch = "Yes") {
			++outIndex
			searchOut[outIndex] := listArr[listIndex]
		}
	}
	return searchOut
}

proj4_Init(Option) {			;option = 0 epsg / option = 1 esri
FileCreateDir, %a_workingdir%\PROJ\bin
fileinstall, C:\Users\watershed\Google Drive\AHK_Scripts\Projection\PROJ\bin\alaska.lla, %A_WorkingDir%\PROJ\bin\alaska.lla, 1
fileinstall, C:\Users\watershed\Google Drive\AHK_Scripts\Projection\PROJ\bin\conus.lla, %A_WorkingDir%\PROJ\bin\conus.lla, 1
fileinstall, C:\Users\watershed\Google Drive\AHK_Scripts\Projection\PROJ\bin\cs2cs.exe, %A_WorkingDir%\PROJ\bin\cs2cs.exe, 1
fileinstall, C:\Users\watershed\Google Drive\AHK_Scripts\Projection\PROJ\bin\epsg, %A_WorkingDir%\PROJ\bin\epsg, 1
fileinstall, C:\Users\watershed\Google Drive\AHK_Scripts\Projection\PROJ\bin\epsg_DB, %A_WorkingDir%\PROJ\bin\epsg_DB, 1
fileinstall, C:\Users\watershed\Google Drive\AHK_Scripts\Projection\PROJ\bin\epsg_DB_1, %A_WorkingDir%\PROJ\bin\epsg_DB_1, 1
fileinstall, C:\Users\watershed\Google Drive\AHK_Scripts\Projection\PROJ\bin\esri, %A_WorkingDir%\PROJ\bin\esri, 1
fileinstall, C:\Users\watershed\Google Drive\AHK_Scripts\Projection\PROJ\bin\esri_DB_1, %A_WorkingDir%\PROJ\bin\esri_DB_1, 1
fileinstall, C:\Users\watershed\Google Drive\AHK_Scripts\Projection\PROJ\bin\FL.lla, %A_WorkingDir%\PROJ\bin\FL.lla, 1
fileinstall, C:\Users\watershed\Google Drive\AHK_Scripts\Projection\PROJ\bin\geod.exe, %A_WorkingDir%\PROJ\bin\geod.exe, 1
fileinstall, C:\Users\watershed\Google Drive\AHK_Scripts\Projection\PROJ\bin\hawaii.lla, %A_WorkingDir%\PROJ\bin\hawaii.lla, 1
fileinstall, C:\Users\watershed\Google Drive\AHK_Scripts\Projection\PROJ\bin\MD.lla, %A_WorkingDir%\PROJ\bin\MD.lla, 1
fileinstall, C:\Users\watershed\Google Drive\AHK_Scripts\Projection\PROJ\bin\nad2bin.exe, %A_WorkingDir%\PROJ\bin\nad2bin.exe, 1
fileinstall, C:\Users\watershed\Google Drive\AHK_Scripts\Projection\PROJ\bin\nad2nad.exe, %A_WorkingDir%\PROJ\bin\nad2nad.exe, 1
fileinstall, C:\Users\watershed\Google Drive\AHK_Scripts\Projection\PROJ\bin\nad27, %A_WorkingDir%\PROJ\bin\nad27, 1
fileinstall, C:\Users\watershed\Google Drive\AHK_Scripts\Projection\PROJ\bin\nad83, %A_WorkingDir%\PROJ\bin\nad83, 1
fileinstall, C:\Users\watershed\Google Drive\AHK_Scripts\Projection\PROJ\bin\ntv1_can.dat, %A_WorkingDir%\PROJ\bin\ntv1_can.dat, 1
fileinstall, C:\Users\watershed\Google Drive\AHK_Scripts\Projection\PROJ\bin\proj.dll, %A_WorkingDir%\PROJ\bin\proj.dll, 1
fileinstall, C:\Users\watershed\Google Drive\AHK_Scripts\Projection\PROJ\bin\proj.exe, %A_WorkingDir%\PROJ\bin\proj.exe, 1
fileinstall, C:\Users\watershed\Google Drive\AHK_Scripts\Projection\PROJ\bin\prvi.lla, %A_WorkingDir%\PROJ\bin\prvi.lla, 1
fileinstall, C:\Users\watershed\Google Drive\AHK_Scripts\Projection\PROJ\bin\stgeorge.lla, %A_WorkingDir%\PROJ\bin\stgeorge.lla, 1
fileinstall, C:\Users\watershed\Google Drive\AHK_Scripts\Projection\PROJ\bin\stlrnc.lla, %A_WorkingDir%\PROJ\bin\stlrnc.lla, 1
fileinstall, C:\Users\watershed\Google Drive\AHK_Scripts\Projection\PROJ\bin\stpaul.lla, %A_WorkingDir%\PROJ\bin\stpaul.lla, 1
fileinstall, C:\Users\watershed\Google Drive\AHK_Scripts\Projection\PROJ\bin\TN.lla, %A_WorkingDir%\PROJ\bin\TN.lla, 1
fileinstall, C:\Users\watershed\Google Drive\AHK_Scripts\Projection\PROJ\bin\WI.lla, %A_WorkingDir%\PROJ\bin\WI.lla, 1
fileinstall, C:\Users\watershed\Google Drive\AHK_Scripts\Projection\PROJ\bin\WO.lla, %A_WorkingDir%\PROJ\bin\WO.lla, 1
fileinstall, C:\Users\watershed\Google Drive\AHK_Scripts\Projection\PROJ\bin\world, %A_WorkingDir%\PROJ\bin\world, 1


iniRead, epsg, .\PROJ\bin\epsg_DB_1
iniRead, esri, .\PROJ\bin\esri_DB_1

If (Option = 0)
	return epsg
else if (Option = 1)
	return esri
}

proj4_Run(xyzArrIn,epsgInDef,epsgOutDef) {
	If !fileexist(".\PROJ") 
	{
		msgbox, Please run proj4_Init First
		ExitApp
	}
	
	FileCreateDir, .\PROJ\temp
	out:=fileopen(".\PROJ\temp\input.txt", "rw")
	xyzArrOut := object()
	
	loop % xyzArrIn.MaxIndex()
		out.write(xyzArrIn[a_index][1] . a_space . xyzArrIn[a_index][2] . a_space . xyzArrIn[a_index][3] . "`r`n")
	out.close()

	iniRead, epsgIn, .\PROJ\bin\epsg_DB_1, %epsgInDef%, def ;example 4326=longlat
	iniRead, epsgOut, .\PROJ\bin\epsg_DB_1, %epsgOutDef%, def ;example 2228=UTM Zone 10 / WGS84
	
	If (epsgIn = "ERROR")
		iniRead, epsgIn, .\PROJ\bin\esri_DB_1, %epsgInDef%, def
	If (epsgOut = "ERROR")
		iniRead, epsgOut, .\PROJ\bin\esri_DB_1, %epsgOutDef%, def
	
	InfoCode =
		(
		".\PROJ\bin\cs2cs.exe" %epsgIn% +to %epsgOut% .\PROJ\temp\input.txt > .\PROJ\temp\output.txt
		)				;+proj=longlat +ellps=WGS84 +datum=WGS84 +no_defs +to +proj=utm +zone=10 +ellps=WGS84 +datum=WGS84 +units=m +no_defs
	Run, %comspec% /c %InfoCode%, %A_WorkingDir%, Min, proj4
	Process, Wait, %proj4%
	Process, WaitClose, %proj4%

	in:=fileopen(".\PROJ\temp\output.txt", "rw")
loop % xyzArrIn.MaxIndex()
{
	xyzSplitOut := strsplit(in.ReadLine(), [a_tab,a_space], "`r`n")
	, xyzArrOut[a_index]:= [xyzSplitOut[1],xyzSplitOut[2],xyzSplitOut[3]]
}
	in.close()
;~ filedelete, .\PROJ\temp\output.txt
;~ filedelete, .\PROJ\temp\input.txt

return xyzArrOut
}

WMM_Init() {
	FileCreateDir, %A_WorkingDir%\WMM\WMM2015_Windows\bin
	FileCreateDir, %A_WorkingDir%\WMM\WMM2015_Windows\src
	FileInstall, C:\Users\watershed\Google Drive\AHK_Scripts\Cineflex_Ultra_Scripts\WMM\WMM2015_Windows\bin\WMM.COF, %A_WorkingDir%\WMM\WMM2015_Windows\bin\WMM.COF, 1
	FileInstall, C:\Users\watershed\Google Drive\AHK_Scripts\Cineflex_Ultra_Scripts\WMM\WMM2015_Windows\bin\WMM_2010.COF, %A_WorkingDir%\WMM\WMM2015_Windows\bin\WMM_2010.COF, 1
	FileInstall, C:\Users\watershed\Google Drive\AHK_Scripts\Cineflex_Ultra_Scripts\WMM\WMM2015_Windows\bin\WMM_2015.COF, %A_WorkingDir%\WMM\WMM2015_Windows\bin\WMM_2015.COF, 1
	FileInstall, C:\Users\watershed\Google Drive\AHK_Scripts\Cineflex_Ultra_Scripts\WMM\WMM2015_Windows\bin\wmm_file.exe, %A_WorkingDir%\WMM\WMM2015_Windows\bin\wmm_file.exe, 1
}

WMM_Run(xyzprhArr,4Year,2Month,2Day) {
	;XY must be in lat/long format
	If !fileexist(".\WMM") 
	{
		msgbox, Please run WMM_Init First
		ExitApp
	}
	
	workPath := A_WorkingDir . "\WMM\WMM2015_Windows\bin"
	inputPath := A_WorkingDir . "\WMM\WMM2015_Windows\bin\input.txt"
	outputPath := A_WorkingDir . "\WMM\WMM2015_Windows\bin\output.txt"
	
	datetime := 4Year . 2Month . 2Day . 00 . 00 . 00
	
	If (datetime < 20150101000000) {
		FileDelete, %workPath%\WMM.COF
		FileCopy, %workPath%\WMM_2010.COF, %workPath%\WMM.COF, 1
	}
	else if (datetime > 20150101000000 AND datetime < 20200101000000) {
		FileDelete, %workPath%\WMM.COF
		FileCopy, %workPath%\WMM_2015.COF, %workPath%\WMM.COF, 1
	}
	else {
		msgbox, Date range outside of World Magnetic Model tables `n contact David Brandt for update
		ExitApp
	}
	
	formattime, DoY, %datetime%, YDay
	formTime := Round(4Year . "." . SubStr((DoY/366), 3), 3)	
	
	FileDelete, %inputPath%
	FileDelete, %outputPath%
	input:=fileopen(inputPath, "rw")
	xyzprhArrOut := object()
	
	loop % xyzprhArr.MaxIndex() {
		input.write(formTime . " " . "E M" . xyzprhArr[a_index][3] . " " . xyzprhArr[a_index][2] . " " . xyzprhArr[a_index][1] . "`r`n")
	}
	input.close()
	
	InfoCode =
		(
		wmm_file.exe f input.txt output.txt
		)	
	Run, %comspec% /c %InfoCode%, %workPath%, min, wmmNum
	Process, Wait, %wmmNum%
	Process, WaitClose, %wmmNum%
	
	output := fileopen(outputPath, "rw")
	loop % (xyzprhArr.MaxIndex()+1) {
		rawLine := output.ReadLine()
		if (a_index = 1)
			continue
		index := a_index-1
		StringReplace, line, rawLine, %A_Space%    %A_Space%, %A_Space%
		StringReplace, line, line, %A_Space%   %A_Space%, %A_Space%
		StringReplace, line, line, %A_Space%  %A_Space%, %A_Space%
		StringReplace, line, line, %A_Space% %A_Space%, %A_Space%
		StringReplace, line, line, %A_Space%%A_Space%, %A_Space%
		StringReplace, line, line, %A_Space%, %A_Space%
		hSplit := strsplit(line, a_space, "dm`r`n")
		hSplitCombo := hSplit[6] . "." . hSplit[7]
		hSplitCombo := hSplitCombo+0
		xyzprhArrOut[index] := [xyzprhArr[index][1],xyzprhArr[index][2],xyzprhArr[index][3],xyzprhArr[index][4],xyzprhArr[index][5],(xyzprhArr[index][6] + hSplitCombo)]
	}
	
	output.close()
	return xyzprhArrOut
}
	
simpleReplace(inputVar,Original,Replacement) {
	zero := inputVar
	, one := Original
	, two := Replacement
	StringReplace, three, zero, %one%, %two%, All
	return (three)
}

Lerp(p0, p1, t, I) {

	return (((1-(I*t))*p0)+((I*t)*p1))
}

CaspCorrection(x) {
return (Round((x/0.00032808333), 3))
}

proj42Ustation(Orig,toMeter) {
	return (Round((Orig*toMeter*10000),3))
}

UTMCorrection(x) {
return (Round((x*10000), 3))
}

Interpret_Ultra_Meta(csvPath) {
	pi := 4*atan(1)
	csv:=fileopen(csvPath, "rw")
	csvObj:=object()
	
	Loop,
	{
		csvLine:="",		csvLine:=csv.ReadLine()
		;~ listvars
		If (csvLine = "")
			break
		
		If (A_Index = 1)
			continue
		
		Index:=A_Index-1
		preIndex:=A_Index-2
		
		csvRec:="",		csvRec := strsplit(csvLine, A_Tab)
		csvR := csvRec.MaxIndex()
		If (csvRec.MaxIndex() = 0)
			break
		
		Else If (csvRec.MaxIndex() != 54)
		{
			msgbox, problem parsing CSV file at line %A_Index%, # of fields: %csvR%
			ExitApp
		}
		;~ ListVars
		;~ pause
		;~ msgbox % "center Lat: " . csvRec[37] . ", center Lon: " . csvRec[38]
		
		csvObj.UpTime[Index]	:=csvRec[1],
		csvObj.Clock[Index]		:=csvRec[2],
		csvObj.formatT[Index]	:=Round(RegExReplace(RegExReplace(RegExReplace(csvRec[2], ":", ""), a_space, ""), "/", "")),
		csvObj.timeH[Index]		:=csvRec[3],
		csvObj.timeM[Index]		:=csvRec[4],
		csvObj.timeS[Index]		:=csvRec[5],
		csvObj.timeF[Index]		:=csvRec[6],
		csvObj.Lens[Index]		:=csvRec[7],
		csvObj.focusDis[Index]	:=csvRec[8],
		csvObj.focusLen[Index]	:=csvRec[9],
		csvObj.irisStop[Index]	:=csvRec[10],
		csvObj.rawFocus[Index]	:=csvRec[11],
		csvObj.rawZoom[Index]	:=csvRec[12],
		csvObj.rawIris[Index]	:=csvRec[13],
		csvObj.rawFocusMin[Index]:=csvRec[14],
		csvObj.rawFocusMax[Index]:=csvRec[15],
		csvObj.rawZoomMin[Index]:=csvRec[16],
		csvObj.rawZoomMax[Index]:=csvRec[17],
		csvObj.rawIrisMin[Index]:=csvRec[18],
		csvObj.rawIrisMax[Index]:=csvRec[19],
		csvObj.hFOV[Index]		:=csvRec[20],
		csvObj.vFOV[Index]		:=csvRec[21],
		csvObj.cameraH[Index]	:=csvRec[22],
		csvObj.cameraP[Index]	:=csvRec[23],
		csvObj.cameraR[Index]	:=csvRec[24],
		csvObj.cameraLat[Index]	:=csvRec[25],
		csvObj.cameraLon[Index]	:=csvRec[26],
		csvObj.cameraAlt[Index]	:=csvRec[27],
		csvObj.losH[Index]		:=csvRec[28],
		csvObj.losP[Index]		:=csvRec[29],
		csvObj.losR[Index]		:=csvRec[30],
		csvObj.platformH[Index]	:=csvRec[31],
		csvObj.platformP[Index]	:=csvRec[32],
		csvObj.platformR[Index]	:=csvRec[33],
		csvObj.velN[Index]		:=csvRec[34],
		csvObj.velE[Index]		:=csvRec[35],
		csvObj.velD[Index]		:=csvRec[36],
		csvObj.centerLat[Index]	:=csvRec[37],
		csvObj.centerLon[Index]	:=csvRec[38],
		csvObj.centerAlt[Index]	:=csvRec[39],
		csvObj.ulLat[Index]		:=csvRec[40],
		csvObj.ulLon[Index]		:=csvRec[41],
		csvObj.ulAlt[Index]		:=csvRec[42],
		csvObj.urLat[Index]		:=csvRec[43],
		csvObj.urLon[Index]		:=csvRec[44],
		csvObj.urAlt[Index]		:=csvRec[45],
		csvObj.lrLat[Index]		:=csvRec[46],
		csvObj.lrLon[Index]		:=csvRec[47],
		csvObj.lrAlt[Index]		:=csvRec[48],
		csvObj.llLat[Index]		:=csvRec[49],
		csvObj.llLon[Index]		:=csvRec[50],
		csvObj.llAlt[Index]		:=csvRec[51],
		csvObj.slantR[Index]	:=csvRec[52],
		csvObj.base[Index]		:=csvRec[53],
		csvObj.height[Index]	:=csvRec[54],
		
; Interpolate Frame Coordinates

		If (csvObj.centerLat[Index] != csvObj.centerLat[preIndex])
		{
			interpMaxF:=interpIndexF
			If (csvObj.centerLat[Index] = "")
			{
				loop % interpIndexF
				{
					interpIF:=A_Index
					interpHoldF:=Index-interpIndexF
					csvObj.interpMaxF[interpHoldF]		:=interpMaxF,
					csvObj.interpIF[interpHoldF]		:=interpIF,
					csvObj.postcenterLat[interpHoldF]	:=csvObj.centerLat[interpHoldF],
					csvObj.postcenterLon[interpHoldF]	:=csvObj.centerLon[interpHoldF],
					csvObj.postcenterAlt[interpHoldF]	:=csvObj.centerAlt[interpHoldF],
					csvObj.postulLat[interpHoldF]		:=csvObj.ulLat[interpHoldF],
					csvObj.postulLon[interpHoldF]		:=csvObj.ulLon[interpHoldF],
					csvObj.postulAlt[interpHoldF]		:=csvObj.ulAlt[interpHoldF],
					csvObj.posturLat[interpHoldF]		:=csvObj.urLat[interpHoldF],
					csvObj.posturLon[interpHoldF]		:=csvObj.urLon[interpHoldF],
					csvObj.posturAlt[interpHoldF]		:=csvObj.urAlt[interpHoldF],
					csvObj.postlrLat[interpHoldF]		:=csvObj.lrLat[interpHoldF],
					csvObj.postlrLon[interpHoldF]		:=csvObj.lrLon[interpHoldF],
					csvObj.postlrAlt[interpHoldF]		:=csvObj.lrAlt[interpHoldF],
					csvObj.postllLat[interpHoldF]		:=csvObj.llLat[interpHoldF],
					csvObj.postllLon[interpHoldF]		:=csvObj.llLon[interpHoldF],
					csvObj.postllAlt[interpHoldF]		:=csvObj.llAlt[interpHoldF],
					csvObj.postslantR[interpHoldF]		:=csvObj.slantR[interpHoldF],
					csvObj.postBase[interpHoldF]		:=csvObj.base[interpHoldF],
					csvObj.postHeight[interpHoldF]		:=csvObj.height[interpHoldF]
					interpIndexF-=1
				}
				interpIndexF:=1
				continue
			}
			
			loop % interpIndexF
			{
				interpIF:=A_Index
				interpHoldF:=Index-interpIndexF
				csvObj.interpMaxF[interpHoldF]		:=interpMaxF,
				csvObj.interpIF[interpHoldF]		:=interpIF,
				csvObj.postcenterLat[interpHoldF]	:=csvObj.centerLat[Index],
				csvObj.postcenterLon[interpHoldF]	:=csvObj.centerLon[Index],
				csvObj.postcenterAlt[interpHoldF]	:=csvObj.centerAlt[Index],
				csvObj.postulLat[interpHoldF]		:=csvObj.ulLat[Index],
				csvObj.postulLon[interpHoldF]		:=csvObj.ulLon[Index],
				csvObj.postulAlt[interpHoldF]		:=csvObj.ulAlt[Index],
				csvObj.posturLat[interpHoldF]		:=csvObj.urLat[Index],
				csvObj.posturLon[interpHoldF]		:=csvObj.urLon[Index],
				csvObj.posturAlt[interpHoldF]		:=csvObj.urAlt[Index],
				csvObj.postlrLat[interpHoldF]		:=csvObj.lrLat[Index],
				csvObj.postlrLon[interpHoldF]		:=csvObj.lrLon[Index],
				csvObj.postlrAlt[interpHoldF]		:=csvObj.lrAlt[Index],
				csvObj.postllLat[interpHoldF]		:=csvObj.llLat[Index],
				csvObj.postllLon[interpHoldF]		:=csvObj.llLon[Index],
				csvObj.postllAlt[interpHoldF]		:=csvObj.llAlt[Index],
				csvObj.postslantR[interpHoldF]		:=csvObj.slantR[Index],
				csvObj.postBase[interpHoldF]		:=csvObj.base[Index],
				csvObj.postHeight[interpHoldF]		:=csvObj.height[Index],
				interpIndexF-=1
			}
			interpIndexF:=1
		}
		else
			interpIndexF+=1

; Interpolate Camera Coordinates and Angles

		If (csvObj.cameraLat[Index] != csvObj.cameraLat[preIndex])
		{
			interpMaxC:=interpIndexC
			If (csvObj.cameraLat[Index] = "")
			{
				loop % interpIndexC
				{
					interpIC:=A_Index
					interpHoldC:=Index-interpIndexC
					csvObj.interpMaxC[interpHoldC]		:=interpMaxC,
					csvObj.interpIC[interpHoldC]		:=interpIC,
					csvObj.postcameraLat[interpHoldC]	:=csvObj.cameraLat[interpHoldC],
					csvObj.postcameraLon[interpHoldC]	:=csvObj.cameraLon[interpHoldC],
					csvObj.postcameraAlt[interpHoldC]	:=csvObj.cameraAlt[interpHoldC],
					csvObj.postlosH[interpHoldC]		:=csvObj.losH[interpHoldC],
					csvObj.postlosP[interpHoldC]		:=csvObj.losP[interpHoldC],
					csvObj.postlosR[interpHoldC]		:=csvObj.losR[interpHoldC],
					csvObj.postplatformH[interpHoldC]	:=csvObj.platformH[interpHoldC],
					csvObj.postplatformP[interpHoldC]	:=csvObj.platformP[interpHoldC],
					csvObj.postplatformR[interpHoldC]	:=csvObj.platformR[interpHoldC],
					csvObj.postvelN[interpHoldC]		:=csvObj.velN[interpHoldC],
					csvObj.postvelE[interpHoldC]		:=csvObj.velE[interpHoldC],
					csvObj.postvelD[interpHoldC]		:=csvObj.velD[interpHoldC],
					interpIndexC-=1
					 
				}
				interpIndexC:=1
				continue
			}
			loop % interpIndexC
			{
				interpIC:=A_Index
				interpHoldC:=Index-interpIndexC
				csvObj.interpMaxC[interpHoldC]		:=interpMaxC,
				csvObj.interpIC[interpHoldC]		:=interpIC,
				csvObj.postcameraLat[interpHoldC]	:=csvObj.cameraLat[Index],
				csvObj.postcameraLon[interpHoldC]	:=csvObj.cameraLon[Index],
				csvObj.postcameraAlt[interpHoldC]	:=csvObj.cameraAlt[Index],
				csvObj.postlosH[interpHoldC]		:=csvObj.losH[Index],
				csvObj.postlosP[interpHoldC]		:=csvObj.losP[Index],
				csvObj.postlosR[interpHoldC]		:=csvObj.losR[Index],
				csvObj.postplatformH[interpHoldC]	:=csvObj.platformH[Index],
				csvObj.postplatformP[interpHoldC]	:=csvObj.platformP[Index],
				csvObj.postplatformR[interpHoldC]	:=csvObj.platformR[Index],
				csvObj.postvelN[interpHoldC]		:=csvObj.velN[Index],
				csvObj.postvelE[interpHoldC]		:=csvObj.velE[Index],
				csvObj.postvelD[interpHoldC]		:=csvObj.velD[Index],
				interpIndexC-=1				
			}
			interpIndexC:=1
		}
		else
			interpIndexC+=1
			
		;~ msgbox % csvObj.postlosH[a_index] . "," . csvObj.postlosR[a_index] . "," . csvObj.postlosP[a_index]
	}
	;~ msgbox % csvObj.cameraLat[Index] . ","
	csvObj.total := Index
	csv.close
	return (csvObj)
}
PitchRollCorrect(Pitch,Roll,Heading) {
		global 
		
		R := Abs(Roll)
		Ang := sqrt(R**2+Pitch**2)
		AzCorr := (atan((abs(Pitch*0.01745329251))/(abs(R*0.01745329251))))*57.2957795131

		If (Roll > 0 AND Pitch > 0)
			Az := (90-AzCorr)+Heading
		else if (Roll > 0 AND Pitch < 0)
			Az := (90+AzCorr)+Heading
		else if (Roll < 0 AND Pitch < 0)
			Az := (270-AzCorr)+Heading
		else if (Roll < 0 AND Pitch > 0)
			Az := (270+AzCorr)+Heading
		
		If (R < 0)
			Az := Az-((Az-Heading)*2)
		
		If (Az > 360)
			Az := Az-360
		
		PRC := [Az,Ang]
		return (PRC)
	}

FindPointZ_ASCDEM(x,y,z,p,r,h,FoV,columns,rows,xllc,yllc,xurc,yurc,arrayName,Omega,Phi,Kappa,DZ,cellSize:=10,K180:=0,nodata:="") {
	pi := 4*atan(1)
	;~ if !isobject(testOutputf) {
		;~ filedelete, FindPointZ_testOut.txt
		;~ testOutputf := fileopen("FindPointZ_testOut.txt", "rw")
	;~ }
	
	K := K180=180 ? -1 : 1,			;~ set up kappa rotation setting
	r := (r*(K))+Omega, 			;~ set up attitude with boresight rotations
	p := (p*(K))+Phi, 
	h := h+Kappa+K180
	
	If (x > xurc || x < xllc || y > yurc || y < yllc) {				;~ is this positon outside of DEM / if so, go to "NoCoord"
		goto, NoCoord
	}
	
	Corr := PitchRollCorrect(p,r,h)		;~ Interpret PRH values and determine azimuth and angle from origin point
	
	Caz := Corr[1]*(pi/180), 		;~ azimuth of ray to point on ground (north = 0 / south = 180 / clockwise)
	Cang := Corr[2]*(pi/180)		;~ angle from nadir of pitch/roll (0 = nadir / 90 = horizon)
	
	NDY := nodata="" ? 0 : 1
	
	Loop
	{
		If (A_Index = 1)										;~ magnitude of x/y distance on ground (changed to 0.5 to try out bilinear interpolation)
			RmagCount := 1
		else if (a_index = 2)
			RmagCount += (RZDiff*tan(Cang))
		
		If (RZDiff >= 0)
			RmagCount += (RZDiff*tan(Cang))
		else If (RZDiff < 0)
			RmagCount -= (abs(RZDiff)*tan(Cang))
		
		Rmag := RmagCount/2 
		
		RrayZ := z-(Rmag/tan(Cang)), 							;~ z value at point along ray
		RX := x+(((Sin(Caz))*(Rmag))), 							;~ X value of ray point
		RY := y+(((Cos(Caz))*(Rmag))), 							;~ Y value of ray point
		XshiftRup := Ceil((RX-xllc)/cellSize), 					;~ Which column to shift to / left-most X
		YshiftRdown := Ceil((rows)-((RY-yllc)/cellSize)), 	;~ which row to shift to / top-most Y
		XshiftRdown := floor((RX-xllc)/cellSize), 				;~ Which column to shift to / right-most X
		YshiftRup := floor((rows)-((RY-yllc)/cellSize)),		;~ which row to shift to / bottom-most Y
		xLeft := (XshiftRdown*cellSize)+xllc,
		xRight := (XshiftRup*cellSize)+xllc,
		yUpper := (((rows-YshiftRup)*cellSize)+yllc),
		yLower := (((rows-YshiftRdown)*cellSize)+yllc),
		ulRZ := arrayName.dem[XshiftRdown, YshiftRup],
		urRZ := arrayName.dem[XshiftRup, YshiftRup],
		llRZ := arrayName.dem[XshiftRdown, YshiftRdown],
		lrRZ := arrayName.dem[XshiftRup, YshiftRdown],
		RZ := Bilinear_Interpolation_Point(xLeft,xRight,yLower,yUpper,RX,RY,ulRZ,llRZ,urRZ,lrRZ)
		RZDiff := RrayZ-RZ ;~ difference between ray Z value and array Z value at x/y
	} Until (RZDiff <= 0.001 AND RZDiff > -0.001) ;~ is it zero?  then you have found the ground along the ray
	
	;~ taCount += 1
	;~ testArray := taCount . "  " . x . "  " . y . "  " . z . "  " . p . "  " . r . "  " . h . "  " . Corr[1] . "  " . Corr[2] . "  " . Rmag . "  " . RX . "  " . RY . "  " . XshiftRup . "  " . XshiftRdown . "  " . YshiftRup . "  " . YshiftRdown . "  " . xLeft . "  " . xRight . "  " . yUpper . "  " . yLower . "  " . ulRZ . "  " . urRZ . "  " . llRZ . "  " . lrRZ . "  " . RZ . "  " . RZDiff . " "
	;~ testOutputf.Write(testArray)
	
	ABC_Z := [RX,RY,RZ]
	return (ABC_Z)
	
	NoCoord:
	;~ NRange := z-DZ
	;~ Loop ; right side
	;~ {
		;~ Rmag := (cellSize*A_Index), 
		;~ RrayZ := z-(Rmag/tan(CRang)), 
		;~ RX := x+(((Sin(CRaz))*(Rmag))), 
		;~ RY := y+(((Cos(CRaz))*(Rmag))), 
		;~ RZ := arrayName[XshiftR, YshiftR], 
		;~ RZDiff := RrayZ-RZ
	;~ } Until (RZDiff <= 0)
	
	;~ Loop ; left side
	;~ {
		;~ Lmag := (cellSize*A_Index), 
		;~ LrayZ := z-(Lmag/tan(CLang)), 
		;~ LX := x+(((Sin(CLaz))*(Lmag))), 
		;~ LY := y+(((Cos(CLaz))*(Lmag))),
		;~ XshiftL := Round((LX-xllc)/cellSize), 
		;~ YshiftL := Round((rows+5+NDY)-((LY-yllc)/cellSize)), 
		;~ LZ := arrayName[XshiftL, YshiftL], 
		;~ LZDiff := LrayZ-LZ
	;~ } Until (LZDiff <= 0)

	return ("No")
}

Bilinear_Interpolation(xLeft,xRight,yLower,yUpper,valueUL,valueLL,valueUR,valueLR,resolution) {
		grid := object()
		
		stepX := (abs(xLeft-xRight)/resolution)
		stepY := (abs(yLower-yUpper)/resolution)
		
		xScale := 0
		loop % stepX
		{
			++xScale
			X := (xLeft+(resolution*xScale))
			R1 := (((xRight-X)/(xRight-xLeft))*valueLL) + (((X-xLeft)/(xRight-xLeft))*valueLR)
			R2 := (((xRight-X)/(xRight-xLeft))*valueUL) + (((X-xLeft)/(xRight-xLeft))*valueUR)
			
			yScale := 0
			Loop % stepY
			{
				++yScale
				Y := (yLower+(resolution*yScale))
				P := ((yUpper-Y)/(yUpper-yLower))*R1 + ((Y-yLower)/(yUpper-yLower))*R2
				grid[xScale,yScale] := [X,Y,P]
				;~ ListVars
				;~ msgbox
			}
		}
		grid.col := stepX
		grid.row := stepY
		grid.llx := xLeft
		grid.lly := yLower
		grid.res := resolution
		return grid
	}
Bilinear_Interpolation_Point(xLeft,xRight,yLower,yUpper,X,Y,valueUL,valueLL,valueUR,valueLR) {
		
		R1 := (((xRight-X)/(xRight-xLeft))*valueLL) + (((X-xLeft)/(xRight-xLeft))*valueLR)
		, R2 := (((xRight-X)/(xRight-xLeft))*valueUL) + (((X-xLeft)/(xRight-xLeft))*valueUR)
		, P := ((yUpper-Y)/(yUpper-yLower))*R1 + ((Y-yLower)/(yUpper-yLower))*R2
		
		return P
	}
simple_moving_average_filter(arrayName,sampleAmount,sampleNumber,arrayNumber) {
	Loop % ((sampleAmount*2)+1) {
		if (sampleAmount > sampleNumber-1)
			totalMeasured += (arrayName[sampleNumber][arrayNumber])
		else if (sampleAmount > (arrayName.MaxIndex()-(sampleNumber+1)))
			totalMeasured += (arrayName[sampleNumber][arrayNumber])
		else
			totalMeasured += arrayName[(sampleNumber-sampleAmount)+(a_index-1)][arrayNumber]

	}

	return (totalMeasured/((sampleAmount*2)+1))
}
simple_moving_median_filter(arrayName,sampleAmount,sampleNumber,arrayNumber) {
	totalMeasured := ""
	median := ""
	Loop % ((sampleAmount*2)+1) {
		if (a_index < ((sampleAmount*2)+1))
			totalMeasured .= arrayName[(sampleNumber-sampleAmount)+(a_index-1)][arrayNumber] . ","
		else
			totalMeasured .= arrayName[(sampleNumber-sampleAmount)+(a_index-1)][arrayNumber]
	}
	sort totalMeasured, ND,
	StringSplit, totalMeasured, totalMeasured, `,
	median := floor(totalMeasured0 / 2)
	return totalMeasured%median%
	}
Ustation_ZXZ_Rotation(Heading,Pitch,Roll) {
	; takes zyx rotations in degrees (heading, Pitch, Roll) and generates a transposed zxz rotation matrix for use with Microstation MSA animation scripts.
	pi := 4*atan(1),
	toDeg := 180/pi,
	toRad := pi/180
	
	h := Heading*toRad,
	p := ((Pitch+90)*(-1))*toRad,
	r := Roll*toRad
	
	a11 := (cos(h)*cos(r))-(cos(p)*sin(r)*sin(h)),
	a12 := (-sin(h)*cos(r))-(cos(p)*sin(r)*cos(h)),
	a13 := sin(p)*sin(r),
	a21 := (cos(h)*sin(r))+(cos(p)*cos(r)*sin(h)),
	a22 := (-sin(h)*sin(r))+(cos(p)*cos(r)*cos(h)),
	a23 := (-sin(p)*cos(r)),
	a31 := sin(h)*sin(p)
	a32 := cos(h)*sin(p)
	a33 := cos(p)
	
	rot2Msa := a11 . a_tab . a12 . a_tab . a13 . "`r`n" . a21 . a_tab . a22 . a_tab . a23 . "`r`n" . a31 . a_tab . a32 . a_tab . a33
	
	return (rot2Msa)
}

;write/read the INI file for default values
Defaults := FileOpen("Defaults.ini", "rw")
if !IsObject(Defaults)
{
	Defaults := FileOpen("Defaults.ini", "rw")
	
	IniWrite, %A_WorkingDir%, Defaults.ini, Path, Meta
IniWrite, %A_WorkingDir%, Defaults.ini, Path, Jpeg
IniWrite, %A_WorkingDir%, Defaults.ini, Path, Flt
IniWrite, 0, Defaults.ini, Camera, X
IniWrite, 0, Defaults.ini, Camera, Y
IniWrite, 0, Defaults.ini, Camera, Z
IniWrite, 0, Defaults.ini, Camera, H
IniWrite, 0, Defaults.ini, Camera, P
IniWrite, 0, Defaults.ini, Camera, R
IniWrite, 23.98, Defaults.ini, FPA_Dim, H
IniWrite, 13.49, Defaults.ini, FPA_Dim, V
IniWrite, 1.78, Defaults.ini, Aspect_Ratio
IniWrite, 15, Defaults.ini, noiseKernel, X
IniWrite, 15, Defaults.ini, noiseKernel, Y
IniWrite, 15, Defaults.ini, noiseKernel, Z
IniWrite, 15, Defaults.ini, noiseKernel, H
IniWrite, 15, Defaults.ini, noiseKernel, P
IniWrite, 10, Defaults.ini, noiseKernel, R
IniWrite, 5, Defaults.ini, smoothKernel, X
IniWrite, 5, Defaults.ini, smoothKernel, Y
IniWrite, 5, Defaults.ini, smoothKernel, Z
IniWrite, 5, Defaults.ini, smoothKernel, H
IniWrite, 5, Defaults.ini, smoothKernel, P
IniWrite, 5, Defaults.ini, smoothKernel, R
}

IniRead, csvP, Defaults.ini, Path, Meta
IniRead, jpeg1, Defaults.ini, Path, Jpeg
IniRead, fltPath, Defaults.ini, Path, Flt
IniRead, xConstantOrigin, Defaults.ini, Camera, X
IniRead, yConstantOrigin, Defaults.ini, Camera, Y
IniRead, zConstantOrigin, Defaults.ini, Camera, Z
IniRead, hConstantOrigin, Defaults.ini, Camera, H
IniRead, pConstantOrigin, Defaults.ini, Camera, P
IniRead, rConstantOrigin, Defaults.ini, Camera, R
IniRead, hFPA, Defaults.ini, FPA_Dim, H
IniRead, vFPA, Defaults.ini, FPA_Dim, V
IniRead, aspectRatio, Defaults.ini, Aspect_Ratio
IniRead, filterSize1x, Defaults.ini, noiseKernel, X
IniRead, filterSize1y, Defaults.ini, noiseKernel, Y
IniRead, filterSize1z, Defaults.ini, noiseKernel, Z
IniRead, filterSize1h, Defaults.ini, noiseKernel, H
IniRead, filterSize1p, Defaults.ini, noiseKernel, P
IniRead, filterSize1r, Defaults.ini, noiseKernel, R
IniRead, filterSize2x, Defaults.ini, smoothKernel, X
IniRead, filterSize2y, Defaults.ini, smoothKernel, Y
IniRead, filterSize2z, Defaults.ini, smoothKernel, Z
IniRead, filterSize2h, Defaults.ini, smoothKernel, H
IniRead, filterSize2p, Defaults.ini, smoothKernel, P
IniRead, filterSize2r, Defaults.ini, smoothKernel, R

Defaults.close()

WMM_Init()
epsg := simpleReplace(proj4_Init(0),"`n","|"),
esri := simpleReplace(proj4_Init(1),"`n","|"),
epsgArr := strsplit(epsg, "|"),
esriArr := strsplit(esri, "|")

Menu, FileMenu, Add, Advanced, MENUadvanced
Menu, MyMenu, Add, &Settings, :FileMenu
Gui, Menu, MyMenu
Gui, Add, GroupBox, x6 y7 w460 h160 , File Inputs
Gui, Add, Text, x16 y27 w150 h20 , Select metadata CSV from Ultra
Gui, Add, Edit, x16 y47 w370 h20 vcsvP, %csvP%
Gui, Add, Button, x396 y47 w60 h20 gbrowseC, Browse
Gui, Add, Text, x16 y73 w270 h20 , Select the first extracted JPEG from Ultra clip sequence
Gui, Add, Edit, x16 y93 w370 h20 vjpeg1, %jpeg1%
Gui, Add, Button, x396 y93 w60 h20 gbrowseJ, Browse
Gui, Add, Text, x16 y117 w270 h20 , Select DEM file in USGS Float (FLT) format
Gui, Add, Edit, x16 y137 w370 h20 vfltPath, %fltPath%
Gui, Add, Button, x396 y137 w60 h20 gbrowseF, Browse
Gui, Add, ListBox, x16 y255 w370 h134 vepsgOut gepsgChoose, %epsg%
Gui, Add, ListBox, x15 y416 w370 h134 vesriOut gesriChoose, %esri%
Gui, Add, Text, x16 y175 w370 h20 , Select Output Projection / Units
Gui, Add, Button, x396 y255 w70 h30 gCancel, Cancel
Gui, Add, Button, x396 y295 w70 h30 gOK, OK
Gui, Add, Progress, x15 y558 w370 h10 vMyProgress -Smooth, 10
Gui, Add, Text, x16 y575 w370 h20 vProgressText, Setup...
Gui, Add, Button, x396 y205 w70 h20 gsearch, Search
Gui, Add, Edit, x16 y205 w370 h20 vfilterSearch, Filter by Search Terms
Gui, Add, Text, x16 y235 w150 h20 , EPSG Projections
Gui, Add, Text, x16 y395 w150 h20 , ESRI Projections
; Generated using SmartGUI Creator 4.0
Gui, Show, x131 y91 h608 w479, Ultra 2 MSA V1.0
Return

MENUadvanced:
Gui +OwnDialogs
Gui, Submit, NoHide
GoSub, advanced
return

epsgChoose:
Gui, submit, nohide
GuiControl, Choose, esriOut, 0
return

esriChoose:
Gui, submit, nohide
GuiControl, Choose, epsgOut, 0
return

browseC:
FileSelectFile, csvP, 3, %csvP%, Select metadata CSV from Cineflex GEO+ module, CSV file (*.csv)
If (csvP = "") {
	GuiControl, , csvP, No Selected File
	return
} else {
	GuiControl, , csvP, %csvP%
	return
}

browseJ:
FileSelectFile, jpeg1, 3, %jpeg1%, Select the first extracted JPEG from Ultra clip sequence, JPEG file (*.jpg; *.jpeg)
If (jpeg1 = "") {
	GuiControl, , jpeg1, No Selected File
	return
} else {
	GuiControl, , jpeg1, %jpeg1%
	return
}

browseF:
FileSelectFile, fltPath, 3, %fltPath%, Select DEM file covering filmed area, Float grid file (*.flt)
If (fltPath = "") {
	GuiControl, , fltPath, No Selected File
	return
} else {
	GuiControl, , fltPath, %fltPath%
	return
}

search:
Gui, submit, nohide
filter := StrSplit(filterSearch, a_space),
resultArrEPSG := listSearch(filter,epsgArr),
resultArrESRI := listSearch(filter,esriArr), 
resultVarEPSG := "|",
resultVarESRI := "|",
loop % resultArrEPSG.maxindex()
	resultVarEPSG .= "|" . resultArrEPSG[a_index]
loop % resultArrESRI.maxindex()
	resultVarESRI .= "|" . resultArrESRI[a_index]
GuiControl, -Redraw, epsgOut
GuiControl, , epsgOut, %resultVarEPSG%
GuiControl, +Redraw, epsgOut
GuiControl, -Redraw, esriOut
GuiControl, , esriOut, %resultVarESRI%
GuiControl, +Redraw, esriOut
return

advanced:
Gui, adv:New
Gui, adv:Add, GroupBox, x26 y7 w310 h220 , Installation Parameters
Gui, adv:Add, Text, x36 y27 w110 h20 , Camera X Adjustment
Gui, adv:Add, Text, x36 y47 w110 h20 , Camera Y Adjustment
Gui, adv:Add, Text, x36 y67 w110 h20 , Camera Z Adjustment
Gui, adv:Add, Text, x36 y87 w140 h20 , Camera Heading Adjustment
Gui, adv:Add, Text, x36 y107 w130 h20 , Camera Pitch Adjustment
Gui, adv:Add, Text, x36 y127 w120 h20 , Camera Roll Adjustment
Gui, adv:Add, Text, x36 y147 w130 h20 , FPA Horizontal Dimension
Gui, adv:Add, Text, x36 y167 w120 h20 , FPA Vertical Dimension
Gui, adv:Add, Text, x36 y187 w70 h20 , Aspect Ratio
Gui, adv:Add, Text, x276 y27 w40 h20 , meters
Gui, adv:Add, Text, x276 y47 w40 h20 , meters
Gui, adv:Add, Text, x276 y67 w40 h20 , meters
Gui, adv:Add, Text, x276 y87 w40 h20 , degrees
Gui, adv:Add, Text, x276 y107 w40 h20 , degrees
Gui, adv:Add, Text, x276 y127 w40 h20 , degrees
Gui, adv:Add, Text, x276 y147 w50 h20 , millimeters
Gui, adv:Add, Text, x276 y167 w50 h20 , millimeters
Gui, adv:Add, Edit, x216 y27 w60 h20 vxConstantOrigin, %xConstantOrigin%
Gui, adv:Add, Edit, x216 y47 w60 h20 vyConstantOrigin, %yConstantOrigin%
Gui, adv:Add, Edit, x216 y67 w60 h20 vzConstantOrigin, %zConstantOrigin%
Gui, adv:Add, Edit, x216 y87 w60 h20 vhConstantOrigin, %hConstantOrigin%
Gui, adv:Add, Edit, x216 y107 w60 h20 vpConstantOrigin, %pConstantOrigin%
Gui, adv:Add, Edit, x216 y127 w60 h20 vrConstantOrigin, %rConstantOrigin%
Gui, adv:Add, Edit, x216 y147 w60 h20 vhFPA, %hFPA%
Gui, adv:Add, Edit, x216 y167 w60 h20 vvFPA, %vFPA%
Gui, adv:Add, Edit, x216 y187 w60 h20 vaspectRatio, %aspectRatio%
Gui, adv:Add, GroupBox, x26 y227 w310 h170 , Noise Filter Parameters
Gui, adv:Add, Text, x36 y257 w110 h20 , Kernel Size X
Gui, adv:Add, Text, x36 y277 w110 h20 , Kernel Size Y
Gui, adv:Add, Text, x36 y297 w110 h20 , Kernel Size Z
Gui, adv:Add, Text, x36 y317 w110 h20 , Kernel Size Heading
Gui, adv:Add, Text, x36 y337 w110 h20 , Kernel Size Pitch
Gui, adv:Add, Text, x36 y357 w110 h20 , Kernel Size Roll
Gui, adv:Add, Edit, x216 y257 w60 h20 vfilterSize1x, %filterSize1x%
Gui, adv:Add, Edit, x216 y277 w60 h20 vfilterSize1y, %filterSize1y%
Gui, adv:Add, Edit, x216 y297 w60 h20 vfilterSize1z, %filterSize1z%
Gui, adv:Add, Edit, x216 y317 w60 h20 vfilterSize1h, %filterSize1h%
Gui, adv:Add, Edit, x216 y337 w60 h20 vfilterSize1p, %filterSize1p%
Gui, adv:Add, Edit, x216 y357 w60 h20 vfilterSize1r, %filterSize1r%
Gui, adv:Add, GroupBox, x26 y397 w310 h170 , Smoothing Filter Parameters
Gui, adv:Add, Text, x36 y427 w110 h20 , Kernel Size X
Gui, adv:Add, Text, x36 y447 w110 h20 , Kernel Size Y
Gui, adv:Add, Text, x36 y467 w110 h20 , Kernel Size Z
Gui, adv:Add, Text, x36 y487 w110 h20 , Kernel Size Heading
Gui, adv:Add, Text, x36 y507 w110 h20 , Kernel Size Pitch
Gui, adv:Add, Text, x36 y527 w110 h20 , Kernel Size Roll
Gui, adv:Add, Edit, x216 y427 w60 h20 vfilterSize2x, %filterSize2x%
Gui, adv:Add, Edit, x216 y447 w60 h20 vfilterSize2y, %filterSize2y%
Gui, adv:Add, Edit, x216 y467 w60 h20 vfilterSize2z, %filterSize2z%
Gui, adv:Add, Edit, x216 y487 w60 h20 vfilterSize2h, %filterSize2h%
Gui, adv:Add, Edit, x216 y507 w60 h20 vfilterSize2p, %filterSize2p%
Gui, adv:Add, Edit, x216 y527 w60 h20 vfilterSize2r, %filterSize2r%
Gui, adv:Add, Button, x156 y577 w80 h30 gadvApply, Apply
Gui, adv:Add, Button, x256 y577 w80 h30 gadvCancel, Cancel
; Generated using SmartGUI Creator 4.0
Gui, Show, x131 y91 h625 w374, Advanced Settings
Return

advApply:
Gui, Submit, nohide
Gui, adv:Destroy
return

advCancel:
advGuiClose:
Gui, adv:Destroy
return


GuiClose:
Cancel:
ExitApp


OK:
Gui, Submit, nohide

Defaults := FileOpen("Defaults.ini", "rw")	

IniDelete, Defaults.ini, Path, Meta
IniDelete, Defaults.ini, Path, Jpeg
IniDelete, Defaults.ini, Path, Flt
IniDelete, Defaults.ini, Camera, X
IniDelete, Defaults.ini, Camera, Y
IniDelete, Defaults.ini, Camera, Z
IniDelete, Defaults.ini, Camera, H
IniDelete, Defaults.ini, Camera, P
IniDelete, Defaults.ini, Camera, R
IniDelete, Defaults.ini, FPA_Dim, H
IniDelete, Defaults.ini, FPA_Dim, V
IniDelete, Defaults.ini, Aspect_Ratio
IniDelete, Defaults.ini, noiseKernel, X
IniDelete, Defaults.ini, noiseKernel, Y
IniDelete, Defaults.ini, noiseKernel, Z
IniDelete, Defaults.ini, noiseKernel, H
IniDelete, Defaults.ini, noiseKernel, P
IniDelete, Defaults.ini, noiseKernel, R
IniDelete, Defaults.ini, smoothKernel, X
IniDelete, Defaults.ini, smoothKernel, Y
IniDelete, Defaults.ini, smoothKernel, Z
IniDelete, Defaults.ini, smoothKernel, H
IniDelete, Defaults.ini, smoothKernel, P
IniDelete, Defaults.ini, smoothKernel, R
IniWrite, %csvP%, Defaults.ini, Path, Meta
IniWrite, %jpeg1%, Defaults.ini, Path, Jpeg
IniWrite, %fltPath%, Defaults.ini, Path, Flt
IniWrite, %xConstantOrigin%, Defaults.ini, Camera, X
IniWrite, %yConstantOrigin%, Defaults.ini, Camera, Y
IniWrite, %zConstantOrigin%, Defaults.ini, Camera, Z
IniWrite, %hConstantOrigin%, Defaults.ini, Camera, H
IniWrite, %pConstantOrigin%, Defaults.ini, Camera, P
IniWrite, %rConstantOrigin%, Defaults.ini, Camera, R
IniWrite, %hFPA%, Defaults.ini, FPA_Dim, H
IniWrite, %vFPA%, Defaults.ini, FPA_Dim, V
IniWrite, %aspectRatio%, Defaults.ini, Aspect_Ratio
IniWrite, %filterSize1x%, Defaults.ini, noiseKernel, X
IniWrite, %filterSize1y%, Defaults.ini, noiseKernel, Y
IniWrite, %filterSize1z%, Defaults.ini, noiseKernel, Z
IniWrite, %filterSize1h%, Defaults.ini, noiseKernel, H
IniWrite, %filterSize1p%, Defaults.ini, noiseKernel, P
IniWrite, %filterSize1r%, Defaults.ini, noiseKernel, R
IniWrite, %filterSize2x%, Defaults.ini, smoothKernel, X
IniWrite, %filterSize2y%, Defaults.ini, smoothKernel, Y
IniWrite, %filterSize2z%, Defaults.ini, smoothKernel, Z
IniWrite, %filterSize2h%, Defaults.ini, smoothKernel, H
IniWrite, %filterSize2p%, Defaults.ini, smoothKernel, P
IniWrite, %filterSize2r%, Defaults.ini, smoothKernel, R

Defaults.close()


;**************************************************************************************************************
;~ fltPath := "E:\Sandpiper_Enbridge_Resources\North_America_Geographic_3arcsec_ND_MN_to_UTM13.flt"
;~ fovConstant := 0
;~ xConstantOrigin := 0  ;1.285
;~ yConstantOrigin := 0  ;-5.5
;~ zConstantOrigin := -5 ;-5

;~ pConstantOrigin := 1.8 ;~ in deg / potential pitch boresight = +1.8
;~ rConstantOrigin := 0 ;~ in deg
;~ hConstantOrigin := (2.89) ;~ in deg / -6 for clip131 (2.84 actual) / -1.5 for Clip104 (7.84 actual) / (East declination is positive (clockwise) rotation ; West declination is negative (counter-clockwise) rotation) / Heading Boresight = -9.2

;~ xConstantTarget := 0  ;1.285
;~ yConstantTarget := 0  ;-5.5
;~ zConstantTarget := 0 ;11

;~ filterSize1r := 10
;~ filterSize2r := 5
;~ filterSize1p := 15
;~ filterSize2p := 5
;~ filterSize1h := 15
;~ filterSize2h := 5
;~ filterSize1x := 15
;~ filterSize2x := 5
;~ filterSize1y := 15
;~ filterSize2y := 5
;~ filterSize1z := 15
;~ filterSize2z := 5
pi := 4*atan(1)
matrixOut := 0 ;~ 1 = yes / 0 = no
;**************************************************************************************************************

If (epsgOut = "")
	proj4Out := esriOut
else If (esriOut = "")
	proj4Out := epsgOut

toMeter := 1
If instr( proj4Out,"+to_meter=")
{
	toMeterSpot := instr(proj4Out,"+to_meter=")
	toMeter := substr(proj4Out,(toMeterSpot+10),6)
}

SplitPath, csvP, wExt, Dir, Ext, noExt
MSAf = %Dir%\%noExt%_Camera_Transform.msa
FileDelete, %MSAf%
MSAfile:=fileopen(MSAf, "w")
MSAhead = 
(
MS-ANI-V0
view_number 1
script_scale 1.000000

setting render
 background_file %jpeg1%
 frame 0.000000
 interpolation linear
 velocity constant
end

setting render
 background_increment 1.00000
 frame 0.000000
 interpolation linear
 velocity constant
end

camera_transform CAMTRANSFORM
 interpolation linear


)
MSAfile.write(MSAhead)

Guicontrol, , MyProgress, 20
Guicontrol, , ProgressText, Reading Geo+ Metadata

ultraC:=Interpret_Ultra_Meta(csvP)

Guicontrol, , MyProgress, 30
Guicontrol, , ProgressText, Reading FLT array

floatArray := Read_FLT4Array_Object(fltPath)

Guicontrol, , MyProgress, 40
Guicontrol, , ProgressText, Interpolating Positions / Orientations

Cen := []
Cam := []

loop % ultraC.total {
	If (a_index != 1) {
		Camlat:=Lerp(ultraC.cameraLat[a_index], ultraC.postcameraLat[a_index], (1/(ultraC.interpMaxC[a_index])), ultraC.interpIC[a_index])
		, Camlon:=Lerp(ultraC.cameraLon[a_index], ultraC.postcameraLon[a_index], (1/(ultraC.interpMaxC[a_index])), ultraC.interpIC[a_index])
		, Camalt:=Lerp(ultraC.cameraAlt[a_index], ultraC.postcameraAlt[a_index], (1/(ultraC.interpMaxC[a_index])), ultraC.interpIC[a_index])
		, Cenlat:=Lerp(ultraC.centerLat[a_index], ultraC.postcenterLat[a_index], (1/(ultraC.interpMaxF[a_index])), ultraC.interpIF[a_index])
		, Cenlon:=Lerp(ultraC.centerLon[a_index], ultraC.postcenterLon[a_index], (1/(ultraC.interpMaxF[a_index])), ultraC.interpIF[a_index])
		, Cenalt:=Lerp(ultraC.centerAlt[a_index], ultraC.postcenterAlt[a_index], (1/(ultraC.interpMaxF[a_index])), ultraC.interpIF[a_index])
		, CamH:=Lerp(ultraC.losH[a_index], ultraC.postlosH[a_index], (1/(ultraC.interpMaxC[a_index])), ultraC.interpIC[a_index])
		, CamR:=Lerp(ultraC.losR[a_index], ultraC.postlosR[a_index], (1/(ultraC.interpMaxC[a_index])), ultraC.interpIC[a_index])
		, CamP:=(Lerp(ultraC.losP[a_index], ultraC.postlosP[a_index], (1/(ultraC.interpMaxC[a_index])), ultraC.interpIC[a_index]))
		, Cen[a_index] := [Cenlon,Cenlat,Cenalt]
		, Cam[a_index] := [Camlon,Camlat,Camalt,CamP,CamR,CamH]
	} else {
		Camlat:=ultraC.cameraLat[a_index],
		Camlon:=ultraC.cameraLon[a_index],
		Camalt:=ultraC.cameraAlt[a_index],
		Cenlat:=ultraC.centerLat[a_index],
		Cenlon:=ultraC.centerLon[a_index],
		Cenalt:=ultraC.centerAlt[a_index],
		CamH:=ultraC.losH[a_index],
		CamR:=ultraC.losR[a_index],
		CamP:=ultraC.losP[a_index],
		Cen[a_index] := [Cenlon,Cenlat,Cenalt],
		Cam[a_index] := [Camlon,Camlat,Camalt,CamP,CamR,CamH]
	}

}

Guicontrol, , MyProgress, 45
Guicontrol, , ProgressText, Adjust for magnetic declination

formTime := ultraC.formatT[1]
formattime, Year, %formTime%, yyyy
formattime, Month, %formTime%, MM
formattime, Day, %formTime%, dd
camMag := WMM_Run(Cam,Year,Month,Day)

Guicontrol, , MyProgress, 50
Guicontrol, , ProgressText, Filtering RAW data - pass 1

newCampass1 := object()
newCampass2 := object()

loop % ultraC.total {
	fCamX := simple_moving_average_filter(camMag,filterSize1x,a_index,1),
	fCamY := simple_moving_average_filter(camMag,filterSize1y,a_index,2),
	fCamZ := simple_moving_average_filter(camMag,filterSize1z,a_index,3),
	fCamP := simple_moving_average_filter(camMag,filterSize1p,a_index,4),
	fCamR := simple_moving_median_filter(camMag,filterSize1r,a_index,5),
	fCamH := simple_moving_average_filter(camMag,filterSize1h,a_index,6)

	newCampass1[a_index] := [fCamX,fCamY,fCamZ,fCamP,fCamR,fCamH]
}

;~ msgbox % newCampass1[10][1] . "," . newCampass1[10][2] . "," . newCampass1[10][3] . "," . newCampass1[10][4] . "," . newCampass1[10][5] . "," . newCampass1[10][6]

Guicontrol, , MyProgress, 50
Guicontrol, , ProgressText, Filtering RAW data - pass 2

fCamX := 0,
fCamY := 0,
fCamZ := 0,
fCamP := 0,
fCamR := 0,
fCamH := 0

loop % newCampass1.maxindex() {
	fCamX := simple_moving_average_filter(newCampass1,filterSize2x,a_index,1),
	fCamY := simple_moving_average_filter(newCampass1,filterSize2y,a_index,2),
	fCamZ := simple_moving_average_filter(newCampass1,filterSize2z,a_index,3),
	fCamP := simple_moving_average_filter(newCampass1,filterSize2p,a_index,4),
	fCamR := simple_moving_average_filter(newCampass1,filterSize2r,a_index,5),
	fCamH := simple_moving_average_filter(newCampass1,filterSize2h,a_index,6)
	
	newCampass2[a_index] := [fCamX,fCamY,fCamZ,fCamP,fCamR,fCamH]
}


Guicontrol, , MyProgress, 55
Guicontrol, , ProgressText, Generating Camera Rotation Matrices 

rotMatrix := []
loop % ultraC.total {
	rotMatrix[a_index] := Ustation_ZXZ_Rotation(newCampass2[a_index][6]+hConstantOrigin,newCampass2[a_index][4]+pConstantOrigin,newCampass2[a_index][5]+rConstantOrigin)
}

Guicontrol, , MyProgress, 60
Guicontrol, , ProgressText, Reprojecting Camera Positions

camOut := proj4_Run(newCampass2,"WGS 84",proj4Out)

Guicontrol, , MyProgress, 70
Guicontrol, , ProgressText, Ray tracing camera targets

returnTarget := []

loop % ultraC.total {
	returnTarget[a_index] := FindPointZ_ASCDEM((camOut[a_index][1]+xConstantOrigin),(camOut[a_index][2]+yConstantOrigin),(camOut[a_index][3]+zConstantOrigin),(newCampass2[a_index][4]+90+pConstantOrigin),(newCampass2[a_index][5]+rConstantOrigin),(newCampass2[a_index][6]+hConstantOrigin),0,floatArray.CLMN,floatArray.ROWS,floatArray.XLLC,floatArray.YLLC,floatArray.XURC,floatArray.YURC,floatArray,0,0,0,0,floatArray.Csize,0,floatArray.NODATA)
}

Guicontrol, , MyProgress, 80
Guicontrol, , ProgressText, Smoothing targetting

smoothTarget := []

loop % ultraC.total {
	sTargetx := simple_moving_average_filter(returnTarget,filterSize,a_index,1)
	sTargety := simple_moving_average_filter(returnTarget,filterSize,a_index,2)
	sTargetz := simple_moving_average_filter(returnTarget,filterSize,a_index,3)
	
	smoothTarget[a_index] := [sTargetx,sTargety,sTargetz]
}
	
Guicontrol, , MyProgress, 90
Guicontrol, , ProgressText, Writing MSA script
;(newCam[a_index][5]+rConstantOrigin)  actual roll value
loop % ultraC.total {	
	CamY:=proj42Ustation((camOut[a_index][2]+yConstantOrigin),toMeter)
	CamX:=proj42Ustation((camOut[a_index][1]+xConstantOrigin),toMeter)
	CamZ:=proj42Ustation((camOut[a_index][3]+zConstantOrigin),toMeter)
	
	CenY:=proj42Ustation((smoothTarget[a_index][2]),toMeter)
	CenX:=proj42Ustation((smoothTarget[a_index][1]),toMeter)
	CenZ:=proj42Ustation((smoothTarget[a_index][3]),toMeter)
	
	hFOV := (2*atan(hFPA/(2*ultraC.focusLen[a_index])))
	vFOV := (2*atan(vFPA/(2*ultraC.focusLen[a_index])))

	;~ Write a "test output" for diagnostic purposes
	;~ if !isobject(testOutputf) {
		;~ filedelete, FindPointZ_testOut.txt
		;~ testOutputf := fileopen("FindPointZ_testOut.txt", "rw")
	;~ }
	
	;~ testOutputf.Write(A_Index . "," . CamX . "," . CamY . "," . CamZ . "," . CenX . "," . CenY . "," . CenZ . "`n")
	
	rotation := rotMatrix[a_index]
	frameNum := a_index-1

Frame =	;target point command: target_point %CenX% %CenY% %CenZ%
(	
 frame %frameNum%
 origin %CamX% %CamY% %CamZ%
 rotation
%rotation%
 camera_angle %hFOV%
 aspect_ratio %aspectRatio%
 view_offset 0.00, 0.00
 view_size 150000.000000
 front_clip 10000.000000
 back_clip 4000000.000000
 
 
 )
	MSAfile.write(Frame)
}

Guicontrol, , MyProgress,100
Guicontrol, , ProgressText, Done!

Sleep, 1000
MSAfile.write("end")
MSAfile.Close()
testOutputf.close()
exitapp

