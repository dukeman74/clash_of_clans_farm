#Region ;**** Directives created by AutoIt3Wrapper_GUI ****
#AutoIt3Wrapper_Icon=face.ico
#AutoIt3Wrapper_Outfile=elixer farm x86.exe
#AutoIt3Wrapper_Outfile_x64=elixer farm x64.exe
#AutoIt3Wrapper_Compile_Both=y
#AutoIt3Wrapper_UseX64=y
#EndRegion ;**** Directives created by AutoIt3Wrapper_GUI ****
#include <misc.au3>
#include <Constants.au3>
#include <MsgBoxConstants.au3>
#include <WinAPI.au3>
#include <GUIConstantsEx.au3>
#include <GuiButton.au3>
#include <GDIPlus.au3>
#include <ScreenCapture.au3>
#include <File.au3>
#include <String.au3>

HotKeySet("^!q", "Quit")


If True Then ;initialize GUI and other variables
	$guu = GUICreate("Clash Builder Elixer Farm", 500, 500, 100,100)
	$x=0
	$y=0

	$winlabel = GUICtrlCreateLabel("battles: 0", 10, 430, 200, 20)

	$hotkeys = GUICtrlCreateLabel("QUIT: ctrl+alt+q", 1, 0)
	$hotkeys = GUICtrlCreateLabel("hold ESC: break out of farm without closing", 1, 30)
	$runtime = GUICtrlCreateLabel("runtime: 0 min", 233, 400,2000)
	$initmoney = GUICtrlCreatebutton("", 80, 430,150,50,$BS_BITMAP)
	$currentmoney = GUICtrlCreatebutton("", 280, 430,150,50,$BS_BITMAP)


	$clipcoords = GUICtrlCreateButton("copy coords", 300, 10)
	$clipblock = GUICtrlCreateButton("copy block untill", 300, 40)
	$farmbutton = GUICtrlCreateButton("farm", 40, 60)

	Opt("GUICloseOnESC", 0)
	Opt("SendKeyDownDelay", 20)
	Global $fileheader = "temp"
	$dll = DllOpen("user32.dll")
	DirCreate($fileheader)
	$farm_start_timer=Null
	$battles=0
	$battles_per_collect=10


	WinSetOnTop($guu, "", $WINDOWS_ONTOP)
	GUISetState(@SW_SHOW, $guu)

	$writeout=""
	$hand = WinGetHandle("Clash of Clans")
	if @error <> 0 Then
		MsgBox($MB_SYSTEMMODAL, "clash not running", "launch clash of clans from google play on pc")
		Quit()
	EndIf
	WinMove($hand,"",700,200,906,539)
	WinActivate($hand)

EndIf

While True
	Sleep(10)
	$idMsg = GUIGetMsg()
	Switch $idMsg
		Case $GUI_EVENT_CLOSE
			Quit()
		Case $clipcoords
			$t=await_mouse_click()
			set_x_y()
			ClipPut("mouse_click(" & $t[0]-$x & "," & $t[1]-$y & ")")
		Case $clipblock
			$t=await_mouse_click()
			set_x_y()
			$mp=MouseGetPos()
			MouseMove($mp[0]+100,$mp[1],0)
			$pixel=PixelGetColor($mp[0],$mp[1])
			MouseMove($mp[0],$mp[1],0)
			ClipPut("block_until_match(" & $t[0]-$x & "," & $t[1]-$y & ", 0x" & Hex($pixel,6) & ")")
		Case $farmbutton
			$fname=$fileheader & "/init.bmp"
			set_x_y()
			snap($fname)
			_GUICtrlButton_SetImage($initmoney,$fname)
			$farm_start_timer=TimerInit()
			$local_battles=0
			WinActivate($hand)
			While True
				if _IsPressed("1B",$dll) Then
					ExitLoop
				EndIf
				queue()
				mouse_click(224,481) ; click troop 1
				sleep(50)
				mouse_click(58,216) ; random placement
				spam_until_match(76,397, 0xFC5D64) ; surrender button
				mouse_click(62,401)
				block_until_match(570,328, 0xDAF77E) ; okay to surrender
				mouse_click(520,326)
				block_until_match(495,458, 0x8BD43A) ; return home after loss screen
				mouse_click(452,451)
				block_until_match(26,420, 0xA84A10) ; attack square
				finish_battle()
				sleep(100)
				$local_battles+=1
				if $local_battles==$battles_per_collect Then
					$local_battles=0
					sleep(400)
					mouse_click_drag(300,300,0,0)
					mouse_click_drag(300,300,0,0)
					mouse_click_drag(300,300,0,0)
					MouseWheel("down",10)
					mouse_click_drag(300,100,300,400)
					;ExitLoop
					;mouse_click(549,110)
					;mouse_click(543,100)
					;mouse_click(542,106)
					sleep(200)
					mouse_click(545,107);elixer cart
					spam_until_match(587,428, 0x8D5200); wood near collect
					mouse_click(645,453)
					sleep(100)
					mouse_click(750,83);close collect
					mouse_click(859,173);move mouse away for pic
					sleep(500)
					update_picture()
				EndIf
			WEnd
	EndSwitch
WEnd
Func snap($fname,$xi=738,$yi=80,$x2=890,$y2=110)
   $boi=_ScreenCapture_Capture("", $x + $xi, $y + $yi, $x + $x2, $y + $y2)
   _ScreenCapture_SaveImage ( $fname, $boi)
EndFunc

Func return_to_village_and_requeue()
	mouse_click(446,432)
	block_until_match(26,420, 0xA84A10)
	queue()
EndFunc

func queue()
	mouse_click(64,474) ; attack button
	block_until_match(713,355, 0x69824F) ; green enter battle button
	mouse_click(683,354)
	block_until_match(80,45, 0xF8F895,return_to_village_and_requeue) ; defender
EndFunc

Func pic_no_mouse($fname, $x, $y)
	MouseMove(0, 0, 0)
	Sleep(10)
	MouseMove($x, $y, 0)
EndFunc   ;==>pic_no_mouse

func set_x_y()
	$a=WinGetPos($hand)
	$x=$a[0]
	$y=$a[1]
EndFunc

Func await_mouse_click()
	While True
		If _IsPressed("02") Then
			return(MouseGetPos())
		EndIf
	WEnd
EndFunc   ;==>await_mouse_click

Func mouse_click($cx,$cy,$alt=False)
	MouseClick($MOUSE_CLICK_LEFT,$x+$cx,$y+$cy,1,0)
EndFunc

Func mouse_click_drag($cx,$cy,$cx2,$cy2)
	MouseClickDrag($MOUSE_CLICK_LEFT,$x+$cx,$y+$cy,$x+$cx2,$y+$cy2,0)
EndFunc

Func update_picture()
	$fname=$fileheader & "/current.bmp"
	snap($fname)
	_GUICtrlButton_SetImage($currentmoney,$fname)

EndFunc

func finish_battle()
	$battles+=1
	GUICtrlSetData($winlabel,"battles: " & $battles)
	$str="runtime: " & (TimerDiff($farm_start_timer)/(1000*60))
	$str=StringSplit($str,".")[1] & " min"
	GUICtrlSetData($runtime,$str)
EndFunc

Func spam_until_match($cx,$cy,$pixel)
	$myx=$cx+$x
	$myy=$cy+$y
	$annoyance=0
	$t=MouseGetPos()
	While pixel_similarity(PixelGetColor($myx, $myy),$pixel)<.98
		$xoff=Random(0,$annoyance)
		$yoff=Random(0,$annoyance)
		MouseClick($MOUSE_CLICK_LEFT,$t[0]+$xoff,$t[1]+$yoff,1,0)
		$annoyance+=0.5
		sleep(10)
	WEnd
EndFunc

Func sad()
	ConsoleWrite("block gave up" & @CRLF)
EndFunc

Func block_until_match($cx,$cy,$pixel,$fallback=sad)
	$timer=TimerInit()
	$myx=$cx+$x
	$myy=$cy+$y
	While pixel_similarity(PixelGetColor($myx, $myy),$pixel)<.98
		sleep(10)
		if TimerDiff($timer) > 4000 Then
			return($fallback())
		EndIf
	WEnd
EndFunc

Func pixel_similarity($p1, $p2)
	$r1 = BitShift(BitAND($p1, 0xFF0000), 16)
	$g1 = BitShift(BitAND($p1, 0x00FF00), 8)
	$b1 = BitAND($p1, 0x0000FF)

	$r2 = BitShift(BitAND($p2, 0xFF0000), 16)
	$g2 = BitShift(BitAND($p2, 0x00FF00), 8)
	$b2 = BitAND($p2, 0x0000FF)

	$off = 0
	$off += Abs($r1 - $r2)
	$off += Abs($g1 - $g2)
	$off += Abs($b1 - $b2)
	$off /= 3.0
	$off /= 255.0
	$sim = 1 - $off
	Return ($sim)
EndFunc

Func Quit()
	DirRemove($fileheader,1)
	Exit
EndFunc
