#SingleInstance, force

; placeholder and declare var
posmsg1 := "X: ----,`tY: ----"
posmsg2 := "X: ----,`tY: ----"
dis := "----", shifted = "----"
rad := "----", deg := "----"
pointmsg = Press MButton to save coords
point := 1

; main loop
loop {
MouseCoord()
tooltip, 
(
+ Mouse coordinates
- Screen:    X: %scrX%`tY: %scrY%
- Window: X: %winX%`tY: %winY%
===================
+ Status:
%pointmsg%

+ Saved coordinates (screen)
- Coord 1: %posmsg1%
- Coord 2: %posmsg2%

+ Calculation (crd1 -> crd2)
- Distance (px):  `t%dis%
- Shifted (X , Y): `t%shifted%
- Angle (between X axis & vct 
of two saved coordinates)
 Radian / pi:`t%rad%
 Degree:   `t%deg% 
===================
Mouse 4 copy screen crd
Mouse 5 copy window crd
Middle Mouse save the 
 screen coordinates
Right Mouse suspend (hold)
Esc to exit
===================
Made by Dungx
AHKver: %A_AhkVersion%
)
sleep, 10
}

XButton1::
clipboard = %scrX%, %scrY%
return

XButton2::
clipboard = %winX%, %winY%
return

; calculate idk
DisCalc(pos0, pos1, dec_place := 0) {
	global point, pointmsg
	static pi := 3.1415
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

; capture mouse coord in "real" time (maybe > 10ms)
MouseCoord() {
	global
	if GetKeyState("RButton", "P")
		return
	Coordmode, mouse, screen
	Mousegetpos, scrX, scrY
	Coordmode, mouse, window
	Mousegetpos, winX, winY
}

; 
MButton::
point := !point
pos%point% := [winX, winY]
pointmsg := "Saved coord #" (point + 1)
arrays := DisCalc(pos0, pos1)
dis := arrays[1], shifted := arrays[2], rad := arrays[3], deg := arrays[4]
posmsg1 := "X: " pos0[1] "`t" "Y: " pos0[2]
posmsg2 := point ? "X: " pos1[1] "`t" "Y: " pos1[2] : "X: ----,`tY: ----"
return


esc::
exitapp
return