; 8 Queens
;
; This script is based on example1.nsi, but it remember the directory, 
; has uninstall support and (optionally) installs start menu shortcuts.
;
; It will install '8 Queens' into a directory that the user selects.
;
;--------------------------------

; The name of the installer
Name "8 Queens, 3.0.3009"

; The file to write
!define PATH_OUT "..\build\windows\install"
!system 'md "${PATH_OUT}"'

OutFile "${Path_Out}\8-Queens-install-3-0-3009.exe"

; Request application privileges for Windows Vista and higher
RequestExecutionLevel admin

; Build Unicode installer
Unicode True

; The default installation directory
InstallDir $PROGRAMFILES\8Queens

; Registry key to check for directory (so if you install again, it will 
; overwrite the old one automatically)
InstallDirRegKey HKLM "Software\NSIS_8Queens" "Install_Dir"

;--------------------------------

; Pages

Page components
Page directory
Page instfiles

UninstPage uninstConfirm
UninstPage instfiles

;--------------------------------

; The stuff to install
Section "8 Queens (required)"

  SectionIn RO
  
  ; Set output path to the installation directory.
  SetOutPath $INSTDIR
  
  ; Put file there
  File /r "..\build\windows\runner\Release\*.*"
  
  ; Write the installation path into the registry
  WriteRegStr HKLM SOFTWARE\NSIS_8Queens "Install_Dir" "$INSTDIR"
  
  ; Write the uninstall keys for Windows
  WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\8Queens" "DisplayName" "NSIS 8Queens"
  WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\8Queens" "UninstallString" '"$INSTDIR\uninstall.exe"'
  WriteRegDWORD HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\8Queens" "NoModify" 1
  WriteRegDWORD HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\8Queens" "NoRepair" 1
  WriteUninstaller "$INSTDIR\uninstall.exe"
  
SectionEnd

; Optional section (can be disabled by the user)
Section "Start Menu Shortcuts"

  CreateDirectory "$SMPROGRAMS\8Queens"
  CreateShortcut "$SMPROGRAMS\8Queens\Uninstall.lnk" "$INSTDIR\uninstall.exe"
  CreateShortcut "$SMPROGRAMS\8Queens\8Queens.lnk" "$INSTDIR\eightqueens.exe"

SectionEnd

; Optional section (can be disabled by the user)
Section "Desktop Menu Shortcuts"

  CreateShortcut "$DESKTOP\8 Queens.lnk" "$INSTDIR\eightqueens.exe"

SectionEnd

;--------------------------------

; Uninstaller

Section "Uninstall"
  
  ; Remove registry keys
  DeleteRegKey HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\8Queens"
  DeleteRegKey HKLM SOFTWARE\NSIS_8Queens

  ; Remove shortcuts, if any
  Delete "$SMPROGRAMS\8Queens\*.lnk"
  Delete "$DESKTOP\8 Queens.lnk"

  ; Remove directories
  RMDir "$SMPROGRAMS\8Queens"
  RMDir /r "$INSTDIR"

SectionEnd
