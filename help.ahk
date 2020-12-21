HelpSubmit:
if !HelpUI_loaded
    gosub,load_HelpUI
Gui HelpUI:show,,Help
return

load_HelpUI:
HelpUI_loaded := 1
Gui HelpUI:font,s12 bold cFFFFFF, Segoe UI
Gui HelpUI:margin,5,5
Gui HelpUI:add, Treeview, x5 y5 w209 h500 gHelpUI_TVClick vHelpUI_TV AltSubmit ReadOnly background1A2427,
Gui HelpUI:Default
Gui HelpUI:TreeView,HelpUI_TV
Loop %AA_scriptdir%\help\*.html
{
    SplitPath, % A_LoopFileFullPath, OutFileName, OutDir, OutExtension, OutNameNoExt, OutDrive
    TV_Add(OutNameNoExt)
}
Gui 1:Default
Gui 1:TreeView,MainTreeHandle
Gui HelpUI:add, ActiveX, x+1 yp w429 hp vHelpUI_WB,Shell.Explorer
HelpUI_WB.Navigate(AA_scriptdir . "\help\about.html")
Gui HelpUI:+Resize
Gui HelpUI:+Owner1
return
HelpUIGuiSize:
GuiControl, HelpUI:Move, HelpUI_TV,% "w" Round( (A_GuiWidth-10)*0.333 ) " h" Round( (A_GuiHeight-10) )
GuiControl, HelpUI:Move, HelpUI_WB,% "x" Round( (A_GuiWidth-10)*0.333 )+1 " w" Round( (A_GuiWidth-10)*0.666 ) " h" Round( (A_GuiHeight-10) )
return
HelpUI_TVClick:
Gui HelpUI:Default
Gui HelpUI:TreeView,HelpUI_TV
itemID := TV_GetSelection()
TV_GetText(itemText, itemID)
HelpUI_WB.Navigate(AA_scriptdir . "\help\" itemText ".html")
Gui 1:Default
Gui 1:TreeView,MainTreeHandle
return