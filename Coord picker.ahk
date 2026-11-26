; COORD PICKER
; To pick coordinates and calulate some necessary values
; Idk if texts can be aligned correctly in other window version/style. This is tested in win10

/* 
 hotkeys:
 Mouse 4 / F5: copy screen coordinate
 Mouse 5 / F6: copy window coordinate
 Middle Mouse: save the screen coordinates
 Right Mouse: pause (hold)
 Esc: terminate script
*/

; req
#SingleInstance, force
#Requires AutoHotkey <2.0
CoordMode, tooltip, screen

; placeholder and declare var
posmsg1 := "X: ---- `t Y: ----"
posmsg2 := "X: ---- `t Y: ----"
dis := "----", shifted = "----"
rad := "----", deg := "----"
point := 1, state := true
pointmsg = Started

; enable hotkey
Sysget, btncount, 43
tcurkey := (btncount = 5) 
	? {"XButton1":"CopyScr", "XButton2": "CopyWin", "MButton": "CalcKey"}
	: {"F5":"CopyScr", "F6": "CopyWin", "MButton": "CalcKey"}
for hkey, name in tcurkey
	hotkey, %hkey%, %name%, on
cachebtncount := btncount

; main loop
loop {
MouseCoord()
if !btncount
	message = Mouse is not installed
else
message =
(
+ Mouse coordinates
- Screen:    X: %scrX%`t Y: %scrY%
- Window: X: %winX%`t Y: %winY%
===================
+ Status:
%pointmsg%

+ Saved coordinates (screen)
- Coord 1: %posmsg1%
- Coord 2: %posmsg2%

+ Calculation (crd1 -> crd2)
- Distance (px):  `t %dis%
- Shifted (X , Y): `t %shifted%
- Angle (between unit vct i 
& vct of two saved coords)
 Radian / pi:`t %rad%
 Degree:   `t %deg% 
===================
Made by Dungx
AHK version: %A_AhkVersion%
)
tooltip, %message%
sleep, 10
}

CopyScr:
pointmsg = Copied screen coord
clipboard = %scrX%, %scrY%
return

CopyWin:
pointmsg = Copied window coord
clipboard = %winX%, %winY%
return

MButton::
return

RButton::
return


; capture mouse coord in "real" time (maybe > 10ms)
MouseCoord() {
	global
	Sysget, btncount, 43
	if (GetKeyState("RButton", "P") || !btncount) {
		pointmsg = Paused, release to continue
		state := !state
		if cachebtncount != btncount
			cachebtncount := btncount
		for hkey, name in tcurkey
			hotkey, %hkey%, %name%, off
		return
	}
	if (cachebtncount != btncount) {
		hotkey, %hkey%, %name%, on
		cachebtncount := btncount
	}
	if (!state && !GetKeyState("RButton", "P")) {
		for hkey, name in tcurkey
			hotkey, %hkey%, %name%, on
		state := !state
		pointmsg = Resumed
	}
	Coordmode, mouse, screen
	Mousegetpos, scrX, scrY
	Coordmode, mouse, window
	Mousegetpos, winX, winY
}

; calculate
DisCalc(pos0, pos1, dec_place := 0) {
	static
	global point, pointmsg
	pi := 3.1415
	p1x := pos0[1], p1y := pos0[2]
	p2x := pos1[1], p2y := pos1[2] 
	if (point) {
		dis := round(sqrt((p1x - p2x) ** 2 + (p1y - p2y) ** 2))
		shifted := abs(p1x - p2x) " , " abs(p1y - p2y)
		rad := atan(abs(p1y - p2y) / abs(p1x - p2x)) / pi
		deg := round((rad * 180), 4)
		return [dis, shifted, round(rad, 4), deg]
	}
	return ["----", "----", "----", "----"]
}



; 
CalcKey:
point := !point
pos%point% := [winX, winY]
pointmsg := "Saved coord #" (point + 1)
arrays := DisCalc(pos0, pos1)
dis := arrays[1], shifted := arrays[2]
rad := arrays[3], deg := arrays[4]
posmsg1 := "X: " pos0[1] "`t " "Y: " pos0[2]
posmsg2 := point 
	? "X: " pos1[1] "`t " "Y: " pos1[2] 
	: "X: ----`t Y: ----"
return


esc::
exitapp
return