;PRJ2KML - 2/9/15 - DB
SetBatchLines, -1
#NoEnv

prjFile = %1%
MouseGetPos, mX, mY

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


Read_PRJ_File(PRJfilePath)
{
	BlockA:=Object()
	
	IniRead, T_Scanner, %PRJfilePath%, TerraScan project, Scanner, NONE
	IniRead, T_Storage, %PRJfilePath%, TerraScan project, Storage, NONE
	IniRead, T_Time, %PRJfilePath%, TerraScan project, StoreTime, NONE
	IniRead, T_Color, %PRJfilePath%, TerraScan project, StoreColor, NONE
	IniRead, T_Lock, %PRJfilePath%, TerraScan project, RequireLock, NONE
	IniRead, T_Desc, %PRJfilePath%, TerraScan project, Description, NONE
	IniRead, T_ID, %PRJfilePath%, TerraScan project, FirstPointId, NONE
	IniRead, T_Dir, %PRJfilePath%, TerraScan project, Directory, NONE
	IniRead, T_Trj, %PRJfilePath%, TerraScan project, Trajectories, NONE
	IniRead, T_Ref, %PRJfilePath%, TerraScan project, ReferenceProject, NONE
	IniRead, T_Bsize, %PRJfilePath%, TerraScan project, BlockSize, NONE
	IniRead, T_Bname, %PRJfilePath%, TerraScan project, BlockNaming, NONE
	IniRead, T_Bpre, %PRJfilePath%, TerraScan project, BlockPrefix, NONE
	
	DirA:=strsplit(T_Dir, "\")
	Loop % (DirA.MaxIndex())
	{
		If (A_Index = 1)
		{
			BlockA.DirRoot := Trim(DirA[A_Index], ":")
			continue
		}
		DirTotUNC .= DirA[A_Index] . "\"
	}
	BlockA.DirTot := DirTotUNC
	If InStr(T_Trj, "..\..\")
	{
		Traj_End:=Substr(T_Trj, 7)
		T_Trj:=DirA[1] . "\" . Traj_End
	}
	Else If InStr(T_Trj, "..\")
	{
		Traj_End:=Substr(T_Trj, 4)
		Loop % (DirA.MaxIndex()-2)
			DirTot .= DirA[A_Index] . "\"
		T_Trj:=DirTot . Traj_End
	}
	Else If InStr(T_Trj, ".\")
	{
		Traj_End:=Substr(T_Trj, 3)
		Loop % (DirA.MaxIndex()-1)
			DirTot .= DirA[A_Index] . "\"
		T_Trj:=DirTot . Traj_End
	}		

	BlockA.Scanner := T_Scanner, BlockA.Storage := T_Storage, BlockA.Time := T_Time, BlockA.Color := T_Color, BlockA.Lock := T_Lock, BlockA.Desc := T_Desc, BlockA.ID := T_ID, BlockA.Dir := T_Dir, BlockA.Trj := T_Trj, BlockA.Ref := T_Ref, BlockA.Bsize := T_Bsize, BlockA.Bname := T_Bname, BlockA.Bpre := T_Bpre
	
	PRJ:=fileopen(PRJfilePath, "rw")
	EOB = `r`n
	
	Loop
	{
		PRJline:=PRJ.ReadLine()
		Bname:=StrSplit(PRJline, A_Space, "`r`n")
		If (Bname[1] = "Block")
		{
			Name := Bname[2], BCcount := 0
			If FileExist(T_Dir . "\" . Name)
			{
				FileGetSize, Fsize, %T_Dir%\%Name%
				Record := "Go"
				++Bcount
			}
			continue
		}
		If (PRJline = EOB)
		{
			Record := "Stop"
			If FileExist(T_Dir . "\" . Name)
				BlockA.CC[Bcount,1]:=BCcount
			continue
		}
		
		If (Record = "Go")
		{
			++BCcount
			;BlockA[Bcount,BCcount]:={NameA:Name} ;, BX:Bname[2], BY:Bname[3]}
			BlockA.name[Bcount,BCcount]:=Name
			BlockA.Fsize[Bcount,BCcount]:=Fsize
			BlockA.BX[Bcount,BCcount]:=Bname[2]
			BlockA.BY[Bcount,BCcount]:=Bname[3]

		}

		If PRJ.AtEOF
			Break
	}
	PRJ.close()
	return (BlockA)
}

Write_PRJ_File(PRJfilePath,PRJObj)
{
	FileDelete, %PRJfilePath%
	PRJ:=fileopen(PRJfilePath, "rw")
	
	PRJ.Write("[TerraScan project]`r`n")
	PRJ.Write("Scanner=" . PRJObj.Scanner . "`r`n")
	PRJ.Write("Storage=" . PRJObj.Storage . "`r`n")
	PRJ.Write("StoreTime=" . PRJObj.Time . "`r`n")
	PRJ.Write("StoreColor=" . PRJObj.Color . "`r`n")
	PRJ.Write("RequireLock=" . PRJObj.Lock . "`r`n")
	PRJ.Write("Description=" . PRJObj.Desc . "`r`n")
	PRJ.Write("FirstPointId=" . PRJObj.ID . "`r`n")
	PRJ.Write("Directory=" . PRJObj.Dir . "`r`n")
	PRJ.Write("Trajectories=" . PRJObj.Trj . "`r`n")
	PRJ.Write("BlockSize=" . PRJObj.Bsize . "`r`n")
	PRJ.Write("BlockNaming=" . PRJObj.Bname . "`r`n")
	PRJ.Write("BlockPrefix=" . PRJObj.Bpre . "`r`n")
	PRJObj.Ref="NONE" ? "skip" : PRJ.Write("ReferenceProject=" . PRJObj.Ref . "`r`n")
	PRJ.Write("`r`n")
	
	Loop % PRJObj.CC.MaxIndex()
	{
		Bcount := A_Index
		PRJ.Write("Block " . PRJObj.name[Bcount,1] . "`r`n")
		Loop % PRJObj.CC[Bcount,1]
		{
			PRJ.Write(" " . PRJObj.BX[Bcount,A_Index] . " " . PRJObj.BY[Bcount,A_Index] . "`r`n")
		}
		PRJ.Write("`r`n")
	}
		
	
	PRJ.close()
	return
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
	
simpleReplace(inputVar,Original,Replacement) {
	zero := inputVar
	, one := Original
	, two := Replacement
	StringReplace, three, zero, %one%, %two%, All
	return (three)
}

epsg := simpleReplace(proj4_Init(0),"`n","|"),
esri := simpleReplace(proj4_Init(1),"`n","|"),
epsgArr := strsplit(epsg, "|"),
esriArr := strsplit(esri, "|")

Gui, Add, ListBox, x16 y85 w370 h134 vepsgOut gepsgChoose, %epsg%
Gui, Add, ListBox, x15 y246 w370 h134 vesriOut gesriChoose, %esri%
Gui, Add, Text, x16 y5 w370 h20 , Select Output Projection / Units
Gui, Add, Button, x396 y85 w70 h30 gCancel, Cancel
Gui, Add, Button, x396 y125 w70 h30 gOK, OK
Gui, Add, Progress, x15 y388 w370 h10 vMyProgress -Smooth, 10
Gui, Add, Text, x16 y405 w370 h20 vProgressText, Setup...
Gui, Add, Button, x396 y35 w70 h20 gsearch, Search
Gui, Add, Edit, x16 y35 w370 h20 vfilterSearch, Filter by Search Terms
Gui, Add, Text, x16 y65 w150 h20 , EPSG Projections
Gui, Add, Text, x16 y225 w150 h20 , ESRI Projections
; Generated using SmartGUI Creator 4.0
Gui, Show, x%mX% y%mY% h438 w483, PRJ2KML v1.0
Return

epsgChoose:
Gui, submit, nohide
GuiControl, Choose, esriOut, 0
return

esriChoose:
Gui, submit, nohide
GuiControl, Choose, epsgOut, 0
return

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

OK:
Gui, Submit, nohide

Guicontrol, , MyProgress, 20
Guicontrol, , ProgressText, Reading PRJ

prjObj := Read_PRJ_File(prjFile)

SplitPath, prjFile, wExt, Dir, Ext, noExt
progress, 20, , Write Header Info
kmlF:=FileOpen(Dir . "\PRJ_" . noExt . ".kml", "w")

kmlHead=
(
<?xml version="1.0" encoding="UTF-8"?>
<kml xmlns="http://www.opengis.net/kml/2.2" xmlns:gx="http://www.google.com/kml/ext/2.2" xmlns:kml="http://www.opengis.net/kml/2.2" xmlns:atom="http://www.w3.org/2005/Atom">
<Document>
	<StyleMap id="msn_ylw-pushpin">
		<Pair>
			<key>normal</key>
			<styleUrl>#sn_ylw-pushpin</styleUrl>
		</Pair>
		<Pair>
			<key>highlight</key>
			<styleUrl>#sh_ylw-pushpin</styleUrl>
		</Pair>
	</StyleMap>
	<Style id="sh_ylw-pushpin">
		<IconStyle>
			<scale>1.3</scale>
			<Icon>
				<href>http://maps.google.com/mapfiles/kml/pushpin/ylw-pushpin.png</href>
			</Icon>
			<hotSpot x="20" y="2" xunits="pixels" yunits="pixels"/>
		</IconStyle>
		<LineStyle>
			<color>00ffffff</color>
			<width>0</width>
		</LineStyle>
		<PolyStyle>
			<color>bfffffff</color>
		</PolyStyle>
	</Style>
	<Style id="sn_ylw-pushpin">
		<IconStyle>
			<scale>1.1</scale>
			<Icon>
				<href>http://maps.google.com/mapfiles/kml/pushpin/ylw-pushpin.png</href>
			</Icon>
			<hotSpot x="20" y="2" xunits="pixels" yunits="pixels"/>
		</IconStyle>
		<LineStyle>
			<color>90ffffff</color>
			<width>0.1</width>
		</LineStyle>
		<PolyStyle>
			<color>500000ff</color>
		</PolyStyle>
	</Style>
	<Style id="check-hide-children">
		<ListStyle>
			<listItemType>checkHideChildren</listItemType>
		</ListStyle>
	</Style>
<Folder>
	<name>PRJ_%noExt%</name>

)
kmlF.Write(kmlHead)

