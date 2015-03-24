SetBatchLines, -1
#NoEnv

ENVI_hdr_READ(fileObj) { ;read an ENVI header...assume wavelength is the last line
	hdrObj := object()
	loop {
		line := fileObj.ReadLine()
		if instr(line, "description") {
			hold := ""
			RegExMatch(line, "= (.*)$", hold)
			hdrObj.desc := hold1
		}
		else if instr(line, "samples") {
			hold := ""
			RegExMatch(line, "= (.*)$", hold)
			hdrObj.samples := hold1+0
		}
		else if instr(line, "lines") {
			hold := ""
			RegExMatch(line, "= (.*)$", hold)
			hdrObj.lines := hold1+0
		}
		else if instr(line, "bands") {
			hold := ""
			RegExMatch(line, "= (.*)$", hold)
			hdrObj.bands := hold1+0
		}
		else if instr(line, "header offset") {
			hold := ""
			RegExMatch(line, "= (.*)$", hold)
			hdrObj.offset := hold1+0
		}
		else if instr(line, "file type") {
			hold := ""
			RegExMatch(line, "= (.*)$", hold)
			hdrObj.filetype := hold1
		}
		else if instr(line, "data type") {
			hold := ""
			RegExMatch(line, "= (.*)$", hold)
			hdrObj.dataType := hold1
		}
		else if instr(line, "interleave") {
			hold := ""
			RegExMatch(line, "= (.*)$", hold)
			hdrObj.interleave := hold1
		}
		else if instr(line, "sensor type") {
			hold := ""
			RegExMatch(line, "= (.*)$", hold)
			hdrObj.senType := hold1
		}
		else if instr(line, "byte order") {
			hold := ""
			RegExMatch(line, "= (.*)$", hold)
			hdrObj.byteOrder := hold1
		}
		else if instr(line, "x start") {
			hold := ""
			RegExMatch(line, "= (.*)$", hold)
			hdrObj.xStart := hold1
		}
		else if instr(line, "y start") {
			hold := ""
			RegExMatch(line, "= (.*)$", hold)
			hdrObj.yStart := hold1
		}
		else if instr(line, "wavelength") AND !instr(line, "units")
		{
			loop {
				line .= fileObj.ReadLine()
			} until instr(line, "}")
				hdrObj.wavelengths := SubStr(line, 14)
		}
		else if instr(line, "wavelength units")
		{
			hold := ""
			RegExMatch(line, "= (.*)$", hold)
			hdrObj.waveUnits := hold1
		}
		else if fileObj.AtEOF 
			break

	}
		ListVars
		msgbox % hdrObj.lines
	if (hdrObj.dataType = 1)
		hdrObj.byteLen := 1
	else if (hdrObj.dataType = 2)
		hdrObj.byteLen := 2
	else if (hdrObj.dataType = 3)
		hdrObj.byteLen := 4
	else if (hdrObj.dataType = 4)
		hdrObj.byteLen := 4
	else if (hdrObj.dataType = 5)
		hdrObj.byteLen := 8
	else if (hdrObj.dataType = 6)
		hdrObj.byteLen := 8
	else if (hdrObj.dataType = 9)
		hdrObj.byteLen := 16
	else if (hdrObj.dataType = 12)
		hdrObj.byteLen := 2
	else if (hdrObj.dataType = 13)
		hdrObj.byteLen := 4
	else if (hdrObj.dataType = 14)
		hdrObj.byteLen := 8
	else if (hdrObj.dataType = 15)
		hdrObj.byteLen := 8
	
	return hdrObj
}

ENVI_hdr_WRITE_lineUpdate(fileObj, hdrObj, lineUpdate) {
	fileObj.Write("ENVI`r`n")
	, fileObj.Write("description = " . hdrObj.desc . "`r`n")
	, fileObj.Write("data type = " . hdrObj.dataType . "`r`n")
	, fileObj.Write("byte order = " . hdrObj.byteOrder . "`r`n")
	, fileObj.Write("interleave = " . hdrObj.interleave . "`r`n")
	, fileObj.Write("header offset = " . hdrObj.offset . "`r`n")
	, fileObj.Write("samples = " . hdrObj.samples . "`r`n")
	, fileObj.Write("lines = " . lineUpdate . "`r`n")
	, fileObj.Write("bands = " . hdrObj.bands . "`r`n")
	, fileObj.Write("wavelength units = " . hdrObj.waveUnits . "`r`n")
	, fileObj.Write("wavelength = " . hdrObj.wavelengths . "`r`n")
}

HEADWALL_frameIndex_READ(fileObj) { ;read a HEADWALL frameIndex file into a file object
	fiObj := object()
	Loop 
	{
		line := ""
		if (a_index = 1) {
			line := fileObj.ReadLine()
			continue
		}
		
		++lineIndex
		line := fileObj.ReadLine()
		
		fiObj[lineIndex] := line
		if fileObj.AtEOF
			break
	}
	
	return fiObj
}

HEADWALL_frameIndex_WRITE(fileObj, fiObj, lineOffset, lineCount) {
	fileObj.Write("Frame#" . a_tab . "Time`r`n")
	loop % lineCount {
		fileObj.Write(fiObj[lineOffset+a_index] )
	}
}

;////////////////////////////////////////////////
; loop through user parameters and grab file names
;////////////////////////////////////////////////
fileList := object()
fileListNum := object()

loop, %0% 
{
	++fileIndex
	fileList[fileIndex] := %a_index% 
	SplitPath, %a_index%, wExt, Dir, ext, noExt
	fileListNum[fileIndex] := substr(noExt, 5)
	file4read := %a_index% . ".hdr"
	FileRead, rawHold, %file4read%
	if instr(rawHold, "`r`n")
		continue
	else
	{
		StringReplace, rawHoldNew, rawHold, `n, `r`n, All
		FileDelete, %file4read%
		FileAppend, %rawHoldNew%, %file4read%
	}
}

;////////////////////////////////////////////////
; indentify size of file chunks required by user
;////////////////////////////////////////////////
InputBox,   bilEndline, divideRawBILs, Maximum number of lines per divided BIL file., , , , , , , , 1000
FileSelectFolder, outDir, *%Dir%, 3, Select output folder for new "chunked" files

Progress, R0-%fileIndex%, Files completed:
;////////////////////////////////////////////////
; loop through files...
;////////////////////////////////////////////////
loop % fileIndex {
	fileName := fileList[a_index]
	fiNum := fileListNum[a_index]
	SplitPath, fileName, wExt, Dir, ext, noExt
	Progress, %a_index%, Files completed: %a_index%
	Progress, Off
	
	;////////////////////////////////////////////////
	;  log HDR file characteristics for use in slicing up file
	;////////////////////////////////////////////////
	hdrFile := fileopen(fileName . ".hdr", "rw")
	hdrObj := ENVI_hdr_READ(hdrFile)
	hdrFile.Close()
	ListVars
	msgbox % hdrObj.lines
	;////////////////////////////////////////////////
	; If original file size is smaller than requested chunk size, output original file and original frameIndex/HDR files
	;////////////////////////////////////////////////
	if (hdrObj.lines <= bilEndline) {
		source := Dir . "\" . noExt
		destination := outDir . "\" . noExt
		FileCopy, %source%.hdr, %destination%_1.hdr, 1
		FileCopy,  %source%, %destination%_1, 1
		FileCopy,  %Dir%\frameIndex_%fiNum%.txt, %outDir%\frameIndex_%fiNum%_1.txt, 1
		continue
	}
	
	;////////////////////////////////////////////////
	; log frameIndex file data for use in chunks
	;////////////////////////////////////////////////
	fiFile := FileOpen("frameIndex_" . fiNum . ".txt", "rw")
	fiObj := HEADWALL_frameIndex_READ(fiFile)
	fiFile.Close()
	;////////////////////////////////////////////////
	; calculate numbers to determine file pointer movement and ultimate file size output
	;////////////////////////////////////////////////
	totalSize := hdrObj.byteLen * hdrObj.bands * hdrObj.samples * hdrObj.lines
	chipSize := hdrObj.byteLen * hdrObj.bands * hdrObj.samples * bilEndline
	;////////////////////////////////////////////////
	;...for moving pointer and file size...
	;////////////////////////////////////////////////
	chipCount := Floor(totalSize/chipSize)
	modDivisorByte := chipSize*chipCount
	remainCount := Mod(totalSize, modDivisorByte)
	;////////////////////////////////////////////////
	;...for output line amounts...
	;////////////////////////////////////////////////
	lineCount := Floor(hdrObj.lines/bilEndline)
	modDivisorLine := lineCount*bilEndline
	remainLine := Mod(hdrObj.lines, modDivisorLine)
	fiLineCount := 0
	
	;////////////////////////////////////////////////
	; open original BIL file
	;////////////////////////////////////////////////
	enviFile := FileOpen(fileName, "rw")
	enviFileindex := 0
	;////////////////////////////////////////////////
	; loop through BIL file chunks and get chunk data
	;////////////////////////////////////////////////
	loop % chipCount {
		++enviFileindex
		
		fileChip := ""
		VarSetCapacity(fileChip, chipSize)
		enviFile.RawRead(fileChip, chipSize)
		
		enviFilechunk := FileOpen(outDir . "\" . wExt . "_" . enviFileindex, "rw")
		enviFilechunk.RawWrite(fileChip, chipSize)
		enviFilechunk.close()
		;////////////////////////////////////////////////
		;write HDR for chunk
		;////////////////////////////////////////////////
		hdrFilechunk := FileOpen(outDir . "\" . wExt . "_" . enviFileindex . ".hdr", "rw")
		ENVI_hdr_WRITE_lineUpdate(hdrFilechunk, hdrObj, bilEndline)
		hdrFilechunk.close()		
		;////////////////////////////////////////////////
		;write frameIndex for chunk
		;////////////////////////////////////////////////
		fiFilechunk := FileOpen(outDir . "\" . "frameIndex_" . fiNum . "_" . enviFileindex . ".txt", "rw")
		HEADWALL_frameIndex_WRITE(fiFilechunk, fiObj, fiLineCount, bilEndline)
		fiFilechunk.Close()
		
		fiLineCount := bilEndline*enviFileindex
	}
	;////////////////////////////////////////////////
	; write last chunk that is the remainder of original file after all full-size chunks are removed
	;////////////////////////////////////////////////
	++enviFileindex
	fileChip := ""
	VarSetCapacity(fileChip, remainCount)
	enviFile.RawRead(fileChip, remainCount)

	enviFilechunk := FileOpen(outDir . "\" . wExt . "_" . enviFileindex, "rw")
	enviFilechunk.RawWrite(fileChip, remainCount)
	enviFilechunk.close()
	
	;////////////////////////////////////////////////
	;write HDR for remainder chunk
	;////////////////////////////////////////////////
	hdrFilechunk := FileOpen(outDir . "\" . wExt . "_" . enviFileindex . ".hdr", "rw")
	ENVI_hdr_WRITE_lineUpdate(hdrFilechunk, hdrObj, remainLine)
	hdrFilechunk.close()	
	;////////////////////////////////////////////////
	;write frameIndex for remainder chunk
	;////////////////////////////////////////////////
	fiFilechunk := FileOpen(outDir . "\" . "frameIndex_" . fiNum . "_" . enviFileindex . ".txt", "rw")
	HEADWALL_frameIndex_WRITE(fiFilechunk, fiObj, fiLineCount, remainLine)
	fiFilechunk.Close()
}
		
		Progress, %fileIndex%, DONE!
		sleep, 2000
		
		ExitApp
		
	