SetBatchLines, -1
#Include class_EasyIni.ahk

vIni := class_EasyIni("test1500.ini") ; Create

Loop 1500
{
	   if (!vIni.AddSection(chr(A_Index), A_Index, A_Index, sError))
			   sErrors .= sError "`n"
} ; Takes < 1sec

vIni.Save()
return