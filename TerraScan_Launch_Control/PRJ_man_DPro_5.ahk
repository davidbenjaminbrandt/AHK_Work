SetBatchLines, -1
#NoEnv
#maxmem 128

GetProcessTimes(PID=0)    { 
   Static oldKrnlTime, oldUserTime 
   Static newKrnlTime, newUserTime 

   oldKrnlTime := newKrnlTime 
   oldUserTime := newUserTime 

   hProc := DllCall("OpenProcess", "Uint", 0x400, "int", 0, "Uint", pid) 
   DllCall("GetProcessTimes", "Uint", hProc, "int64P", CreationTime, "int64P"
           , ExitTime, "int64P", newKrnlTime, "int64P", newUserTime) 

   DllCall("CloseHandle", "Uint", hProc) 
   ;~ MsgBox, %oldKrnlTime%  %oldUserTime% 
Return (newKrnlTime-oldKrnlTime + newUserTime-oldUserTime)/10000000 * 100   
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


Read_TSK_File(TSKfilePath)
{
	TaskA := Object()
	IniRead, T_Task, %TSKfilePath%, TerraSlave task, Task, NONE
	IniRead, T_Macro, %TSKfilePath%, TerraSlave task, Macro, NONE
	IniRead, T_SaveResults, %TSKfilePath%, TerraSlave task, SaveResults, NONE
	IniRead, T_Neighbours, %TSKfilePath%, TerraSlave task, Neighbours, NONE
	IniRead, T_Dispatcher, %TSKfilePath%, TerraSlave task, Dispatcher, NONE
	IniRead, T_ProcessBy, %TSKfilePath%, TerraSlave task, ProcessBy, NONE
	IniRead, T_CoordOriginX, %TSKfilePath%, TerraSlave task, CoordOriginX, NONE
	IniRead, T_CoordOriginY, %TSKfilePath%, TerraSlave task, CoordOriginY, NONE
	IniRead, T_CoordOriginZ, %TSKfilePath%, TerraSlave task, CoordOriginZ, NONE
	IniRead, T_CoordResolution, %TSKfilePath%, TerraSlave task, CoordResolution, NONE
	IniRead, T_CoordUnitInMeters, %TSKfilePath%, TerraSlave task, CoordUnitInMeters, NONE
	IniRead, T_Project, %TSKfilePath%, TerraSlave task, Project, NONE
	IniRead, T_ProjectDate, %TSKfilePath%, TerraSlave task, ProjectDate, NONE
	IniRead, T_ProjectTime, %TSKfilePath%, TerraSlave task, ProjectTime, NONE
	IniRead, T_Blocks, %TSKfilePath%, TerraSlave task, Blocks, NONE
	IniRead, T_Progress, %TSKfilePath%, TerraSlave task, Progress, NONE
	IniRead, T_Reports, %TSKfilePath%, TerraSlave task, Reports, NONE
	IniRead, T_WriteBlocks, %TSKfilePath%, TerraSlave task, WriteBlocks, NONE
	IniRead, T_PointClasses, %TSKfilePath%, TerraSlave task, PointClasses, NONE
	IniRead, T_Trajectories, %TSKfilePath%, TerraSlave task, Trajectories, NONE
	IniRead, T_TrjBadQuality, %TSKfilePath%, TerraSlave task, TrjBadQuality, NONE
	IniRead, T_TrjPoorQuality, %TSKfilePath%, TerraSlave task, TrjPoorQuality, NONE
	IniRead, T_TrjNormalQuality, %TSKfilePath%, TerraSlave task, TrjNormalQuality, NONE
	IniRead, T_TrjGoodQuality, %TSKfilePath%, TerraSlave task, TrjGoodQuality, NONE
	IniRead, T_TrjExcelQuality, %TSKfilePath%, TerraSlave task, TrjExcelQuality, NONE
	IniRead, T_CoordinateSystemFolder, %TSKfilePath%, TerraSlave task, CoordinateSystemFolder, NONE
	IniRead, T_Transformations, %TSKfilePath%, TerraSlave task, Transformations, NONE
	IniRead, T_ProjectionSystems, %TSKfilePath%, TerraSlave task, ProjectionSystems, NONE
	IniRead, T_FileFormats, %TSKfilePath%, TerraSlave task, FileFormats, NONE
	IniRead, T_SectionTemplates, %TSKfilePath%, TerraSlave task, SectionTemplates, NONE
	IniRead, T_WgsFinlandEquation, %TSKfilePath%, TerraSlave task, WgsFinlandEquation, NONE		
	
	TaskA.Task:=T_Task, TaskA.Macro:=T_Macro, TaskA.SaveResults:=T_SaveResults, TaskA.Neighbours:=T_Neighbours, TaskA.Dispatcher:=T_Dispatcher, TaskA.ProcessBy:=T_ProcessBy, TaskA.CoordOriginX:=T_CoordOriginX, TaskA.CoordOriginY:=T_CoordOriginY, TaskA.CoordOriginZ:=T_CoordOriginZ, TaskA.CoordResolution:=T_CoordResolution, TaskA.CoordUnitInMeters:=T_CoordUnitInMeters, TaskA.Project:=T_Project, TaskA.ProjectDate:=T_ProjectDate, TaskA.ProjectTime:=T_ProjectTime, TaskA.Blocks:=T_Blocks, TaskA.Progress:=T_Progress, TaskA.Reports:=T_Reports, TaskA.WriteBlocks:=T_WriteBlocks, TaskA.PointClasses:=T_PointClasses, TaskA.Trajectories:=T_Trajectories, TaskA.TrjBadQuality:=T_TrjBadQuality, TaskA.TrjPoorQuality:=T_TrjPoorQuality, TaskA.TrjNormalQuality:=T_TrjNormalQuality, TaskA.TrjGoodQuality:=T_TrjGoodQuality, TaskA.TrjExcelQuality:=T_TrjExcelQuality, TaskA.CoordinateSystemFolder:=T_CoordinateSystemFolder, TaskA.Transformations:=T_Transformations, TaskA.ProjectionSystems:=T_ProjectionSystems, TaskA.FileFormats:=T_FileFormats, TaskA.SectionTemplates:=T_SectionTemplates, TaskA.WgsFinlandEquation:=T_WgsFinlandEquation
	
	return (TaskA)
}

Write_TSK_File(TSKfilePath,TaskObj)
{
	TSK:=fileopen(TSKfilePath, "rw")
	
	TSK.Write("[TerraSlave task]`r`n")
	TSKres1 := TaskObj.Task="" ? "skip" : TSK.Write("Task=" . TaskObj.Task . "`r`n")
	TSKres2 := TaskObj.Macro="" ? "skip" : TSK.Write("Macro=" . TaskObj.Macro . "`r`n")
	TSKres3 := TaskObj.SaveResults="" ? "skip" : TSK.Write("SaveResults=" . TaskObj.SaveResults . "`r`n")
	TSKres4 := TaskObj.Neighbours="" ? "skip" : TSK.Write("Neighbours=" . TaskObj.Neighbours . "`r`n")
	TSKres5 := TaskObj.Dispatcher="" ? "skip" : TSK.Write("Dispatcher=" . TaskObj.Dispatcher . "`r`n")
	TSKres6 := TaskObj.ProcessBy="" ? "skip" : TSK.Write("ProcessBy=" . TaskObj.ProcessBy . "`r`n")
	TSKres7 := TaskObj.CoordOriginX="" ? "skip" : TSK.Write("CoordOriginX=" . TaskObj.CoordOriginX . "`r`n")
	TSKres8 := TaskObj.CoordOriginY="" ? "skip" : TSK.Write("CoordOriginY=" . TaskObj.CoordOriginY . "`r`n")
	TSKres9 := TaskObj.CoordOriginZ="" ? "skip" : TSK.Write("CoordOriginZ=" . TaskObj.CoordOriginZ . "`r`n")
	TSKres10 := TaskObj.CoordResolution="" ? "skip" : TSK.Write("CoordResolution=" . TaskObj.CoordResolution . "`r`n")
	TSKres11 := TaskObj.CoordUnitInMeters="" ? "skip" : TSK.Write("CoordUnitInMeters=" . TaskObj.CoordUnitInMeters . "`r`n")
	TSKres12 := TaskObj.Project="" ? "skip" : TSK.Write("Project=" . TaskObj.Project . "`r`n")
	TSKres13 := TaskObj.ProjectDate="" ? "skip" : TSK.Write("ProjectDate=" . TaskObj.ProjectDate . "`r`n")
	TSKres14 := TaskObj.ProjectTime="" ? "skip" : TSK.Write("ProjectTime=" . TaskObj.ProjectTime . "`r`n")
	TSKres15 := TaskObj.Blocks="" ? "skip" : TSK.Write("Blocks=" . TaskObj.Blocks . "`r`n")
	TSKres16 := TaskObj.Progress="" ? "skip" : TSK.Write("Progress=" . TaskObj.Progress . "`r`n")
	TSKres17 := TaskObj.Reports="" ? "skip" : TSK.Write("Reports=" . TaskObj.Reports . "`r`n")
	TSKres18 := TaskObj.WriteBlocks="" ? "skip" : TSK.Write("WriteBlocks=" . TaskObj.WriteBlocks . "`r`n")
	TSKres19 := TaskObj.PointClasses="" ? "skip" : TSK.Write("PointClasses=" . TaskObj.PointClasses . "`r`n")
	TSKres20 := TaskObj.Trajectories="" ? "skip" : TSK.Write("Trajectories=" . TaskObj.Trajectories . "`r`n")
	TSKres21 := TaskObj.TrjBadQuality="" ? "skip" : TSK.Write("TrjBadQuality=" . TaskObj.TrjBadQuality . "`r`n")
	TSKres22 := TaskObj.TrjPoorQuality="" ? "skip" : TSK.Write("TrjPoorQuality=" . TaskObj.TrjPoorQuality . "`r`n")
	TSKres23 := TaskObj.TrjNormalQuality="" ? "skip" : TSK.Write("TrjNormalQuality=" . TaskObj.TrjNormalQuality . "`r`n")
	TSKres24 := TaskObj.TrjGoodQuality="" ? "skip" : TSK.Write("TrjGoodQuality=" . TaskObj.TrjGoodQuality . "`r`n")
	TSKres25 := TaskObj.TrjExcelQuality="" ? "skip" : TSK.Write("TrjExcelQuality=" . TaskObj.TrjExcelQuality . "`r`n")
	TSKres26 := TaskObj.CoordinateSystemFolder="" ? "skip" : TSK.Write("CoordinateSystemFolder=" . TaskObj.CoordinateSystemFolder . "`r`n")
	TSKres27 := TaskObj.Transformations="" ? "skip" : TSK.Write("Transformations=" . TaskObj.Transformations . "`r`n")
	TSKres28 := TaskObj.ProjectionSystems="" ? "skip" : TSK.Write("ProjectionSystems=" . TaskObj.ProjectionSystems . "`r`n")
	TSKres29 := TaskObj.FileFormats="" ? "skip" : TSK.Write("FileFormats=" . TaskObj.FileFormats . "`r`n")
	TSKres30 := TaskObj.SectionTemplates="" ? "skip" : TSK.Write("SectionTemplates=" . TaskObj.SectionTemplates . "`r`n")
	TSKres31 := TaskObj.WgsFinlandEquation="" ? "skip" : TSK.Write("WgsFinlandEquation=" . TaskObj.WgsFinlandEquation . "`r`n")
	
	TSK.close()
	return
}

Generate_Tslaves(TS_amount,TSKfilePATH)
{
	FileCreateDir, %A_workingdir%\tslave\progress
	FileCreateDir, %A_workingdir%\tslave\queue
	FileCreateDir, %A_workingdir%\tslave\reports
	FileCreateDir, %A_workingdir%\tslave\task
	FileInstall, C:\terra\tslave\tslave.exe, %A_WorkingDir%\tslave\tslave.exe
	FileInstall, C:\terra\tslave\tslave.upf, %A_WorkingDir%\tslave\tslave.upf
	FileCopy, %TSKfilePATH%, %A_workingdir%\tslave\task, 1

	SlavesO:=Object()
	
	Loop % TS_amount
	{
		FileCopyDir, %A_workingdir%\tslave, C:\terra\tslave_%A_Index%, 1
		SlavesO.path[A_Index]:="C:\terra\tslave_" . A_Index
		Run, *Open C:\terra\tslave_%A_Index%\tslave.exe, , Hide, PIDslave
		SlavesO.PID[A_Index]:=PIDslave
		SlavesO.RowN[A_Index]:=LV_Add("", "TSlave_" . A_Index, "", "")
	}
	
	LV_ModifyCol()
	FileRemoveDir, %A_workingdir%\tslave, 1
	return (SlavesO)
}

Destroy_Tslaves(SlavesObj)
{
	Loop % SlavesObj.path.Maxindex()
	{
		slaveSlash:=SlavesObj.path[A_index]
		FileRemoveDir, %slaveSlash%, 1
	}
}
	
TSK_Delete_Aborted(TSKobj)
{
	AbortedF:=0, Dlist := ""
	ReportPath:=TSKobj.Reports
	Loop, %ReportPath%\*.txt
	{
		Loop, Read, %A_LoopFileLongPath%
		{
			If (A_LoopReadLine = "Status=Aborted" OR A_LoopReadLine = "Status=Removed" OR A_LoopReadLine = "Status=Failed")
			{
				
				++AbortedF
				Dlist .= A_LoopFileLongPath . "`r`n"
				break
			}			
		}
	}
	Loop, parse, Dlist, `r`n
	{
		filedelete, %A_LoopField%
	}
	return (AbortedF)
}

;%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%FUNCTION AERA ABOVE%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

Menu, FileMenu, Add, PRJ-a-lator, MENUprj-a-lator
Menu, MyMenu, Add, &Tools, :FileMenu
Gui, Menu, MyMenu
Gui, Add, GroupBox, x6 y5 w480 h60 vPROfi, Project File
Gui, Add, Edit, x16 y25 w380 h20 vPRJpath, Select PRJ File
Gui, Add, Button, x406 y25 w70 h20 gBrowsePRJ vBrowsePRJv, Browse
Gui, Add, GroupBox, x6 y65 w480 h60 vMACfi, Macro
Gui, Add, Edit, x16 y85 w380 h20 vMACpath, Select MAC File
Gui, Add, Button, x406 y85 w70 h20 gBrowseMAC vBrowseMACv, Browse
Gui, Add, GroupBox, x6 y125 w480 h60 vSAVbe, Save Behavior
Gui, Add, Edit, x156 y145 w240 h20 +Disabled vOUTpath, Select Output Location
Gui, Add, Button, x406 y145 w70 h20 +Disabled gBrowseOUT vBout, Browse
Gui, Add, DropDownList, x16 y145 w130 h20 +R3 vSaveS gSaveSub, Do Not Save||Save Over Original|Save New Copy|
Gui, Add, GroupBox, x6 y185 w100 h50 vNghbrs, Neighbors
Gui, Add, Edit, x16 y205 w80 h20 vNeighborsS , 0.00
Gui, Add, GroupBox, x116 y185 w90 h50 vNoSL, # of Slaves
Gui, Add, DropDownList, x126 y205 w70 h20 +R8 vSlavesN, 1|2|3|4||5|6|7|8|9|10|11|12|13|14|15|16|17|18|19|20|21|22|23|24|
Gui, Add, GroupBox, x216 y185 w100 h50 vWorkU, Working Unit
Gui, Add, DropDownList, x226 y205 w80 h20 vUnit gUnitSub +R3, Meters||Survey Ft|Int Ft|
Gui, Add, Button, x326 y195 w70 h30 gOK, OK
Gui, Add, Button, x406 y195 w70 h30 gCancel, Cancel
Gui, Add, Progress, x16 y313 w460 h20 vMyProgress, 5
Gui, Add, Text, x16 y333 w460 h20 vProgressT, Setup...
Gui, Add, ListView, x10 y368 w474 h220 , Slave|File|Step|
Gui, Add, GroupBox, x6 y235 w480 h70 +Disabled vTSKgroup, Task File
Gui, Add, CheckBox, x16 y251 w140 h20 vTSKreV gTSKre, Previous Task ReStart?
Gui, Add, Edit, x16 y275 w380 h20 +Disabled vTSKfiv, Select TSK File
Gui, Add, Button, x406 y275 w70 h20 +Disabled vBrowseTSKv gBrowseTSK, Browse
; Generated using SmartGUI Creator 4.0
Gui, Show, x0 y0 h601 w498, TerraSlave Launch Control
return

MENUprj-a-lator:
Gui +OwnDialogs
Gui, Submit, NoHide
GoSub, AutoPrjSub
return

TSKre:
Gui, Submit, NoHide
GuiControl, Disable%TSKreV%, PROfi
GuiControl, Disable%TSKreV%, PRJpath
GuiControl, Disable%TSKreV%, BrowsePRJv
GuiControl, Disable%TSKreV%, MACfi
GuiControl, Disable%TSKreV%, MACpath
GuiControl, Disable%TSKreV%, BrowseMACv
GuiControl, Disable%TSKreV%, SAVbe
GuiControl, Disable%TSKreV%, OUTpath
GuiControl, Disable%TSKreV%, Bout
GuiControl, Disable%TSKreV%, SaveS
GuiControl, Disable%TSKreV%, Nghbrs
GuiControl, Disable%TSKreV%, NeighborsS
GuiControl, Disable%TSKreV%, WorkU
GuiControl, Disable%TSKreV%, Unit
GuiControl, Enable%TSKreV%, TSKgroup
GuiControl, Enable%TSKreV%, TSKfiv
GuiControl, Enable%TSKreV%, BrowseTSKv
return

BrowseTSK:
Gui +OwnDialogs
FileSelectFile, TSKfiv, 3, %TSKfiv%, Select TSK file, TScan TASK File (*.tsk)
If (TSKfiv = "")
 {
  Guicontrol, , TSKfiv, No File Selected!
  return
 }
 GuiControl, , TSKfiv, Checking for Aborted, Failed, or Removed files...
 TSKabort:=Read_TSK_File(TSKfiv)
 AbortedF:=TSK_Delete_Aborted(TSKabort)
 GuiControl, , TSKfiv, Added back %AbortedF% files into Task Queue
 Sleep, 2000
 GuiControl, , TSKfiv, %TSKfiv%
return
 
BrowsePRJ:
Gui +OwnDialogs
FileSelectFile, PRJpath, 3, %PRJpath%, Select PRJ File, TScan Project File (*.prj)
If (PRJpath = "")
 {
  Guicontrol, , PRJpath, No File Selected!
  return
 }
  FileGetTime, PRJDT, %PRJpath%
  FormatTime, PRJdate, %PRJDT%, yyyyMMdd
  FormatTime, PRJtime, %PRJDT%, HHmmss
  GuiControl, , PRJpath, %PRJpath%
return

BrowseMAC:
Gui +OwnDialogs
FileSelectFile, MACpath, 3, %MACpath%, Select MAC File, TScan Macro File (*.mac)
If (MACpath = "")
 {
  Guicontrol, , MACpath, No File Selected!
  return
 }
  GuiControl, , MACpath, %MACpath%
return

BrowseOUT:
Gui +OwnDialogs
FileSelectFolder, OUTpath, *%OUTpath%, 3, Select Output Location
If (OUTpath = "")
 {
  Guicontrol, , OUTpath, No Output Location Selected!
  return
 }
  GuiControl, , OUTpath, %OUTpath%
return

SaveSub:
Gui, Submit, NoHide
If (SaveS = "Do Not Save")
{
	GuiControl, Disable, OUTpath
	GuiControl, Disable, Bout
	SaveNum:=0
}
Else If (SaveS = "Save Over Original")
{
	GuiControl, Disable, OUTpath
	GuiControl, Disable, Bout
	SaveNum:=1
}
Else If (SaveS = "Save New Copy")
{
	GuiControl, Enable, OUTpath
	GuiControl, Enable, Bout
	SaveNum:=3
}
Return

Unitsub:
Gui, Submit, NoHide
If (Unit = "Meters")
	UnitNum:="0.00000000"
Else If (Unit = "Survey Ft")
	UnitNum:="3.28083333"
Else If (Unit = "Int Ft")
	UnitNum:="3.28083990"
Return

Cancel:
GuiClose:
SetTimer, CheckSlave, Off
Settimer, ProgressSlave, Off
Loop % SlaveOBJ.PID.MaxIndex()
{
	slaveTitle:=SlaveOBJ.PID[A_Index]
	ControlClick, Button1, ahk_pid %slaveTitle%, , , , NA
}
slavetitle:=""
Loop % SlaveOBJ.PID.MaxIndex()
{
	slaveTitle:=SlaveOBJ.PID[A_Index]
	If winexist("ahk_pid " . slaveTitle)
	{
		Loop
		{
			sleep, 10
			ControlGetText, slaveAbort, Button2, ahk_pid %slaveTitle%
		} Until (slaveAbort = "Activate")
		PostMessage, 0x112, 0xF060,,, ahk_pid %slaveTitle%
	}
}
Destroy_Tslaves(SlaveOBJ)
ExitApp

OK:
GoSub, SaveSub
Gui, Submit, NoHide
 

PRJobj:=Read_PRJ_File(PRJpath)

If (TSKreV != 1)
{
	Start_Time:=A_YYYY . A_MM . A_DD . "_" . A_Hour . A_Min . A_Sec

	SplitPath, PRJpath, PRJpathWext, PRJpathDIR, , PRJpathNOext
	PRJprjPATH:="\\" . A_ComputerName . "\" . PRJobj.DirRoot . "\" . PRJobj.DirTot . PRJpathNOext . "_MACRO_" . Start_Time . "\prj"
	PRJtempPATH:="\\" . A_ComputerName . "\" . PRJobj.DirRoot . "\" . PRJobj.DirTot . PRJpathNOext . "_MACRO_" . Start_Time . "\prj\" . PRJpathNOext . "_TEMP.prj"
	PRJtaskPATH:="\\" . A_ComputerName . "\" . PRJobj.DirRoot . "\" . PRJobj.DirTot . PRJpathNOext . "_MACRO_" . Start_Time . "\taskCOPY"
	PRJmacroPATH:="\\" . A_ComputerName . "\" . PRJobj.DirRoot . "\" . PRJobj.DirTot . PRJpathNOext . "_MACRO_" . Start_Time . "\macroCOPY"
	PRJprogressPATH:="\\" . A_ComputerName . "\" . PRJobj.DirRoot . "\" . PRJobj.DirTot . PRJpathNOext . "_MACRO_" . Start_Time . "\progress"
	PRJreportsPATH:="\\" . A_ComputerName . "\" . PRJobj.DirRoot . "\" . PRJobj.DirTot . PRJpathNOext . "_MACRO_" . Start_Time . "\reports"
	FileCreateDir, %PRJtaskPATH%
	FileCreateDir, %PRJmacroPATH%
	FileCreateDir, %PRJprogressPATH%
	FileCreateDir, %PRJreportsPATH%
	FileCreateDir, %PRJprjPATH%
	FileCopy, %MACpath%, %PRJmacroPATH%, 1
	Write_PRJ_File(PRJtempPATH,PRJobj)

	TASKobj:=Object()
	TSKpath:=PRJtaskPATH . "\" . Start_Time . ".tsk"

	 TASKobj.Task:="tscan_macro"
	 TASKobj.Macro:=MACpath
	 TASKobj.SaveResults:=SaveNum
	 TASKobj.Neighbours:=Round(NeighborsS, 2)
	 TASKobj.Dispatcher:=A_ComputerName
	 TASKobj.ProcessBy:=A_ComputerName
	 TASKobj.CoordOriginX:="-0.000"
	 TASKobj.CoordOriginY:="-0.000"
	 TASKobj.CoordOriginZ:="-0.000"
	 TASKobj.CoordResolution:="100"
	 TASKobj.CoordUnitInMeters:=UnitNum
	 TASKobj.Project:=PRJtempPATH
	 TASKobj.ProjectDate:=PRJdate
	 TASKobj.ProjectTime:=PRJtime
	 TASKobj.Blocks:="1-" . PRJobj.CC.MaxIndex()
	 TASKobj.Progress:=PRJprogressPATH
	 TASKobj.Reports:=PRJreportsPATH
	 TASKobj.WriteBlocks := OUTpath="Select Output Location" ? "" : OUTpath
	 TASKobj.PointClasses:="\\" . A_ComputerName . "\c\terra\tscan\tscan.ptc"
	 TASKobj.Trajectories := T_Trj="NONE" ? "" : T_Trj
	 TASKobj.CoordinateSystemFolder:="\\" . A_ComputerName . "\c\terra\coordsys"
	 TASKobj.Transformations:="\\" . A_ComputerName . "\c\terra\tscan\trans.inf"
	 TASKobj.ProjectionSystems:="\\" . A_ComputerName . "\c\terra\tscan\projection_systems.inf"
	 TASKobj.FileFormats:="\\" . A_ComputerName . "\c\terra\tscan\outfmt.inf"
	 TASKobj.SectionTemplates:="\\" . A_ComputerName . "\c\terra\tscan\section_templates.inf"
	 TASKobj.WgsFinlandEquation:=0

	Write_TSK_File(TSKpath,TASKobj)
}
else
{
	TSKpath := TSKfiv
}

FinalTSK:=Read_TSK_File(TSKpath), RtotFiles:=StrSplit(FinalTSK.Blocks, "-", "`r`n"), progressTotal:=RtotFiles[2]

SlaveOBJ:=Generate_Tslaves(SlavesN,TSKpath)

SetTimer, CheckSlave, 250
Settimer, ProgressSlave, 1000
Settimer, ReportSlave, 30000

;#############################SUB-ROUTINES#################################################################################

CheckSlave:
Loop % SlaveOBJ.path.Maxindex()
{
	slaveText:=SlaveOBJ.PID[A_Index]
	ControlGetText, CS, Static1, ahk_pid %slaveText%
	ControlGetText, CF, Static2, ahk_pid %slaveText%
	ControlGetText, CSt, Static3, ahk_pid %slaveText%

	LV_Modify(SlaveOBJ.RowN[A_Index], "Col2", CF)
	LV_Modify(SlaveOBJ.RowN[A_Index], "Col3", CSt) 
}
LV_ModifyCol()

return

ProgressSlave:
ProgressLoad1:=0, ProgressLoad2:=0, ProgressLoad:=0
Loop % SlaveOBJ.path.Maxindex()
{
	slaveText:=SlaveOBJ.PID[A_Index]
	ControlGetText, CS, Static1, ahk_pid %slaveText%
	ControlGetText, CF, Static2, ahk_pid %slaveText%
	ControlGetText, CSt, Static3, ahk_pid %slaveText%
	ProgressLoad1 += Round(GetProcessTimes(slaveText), 2)
}
Loop % SlaveOBJ.path.Maxindex()
{
	slaveText:=SlaveOBJ.PID[A_Index]
	ControlGetText, CS, Static1, ahk_pid %slaveText%
	ControlGetText, CF, Static2, ahk_pid %slaveText%
	ControlGetText, CSt, Static3, ahk_pid %slaveText%
	ProgressLoad2 += Round(GetProcessTimes(slaveText), 2)
}
Rfiles:=0
FinalReports:=FinalTSK.Reports . "\*.txt"
Loop, %FinalReports%
{
	++Rfiles
}
ProgressUpdate:=(Rfiles/progressTotal)*100
ProgressLoad := (ProgressLoad1+ProgressLoad2)/2
ProgressLoad := ProgressLoad>200 ? 100 : Round((ProgressLoad/2), 2)
GuiControl, , MyProgress, %ProgressUpdate%
GuiControl, , ProgressT, CPU usage: %ProgressLoad% `%  |  Files: %Rfiles% `/ %progressTotal% complete  |  Output Concerns: %ConcernVar%
return

ReportSlave:
AbortedFF:=0, ReportTotal:=0
Failure := Object()
BlockReport := Object()
ReportSlavePATH:=FinalTSK.Reports
Loop, %ReportSlavePATH%\*.txt
{
	AbortedF := 0
	BlockReportHOLD := ""
	FileGetTime, Reporttime, %A_LoopFileLongPath%
	FormatTime, Reporttime, %Reporttime%, HH:mm:ss
	Loop, Read, %A_LoopFileLongPath%
	{
		If (A_index = 1)
		{
			Computer:=A_LoopReadLine
			continue
		}
		If (A_index = 3)
		{
			FailBlock:=A_LoopReadLine
			continue
		}
		If InStr(A_LoopReadLine, "returned -")
		{
			DStep := A_LoopReadLine
		}
		If (A_LoopReadLine = "Status=Aborted" OR A_LoopReadLine = "Status=Removed" OR A_LoopReadLine = "Status=Failed")
		{
			AbortedF := 1
			++AbortedFF
			Dlist := A_LoopReadLine
			break
		}
		If (A_LoopReadLine = "")
			continue
		BlockReportHOLD .= A_LoopReadLine . " ^ &#10;"
		
	}
	++ReportTotal
	BlockReport.Computer[ReportTotal]:=Computer
	BlockReport.Time[ReportTotal]:=Reporttime
	BlockReport.Block[ReportTotal]:=FailBlock
	BlockReport.Step[ReportTotal]:=BlockReportHOLD
	
	If AbortedF
	{
		Failure.Computer[AbortedFF]:=Computer
		Failure.Block[AbortedFF]:=FailBlock
		Failure.Dlist[AbortedFF]:=Dlist
		Failure.DStep[AbortedFF]:=DStep
	}
	else
		continue
}

FailOUThold = %ReportSlavePATH%\Concerns_List.csv
BlockOUThold = %ReportSlavePATH%\Reports_List.xml
FailOUT:=fileopen(FailOUThold, "w")
BlockReportOUT:=fileopen(BlockOUThold, "w")
BlockHead =
(
<?xml version="1.0" encoding="UTF-8"?>
<?mso-application progid="Excel.Sheet"?>
<Workbook xmlns="urn:schemas-microsoft-com:office:spreadsheet" xmlns:c="urn:schemas-microsoft-com:office:component:spreadsheet" xmlns:html="http://www.w3.org/TR/REC-html40" xmlns:o="urn:schemas-microsoft-com:office:office" xmlns:ss="urn:schemas-microsoft-com:office:spreadsheet" xmlns:x2="http://schemas.microsoft.com/office/excel/2003/xml" xmlns:x="urn:schemas-microsoft-com:office:excel" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"><OfficeDocumentSettings xmlns="urn:schemas-microsoft-com:office:office">
</OfficeDocumentSettings>
<ExcelWorkbook xmlns="urn:schemas-microsoft-com:office:excel">
</ExcelWorkbook>
<Styles>
	<Style ss:ID="Default" ss:Name="Normal">
		<Alignment ss:Vertical="Top" ss:WrapText="1"/>
	</Style>
</Styles>
	<ss:Worksheet ss:Name="Sheet1">
			<Table>
				<Column ss:AutoFitWidth="0" ss:Width="175"/>
				<Column ss:AutoFitWidth="0" ss:Width="175"/>
				<Column ss:AutoFitWidth="0" ss:Width="175"/>
				<Column ss:Width="550"/>
				
)
BlockReportOUT.Write(BlockHead)

Loop, %AbortedFF%
{
	HoldingFailure:= ""
	HoldingFailure:=Failure.Block[A_Index] . "," . Failure.Dlist[A_Index] . "," . Failure.Computer[A_Index] . "," . Failure.DStep[A_Index] . "`r`n"
	FailOUT.Write(HoldingFailure)
}
Loop, %ReportTotal%
{
	HoldingBlockReport:=""
	HoldingBlockReport:="<Row ss:AutoFitHeight=""0"" ss:Height=""45"">`r`n<Cell>`r`n<Data ss:Type=""String"">" . BlockReport.Block[A_Index] . "</Data>`r`n</Cell>`r`n<Cell>`r`n<Data ss:Type=""String"">" . BlockReport.Time[A_Index] . "</Data>`r`n</Cell>`r`n<Cell>`r`n<Data ss:Type=""String"">" . BlockReport.Computer[A_Index] . "</Data>`r`n</Cell>`r`n<Cell>`r`n<Data ss:Type=""String"">"  . BlockReport.Step[A_Index] . "</Data>`r`n</Cell>`r`n</Row>`r`n"
	BlockReportOUT.Write(HoldingBlockReport)
}
BlockFoot = 
(
			</Table>
		<x:WorksheetOptions/>
	</ss:Worksheet>
</Workbook>

)
BlockReportOUT.Write(BlockFoot)
ConcernVar:=AbortedFF
BlockReportOUT.Close()
FailOUT.Close()
return

;###########################################Prj-A-Lator SUBROUTINE########################################################################################

CS2CS_UTM_LatLon(CoordEnumObj,From="lonlat",To="EN",Zone="10")
{
	If (From = "lonlat" && To = "EN")
	{
		fromV 		:= "+proj=longlat +ellps=WGS84 +datum=WGS84 +no_defs"
		toV			:= "+proj=utm +zone=" . Zone . " +ellps=WGS84 +datum=WGS84 +units=m +no_defs"
	}
	If (From = "EN" && To = "lonlat")
	{
		fromV 		:= "+proj=utm +zone=" . Zone . " +ellps=WGS84 +datum=WGS84 +units=m +no_defs"
		toV			:= "+proj=longlat +ellps=WGS84 +datum=WGS84 +no_defs"
	}
	
	FileCreateDir, %A_WorkingDir%\proj4\proj\bin
	FileCreateDir, %A_WorkingDir%\proj4\proj\nad
	FileCreateDir, %A_WorkingDir%\proj4\Temp
	
	FileInstall, C:\install\proj4\proj\nad\world, %A_WorkingDir%\proj4\proj\nad\world
	FileInstall, C:\install\proj4\proj\nad\WO.lla, %A_WorkingDir%\proj4\proj\nad\WO.lla
	FileInstall, C:\install\proj4\proj\nad\WI.lla, %A_WorkingDir%\proj4\proj\nad\WI.lla
	FileInstall, C:\install\proj4\proj\nad\TN.lla, %A_WorkingDir%\proj4\proj\nad\TN.lla
	FileInstall, C:\install\proj4\proj\nad\stpaul.lla, %A_WorkingDir%\proj4\proj\nad\stpaul.lla
	FileInstall, C:\install\proj4\proj\nad\stlrnc.lla, %A_WorkingDir%\proj4\proj\nad\stlrnc.lla
	FileInstall, C:\install\proj4\proj\nad\stgeorge.lla, %A_WorkingDir%\proj4\proj\nad\stgeorge.lla
	FileInstall, C:\install\proj4\proj\nad\prvi.lla, %A_WorkingDir%\proj4\proj\nad\prvi.lla
	FileInstall, C:\install\proj4\proj\nad\ntv1_can.dat, %A_WorkingDir%\proj4\proj\nad\ntv1_can.dat
	FileInstall, C:\install\proj4\proj\nad\nad83, %A_WorkingDir%\proj4\proj\nad\nad83
	FileInstall, C:\install\proj4\proj\nad\nad27, %A_WorkingDir%\proj4\proj\nad\nad27
	FileInstall, C:\install\proj4\proj\nad\MD.lla, %A_WorkingDir%\proj4\proj\nad\MD.lla
	FileInstall, C:\install\proj4\proj\nad\hawaii.lla, %A_WorkingDir%\proj4\proj\nad\hawaii.lla
	FileInstall, C:\install\proj4\proj\nad\FL.lla, %A_WorkingDir%\proj4\proj\nad\FL.lla
	FileInstall, C:\install\proj4\proj\nad\esri, %A_WorkingDir%\proj4\proj\nad\esri
	FileInstall, C:\install\proj4\proj\nad\epsg, %A_WorkingDir%\proj4\proj\nad\epsg
	FileInstall, C:\install\proj4\proj\nad\conus.lla, %A_WorkingDir%\proj4\proj\nad\conus.lla
	FileInstall, C:\install\proj4\proj\nad\alaska.lla, %A_WorkingDir%\proj4\proj\nad\alaska.lla
	
	FileInstall, C:\install\proj4\proj\bin\cs2cs.exe, %A_WorkingDir%\proj4\proj\bin\cs2cs.exe
	FileInstall, C:\install\proj4\proj\bin\proj.dll, %A_WorkingDir%\proj4\proj\bin\proj.dll
	
	IN:=fileopen(A_WorkingDir . "\proj4\Temp\input.txt", "rw")
	loop % CoordEnumObj.X.MaxIndex()
		IN.write(CoordEnumObj.X[A_index] . " " . CoordEnumObj.Y[A_index] . "`r`n")
	IN.close()

	InfoCode =
	(
	"C:\install\proj4\proj\bin\cs2cs.exe" +proj=longlat +ellps=WGS84 +datum=WGS84 +no_defs +to +proj=utm +zone=10 +ellps=WGS84 +datum=WGS84 +units=m +no_defs "%A_WorkingDir%\proj4\Temp\input.txt" > "%A_WorkingDir%\proj4\Temp\output.txt"
	)
	Run, %comspec% /c %InfoCode%, , hide, CS2CS
	Process, Wait, %CS2CS%
	Process, WaitClose, %CS2CS%

	OUT:=fileopen(A_WorkingDir . "\proj4\Temp\output.txt", "rw")
	loop % CoordEnumObj.X.MaxIndex()
	{
		what := StrSplit(OUT.ReadLine(), " `t")
		CoordEnumObj.Xnew[A_Index] := what[1], CoordEnumObj.Ynew[A_Index] := what[2]
	}	
	
	FileRemoveDir, %A_WorkingDir%\proj4, 1
	
	return (CoordEnumObj)
}


Run_TILE_Builder(LASdir, TILEout, TILEprefix, TILEsize)
{
	FileInstall, C:\install\lastools\bin\lastile.exe, lastile.exe, 1
	
	InfoCode =
	(
	lastile -i "%LASdir%\*.las" -full_bb -tile_size %TILEsize% -odir "%TILEout%" -o %TILEprefix%.las
	)
	msgbox % InfoCode
	Run, %comspec% /c %InfoCode%, , Hide, LASTILE

	Process, Wait, %LASTILE% 
	Process, WaitClose, %LASTILE%
	return
}

Run_PRJ_Builder(LASdir, PRJname, TRJyes, TILEyes, TILEdir, TILEsize:=0)
{
	FileInstall, C:\install\lastools\bin\lasinfo.exe, lasinfo.exe, 1
	splitpath, PRJname, nameWext, nameDir, nameExt, nameNOext
	PRJfOUT:=fileopen(PRJname, "rw")
	If !TILEyes
	{
		Loop,  %LASdir%\*.las
		{
		If (A_Index = 1)
			SplitPath, A_LoopFileFullPath, FilewExt, FileDir, FileExt, FilenoExt
		++TotalLAS
		FileList = %FileList%%A_LoopFileFullPath%`n
		}
	}
	If TILEyes
	{
		Loop,  %TILEdir%\*.las
		{
		If (A_Index = 1)
			SplitPath, A_LoopFileFullPath, FilewExt, FileDir, FileExt, FilenoExt
		++TotalLAS
		FileList = %FileList%%A_LoopFileFullPath%`n
		}
	}

	Loop, parse, FileList, `n
	{
		InfoCode =
		(
		lasinfo -i %A_LoopField% -otxt -nv -nc
		)
		Run, %comspec% /c %InfoCode%, , Hide, LASINFO
	}

	Process, Wait, %LASINFO% 
	Process, WaitClose, %LASINFO%
	
TILEobj:=Object()
Loop, parse, FileList, `n
{

	If (A_LoopField = "")
		break
	if (a_index = 1)
	{
        selectedpath = %PRJname%
				
		PRJhead =
		(
[TerraScan project]
Scanner=Airborne
Storage=LAS1.2
StoreTime=1
StoreColor=1
RequireLock=0
Description=%nameWext%
FirstPointId=1
Directory=%FileDir%

		) 
		PRJfOUT.Write(PRJhead)
		
		if (TRJyes != 0)
		{
			PRJTRJhead =
			(
Trajectories=%TRJyes%
			
			)
			PRJfOUT.Write(PRJTRJhead)
		}
		
		PRJfoot =
		(
BlockSize=900
BlockNaming=0
BlockPrefix=pt


		)
		PRJfOUT.Write(PRJfoot)
	}
		
		splitpath, A_LoopField, wExt, Dir, Ext, noExt
		If TILEyes
		{
			FileRead, textVar, %Dir%\%noExt%.txt
			
			StringReplace textVar, textVar, %A_Space%    %A_Space%, %A_Space%, All 
			StringReplace textVar, textVar, %A_Space% %A_Space%, %A_Space%, All 
			StringReplace textVar, textVar, %A_Space%%A_Space%, %A_Space%, All 
			StringReplace textVar, textVar, %A_Space%%A_Space%, %A_Space%, All
			
			FileDelete, %Dir%\%noExt%.txt

			min := "min x y z"
			max := "max x y z"
			Loop, parse, textVar, `n
			{
				If InStr(A_LoopField, min)
				{
					StringSplit, MyArray, A_LoopField, %A_Space%
					
					MinX := round(MyArray6)
					MinY := round(MyArray7)
				}
				If InStr(A_LoopField, max)
				{
					StringSplit, MyArray, A_LoopField, %A_Space%
					
					MaxX := round(MyArray6)
					MaxY := round(MyArray7)
				}
			}

		
		PRJbod = 
		(
Block %noExt%.las
%MinX%.00 %MinY%.00
%MinX%.00 %MaxY%.00
%MaxX%.00 %MaxY%.00
%MaxX%.00 %MinY%.00
%MinX%.00 %MinY%.00


		)
		PRJfOUT.Write(PRJbod)
		}
		If !TILEyes
		{
			
			FileRead, textVar, %Dir%\%noExt%.txt
			
			StringReplace textVar, textVar, %A_Space%    %A_Space%, %A_Space%, All 
			StringReplace textVar, textVar, %A_Space% %A_Space%, %A_Space%, All 
			StringReplace textVar, textVar, %A_Space%%A_Space%, %A_Space%, All 
			StringReplace textVar, textVar, %A_Space%%A_Space%, %A_Space%, All
			
			FileDelete, %Dir%\%noExt%.txt

			min := "min x y z"
			max := "max x y z"
			Loop, parse, textVar, `n
			{
				If InStr(A_LoopField, min)
				{
					StringSplit, MyArray, A_LoopField, %A_Space%
					OminX := MyArray6, OminY := MyArray7
				}
				If InStr(A_LoopField, max)
				{
					StringSplit, MyArray, A_LoopField, %A_Space%
					OmaxX := MyArray6, OmaxY := MyArray7
				}
			}
			TILEobj.file[A_Index]:=noExt
			TILEobj.minX[A_index]:=OminX
			TILEobj.minY[A_index]:=OminY
			TILEobj.maxX[A_index]:=OmaxX
			TILEobj.maxY[A_index]:=OmaxY
		}
}
	If !TILEyes
	{
		Loop % TILEobj.file.MaxIndex()
		{
			C_minX:=TILEobj.minX[a_index],		O_minX:=0,		O_minX_C:=0,		O_minX_C_oppose:=0
			C_maxX:=TILEobj.maxX[a_index],		O_maxX:=0,		O_maxX_C:=0,		O_maxX_C_oppose:=0
			C_minY:=TILEobj.minY[a_index],		O_minY:=0,		O_minY_C:=0,		O_minY_C_oppose:=0
			C_maxY:=TILEobj.maxY[a_index],		O_maxY:=0,		O_maxY_C:=0,		O_maxY_C_oppose:=0

			Loop % TILEobj.file.MaxIndex()		;minX
			{
				If (abs(TILEobj.minX[A_Index] - C_minX) <= 5)
				{
					O_minX_C += 1
					O_minX += TILEobj.minX[A_Index]
				}
				Else If (abs(TILEobj.maxX[A_Index] - C_minX) <= 5)
				{
					O_minX_C += 1, O_minX_C_oppose += 1
					O_minX += TILEobj.maxX[A_Index]
				}
			}
			Loop % TILEobj.file.MaxIndex()		;maxX
			{
				If (abs(TILEobj.minX[A_Index] - C_maxX) <= 5)
				{
					O_maxX_C += 1, O_maxX_C_oppose += 1
					O_maxX += TILEobj.minX[A_Index]
				}
				Else If (abs(TILEobj.maxX[A_Index] - C_maxX) <= 5)
				{
					O_maxX_C += 1
					O_maxX += TILEobj.maxX[A_Index]
				}
			}
			Loop % TILEobj.file.MaxIndex()		;minY
			{
				If (abs(TILEobj.minY[A_Index] - C_minY) <= 5)
				{
					O_minY_C +=1
					O_minY += TILEobj.minY[A_Index]
				}
				Else If (abs(TILEobj.maxY[A_Index] - C_minY) <= 5)
				{
					O_minY_C += 1, O_minY_C_oppose += 1
					O_minY += TILEobj.maxY[A_Index]
				}
			}
			Loop % TILEobj.file.MaxIndex()		;maxY
			{
				If (abs(TILEobj.minY[A_Index] - C_maxY) <= 5)
				{
					O_maxY_C += 1, O_maxY_C_oppose += 1
					O_maxY += TILEobj.minY[A_Index]
				}
				Else If (abs(TILEobj.maxY[A_Index] - C_maxY) <= 5)
				{
					O_maxY_C += 1
					O_maxY += TILEobj.maxY[A_Index]
				}
			}
			
			BlockFile:=TILEobj.file[A_Index]
			,LLX := O_minX_C_oppose=0 ? C_minX : Round((O_minX/O_minX_C), 2)
			,URX := O_maxX_C_oppose=0 ? C_maxX : Round((O_maxX/O_maxX_C), 2)
			,LLY := O_minY_C_oppose=0 ? C_minY : Round((O_minY/O_minY_C), 2)
			,URY := O_maxY_C_oppose=0 ? C_maxY : Round((O_maxY/O_maxY_C), 2)

			PRJbod = 
			(
Block %BlockFile%.las
%LLX% %LLY%
%LLX% %URY%
%URX% %URY%
%URX% %LLY%
%LLX% %LLY%


			)
			PRJfOUT.Write(PRJbod)
		}
	}
			
				
	
	PRJfOUT.close()
	return
	}
	
Run_TRJ_Cutter(LASdir, SBETIN, TRJOUT, deduceYES, firstLine)
{
	FileInstall, C:\install\lastools\bin\lasinfo.exe, lasinfo.exe, 1
	InfoCode =
	(
	lasinfo -i %LASdir%\*.las -otxt
	)
	Run, %comspec% /c %InfoCode%, , Hide, LASINFO
	Process, Wait, %LASINFO% 
	Process, WaitClose, %LASINFO%
	
	Loop, %LASdir%\*.las
	{
		splitpath, A_LoopFileFullPath, wExt, Dir, Ext, noExt
		FileRead, textVar, %Dir%\%noExt%.txt
			
		StringReplace textVar, textVar, %A_Space%    %A_Space%, %A_Space%, All 
		StringReplace textVar, textVar, %A_Space% %A_Space%, %A_Space%, All 
		StringReplace textVar, textVar, %A_Space%%A_Space%, %A_Space%, All 
		StringReplace textVar, textVar, %A_Space%%A_Space%, %A_Space%, All
			
		FileDelete, %Dir%\%noExt%.txt

		GPStime := "gps_time"
		Loop, parse, textVar, `n
		{
			If InStr(A_LoopField, GPStime)
			{
				StrSplit(A_LoopField, A_Space)
				OminX := MyArray6, OminY := MyArray7
			}
		}
		TILEobj.file[A_Index]:=noExt
		TILEobj.minX[A_index]:=OminX
		TILEobj.minY[A_index]:=OminY
		TILEobj.maxX[A_index]:=OmaxX
		TILEobj.maxY[A_index]:=OmaxY
	}


	
}

AutoPrjSub:
Gui, Aprj:New	
Gui, Aprj:Add, GroupBox,	x26 y5 w600 h70 				+Disabled vAPRJ_GB1,						Project Creation
Gui, Aprj:Add, CheckBox,	x6 y25 w20 h30 					gchk1 vAPRJ_yes,
Gui, Aprj:Add, Text,		x36 y49 w70 h20 				+Disabled vAPRJ_Text1,						Output PRJ
Gui, Aprj:Add, Edit,		x116 y47 w400 h20 				+Disabled vAPRJ_PRJout,						Select PRJ Output / Name
Gui, Aprj:Add, Button, 		x526 y47 w80 h20 				+Disabled gAPRJ_PRJbrowse vAPRJ_Browse1,	Browse
Gui, Aprj:Add, Text, 		x36 y27 w76 h20 				+Disabled vAPRJ_Text2,						Input LAS / FLs
Gui, Aprj:Add, Edit, 		x116 y25 w400 h20 				+Disabled vAPRJ_LASin,						Select Input LAS / Raw FLs
Gui, Aprj:Add, Button, 		x526 y25 w80 h20 				+Disabled gAPRJ_LASbrowse vAPRJ_Browse2,	Browse
Gui, Aprj:Add, GroupBox, 	x26 y75 w600 h70 				+Disabled vAPRJ_GB2,						Tiling
Gui, Aprj:Add, CheckBox, 	x6 y95 w20 h30 					+Disabled gchk2 vATILE_yes,
Gui, Aprj:Add, Text, 		x36 y97 w76 h20 				+Disabled vAPRJ_Text3,						Output Tiles
Gui, Aprj:Add, Edit, 		x116 y95 w400 h20 				+Disabled vAPRJ_TILEout,					Select Tile Output Directory
Gui, Aprj:Add, Button, 		x526 y95 w80 h20 				+Disabled gAPRJ_TILEbrowse vAPRJ_Browse3,	Browse
Gui, Aprj:Add, Text, 		x326 y121 w50 h20 				+Disabled vAPRJ_Text4,						Tile Size?
Gui, Aprj:Add, Edit, 		x376 y119 w90 h20 				+Disabled vAPRJ_TILEsize,					Edit
Gui, Aprj:Add, Text, 		x480 y121 w36 h20 				+Disabled vAPRJ_Text5,						Prefix?
Gui, Aprj:Add, Edit, 		x516 y119 w90 h20 				+Disabled vAPRJ_TILEpre,					Edit
Gui, Aprj:Add, GroupBox,	x26 y145 w600 h70 				+Disabled vAPRJ_GB3, 						Trajectories
Gui, Aprj:Add, CheckBox,	x6 y165 w20 h30 				+Disabled gchk3 vATRJ_yes,
Gui, Aprj:Add, Text, 		x36 y167 w80 h20 				+Disabled vAPRJ_Text6,						Input OUT/SOL
Gui, Aprj:Add, Edit,		x116 y165 w400 h20 				+Disabled vAPRJ_SBETin,						Select Input .OUT / .SOL
Gui, Aprj:Add, Button,		x526 y165 w80 h20 				+Disabled gAPRJ_SBETbrowse vAPRJ_Browse4,	Browse
Gui, Aprj:Add, Text,		x36 y189 w76 h20 				+Disabled vAPRJ_Text7,						Output TRJs
Gui, Aprj:Add, Edit,		x116 y187 w200 h20 				+Disabled vAPRJ_TRJout,						Select Output TRJ Directory
Gui, Aprj:Add, Button,		x326 y187 w80 h20 				+Disabled gAPRJ_TRJbrowse vAPRJ_Browse5,	Browse
Gui, Aprj:Add, CheckBox,	x416 y189 w70 h20 				+Disabled vDEDUCE,							Deduce?
Gui, Aprj:Add, Text,		x492 y191 w42 h20 				+Disabled vAPRJ_Text8,						1st FL #
Gui, Aprj:Add, Edit,		x536 y189 w70 h20 				+Disabled vAPRJ_FirstLine,					Edit
Gui, Aprj:Add, GroupBox,	x26 y215 w600 h70 				+Disabled vAPRJ_GB4,						Grounds-Per-Line
Gui, Aprj:Add, CheckBox,	x6 y235 w20 h30 				+Disabled gchk4 vAMAC_yes,
Gui, Aprj:Add, Edit,		x46 y245 w470 h20 				+Disabled vAPRJ_MACROin,					Select GPL Macro
Gui, Aprj:Add, Button,		x526 y245 w80 h20 				+Disabled gAPRJ_MACRObrowse vAPRJ_Browse6,	Browse
Gui, Aprj:Add, Button,		x506 y305 w100 h30 				gAPRJ_Cancel,								Cancel
Gui, Aprj:Add, Button,		x396 y305 w100 h30 				+Disabled gAPRJ_OK vAPRJ_OK,				OK
Gui, Aprj:Add, Progress, 	x26 y295 w350 h20 				vAPRJ_Progress, 							10
Gui, Aprj:Add, Text, 		x26 y315 w350 h20 				vAPRJ_ProText, 								Setup...
;~ ; Generated using SmartGUI Creator 4.0
Gui, Aprj:Show,				x504 y0 h357 w644				, 											Prj-A-Lator
Return

chk1:
Gui, submit, nohide
GuiControl, Enable%APRJ_yes%, APRJ_GB1
GuiControl, Enable%APRJ_yes%, APRJ_Text1
GuiControl, Enable%APRJ_yes%, APRJ_PRJout
GuiControl, Enable%APRJ_yes%, APRJ_Browse1
GuiControl, Enable%APRJ_yes%, APRJ_Text2
GuiControl, Enable%APRJ_yes%, APRJ_LASin
GuiControl, Enable%APRJ_yes%, APRJ_Browse2
GuiControl, Enable%APRJ_yes%, ATILE_yes
GuiControl, Enable%APRJ_yes%, APRJ_OK
If !APRJ_yes
{
	Guicontrol, , ATILE_yes, 0
	gosub, chk2
}
return
chk2:
Gui, submit, nohide
GuiControl, Enable%ATILE_yes%, APRJ_GB2
GuiControl, Enable%ATILE_yes%, APRJ_Text3
GuiControl, Enable%ATILE_yes%, APRJ_TILEout
GuiControl, Enable%ATILE_yes%, APRJ_Browse3
GuiControl, Enable%ATILE_yes%, APRJ_Text4
GuiControl, Enable%ATILE_yes%, APRJ_TILEsize
GuiControl, Enable%ATILE_yes%, APRJ_Text5
GuiControl, Enable%ATILE_yes%, APRJ_TILEpre
GuiControl, Enable%ATILE_yes%, ATRJ_yes
If !ATILE_yes
{
	Guicontrol, , ATRJ_yes, 0
	gosub, chk3
}
return
chk3:
Gui, submit, nohide
GuiControl, Enable%ATRJ_yes%, APRJ_GB3
GuiControl, Enable%ATRJ_yes%, APRJ_Text6
GuiControl, Enable%ATRJ_yes%, APRJ_SBETin
GuiControl, Enable%ATRJ_yes%, APRJ_Browse4
GuiControl, Enable%ATRJ_yes%, APRJ_Text7
GuiControl, Enable%ATRJ_yes%, APRJ_TRJout
GuiControl, Enable%ATRJ_yes%, APRJ_Browse5
GuiControl, Enable%ATRJ_yes%, DEDUCE
GuiControl, Enable%ATRJ_yes%, APRJ_Text8
GuiControl, Enable%ATRJ_yes%, APRJ_FirstLine
GuiControl, Enable%ATRJ_yes%, AMAC_yes
If !ATRJ_yes
{
	Guicontrol, , AMAC_yes, 0
	gosub, chk4
}
return
chk4:
Gui, submit, nohide
GuiControl, Enable%AMAC_yes%, APRJ_GB4
GuiControl, Enable%AMAC_yes%, APRJ_MACROin
GuiControl, Enable%AMAC_yes%, APRJ_Browse6
return


APRJ_PRJbrowse:
Gui, +owndialogs
If (APRJ_PRJout = "Select PRJ Output / Name")
	APRJ_PRJout := ""
FileSelectFile, APRJ_PRJout, 16, *%APRJ_LASin%, Select name for new PRJ file OR overwrite existing PRJ file, TerraSolid Project File (*.prj)
If (APRJ_PRJout = "")
{
	Guicontrol, , APRJ_PRJout, User Must Select/Create PRJ File!
	return
}
GuiControl, , APRJ_PRJout, %APRJ_PRJout%
Gui, submit, nohide
return

APRJ_LASbrowse:
Gui, +owndialogs
If (APRJ_LASin = "Select Input LAS / Raw FLs")
	APRJ_LASin := ""
FileSelectFolder, APRJ_LASin, *%APRJ_LASin%, 3, Select Directory where LAS files are located
If ErrorLevel
{
	Guicontrol, , APRJ_LASin, User Must Select LAS Directory!
	return
}
GuiControl, , APRJ_LASin, %APRJ_LASin%
Gui, submit, nohide
return

APRJ_TILEbrowse:
Gui, +owndialogs
If (APRJ_TILEout = "Select Tile Output Directory")
	APRJ_TILEout := ""
FileSelectFolder, APRJ_TILEout, *%APRJ_TILEout%, 3, Select Directory for Tiled LAS Output.
If ErrorLevel
{
	Guicontrol, , APRJ_TILEout, User Must Select Tile Directory!
	return
}
GuiControl, , APRJ_TILEout, %APRJ_TILEout%
return

APRJ_SBETbrowse:
Gui, +owndialogs
If (APRJ_SBETin = "Select Input .OUT / .SOL")
	APRJ_SBETin := ""
FileSelectFile, APRJ_SBETin, 3, *%APRJ_SBETin%, Select Input Trajectory file for processing, IPAS \ POS SBET (*.sol; *.out)
If ErrorLevel
{
	Guicontrol, , APRJ_SBETin, User Must Select an SBET/SOL!
	return
}
GuiControl, , APRJ_SBETin, %APRJ_SBETin%
return

APRJ_TRJbrowse:
Gui, +owndialogs
If (APRJ_TRJout = "Select Output TRJ Directory")
	APRJ_TRJout := ""
FileSelectFolder, APRJ_TRJout, *%APRJ_TRJout%, 3, Select Output Directory for Trajectories
If ErrorLevel
{
	Guicontrol, , APRJ_TRJout, User Must Select an SBET/SOL!
	return
}
GuiControl, , APRJ_TRJout, %APRJ_TRJout%
return

APRJ_MACRObrowse:
Gui, +owndialogs
If (APRJ_MACROin = "Select GPL Macro")
	APRJ_MACROin := ""
FileSelectFile, APRJ_MACROin, 3, *%APRJ_MACROin%, Select TScan Macro File, TerraSolid Macro File (*.mac)
If ErrorLevel
{
	Guicontrol, , APRJ_MACROin, User Must Select an SBET/SOL!
	return
}
GuiControl, , APRJ_MACROin, %APRJ_MACROin%
return


APRJ_Cancel:
AprjGuiClose:
Gui, Aprj:Destroy
return

APRJ_OK:
Gui, Aprj:Submit, NoHide

If ATILE_yes
{
	GuiControl, , APRJ_Progress, 25
	Guicontrol, , APRJ_ProText, TIling Input LAS files...

	Run_TILE_Builder(APRJ_LASin, APRJ_TILEout, APRJ_TILEpre, APRJ_TILEsize)
}

GuiControl, , APRJ_Progress, 80
Guicontrol, , APRJ_ProText, Generating TerraScan PRJ file...

Run_PRJ_Builder(APRJ_LASin, APRJ_PRJout, ATRJ_yes, ATILE_yes, APRJ_TILEout, APRJ_TILEsize:=0)

GuiControl, , APRJ_Progress, 100
Guicontrol, , APRJ_ProText, Done!
Sleep, 2000
GuiControl, , APRJ_Progress, 10
Guicontrol, , APRJ_ProText, Setup...