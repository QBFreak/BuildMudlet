#cs ----------------------------------------------------------------------------

 AutoIt Version: 3.3.14.2
 Author:         QBFreak <qbfreak@qbfreak.net>

 Script Function:
    Download prerequisites for compiling Mudlet
     * prereqs are pulled from prerequsites.ini
     * any already downloaded are skipped
     * any already installed are skipped
     
     
    A quick note about AutoIt functions that return arrays:
     Functions in AutoIt that return arrays, put the count of the items returned
     in element 0. You'll find that [0] is a number and [1] is your first piece
     if data. Keeping with this convention, the array I use for GUI handles
     works the exact same way. That's why I initially define it with one element
     and set it to 0:

     $ahPrereqs[1] = [0]

#ce ----------------------------------------------------------------------------

#include <AutoItConstants.au3>
#include <ColorConstants.au3>
#include <FontConstants.au3>
#include <GUIConstantsEx.au3>
#include <MsgBoxConstants.au3>
#include <WinAPIFiles.au3>

Opt("GUIOnEventMode", 1) ; Change to OnEvent mode

Const $sAppTitle = "Mudlet Prerequisite Downloader"
Const $sFilePath = "prerequsites.ini"
Const $sDownloader = "wget.exe"
Const $sDownloaderOpts = "--no-check-certificate"

Const $PSTATUS_UNKNOWN = 0
Const $PSTATUS_PENDING = 1
Const $PSTATUS_DOWNLOADING = 2
Const $PSTATUS_DOWNLOADFAILED = 3
Const $PSTATUS_DOWNLOADED = 4
Const $PSTATUS_INSTALLING = 5
Const $PSTATUS_INSTALLED = 6
Const $PSTATUS_INSTALLFAILED = 7

;;;;;;;;;;;;;;;;;;;;;;;;;
;;;       Start       ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;

; Main window
$hGui = GUICreate($sAppTitle, 400, 600, 50, 50)
GUISetOnEvent($GUI_EVENT_CLOSE, "OnExit")

; How far from the top are we going to start?
local $iGUIoffset = 10

; Title
$hAppTitle = GUICtrlCreateLabel($sAppTitle, 30, $iGuiOffset, 400, 20)
GuiCtrlSetFont($hAppTitle, 12, $FW_SEMIBOLD)
$iGUIoffset = $iGUIoffset + 30

;; Make sure we have wget
If Not FileExists(@ScriptDir & "\" & $sDownloader) Then
    ; OHNOES ERROR!
    $hError = GUICtrlCreateLabel("Error: " & $sDownloader & " is not located in the same directory as the script.", 10, $iGUIoffset)
    GUICtrlSetColor($hError, $COLOR_RED)
    $iGUIoffset = $iGUIoffset + 20
    
    ; OK button
    $hOK = GUICtrlCreateButton("OK", 70, $iGUIoffset, 60)
    GUICtrlSetOnEvent($hOK, "OK_OnClick")

    ; Display the GUI
    GUISetState(@SW_SHOW)
    
    ; Wait indefinitely for the user to click OK or close
    While 1
        Sleep(100)
    Wend
EndIf

; Array of Ini section titles
Dim $aPrereqs = IniReadSectionNames($sFilePath)
; Arrays for our GUI handles, currently empty
Dim $ahPrereqs[1] = [0]
Dim $ahStatus[1] = [0]
; Array for Prerequisite status
Dim $aStatus[1] = [0]

If Not @error Then
    ; Expand our GUI handle array to be large enough for all the prerequisites
    Redim $ahPrereqs[$aPrereqs[0] + 1]
    Redim $ahStatus[$aPrereqs[0] + 1]
    Redim $aStatus[$aPrereqs[0] + 1]
    ; Even though I enlarged the array, I probably shouldn't be setting [0] to
    ;  the count of the contents until it actually contains something. Oh well.
    $ahPrereqs[0] = $aPrereqs[0]
    $ahStatus[0] = $ahPrereqs[0]
    $aStatus[0] = $ahPrereqs[0]
    ; Lets see what we've got in the Ini file
    For $i = 1 To $aPrereqs[0]
        $aStatus[$i] = $PSTATUS_UNKNOWN
        $ahStatus[$i] = GUICtrlCreateLabel("Unknown", 10, $iGUIoffset, 90, 15)
        $ahPrereqs[$i] = GUICtrlCreateLabel($aPrereqs[$i], 100, $iGUIoffset, 290, 15)
        $iGUIoffset = $iGUIoffset + 20
    Next
EndIf

$iGUIoffset = $iGUIoffset + 20

; OK button
$hOK = GUICtrlCreateButton("OK", 70, $iGUIoffset, 60, 30)
GUICtrlSetOnEvent($hOK, "OK_OnClick")
GUICtrlSetState($hOK, $GUI_DISABLE)
$iGUIoffset = $iGUIoffset + 40

$aWinPos = WinGetPos($hGUI)
WinMove($hGUI, "", $aWinPos[0], $aWinPos[1], $aWinPos[2], $iGUIoffset + 30)

; Display the GUI
GUISetState(@SW_SHOW)

; Make the GUI Always-on-top
WinSetOnTop($hGui, "", $WINDOWS_ONTOP)

;; UPDATE THE PREREQ STATUS
UpdateStatus()

;; Process downloads
While NextDownload() > -1
    ;; Process a single download
    Local $iDownload = NextDownload()
    
    ; Update the GUI
    $aStatus[$iDownload] = $PSTATUS_DOWNLOADING
    UpdateStatus()
    
    ; Load the URL and Download (saved file name) from the INI file
    Local $sURL = IniRead($sFilePath, $aPrereqs[$iDownload], "URL", "")
    Local $sDownload = IniRead($sFilePath, $aPrereqs[$iDownload], "Download", "")
    ; Are we missing the URL or Downloaded file name?
    If $sURL = "" Or $sDownload = "" Then
        ; Oh no! We are lost!
        $aStatus[$iDownload] = $PSTATUS_DOWNLOADFAILED
    Else
        ; Download the file
        RunWait(@ComSpec & ' /c "' & @ScriptDir & "\" & $sDownloader & '" ' & $sDownloaderOpts & " " & $sURL)
        ; Did it download?
        If FileExists($sDownload) Then
            ; Success!
            $aStatus[$iDownload] = $PSTATUS_DOWNLOADED
        Else
            ; Hrm, it seems that it didn't download
            $aStatus[$iDownload] = $PSTATUS_DOWNLOADFAILED
        EndIf
    EndIf
    
    ; Update the status indicators
    UpdateStatus()
Wend

;; Process installs
While NextInstall() > -1
    ;; Process a single install
    local $iInstall = NextInstall()
    
    ; Update the GUI
    $aStatus[$iInstall] = $PSTATUS_INSTALLING
    UpdateStatus()
    
    ; Load the Install string from the INI file
    Local $sInstall = IniRead($sFilePath, $aPrereqs[$iInstall], "Install", "")
    Local $sPath = IniRead($sFilePath, $aPrereqs[$iInstall], "Path", "")
    ; Are we missing the Install string?
    If $sInstall = "" or $sPath = "" Then
        ; Oh no! We are lost!
        $aStatus[$iInstall] = $PSTATUS_INSTALLFAILED
    Else
        ; Download the file
        RunWait(@ComSpec & " /c " & $sInstall)
        ; Did it fail?
        If @error Then
            $aStatus[$iInstall] = $PSTATUS_INSTALLFAILED
        Else
            ; Did it install?
            If FileExists($sPath) Then
                ; Success!
                $aStatus[$iInstall] = $PSTATUS_INSTALLED
            Else
                ; Hrm, it seems that it didn't download
                $aStatus[$iInstall] = $PSTATUS_INSTALLFAILED
            EndIf
        EndIf
    EndIf
    
    ; Update the status indicators
    UpdateStatus()
Wend

;; Done, enable the OK button and then do nothing
GUICtrlSetState($hOK, $GUI_ENABLE)
While 1
    Sleep(100)
Wend


;;;;;;;;;;;;;;;;;;;;;;;;;
;;;     Functions     ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;

; GUI Close event handler
Func OnExit()
    Exit
EndFunc

; OK click event handler
Func OK_OnClick()
    Exit
EndFunc

;; Update the status of our prerequistes
Func UpdateStatus()
    ; Loop through all the prerequisites
    For $i = 1 To $aPrereqs[0]
        ; Load up the appropriate INI section for the prereq
        local $aSection = IniReadSection($sFilePath, $aPrereqs[$i])
        If Not @error Then
            ; Loop through the key/value pairs of the INI section
            For $j = 1 To $aSection[0][0]
                Select
                    ; Download=...
                    Case StringLower($aSection[$j][0]) = "download"
                        ; Have we downloaded it already?
                        If FileExists($aSection[$j][1]) Then
                            ; Woo! But only update the status if we don't already have a better status
                            ; (ex: If we've Installed it, don't update the status to say we've downloaded it)
                            If $PSTATUS_DOWNLOADED > $aStatus[$i] Then
                                $aStatus[$i] = $PSTATUS_DOWNLOADED
                            EndIf
                        EndIf
                    ; Path=...
                    Case StringLower($aSection[$j][0]) = "path"
                        ; Have we installed it?
                        If FileExists($aSection[$j][1]) Then
                            ; Woo! Update the status!
                            If $PSTATUS_INSTALLED > $aStatus[$i] Then
                                $aStatus[$i] = $PSTATUS_INSTALLED
                            EndIf
                        EndIf
                EndSelect
            Next
        EndIf
        
        ; If the status wasn't changed by the previous, Then mark it pending
        If $PSTATUS_PENDING > $aStatus[$i] Then
            $aStatus[$i] = $PSTATUS_PENDING
        EndIf
        
        ; Update the label on the GUI to reflect the current status
        Select
            Case $aStatus[$i] = $PSTATUS_PENDING
                GUICtrlSetData($ahStatus[$i], "PENDING")
                GUICtrlSetColor($ahStatus[$i], $COLOR_NAVY)
            Case $aStatus[$i] = $PSTATUS_DOWNLOADING
                GUICtrlSetData($ahStatus[$i], "DOWNLOADING")
                GUICtrlSetColor($ahStatus[$i], $COLOR_BLUE)
            Case $aStatus[$i] = $PSTATUS_DOWNLOADFAILED
                GUICtrlSetData($ahStatus[$i], "FAILED")
                GUICtrlSetColor($ahStatus[$i], $COLOR_RED)
            Case $aStatus[$i] = $PSTATUS_DOWNLOADED
                GUICtrlSetData($ahStatus[$i], "DOWNLOADED")
                GUICtrlSetColor($ahStatus[$i], $COLOR_OLIVE)
            Case $aStatus[$i] = $PSTATUS_INSTALLING
                GUICtrlSetData($ahStatus[$i], "INSTALLING")
                GUICtrlSetColor($ahStatus[$i], $COLOR_LIME)
            Case $aStatus[$i] = $PSTATUS_INSTALLFAILED
                GUICtrlSetData($ahStatus[$i], "FAILED")
                GUICtrlSetColor($ahStatus[$i], $COLOR_RED)
            Case $aStatus[$i] = $PSTATUS_INSTALLED
                GUICtrlSetData($ahStatus[$i], "INSTALLED")
                GUICtrlSetColor($ahStatus[$i], $COLOR_GREEN)
            Case Else
                GUICtrlSetData($ahStatus[$i], "UNKNOWN")
                GUICtrlSetColor($ahStatus[$i], $COLOR_GRAY)
        EndSelect
    Next
EndFunc

;; Determine which prereq needs to be downloaded next
Func NextDownload()
    For $i = 1 to $aStatus[0]
        If $aStatus[$i] = $PSTATUS_PENDING Then
            Return $i
        EndIf
    Next
    Return -1
EndFunc

Func NextInstall()
    For $i = 1 to $aStatus[0]
        If $aStatus[$i] = $PSTATUS_DOWNLOADED Then
            Return $i
        EndIf
    Next
    Return -1
EndFunc
