@echo off

rem pdftk and calibre must be installed
rem create source and target dir
rem run cmd with /u -for utf 16
rem in RecoverCopy select . for suffix for folder name


chcp 65001
setlocal EnableDelayedExpansion EnableExtensions


set "SourceParentDir=C:\Original"
set "TargetDir=C:\Processed"
del "%SourceParentDir%\data_A.txt" >nul 2>&1
del "%SourceParentDir%\data_B.txt" >nul 2>&1

set back=%cd%
set "files="
set "originalPDF="


rem create list of pdf files in root dir
for  %%l in (*.pdf) do (
	echo "!%%~nxl">> "%SourceParentDir%\data_B.txt"
)

rem loop through subdirectories
for /d %%i in (%SourceParentDir%\*) do (
	
	rem get filepath of master pdf
	set "originalPDFpath=%%~i"
	set "originalPDFpath=!originalPDFpath!.pdf"
	
	rem get filename of master pdf
	set "originalPDF=%%~nxi"
	set "originalPDF=!originalPDF!.pdf"
	rem echo !originalPDF!
	
	rem create md file
	call :CreateTxtHead
	
	rem create txt for comparison
	call :CreateList
	
	rem traverse subdirectories
	cd "%%i"
	
	rem get list of pdf files
	(for /R %%a in (*.pdf) do (
		set "files=!files! "%%~fa""
		
		set "mdFileName=%%~fa"
		
		echo * !mdFileName:~9,-4!>>"%SourceParentDir%\!originalPDF!.attachments.md"
	)
	
	rem combine pdf files
	call :CreatePDFfromTXT
	call :CopyPDF
	set "files="
	)
	
)

rem copy pdf files without children
call :CopyOriginal

cd %back%
exit /b

:CreateTxtHead
echo ### evidence:>>"%SourceParentDir%\!originalPDF!.attachments.md"
echo !originalPDF:~0,-4!>>"%SourceParentDir%\!originalPDF!.attachments.md"
echo ### attachments:>>"%SourceParentDir%\!originalPDF!.attachments.md"
exit /b

:CreateList
echo "!originalPDF!">> %SourceParentDir%\data_A.txt
exit /b


:CreatePDFfromTXT
ebook-convert "%SourceParentDir%\!originalPDF!.attachments.md" "%TargetDir%\tmp\!originalPDF!.attachments.md.pdf"
exit /b

:CopyPDF
pdftk "!originalPDFpath!" "%TargetDir%\tmp\!originalPDF!.attachments.md.pdf" !files! cat output "%TargetDir%\!originalPDF!"	
exit /b


:CopyOriginal
for /f "delims=" %%G in ('findstr /vixg:"%SourceParentDir%\data_A.txt" "%SourceParentDir%\data_B.txt"') do copy "%SourceParentDir%\%%~G" "%TargetDir%"
exit /b
