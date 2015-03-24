; Set up for PARGE batch orthorectification script

SetBatchLines, -1
#NoEnv
#maxmem 256

; Functions and INI Set up
;***********************************************************************************************
StringSort(a1, a2)
{
	splitpath, a1, , , , as1
	splitpath, a2, , , , as2
	asn1:=strsplit(as1, "_")
	asn2:=strsplit(as2, "_")
	
    return asn1[2] > asn2[2] ? 1 : asn1[2] < asn2[2] ? -1 : 0  ; Sorts alphabetically based on the setting of StringCaseSense.
}

Defaults := FileOpen("Defaults.ini", "r")
if !IsObject(Defaults)
{
	Defaults := FileOpen("Defaults.ini", "rw")
	IniWrite, %A_WorkingDir%, Defaults.ini, pargePath
	IniWrite, %A_WorkingDir%, Defaults.ini, cubePath
	IniWrite, %A_WorkingDir%, Defaults.ini, syncPath
	IniWrite, %A_WorkingDir%, Defaults.ini, navPath
	IniWrite, %A_WorkingDir%, Defaults.ini, borePath
	IniWrite, %A_WorkingDir%, Defaults.ini, demPath
	IniWrite, %A_WorkingDir%, Defaults.ini, outPath
	
	IniWrite, 0, Defaults.ini, rollPos
	IniWrite, 1, Defaults.ini, rollNeg
	IniWrite, 1, Defaults.ini, pitchPos
	IniWrite, 0, Defaults.ini, pitchNeg
	IniWrite, 1, Defaults.ini, headPos
	IniWrite, 0, Defaults.ini, headNeg
	
	IniWrite, 1, Defaults.ini, convertPrj
	IniWrite, 0, Defaults.ini, utmZone
	IniWrite, -9999.0, Defaults.ini, missing
	IniWrite, 0.5, Defaults.ini, outRes
	IniWrite, 25.37, Defaults.ini, FoV
}
IniRead, pargePath, Defaults.ini, pargePath
IniRead, cubeFiles, Defaults.ini, cubePath
IniRead, syncFiles, Defaults.ini, syncPath
IniRead, navFile, Defaults.ini, navPath
IniRead, boreFile, Defaults.ini, borePath
IniRead, demFile, Defaults.ini, demPath
IniRead, outDir, Defaults.ini, outPath

IniRead, rollPos, Defaults.ini, rollPos
IniRead, rollNeg, Defaults.ini, rollNeg
IniRead, pitchPos, Defaults.ini, pitchPos
IniRead, pitchNeg, Defaults.ini, pitchNeg
IniRead, headPos, Defaults.ini, headPos
IniRead, headNeg, Defaults.ini, headNeg

IniRead, convertPrj, Defaults.ini, convertPrj
IniRead, utmZone, Defaults.ini, utmZone
IniRead, missing, Defaults.ini, missing
IniRead, outRes, Defaults.ini, outRes
IniRead, FoV, Defaults.ini, FoV


Defaults.close()
Defaults := FileOpen("Defaults.ini", "rw")

; GUI Set up
;***********************************************************************************************

Gui, Add, GroupBox,			x6 y7 w400 h380 ,							Inputs
{
	Gui, Add, Text,				x16 y27 w300 h20 , 							Select the "parge.sav" file from installation directory
	{
		Gui, Add, Edit,				x16 y47 w310 h20 vpargePath,							%pargePath%
		Gui, Add, Button,			x336 y47 w60 h20 gB_pargePath ,							Browse
	}
	Gui, Add, Text,				x16 y77 w300 h20 ,							Select RAW data cubes from mission directory
	{
		Gui, Add, Edit,				x16 y97 w310 h20 vcubeFiles,							%cubeFiles%
		Gui, Add, Button,			x336 y97 w60 h20 gB_cubeFiles,							Browse
	}
	Gui, Add, Text,				x16 y127 w300 h20 ,							Select corresponding "frameIndex" files from mission directory
	{
		Gui, Add, Edit,				x16 y147 w310 h20 vsyncFiles,							%syncFiles%
		Gui, Add, Button,			x336 y147 w60 h20 gB_syncFiles,							Browse
	}
	Gui, Add, Text,				x16 y177 w300 h20 ,							Select imu_gps.txt file for correct camera
	{
		Gui, Add, Edit,				x16 y197 w310 h20 vnavFile,								%navFile%
		Gui, Add, Button,			x336 y197 w60 h20 gB_navFile,							Browse
	}
	Gui, Add, Text,				x16 y227 w300 h20 ,							Select corresponding boresight file
	{
		Gui, Add, Edit,				x16 y247 w310 h20 vboreFile, 							%boreFile%
		Gui, Add, Button, 			x336 y247 w60 h20 gB_boreFile, 							Browse
	}
	Gui, Add, Text,				x16 y277 w300 h20 , 						Select corresponding DEM for AOI
	{
		Gui, Add, Edit, 			x16 y297 w310 h20 vdemFile, 							%demFile%
		Gui, Add, Button, 			x336 y297 w60 h20 gB_demFile, 							Browse
	}
	Gui, Add, Text, 			x16 y327 w300 h20 , 						Select output directory
	{
		Gui, Add, Edit, 			x16 y347 w310 h20 voutDir, 								%outDir%
		Gui, Add, Button, 			x336 y347 w60 h20 gB_outDir, 							Browse
	}
}
Gui, Add, GroupBox, 		x6 y397 w400 h230 , 						Settings
{

	Gui, Add, Text, 			x16 y417 w70 h30 , 							Image Attitude Parameters:
	{
		Gui, Add, GroupBox, 		x96 y407 w100 h70 , 								Roll
		{
			Gui, Add, Radio, 			x106 y427 w80 h20 vrollPos +Checked%rollPos%, 						Right Up
			Gui, Add, Radio, 			x106 y447 w80 h20 vrollNeg +Checked%rollNeg%, 						Right Down
		}
		Gui, Add, GroupBox, 		x196 y407 w100 h70 , 								Pitch
		{
			Gui, Add, Radio, 			x206 y427 w80 h20 vpitchPos +Checked%pitchPos%, 					Nose Up
			Gui, Add, Radio, 			x206 y447 w80 h20 vpitchNeg +Checked%pitchNeg%, 					Nose Down
		}
		Gui, Add, GroupBox, 		x296 y407 w100 h70 , 								Heading
		{
			Gui, Add, Radio, 			x306 y427 w80 h20 vheadPos +Checked%headPos%, 						+ North East
			Gui, Add, Radio, 			x306 y447 w80 h20 vheadNeg +Checked%headNeg%, 						- North East
		}
	}
	Gui, Add, Text, 			x16 y487 w110 h20 , 						Projection:
		Gui, Add, DropDownList, 	x150 y487 w96 h20 vconvertPrj gZ_convertPrj +Choose%convertPrj% +AltSubmit +R6, 				Arbitrary|UTM|Gauss-Krueger|Gauss-Boaga|US State Plane|Swiss
	Gui, Add, Text, 			x256 y487 w30 h20 , 						Zone:
		Gui, Add, DropDownList, 	x297 y487 w100 h10 vutmzone +R8,
	Gui, Add, Text, 			x16 y517 w140 h20 , 						DEM "NoData" Value:
		Gui, Add, Edit, 			x166 y517 w80 h20 vmissing, 					%missing%
	Gui, Add, Text, 			x16 y547 w110 h20 , 						Output Resolution:
		Gui, Add, Edit, 			x166 y547 w80 h20 voutRes, 						%outRes%
	Gui, Add, Text, 			x16 y577 w110 h20 , 						Field of View:
		Gui, Add, Edit, 			x166 y577 w80 h20 vFoV, 						%FoV%
}
Gui, Add, Button, 			x196 y647 w100 h30 gB_Launch, 				Launch
Gui, Add, Button, 			x306 y647 w100 h30 gB_Cancel, 				Cancel
Gui, Show, 					x45 y45 h689 w415, 							PARGE Batch Launcher V1.0
gosub, Z_convertPrj
Return



B_pargePath:
FileSelectFile, pargePath, 3, %pargePath%, Select the "parge.sav" file, (*.sav)
Guicontrol, , pargePath, %pargePath%
return

B_cubeFiles:
FileSelectFile, cubeFiles, M3, %cubeFiles%, Select RAW data cubes for processing
guicontrol, , cubeFiles, %cubeFiles%
return

B_syncFiles:
FileSelectFile, syncFiles, M3, %syncFiles%, select corresponding "frameIndex" files, (*.txt)
guicontrol, , syncFiles, %syncFiles%
return

B_navFile:
FileSelectFile, navFile, 3, %navFile%, Select imu_gps.txt file for correct camera, (*.txt)
guicontrol, , navFile, %navFile%
return

B_boreFile:
FileSelectFile, boreFile, 3, %boreFile%, Select corresponding boresight file, (*.gcs)
guicontrol, , boreFile, %boreFile%
return

B_demFile:
FileSelectFile, demFile, 3, %demFile%, Select corresponding DEM for AOI, (*.asc)
guicontrol, , demFile, %demFile%
return

B_outDir:
FileSelectFolder, outDir, *%outDir% , 3, Select output directory
guicontrol, , outDir, %outDir%
return

Z_convertPrj:
Gui, submit, nohide
If (convertPrj = 1)
	Guicontrol, , utmzone, |
else if (convertPrj = 2)
	Guicontrol, , utmzone, |1|2|3|4|5|6|7|8|9|10|11|12|13|14|15|16|17|18|19|20|21|22|23|24|25|26|27|28|29|30|31|32|33|34|35|36|37|38|39|40|41|42|43|44|45|46|47|48|49|50|51|52|53|54|55|56|57|58|59|60|
else if (convertPrj = 3)
	Guicontrol, , utmzone, |1|2|3|4|5|6|
else if (convertPrj = 4)
	Guicontrol, , utmzone, |1|2|
else if (convertPrj = 5)
	Guicontrol, , utmzone, |0101||0102|0201|0202|0203|0301|0302|0401|0402|0403|0404|0405|0406|0407|0501|0502|0503|0600|0700|0901|0902|0903|1001|1002|1101|1102|1103|1201|1202|1301|1302|1401|1402|1501|1502|1601|1602|1701|1702|1703|1801|1802|1900|2001|2002|2111|2112|2113|2201|2202|2203|2301|2302|2401|2402|2403|2501|2502|2503|2601|2602|2701|2702|2703|2800|2900|3001|3002|3003|3101|1302|3103|3104|3200|3301|3302|3401|3402|3501|3502|3601|3602|3701|3702|3800|3901|3902|4001|4002|4100|4201|4202|4203|4204|4205|4301|4302|4303|4400|4501|4502|4601|4602|4701|4702|4801|4802|4803|4901|4902|4903|4904|5001|5002|5003|5004|5005|5006|5007|5008|5009|5010|5101|5102|5103|5104|5105|5201|5202|5300|5400|
else if (convertPrj = 6)
	Guicontrol, , utmzone, |
guicontrol, Choose, utmzone, %utmZone%
return

GuiClose:
B_Cancel:
gui, Submit, nohide
IniDelete, Defaults.ini, pargePath
IniDelete, Defaults.ini, cubePath
IniDelete, Defaults.ini, syncPath
IniDelete, Defaults.ini, navPath
IniDelete, Defaults.ini, borePath
IniDelete, Defaults.ini, demPath
IniDelete, Defaults.ini, outPath
IniDelete, Defaults.ini, rollPos
IniDelete, Defaults.ini, rollNeg
IniDelete, Defaults.ini, pitchPos
IniDelete, Defaults.ini, pitchNeg
IniDelete, Defaults.ini, headPos
IniDelete, Defaults.ini, headNeg
IniDelete, Defaults.ini, convertPrj
IniDelete, Defaults.ini, utmZone
IniDelete, Defaults.ini, missing
IniDelete, Defaults.ini, outRes
IniDelete, Defaults.ini, FoV

cubeDir := cubeFileArr.Dir
indexDir := indexFileArr.Dir

IniWrite, %pargePath%, Defaults.ini, pargePath
IniWrite, %cubeDir%, Defaults.ini, cubePath
IniWrite, %indexDir%, Defaults.ini, syncPath
IniWrite, %navFile%, Defaults.ini, navPath
IniWrite, %boreFile%, Defaults.ini, borePath
IniWrite, %demFile%, Defaults.ini, demPath
IniWrite, %outDir%, Defaults.ini, outPath

IniWrite, %rollPos%, Defaults.ini, rollPos
IniWrite, %rollNeg%, Defaults.ini, rollNeg
IniWrite, %pitchPos%, Defaults.ini, pitchPos
IniWrite, %pitchNeg%, Defaults.ini, pitchNeg
IniWrite, %headPos%, Defaults.ini, headPos
IniWrite, %headNeg%, Defaults.ini, headNeg

IniWrite, %convertPrj%, Defaults.ini, convertPrj
IniWrite, %utmzone%, Defaults.ini, utmZone
IniWrite, %missing%, Defaults.ini, missing
IniWrite, %outRes%, Defaults.ini, outRes
IniWrite, %FoV%, Defaults.ini, FoV

ExitApp


B_Launch:
Gui, Submit, nohide

; Check submitted variables before starting batch
;***********************************************************************************************

dtnum := 217
Smooth := 3
proj := convertPrj=1 ? 0 : convertPrj=2 ? 1 : convertPrj=3 ? 2 : convertPrj=4 ? 3 : convertPrj=5 ? 4 : convertPrj=6 ? 5 : -1
rollParam := rollPos=1 ? "+" : rollNeg=1 ? "-" : 0
pitchParam := pitchPos=1 ? "+" : pitchNeg=1 ? "-" : 0
headParam := headPos=1 ? "+" : headNeg=1 ? "-" : 0

If (rollParam = 0 || pitchParam = 0 || headParam = 0)
{
	msgbox, Error in Image Attitude Parameters`nCheck batch setup`n`nExiting...
	goto, GuiClose
}
If (proj = -1)
{
	msgbox, Error in selected Projection`nCheck batch setup`n`nExiting...
	goto, GuiClose
}

; HARDCODED VARIABLES
;~ FileSelectFile, pargePath, 3, , Select the "parge.sav" file, (*.sav)
;~ FileSelectFile, cubeFiles, M3, , Select RAW data cubes for processing
;~ FileSelectFile, syncFiles, M3, , select corresponding "frameIndex" files, (*.txt)
;~ FileSelectFile, navFile, 3, , Select imu_gps.txt file for correct camera, (*.txt)
;~ FileSelectFile, boreFile, , , Select corresponding boresight file, (*.gcs)
;~ FileSelectFile, demFile, , , Select corresponding DEM for AOI, (*.asc)
;~ FileSelectFolder, outDir, , 3, Select output directory
;~ outRes := 0.5
;~ FoV := 21.6									;25.37 for VNIR / 21.6 for SWIR
;~ rollParam := "-" 								;"+" for "right up" / "-" for "left up" / for headwall sensors Left is up.
;~ pitchParam := "+"								;"+" for "nose up" / "-" for "nose down" / for AEGIS Nose is up.
;~ headParam := "+"								;"+" for "east +" / "-" for "west +" / for AEGIS East +
;~ Smooth := 3										;level of imu/gps smoothing.  If processed through POSpac, smoothing is 1
;~ convertPrj := "UTM"
;~ zone := 17
;~ dtnum := 217
;~ proj := 1
;~ utmzone := 17
;~ missing := -9999.0

; Create batch script for IDL to run
;***********************************************************************************************
;; Install Parge files
msgbox % ErrorLevel
splitpath, pargePath, , scriptDir
splitpath, demFile, demWext, demDir, demExt, demNOext

fileinstall , C:\install\parge\v32\parge\etc\ellipsoids.inc, %scriptDir%\ellipsoids.inc, 1
fileinstall, C:\install\parge\v32\parge\etc\parge_batch_DB.pro, %scriptDir%\parge_batch_DB.pro, 1

;;;;; Setup Variables ;;;;;
indexFileArr := object()
cubeFileArr := object()

;;_________________Setup cubeFile array_________________;;
Loop, parse, cubeFiles, `n
{
	If (a_index = 1)
		cubeFileArr.Dir := a_loopfield
	else
		filesHold .= cubeFileArr.Dir . "\" . a_loopfield . "`n"
}

Sort, filesHold, F StringSort

Loop, parse, filesHold, `n
{
	cubeTotal := a_index
	cubeFileArr.Cubes[a_index]:=A_LoopField
}
cubeFileArr.total := cubeTotal
filesHold := ""

;;_________________Setup frameIndex array_________________;;
Loop, parse, syncFiles, `n
{
	If (a_index = 1)
		indexFileArr.Dir := a_loopfield
	else
		filesHold .= indexFileArr.Dir . "\" . a_loopfield . "`n"
}

Sort, filesHold, F StringSort

Loop, parse, filesHold, `n
{
	indexTotal := a_index
	indexFileArr.Cubes[a_index]:=A_LoopField
}
indexFileArr.total := indexTotal
filesHold := ""

;;_________________Start writing script for IDL / Parge batch processing_________________;;
scriptPath := scriptDir . "\pargeBatch_" . a_now . ".txt"
scriptTXT := fileopen(scriptPath, "rw")

syncfile := ""
, cubes := ""
, scriptBody := ""

Loop % cubeFileArr.total
{
	If (a_index = 1)
		cubes .= "'" . cubeFileArr.Cubes[a_index] . "'"
	else
		cubes .= ",'" . cubeFileArr.Cubes[a_index] . "'"
}

Loop % indexFileArr.total
{
	If (a_index = 1)
		syncfile .= "'" . indexFileArr.Cubes[a_index] . "'"
	else
		syncfile .= ",'" . indexFileArr.Cubes[a_index] . "'"		
}

scriptBody =
(
.RESET_SESSION
PREF_SET, 'IDL_PATH', '%scriptDir%;<IDL_DEFAULT>', /COMMIT
.RESET_SESSION

forward_function parge
forward_function xparge_batch_DB

parge,/norun

outpath = "%outDir%\"

mount = 'r%rollParam%p%pitchParam%h%headParam%'
fov = %FoV%
smoothing = 3
resol = %outRes%

dtnum = %dtnum% 
proj = %proj%
utmzone = %utmzone%
missing = %missing%
bandrange = [5,7]

cord = gc_getcord('WGS-84', dtnum, proj, zone=utmzone)

demfile = "%demFile%"
demname = "%demDir%\%demNOext%"

bore = "%boreFile%"

navfile   = "%navFile%"
	
cubes     = [%cubes%]

syncfile  = [%syncfile%]


gc_rdarcdem, demfile, cord=cord, missing=missing, /nosave
gc_wdem, demname

FOR i =0,n_elements(cubes)-1 do $  
   parge_batch_DB, cubes[i], navfile, syncfile[i], demname, mount=mount, fov=fov, smoothing=smoothing, $
   bore=bore,  outpath=outpath, resol=resol, dtnum=dtnum, proj=proj, utmzone=utmzone, missing=missing


;exit                  ; exit IDL

)

scriptTXT.Write(scriptBody)
scriptTXT.Close()

;;_________________Start running batch script from IDL _________________;;

idlRun := scriptPath	

If FileExist("C:\Program Files\Exelis\IDL83\bin\bin.x86_64\idl.exe")
{
	Run, C:\Program Files\Exelis\IDL83\bin\bin.x86\idl.exe "%idlRun%", , , idlID
	Process, Wait, %idlID% 
	sleep, 2000
}
else
{
	Run, C:\Program Files\Exelis\IDL83\bin\bin.x86_64\idl.exe "%idlRun%", , , idlID
	Process, Wait, %idlID% 
	sleep, 2000
}


