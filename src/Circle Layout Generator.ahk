#SingleInstance off
#NoEnv
#Include, Gdip.ahk
Gdip_Startup()

;----------------------------------;
; setting some important variables ;
;----------------------------------;
SetFormat, Float, 0.10 ;decimals have 10 places, minimum number length is 0 places, no spaces added in front
OffsetTop = 50      ;I can adjust these later if I have to to make sure the image fully displays
OffsetLeft = 100
GeneratingBitmap := 0
IniRead, AutoGenerate, C:\Circle Layout Generator Settings.ini, Settings, AutoGenerate
If AutoGenerate != 0
{
	AutoGenerate = 1
}
Font := "Arial"

IniRead, CopyInfoText, C:\Circle Layout Generator Settings.ini, Settings, CopyInfoText
If CopyInfoText != 0
{
	CopyInfoText = 1
}

;------------------;
; creating the gui ;
;------------------;

Gui, Add, Text, x5 y5 w144 h630 0x07  ;draws a box

Gui, Add, Text, x10 y10, Outside Diamter/Radius
Gui, Add, Text, x10 y25, Diameter
Gui, Add, Edit, x10 y40 w50 VOutsideDiameter gODChanged, 2.2
Gui, Add, Text, x74 y25, Radius
Gui, Add, Edit, x74 y40 w50 VOutsideRadius gORChanged, 1.1

Gui, Add, Text, x10 y68, Inside Dia/Rad (Optional)
Gui, Add, Text, x10 y83, Diameter
Gui, Add, Edit, x10 y98 w50 VInsideDiameter gIDChanged
Gui, Add, Text, x74 y83, Radius
Gui, Add, Edit, x74 y98 w50 VInsideRadius gIRChanged

Gui, Add, Text, x10 y126, Part Spacing
Gui, Add, Edit, x10 y141 w50 VSpacing gValueChanged, 0.25

Gui, Add, Text, x10 y169, Full Material Width
Gui, Add, Edit, x10 y184 w50 VFullMatlWidth gValueChanged, 54

Gui, Add, Text, x10 y212, Minimum Matl Edge Space
Gui, Add, Edit, x10 y227 w50 VMinMatlEdgeSpace gValueChanged, 0.25

Gui, Add, Text, x10 y255, Number on Die
Gui, Add, Text, x10 y270, Minimum
Gui, Add, Text, x74 y270, Maximum
Gui, Add, Edit, x10 y285 w50 vMinOnDie gMinOnDieChanged, 2
Gui, Add, UpDown, Range2-9999 0x80, 2
Gui, Add, Edit, x74 y285 w50 vMaxOnDie gMaxOnDieChanged, 6
Gui, Add, UpDown, Range2-9999 0x80, 10

Gui, Add, Text, x10 y313, Max Slit/Press Width
Gui, Add, Text, x73 y328, 
Gui, Add, Edit, x10 y328 w50 vMaxSlitWidth gValueChanged, 24

Gui, Add, Text, x10 y356 w50, Scale
Gui, Add, Edit, x10 y371 w50 vDrawingScale gValueChanged, 100
Gui, Add, UpDown, range1-10000 0x80, 100
Gui, Add, Text, x61 y374, `%

Gui, Add, Text, x10 y402, Unit of Measure
Gui, Add, Edit, x10 y417 w50 vUnitMeasure gValueChanged, Inches

Gui, Add, Text, x10 y455, Colors
Gui, Add, Text, x10 y474, Background
Gui, Add, Edit, x70 y470 w70 vBackgroundColor gValueChanged, White
Gui, Add, Text, x10 y497, Parts
Gui, Add, Edit, x70 y493 w70 vRuleLineColor gValueChanged, Black
Gui, Add, Text, x10 y520, Dimensions
Gui, Add, Edit, x70 y516 w70 vDimLineColor gValueChanged, Dark Red

BackgroundColor := 0xFFFFFFFF

Gui, Add, Text, x10 y544, Line Thickness
Gui, Add, Text, x10 y563, Parts
Gui, Add, Edit, x70 y559 w50 vPartLineThick gValueChanged, 2
Gui, Add, UpDown, 0x80, 2
Gui, Add, Text, x10 y586, Advance
Gui, Add, Edit, x70 y582 w50 vAdvanceLineThick gValueChanged, 1
Gui, Add, UpDown, 0x80, 1
Gui, Add, Text, x10 y609, Dimension
Gui, Add, Edit, x70 y605 w50 vDimLineThick gValueChanged, 1
Gui, Add, UpDown, 0x80, 1

Gui, Add, Text, x148 y5 w144 h630 0x07  ;draws a box

Gui, Add, Text, x153 y10, These settings are only used`nfor custom parameters.
Gui, Add, Text, x153 y45, Exact Matl/Slit Width
Gui, Add, Edit, x153 y60 w50 vExactSlitWidth gValueChanged, 18
Gui, Add, Text, x153 y88, Exact Number on Die
Gui, Add, Edit, x153 y103 w50 vExactNumberOnDie gValueChanged
Gui, Add, UpDown, Range2-9999 0x80, 8
Gui, Add, Text, x153 y131, Nested Angle (Normal is 30)
Gui, Add, Edit, x153 y146 w50 vExactNestAngle gValueChanged
Gui, Add, UpDown, Range30-60, 30

Gui, Add, Radio, x153 y180 vCalculationMethod gValueChanged Checked, Best Material Yield
Gui, Add, Radio, X153 y198 gValueChanged, Use Custom Parameters

Gui, Add, Text, x148 y368 w144 h1 0x07  ;draws a line

Gui, Add, Text, x153 y373, Valid Colors Include:
Gui, Add, Text, x153 y388, Black`nDark Grey`nGrey`nLight Grey`nWhite`nRed`nGreen`nBlue`nMagenta`nHexidecimal Values
Gui, Add, Text, x230 y388, Yellow`nCyan`nOrange`nPink`nPurple`nBrown`nDark Red`nDark Green`nDark Blue

Gui, Add, Text, x148 y522 w144 h1 0x07  ;draws a line

Gui, Add, Button, x153 y528 w90, Generate
Gui, Add, Button, x153 y554 w90, Clipboard
Gui, Add, Button, x153 y580 w90, Save Image
Gui, Add, Button, x153 y606 w90, Save DXF

If AutoGenerate = 1
{
	Gui, Add, Checkbox, x10 y640 vAutoGenerate Checked gAutoGenerateMessage, Auto generate on input change
}
Else
{
	Gui, Add, Checkbox, x10 y640 vAutoGenerate gAutoGenerateMessage, Auto generate on input change
}

If CopyInfoText = 1
{
	Gui, Add, Checkbox, x10 y657 vCopyInfoText Checked gCopyInfoText, Copy/save info from bottom two lines
}
Else
{
	Gui, Add, Checkbox, x10 y657 vCopyInfoText gCopyInfoText, Copy/save info from bottom two lines
}

Gui, Show, w1197 h700, Circle Layout Generator

;-----------------------------------------------------;
; some gdip related stuff still no clue wtf this does ;
;-----------------------------------------------------;
HWND := WinExist("A")
hdc_WINDOW := GetDC(HWND)
hbm_main := CreateDIBSection(900, 700)
hdc_main := CreateCompatibleDC()
obm := SelectObject(hdc_main, hbm_main)
G := Gdip_GraphicsFromHDC(hdc_main)

Return

;-------------------------;
; gui update related subs ;
;-------------------------;
;these update values on the gui when other related ones are changed.

ODChanged:
	if GuiUpdate != 2
	{
		Gui, Submit, NoHide
		OutsideRadius := OutsideDiameter / 2
		GuiControl, , OutsideRadius, %OutsideRadius%
		GuiUpdate = 1
		GoSub ValueChanged
	}
	SetTimer, ResetGuiUpdate, 30
return

ORChanged:
	if GuiUpdate != 1
	{
		Gui, Submit, NoHide
		OutsideDiameter := OutsideRadius * 2
		GuiControl, , OutsideDiameter, %OutsideDiameter%
		GuiUpdate = 2
		GoSub ValueChanged
	}
	SetTimer, ResetGuiUpdate, 30
return

IDChanged:
	if GuiUpdate != 4
	{
		Gui, Submit, NoHide
		InsideRadius := InsideDiameter / 2
		GuiControl, , InsideRadius, %InsideRadius%
		GuiUpdate = 3
		GoSub ValueChanged
	}
	SetTimer, ResetGuiUpdate, 30
return

IRChanged:
	if GuiUpdate != 3
	{
		Gui, Submit, NoHide
		InsideDiameter := InsideRadius * 2
		GuiControl, , InsideDiameter, %InsideDiameter%
		GuiUpdate = 4
		GoSub ValueChanged
	}
	SetTimer, ResetGuiUpdate, 30
return

MinOnDieChanged:
	if GuiUpdate != 6
	{
		Gui, Submit, NoHide
		if MaxOnDie < %MinOnDie%
		{
			SetFormat, Float, 0.0
			MaxOnDie := MinOnDie
			GuiControl, , MaxOnDie, %MaxOnDie%
			GuiUpdate = 5
			SetFormat, Float, 0.8
		}
		GoSub ValueChanged
	}
	SetTimer, ResetGuiUpdate, 30
return

MaxOnDieChanged:
	if GuiUpdate != 5
	{
		Gui, Submit, NoHide
		if MinOnDie > %MaxOnDie%
		{
			SetFormat, Float, 0.0
			MinOnDie := MaxOnDie
			GuiControl, , MinOnDie, %MinOnDie%
			GuiUpdate = 6
			SetFormat, Float, 0.8
			
		}
		GoSub ValueChanged
	}
	SetTimer, ResetGuiUpdate, 30
return

ResetGuiUpdate:
	GuiUpdate = 0
return

ValueChanged:
	Gui, Submit, NoHide
	If AutoGenerate = 1
	{
		SetTimer, ValueChangedTimer, 85
	}
Return

ValueChangedTimer:
	SetTimer, ValueChangedTimer, OFF
	GoSub ButtonGenerate
Return

AutoGenerateMessage:
	Gui, Submit, NoHide
	IniWrite, %AutoGenerate%, C:\Circle Layout Generator Settings.ini, Settings, AutoGenerate
	If AutoGenerate = 1
	{
		SetTimer, ValueChangedTimer, 85
	}
	;there used to be a message here about this being buggy, but I fixed it by adding a 85ms delay to rendering so the message is removed but I didn't change the sub name. This activates when the check box for auto generate is changed.
Return

CopyInfoText:
	Gui, Submit, NoHide
	IniWrite, %CopyInfoText%, C:\Circle Layout Generator Settings.ini, Settings, CopyInfoText
Return

;-----------------;
; generate button ;
;-----------------;

ButtonGenerate:
	GoSub ClearBest
	Gui, Submit, NoHide
	GoSub CheckDataIntegrity
	DrawingScale := DrawingScale / 5
	If DataError = 1
	{
		return
	}
	If CalculationMethod = 1
	{
		NumberOnDie := MinOnDie
		While NumberOnDie <= MaxOnDie                 ;;;;;;;;;;;;;;;;;;;   it works! that took so long to fix  
		{
			Radian := 30 * 0.0174532925
			Error = 0
			HorizontalSpacing := (OutsideDiameter + Spacing) * cos(Radian)
			VerticalSpacing := (OutsideDiameter + Spacing) * sin(Radian)
			MinimumSlitWidth := HorizontalSpacing * (NumberOnDie - 1) + OutsideDiameter + MinMatlEdgeSpace * 2
			if MinimumSlitWidth <= %FullMatlWidth%
			{
				SlitWidth := MinimumSlitWidth            ;just so the while will start
				While SlitWidth >= MinimumSlitWidth
				{
					;now I'm calculating all the possible widths of a roll until I find the closest one that isn't under the minimum requirement.
					NumberOfSlits := A_Index - 1
					SlitWidth := FullMatlWidth / A_Index
					Error = 1
					If A_Index > 1
					{
						Error = 0
					}
				}
				SlitWidth := FullMatlWidth / NumberOfSlits
				Advance := VerticalSpacing * 2
				MaterialUsedPerPart := Advance * SlitWidth / NumberOnDie
				If SlitWidth > %MaxSlitWidth%
				{
					Error = 1
				}
				If (BestMaterialUsedPerPart = 0) or (MaterialUsedPerPart < BestMaterialUsedPerPart) or (MaterialUsedPerPart = BestMaterialUsedPerPart)
				{
					If Error = 0
					{
						AdvanceMethod = 1
						GoSub StoreBest
					}
				}
			}
			else
			{
				break
			}
			NumberOnDie := NumberOnDie + 1
		}
		NumberOnDie := MinOnDie
		DistanceFromCenters := OutsideDiameter + Spacing
		While NumberOnDie <= MaxOnDie
		{
			Loop  ;loop trying slit widths until I break the loop due to negative or over spacing
			{
				SlitWidth := FullMatlWidth / A_Index
				HorizontalSpacing := (SlitWidth - MinMatlEdgeSpace * 2 - OutsideDiameter) / (NumberOnDie - 1)
				AdvanceMethod = 1
				Error = 0
				If NumberOnDie * OutsideDiameter + (NumberOnDie - 1) * Spacing + 2 * MinMatlEdgeSpace < SlitWidth
				{
					Error = 1
				}
				If (MinMatlEdgeSpace * 2) + (OutsideDiameter / 2 * (NumberOnDie + 1)) + (Spacing / 2 * (NumberOnDie - 1)) > SlitWidth
				{
					Error = 1
					Break
				}
				VerticalSpacing := (DistanceFromCenters * DistanceFromCenters) - (HorizontalSpacing * HorizontalSpacing)
				If VerticalSpacing < 0
				{
					VerticalSpacing := -1 * VerticalSpacing
				}
				VerticalSpacing := Sqrt(VerticalSpacing)
				Advance := VerticalSpacing * 2
				MaterialUsedPerPart := Advance * SlitWidth / NumberOnDie
				If (SlitWidth > MaxSlitWidth) or (HorizontalSpacing * 2 < DistanceFromCenters) or (DistanceFromCenters / 2 > VerticalSpacing)
				{
					Error = 1
				}
				If Error = 0
				{
					If (BestMaterialUsedPerPart = 0) or (MaterialUsedPerPart < BestMaterialUsedPerPart)
					{
						AdvanceMethod = 1
						GoSub StoreBest
						StoredOne = 1
					}
					If (StoredOne = 1) and (MaterialUsedPerPart = BestMaterialUsedPerPart)
					{
						AdvanceMethod = 1
						GoSub StoreBest
					}
				}
			}
			NumberOnDie := NumberOnDie + 1
		}
	}
	
	If CalculationMethod = 2
	{
		BestAdvanceMethod := 1
		Radian := ExactNestAngle * 0.0174532925
		BestHorizontalSpacing := (OutsideDiameter + Spacing) * cos(Radian)
		BestVerticalSpacing := (OutsideDiameter + Spacing) * sin(Radian)
		BestNumberOnDie := ExactNumberOnDie
		BestSlitWidth := ExactSlitWidth
		Advance := BestVerticalSpacing * 2
		BestMaterialUsedPerPart := Advance * ExactSlitWidth / ExactNumberOnDie
	}
	
	;BestMaterialUsedPerPart
	;BestSlitWidth
	;BestNumberOnDie
	;BestHorizontalSpacing
	;BestVerticalSpacing
	;BestAdvanceMethod
	;Draw all the circles and dim lines. Also define arrow points to draw later.
	;starting point is at bottom left of bottom left circle.
	GoSub DrawWhiteBackground
	GoSub DrawBackground
	CircleToDraw := "Bottom"
	StartingPointX := OffsetLeft + DrawingScale * (BestSlitWidth / 2 - ((BestHorizontalSpacing * (BestNumberOnDie - 1) + OutsideDiameter) / 2))
	StartingPointY := OffsetTop + DrawingScale * (BestVerticalSpacing * 3)
	If StartingPointX < %OffsetLeft%
	{
		StartingPointX := OffsetLeft + DrawingScale * MinMatlEdgeSpace
	}
	If BestMaterialUsedPerPart > 0
	{
		Loop %BestNumberOnDie%     ;using this loop to draw the bottom then top circles
		{
			CX := StartingPointX + DrawingScale * ((OutsideDiameter / 2) + BestHorizontalSpacing * (A_Index - 1))
			If ceil(A_Index/2)*2 != A_index                              ; if odd, this, else that
			{
				CY := StartingPointY + DrawingScale * (OutsideDiameter / 2)
			}
			Else
			{
				CY := StartingPointY + DrawingScale * (OutsideDiameter / 2 - BestVerticalSpacing)
			}
			Diameter := InsideDiameter
			GoSub CalculateCircle
			GoSub DrawCircle
			Diameter := OutsideDiameter
			GoSub CalculateCircle
			GoSub DrawCircle
			
			
			If A_Index = 1   ;draw dim lines and calculate points for arrows.
			{
				;Make values for the dimensions have a minimum or 4 leading and exactly 4 trailing spaces. Second number defines demial places, first number defines total characters including decimal.
				SetFormat, Float, 9.4
				D_MaterialWidth := BestSlitWidth + 0.1
				D_PartsFullWidth := BestHorizontalSpacing * (BestNumberOnDie - 1) + OutsideDiameter + 0.1
				D_HorizontalSpacing := BestHorizontalSpacing + 0.1
				D_VerticalSpacing := BestVerticalSpacing + 0.1
				D_Spacing := Spacing + 0.1
				D_Advance := (BestVerticalSpacing * 2) + 0.1
				D_Diameter := OutsideDiameter + 0.1
				D_MaterialWidth := D_MaterialWidth - 0.1
				D_PartsFullWidth := D_PartsFullWidth - 0.1
				D_HorizontalSpacing := D_HorizontalSpacing - 0.1
				D_VerticalSpacing := D_VerticalSpacing - 0.1
				D_Spacing := D_Spacing - 0.1
				D_Advance := D_Advance - 0.1
				D_Diameter := D_Diameter - 0.1
				SetFormat, Float, 0.4
				D_MatlUsage := BestVerticalSpacing * 2 * BestSlitWidth / BestNumberOnDie
				D_MatlUsage := D_MatlUsage + 0.1
				D_MatlUsage := D_MatlUsage - 0.1
				SetFormat, Float, 0.10
				
				StringTrimLeft, TrimmedColor, DimLineColor, 2
				Options := "y" . TextY . " x" . TextX . " " . TrimmedColor . " r4 s16"

				
				;Dim line 1
				X1 := OffsetLeft
				X2 := X1
				Y1 := CY
				y2 := CY + DrawingScale * (Diameter / 2) + 91
				GoSub DrawDimLine
				
				GoSub StoreXY                  ;arrow 1
				Y1 := Y2 - 7
				Y2 := Y1
				X1 := X1
				X2 := X1 + DrawingScale * BestSlitWidth
				GoSub DrawDimLine
				
				Message := D_MaterialWidth . "`nMaterial Width"
				TextX := (X1 + X2) / 2 - 39
				TextY := Y1 + 7
				Options := "y" . TextY . " x" . TextX . " c" . TrimmedColor . " r4 s16"
				GoSub DrawText
				
				Message := "Material used per part is " . D_MatlUsage . " Square " . UnitMeasure . ".`nThere are " . BestNumberOnDie . " cavities on this die."
				TextY := TextY + 40
				TextX := 30
				Options := "y" . TextY . " x" . TextX . " c" . TrimmedColor . " r4 s16"
				GoSub DrawText
				
				ArrowAngle := 180
				GoSub DrawArrow
				X1 := X2
				ArrowAngle := 0
				GoSub DrawArrow
				GoSub LoadXY
				
				
				
				
				;Dim Line 6
				X1 := X1 + DrawingScale * BestSlitWidth
				X2 := X1
				If ceil(BestNumberOnDie / 2) * 2 = BestNumberOnDie     ;If even, true. If odd, false. If a decimal, you messed up your input, please try again.
				{
					Y1 := Y1 - DrawingScale * BestVerticalSpacing
				}
				GoSub DrawDimLine
				
				;Dim line 2
				X1 := StartingPointX
				X2 := X1
				Y1 := CY + 7
				y2 := CY + DrawingScale * (Diameter / 2) + 52
				GoSub DrawDimLine
				
				GoSub StoreXY                  ;arrow 2
				Y1 := Y2 - 7
				Y2 := Y1
				X1 := X1
				X2 := X1 + DrawingScale * ((BestNumberOnDie - 1) * BestHorizontalSpacing + OutsideDiameter)
				GoSub DrawDimLine
				
				Message := D_PartsFullWidth
				TextX := (X1 + X2) / 2 - 39
				TextY := Y1 + 7
				Options := "y" . TextY . " x" . TextX . " c" . TrimmedColor . " r4 s16"
				GoSub DrawText
				
				ArrowAngle := 180
				GoSub DrawArrow
				X1 := X2
				ArrowAngle := 0
				GoSub DrawArrow
				GoSub LoadXY
				
				;Dim Line 5
				X1 := X1 + DrawingScale * ((BestNumberOnDie - 1) * BestHorizontalSpacing + OutsideDiameter)
				X2 := X1
				If ceil(BestNumberOnDie / 2) * 2 = BestNumberOnDie     ;If even, true. If odd, false. If a decimal, you messed up your input, please try again.
				{
					Y1 := Y1 - DrawingScale * BestVerticalSpacing
				}
				GoSub DrawDimLine
				
				;Dim line 3
				X1 := StartingPointX + OutsideDiameter * DrawingScale
				X2 := X1
				Y1 := CY + 7
				y2 := CY + DrawingScale * (Diameter / 2) + 15
				GoSub DrawDimLine
				
				GoSub StoreXY                  ;arrow 3
				Y1 := Y2 - 7
				Y2 := Y1
				X1 := X1
				X2 := X1 + DrawingScale * (BestHorizontalSpacing)
				GoSub DrawDimLine
				
				Message := D_HorizontalSpacing
				TextX := (X1 + X2) / 2 - 53
				TextY := Y1 + 7
				Options := "y" . TextY . " x" . TextX . " c" . TrimmedColor . " r4 s16"
				GoSub DrawText
				
				ArrowAngle := 180
				GoSub DrawArrow
				X1 := X2
				ArrowAngle := 0
				GoSub DrawArrow
				GoSub LoadXY
				
				;Dim Line 4
				X1 := X1 + DrawingScale * (BestHorizontalSpacing)
				X2 := X1
				Y1 := Y1 - DrawingScale * BestVerticalSpacing
				GoSub DrawDimLine
				
				;Dim Line 9
				X2 := CX - 7
				X1 := CX - DrawingScale * (Diameter / 2) - 25
				Y1 := CY - OutsideDiameter / 2 * DrawingScale
				Y2 := Y1
				GoSub DrawDimLine
				
				GoSub StoreXY                ;arrow 5
				X1 := X1 + 7
				X2 := X1
				Y1 := Y2 - BestVerticalSpacing * DrawingScale
				GoSub DrawDimLine
				
				Message := D_VerticalSpacing
				TextY := (Y1 + Y2) / 2 - 9
				TextX := X1 - 78
				Options := "y" . TextY . " x" . TextX . " c" . TrimmedColor . " r4 s16"
				GoSub DrawText
				
				ArrowAngle :=270
				GoSub DrawArrow
				Y1 := Y2
				ArrowAngle := 90
				GoSub DrawArrow
				GoSub LoadXY
				
				;Dim Line 10
				X2 := X2 + BestHorizontalSpacing * DrawingScale
				Y1 := Y1 - BestVerticalSpacing * DrawingScale
				Y2 := Y1
				GoSub DrawDimLine
				
				;Arrow 6 This one won't have an arrow point and has two lines.
				X2 := CX + (BestHorizontalSpacing / 2) * DrawingScale
				Y2 := CY - (BestVerticalSpacing / 2 + BestVerticalSpacing + BestVerticalSpacing) * DrawingScale
				X1 := X2 - BestVerticalSpacing * DrawingScale / 2
				Y1 := Y2 - BestHorizontalSpacing * DrawingScale / 2
				GoSub DrawDimLine
				X2 := X1
				Y2 := Y1
				X1 := X1 - 15
				GoSub DrawDimLine
				
				Message := D_Spacing . "`n Spacing"
				TextY := Y1 - 29
				TextX := X1 - 68
				Options := "y" . TextY . " x" . TextX . " c" . TrimmedColor . " r4 s16"
				GoSub DrawText
				
				;Arrow 7
				X2 := CX + BestHorizontalSpacing * DrawingScale
				X1 := X2
				Y2 := CY - (BestVerticalSpacing * 3 + OutsideDiameter / 2) * DrawingScale
				Y1 := Y2 - 15
				GoSub DrawDimLine
				Y2 := Y1
				X2 := X1
				X1 := X1 + 15
				GoSub DrawDimLine
				
				Message := D_Diameter . "`nDiameter"
				TextY := Y1 - 26
				TextX := X1 + 4
				Options := "y" . TextY . " x" . TextX . " c" . TrimmedColor . " r4 s16"
				GoSub DrawText
				
				X1 := X1 - 15
				Y1 := Y1 + 15
				Angle = 90
				GoSub DrawArrow
			}
			If A_Index = %BestNumberOnDie%
			{
				;Dim line 7
				X1 := CX + 7
				X2 := CX + DrawingScale * (Diameter / 2) + 25
				Y1 := CY - DrawingScale * (Diameter / 2)
				Y2 := Y1
				GoSub DrawDimLine
				
				GoSub StoreXY          ;arrow 4
				X1 := X2 - 7
				X2 := X1
				Y1 := Y1 - DrawingScale * BestVerticalSpacing * 2
				GoSub DrawDimLine
				
				Message := D_Advance . "`nAdvance"
				TextY := (Y1 + Y2) / 2 - 18
				TextX := X1 + 9
				Options := "y" . TextY . " x" . TextX . " c" . TrimmedColor . " r4 s16"
				GoSub DrawText
				
				ArrowAngle :=270
				GoSub DrawArrow
				Y1 := Y2
				ArrowAngle := 90
				GoSub DrawArrow
				GoSub LoadXY
				
				;Dim line 8
				Y1 := Y1 - DrawingScale * BestVerticalSpacing * 2
				Y2 := Y1
				GoSub DrawDimLine
				
				
			}
			
			
			
			
			
			;calculate the position of the top circle. Only the Y changes.
			CY := CY - BestVerticalSpacing * 2 * DrawingScale
			Diameter := InsideDiameter
			GoSub CalculateCircle
			GoSub DrawAdvanceCircle
			Diameter := OutsideDiameter
			GoSub CalculateCircle
			GoSub DrawAdvanceCircle
			

			;reset the Y position before looping back to draw the next bottom circle. Only the Y changes.
			CY := CY + BestVerticalSpacing * 2 * DrawingScale
		}
	}
	Else
	{
		GoSub DrawWhiteBackground
		Font = Arial
		Options = x10 y10 cff550000 r4 s20
		Message := "A layout could not be found for your inputs.`n`nAdjust your inputs or use custom parameters."
		GoSub DrawText
		GoSub DrawImage
	}
	

	GoSub DrawImage
return

;-------------------;
; Data input checks ;
;-------------------;

CheckDataIntegrity:
	DataError = 0
	ErrorCount = 0
	ErrorMessage := ""
	If (OutsideDiameter <= 0) or (OutsideRadius <= 0)
	{
		DataError = 1
		ErrorCount := ErrorCount + 1
		ErrorMessage := ErrorMessage . "Outside Diameter/Radius must be greater than 0."
	}
	If (InsideDiameter != "") and (InsideDiameter <= 0)
	{
		DataError = 1
		ErrorCount := ErrorCount + 1
		ErrorMessage := ErrorMessage . "`nInside Diameter/Radius must either be blank or greater than 0."
	}
	If InsideDiameter > OutsideDiameter
	{
		DataError = 1
		ErrorCount := ErrorCount + 1
		ErrorMessage := ErrorMessage . "`nInside Diameter can not be larger than Outside Diameter."
	}
	If Spacing < 0
	{
		DataError = 1
		ErrorCount := ErrorCount + 1
		ErrorMessage := ErrorMessage . "`nPart Spacing must be 0 or greater."
	}
	If CalculationMethod = 1
	{
		If FullMatlWidth <= 0
		{
			DataError = 1
			ErrorCount := ErrorCount + 1
			ErrorMessage := ErrorMessage . "`nFull Material Width must be greater than 0."
		}
		If MinMatlEdgeSpace < 0
		{
			DataError = 1
			ErrorCount := ErrorCount + 1
			ErrorMessage := ErrorMessage . "`nMiniumu Matl Edge Space must be 0 or greater."
		}
		If (MinOnDie < 2) or (MinOnDie > 9999)
		{
			DataError = 1
			ErrorCount := ErrorCount + 1
			ErrorMessage := ErrorMessage . "`nMinimum on die must be between 2 and 9999."
		}
		If (MaxOnDie < 2) or (MaxOnDie > 9999)
		{
			DataError = 1
			ErrorCount := ErrorCount + 1
			ErrorMessage := ErrorMessage . "`nMax on die must be between 2 and 9999."
		}
		If MaxOnDie < %MinOnDie%
		{
			DataError = 1
			ErrorCount := ErrorCount + 1
			ErrorMessage := ErrorMessage . "`nMax on die must be equal to or larger than min on die."
		}
		If MaxSlitWidth <= 0
		{
			DataError = 1
			ErrorCount := ErrorCount + 1
			ErrorMessage := ErrorMessage . "`nMax Slit/Press Width must be greater than 0."
		}
	}
	If DrawingScale <= 0
	{
		DataError = 1
		ErrorCount := ErrorCount + 1
		ErrorMessage := ErrorMessage . "`nScale must be greater than 0."
	}
	ColorInput := DimLineColor
	GoSub ConvertColorToHex
	DimLineColor := ColorOutput
	If !CorrectSyntax
	{
		DataError = 1
		ErrorCount := ErrorCount + 1
		ErrorMessage := ErrorMessage . "`nDimension Line Color is invalid. Check the list of valid colors."
	}
	ColorInput := RuleLineColor
	GoSub ConvertColorToHex
	RuleLineColor := ColorOutput
	If !CorrectSyntax
	{
		DataError = 1
		ErrorCount := ErrorCount + 1
		ErrorMessage := ErrorMessage . "`nPart Line Color is invalid. Check the list of valid colors."
	}
	ColorInput := BackgroundColor
	GoSub ConvertColorToHex
	BackgroundColor := ColorOutput
	If !CorrectSyntax
	{
		DataError = 1
		ErrorCount := ErrorCount + 1
		ErrorMessage := ErrorMessage . "`nBackground Color is invalid. Check the list of valid colors."
	}
	If PartLineThick <= 0
	{
		DataError = 1
		ErrorCount := ErrorCount + 1
		ErrorMessage := ErrorMessage . "`nPart Line Thickness must be greater than 0."
	}
	If AdvanceLineThick <= 0
	{
		DataError = 1
		ErrorCount := ErrorCount + 1
		ErrorMessage := ErrorMessage . "`nAdvance Line Thickness must be greater than 0."
	}
	If DimLineThick <= 0
	{
		DataError = 1
		ErrorCount := ErrorCount + 1
		ErrorMessage := ErrorMessage . "`nDimension Line Thickness must be greater than 0."
	}
	If CalculationMethod = 2
	{
		If ExactSlitWidth <= 0
		{
			DataError = 1
			ErrorCount := ErrorCount + 1
			ErrorMessage := ErrorMessage . "`nCustom Parameter: Exact Matl/Slit Width must be greater than 0."
		}
		If (ExactNumberOnDie < 2) or (ExactNumberOnDie > 9999)
		{
			DataError = 1
			ErrorCount := ErrorCount + 1
			ErrorMessage := ErrorMessage . "`nCustom Parameter: Exact Number on Die must be between 2 and 9999."
		}
		If (ExactNestAngle < 30) or (ExactNestAngle > 60)
		{
			DataError = 1
			ErrorCount := ErrorCount + 1
			ErrorMessage := ErrorMessage . "`nCustom Parameter: Nested Angle must be between 30 and 60."
		}
	}
	If DataError = 1
	{
		If ErrorCount > 1
		{	
			TextPart2 := "these errors"
			TextPart1 := "There are some errors with your data input.`n"
		}
		Else
		{
			TextPart2 := "this error"
			TextPart1 := "There is an error with your data input.`n"
		}	
		If AutoGenerate = 1
		{
			ErrorMessage := TextPart1 . ErrorMessage . "`n`nFix " . TextPart2 . " to continue."
		}
		Else
		{
			ErrorMessage := TextPart1 . ErrorMessage . "`n`nFix " . TextPart2 . " then click Generate."
		}
		GoSub DrawWhiteBackground
		Font = Arial
		Options = x10 y10 cff550000 r4 s20
		Message := ErrorMessage
		GoSub DrawText
		GoSub DrawImage
	}
return

;-----------------------;
; Convert colors to hex ;
;-----------------------;
ConvertColorToHex:
	ColorOutput := ColorInput
	If ColorInput = Black
	{
		ColorOutput := "0xFF000000"
	}
	If ColorInput = Dark Grey
	{
		ColorOutput := "0xFF404040"
	}
	If ColorInput = Grey
	{
		ColorOutput := "0xFF808080"
	}
	If ColorInput = Light Grey
	{
		ColorOutput := "0xFFBFBFBF"
	}
	If ColorInput = White
	{
		ColorOutput := "0xFFFFFFFF"
	}
	If ColorInput = Red
	{
		ColorOutput := "0xFFFF0000"
	}
	If ColorInput = Green
	{
		ColorOutput := "0xFF00FF00"
	}
	If ColorInput = Blue
	{
		ColorOutput := "0xFF0000FF"
	}
	If ColorInput = Magenta
	{
		ColorOutput := "0xFFFF00FF"
	}
	If ColorInput = Yellow
	{
		ColorOutput := "0xFFFFFF00"
	}
	If ColorInput = Cyan
	{
		ColorOutput := "0xFF00FFFF"
	}
	If ColorInput = Orange
	{
		ColorOutput := "0xFFFF7F00"
	}
	If ColorInput = Pink
	{
		ColorOutput := "0xFFFF7FFF"
	}
	If ColorInput = Purple
	{
		ColorOutput := "0xFF7F00FF"
	}
	If ColorInput = Brown
	{
		ColorOutput := "0xFF9C5314"
	}
	If ColorInput = Dark Red
	{
		ColorOutput := "0xFF7F0000"
	}
	If ColorInput = Dark Green
	{
		ColorOutput := "0xFF007F00"
	}
	If ColorInput = Dark Blue
	{
		ColorOutput := "0xFF00007F"
	}
	CorrectSyntax := RegExMatch(ColorOutput,"[0][Xx][a-fA-F0-9][a-fA-F0-9][a-fA-F0-9][a-fA-F0-9][a-fA-F0-9][a-fA-F0-9][a-fA-F0-9][a-fA-F0-9]")   ;looks for 0 then x or X then 8 of a correct hex number
Return

StoreBest:
	BestMaterialUsedPerPart := MaterialUsedPerPart
	BestSlitWidth := SlitWidth
	BestNumberOnDie := NumberOnDie
	BestHorizontalSpacing := HorizontalSpacing
	BestVerticalSpacing := VerticalSpacing
	BestAdvanceMethod := AdvanceMethod
return

ClearBest:
	BestMaterialUsedPerPart := 0
	BestSlitWidth := 0
	BestNumberOnDie := 0
	BestHorizontalSpacing := 0
	BestVerticalSpacing := 0
	BestAdvanceMethod := 0
return

StoreXY:
	X1Temp := X1
	X2Temp := X2
	Y1Temp := Y1
	Y2Temp := Y2
Return

LoadXY:
	X1 := X1Temp
	X2 := X2Temp
	Y1 := Y1Temp
	Y2 := Y2Temp
Return

StoreXY2:
	X1Temp2 := X1
	X2Temp2 := X2
	Y1Temp2 := Y1
	Y2Temp2 := Y2
Return

LoadXY2:
	X1 := X1Temp2
	X2 := X2Temp2
	Y1 := Y1Temp2
	Y2 := Y2Temp2
Return

CalculateCircle:
	X1 := CX - DrawingScale * Diameter / 2
	X2 := DrawingScale * Diameter
	Y1 := CY - DrawingScale * Diameter / 2
	Y2 := DrawingScale * Diameter
Return

;------------------------------------;
; subs for clipboard and save bitmap ;
;------------------------------------;

ButtonClipboard:      ;there must be a better method, but this is what I did because it was easy. It saves the bitmap to the script directory then copies it to the clipboard.
	Gui, Submit, NoHide
	GoSub ButtonGenerate
	GoSub CheckDataIntegrity
	If DataError = 0
	{
		BitmapHeight := (BestVerticalSpacing * 3 + OutsideDiameter) * DrawingScale + 178
		BitmapWidth := BestHorizontalSpacing * (BestNumberOnDie - 1) + OutsideDiameter
		If BitmapWidth < %BestSlitWidth%
		{
			BitmapWidth := BestSlitWidth
		}
		BitmapWidth := BitmapWidth * DrawingScale + 220
		If CopyInfoText = 1
		{
			BitmapHeight := BitmapHeight + 44
			If BitmapWidth < 430
			{
				BitmapWidth := 430   ;this is to leave room for the text at the bottom that says how many on die and how much area of material used per part.
			}
		}
		pBitmap := Gdip_CreateBitmap(BitmapWidth, BitmapHeight)
		G := Gdip_GraphicsFromImage(pBitmap)       ;sets graphic mode to something else so I can save a bitmap?
		bgBrush := Gdip_BrushCreateSolid(0xFFFFFFFF) ;defining brush color
		Gdip_FillRectangle(G,bgBrush,0,0,BitmapWidth,BitmapHeight)
		GoSub ButtonGenerate                       ;I have no damn clue how to use this stuff... But it's working now so I'll leave it.
		Gdip_SaveBitmapToFile(pBitmap, "CircleLayoutTemp-69017382.bmp")
		G := Gdip_GraphicsFromHDC(hdc_main)   ;sets graphic mode back to the correct kind?
		Gdip_SetBitmapToClipboard(pBitmap)
		FileDelete, CircleLayoutTemp-69017382.bmp
	}
	DataError = 0
Return

ButtonSaveImage:        ;saves the image to the user's chosen directory and file name, defaulting to desktop.
	Gui, Submit, NoHide
	GoSub ButtonGenerate
	GoSub CheckDataIntegrity
	If DataError = 0
	{
		FileSelectFile, BMPFileName, S16 , %A_Desktop%\CircleLayout.bmp, Save Image, Bitmap(*.bmp)   ;option S16, S = Save, 16 = Prompt overwrite
		If ErrorLevel = 1     ;if user pressed cancel
		{
			Return
		}
		BitmapHeight := (BestVerticalSpacing * 3 + OutsideDiameter) * DrawingScale + 178
		BitmapWidth := BestHorizontalSpacing * (BestNumberOnDie - 1) + OutsideDiameter
		If BitmapWidth < %BestSlitWidth%
		{
			BitmapWidth := BestSlitWidth
		}
		BitmapWidth := BitmapWidth * DrawingScale + 220
		If CopyInfoText = 1
		{
			BitmapHeight := BitmapHeight + 44
			If BitmapWidth < 500
			{
				BitmapWidth := 500   ;this is to leave room for the text at the bottom that says how many on die and how much area of material used per part.
			}
		}
		pBitmap := Gdip_CreateBitmap(BitmapWidth, BitmapHeight)
		G := Gdip_GraphicsFromImage(pBitmap)       ;sets graphic mode to something else so I can save a bitmap?
		bgBrush := Gdip_BrushCreateSolid(0xFFFFFFFF) ;defining brush color
		Gdip_FillRectangle(G,bgBrush,0,0,BitmapWidth,BitmapHeight)
		GoSub ButtonGenerate                       ;I have no damn clue how to use this stuff... But it's working now so I'll leave it.
		Gdip_SaveBitmapToFile(pBitmap, BMPFileName)
		G := Gdip_GraphicsFromHDC(hdc_main)   ;sets graphic mode back to the correct kind?
	}
	DataError = 0
Return

;----------------------------;
; sub to generate a dxf file ;
;----------------------------;

ButtonSaveDXF:
	Gui, Submit, NoHide
	GoSub ButtonGenerate
	GoSub CheckDataIntegrity
	If DataError = 0
	{
	FileSelectFile, DXFFileName, S16 , %A_Desktop%\CircleLayout.DXF, Save DXF, DXF CAD File(*.DXF)   ;option S16, S = Save, 16 = Prompt overwrite
	If ErrorLevel = 1     ;if user pressed cancel
	{
		Return
	}
	IfExist, %DXFFileName%
	{
		FileDelete, %DXFFileName%
	}
	         ;writing the first part of the file, the header. Next will be separate lines.
	         ;I'm not actually sure how much of this begging stuff is needed so I'll just include it all because it won't hurt anything.
	FileAppend,       
	(
999`nFile Created by United Gasket's Circles die generator by Michael B`n0`nSECTION`n2`nHEADER`n9`n$ACADVER`n1`nAC1006`n9`n$INSBASE`n10`n0.0`n20`n0.0`n30`n0.0`n9`n$EXTMIN`n10`n0.0`n20`n0.0`n9`n$EXTMAX`n10`n10000.0`n20`n10000.0`n0`nENDSEC`n0`nSECTION`n2`nENTITIES`n0`n
), %DXFFileName%
	
	;this is the math to place circles. Based on center points.
	DXF_X := OutsideDiameter / 2
	DXF_Y := OutsideDiameter / 2
	UpDown = 1
	Loop %BestNumberOnDie%
	{
		DXF_Radius := OutsideDiameter / 2
		GoSub AddCircleToDXF
		If InsideDiameter > 0
		{
			DXF_Radius := InsideDiameter / 2
			GoSub AddCircleToDXF
		}
		If UpDown = 1
		{
			DXF_Y := DXF_Y + BestVerticalSpacing
			UpDown = 0
		}
		Else
		{
			DXF_Y := DXF_Y - BestVerticalSpacing
			UpDown = 1
		}
		DXF_X := DXF_X + BestHorizontalSpacing
	}
	;end of cad file. Do not do anythingthing else past this point in this sub.
	FileAppend,
	(
ENDSEC`n0`nEOF`n
),  %DXFFileName%
	}
	DataError = 0
Return



AddCircleToDXF:     ; 10 = x ; 20 = y ; 30 = z ; 40 = radius
	FileAppend,
	(
CIRCLE
8
0
10
%DXF_X%
20
%DXF_Y%
30
0.0
40
%DXF_Radius%
0`n
), %DXFFileName%
Return


;------------------------------------------;
; any sub that draws stuff goes after this ;
;------------------------------------------;

DrawText:
	;Font = Arial
	;Options = x10 y10 cff550000 r4 s20
	Gdip_FontFamilyCreate(Font)
	Gdip_TextToGraphics(G, Message, Options)	
Return

DrawCircle:
	CircleBrush := Gdip_CreatePen(RuleLineColor,PartLineThick)
	Gdip_DrawEllipse(G,CircleBrush, X1, Y1, X2, Y2)
Return

DrawAdvanceCircle:
	CircleBrush := Gdip_CreatePen(RuleLineColor,AdvanceLineThick)
	Gdip_DrawEllipse(G,CircleBrush, X1, Y1, X2, Y2)
Return

DrawDimLine:
	LineBrush := Gdip_CreatePen(DimLineColor,DimLineThick)
	Gdip_DrawLine(G,LineBrush, X1, Y1, X2, Y2)
Return

DrawArrow:
	GoSub StoreXY2
	LineSizeAX := 6 + DimLineThick * 1.7
	Gdip_SetSmoothingMode(G, 4)
	Radian1 := (ArrowAngle + 45) * 0.0174532925
	Radian2 := (ArrowAngle - 45) * 0.0174532925
	X1 := X1
	Y1 := Y1
	X2 := X1 - cos(Radian1) * LineSizeAX
	Y2 := Y1 - Sin(Radian1) * LineSizeAX
	GoSub DrawDimLine
	X2 := X1 - cos(Radian2) * LineSizeAX
	Y2 := Y1 - Sin(Radian2) * LineSizeAX
	GoSub DrawDimLine
	Gdip_SetSmoothingMode(G, 0)
	GoSub LoadXY2
Return

DrawBackground:   ;create a background to be drawn
	bgBrush := Gdip_BrushCreateSolid(BackgroundColor) ;defining brush color
	Gdip_FillRectangle(G,bgBrush,0,0,900,700)    ;drawing a rectangle (x1, y1, x2, y2)
Return

DrawWhiteBackground:   ;create a background to be drawn
	bgBrush := Gdip_BrushCreateSolid(0xFFFFFFFF) ;defining brush color
	Gdip_FillRectangle(G,bgBrush,0,0,900,700)    ;drawing a rectangle (x1, y1, x2, y2)
Return

DrawImage:      ;draws whatever has been created so far
	BitBlt(hdc_WINDOW, 297, 0, 900,700, hdc_main,0,0) ;position of the GDI Image in the GUI (?, posH, posV, W, L, ?)
return




Exit:
GuiClose:
GuiEscape:
ExitApp