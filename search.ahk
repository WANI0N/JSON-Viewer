Enter::
Send,{enter}
activeHWND := GetFocusedControlHwnd()
If (Main_SQueryHWND = activeHWND){
    goto,SearchUI_ButtonClick_byPass
    return
}
return

GetFocusedControlHwnd()
{
    GuiWindowHwnd := WinExist("A")		;stores the current Active Window Hwnd id number in "GuiWindowHwnd" variable
    ControlGetFocus, FocusedControl, ahk_id %GuiWindowHwnd%	;stores the  classname "ClassNN" of the current focused control from the window above in "FocusedControl" variable
    ControlGet, FocusedControlId, Hwnd,, %FocusedControl%, ahk_id %GuiWindowHwnd%	;stores the Hwnd Id number of the focused control found above in "FocusedControlId" variable
    return FocusedControlId
}
focus_search:
GuiControl,1:focus,Main_SQuery
Send,^a
return

SearchUI_clearHighLight:
If prev_SearchUI_c_resultFocus_ID
    SearchUI_highlight(prev_SearchUI_c_resultFocus_ID,0)
prev_SearchUI_c_resultFocus_ID := 0
return
SearchUI_highlight(ItemID,on := 1)
{
    Gui 1:default
    Gui 1:TreeView,MainTreeHandle
    TV_GetText(itemText, ItemID)
    arr := strsplit(itemText," : ")
    If !arr[2]
        fore := clrObj["obj"], opt := "icon" clrObj["icon"]["o"]
    else if IsNum(arr[2])
        fore := clrObj["int"], opt := "icon" clrObj["icon"]["i"]
    else
        fore := clrObj["string"], opt := "icon" clrObj["icon"]["s"]
    back := on ? clrObj["highlight"] : clrObj["back"]
    mainTree.Mod({ItemID:ItemID,fore:fore,back:back,option:opt,NewName:get_string_fm_array(arr," : ")})
}

SearchUI_ButtonClick_byPass:
B_GuiControl := "Main_SButtonPrev"
SearchUI_ButtonClick:
B_GuiControl := !B_GuiControl ? A_GuiControl : B_GuiControl
If !SearchResult_AoO[1]
    return
SearchUI_c_resultFocus += (A_GuiControl = "Main_SButtonPrev") ? -1 : 1
B_GuiControl := ""
SearchUI_c_resultFocus := (SearchUI_c_resultFocus = SearchResult_AoO.MaxIndex()+1) ? 1 : SearchUI_c_resultFocus
SearchUI_c_resultFocus := !SearchUI_c_resultFocus ? SearchResult_AoO.MaxIndex() : SearchUI_c_resultFocus
GuiControl,1:,Main_SMatchCount,% SearchUI_c_resultFocus "/" SearchResult_AoO.MaxIndex()
Gui 1:default
Gui 1:TreeView,MainTreeHandle
GuiControl,%GuiName%:-RedRaw,%LV_handle%
TV_Modify(SearchResult_AoO[SearchUI_c_resultFocus]["id"] , "Select Expand")
If prev_SearchUI_c_resultFocus_ID
    SearchUI_highlight(prev_SearchUI_c_resultFocus_ID,0)
SearchUI_highlight(SearchResult_AoO[SearchUI_c_resultFocus]["id"])
prev_SearchUI_c_resultFocus_ID := SearchResult_AoO[SearchUI_c_resultFocus]["id"]
GuiControl,%GuiName%:+RedRaw,%LV_handle%
return

SearchUI_Submit:
If SearchUI_Process_on
    return
gosub,SearchUI_clearHighLight
Gui 1:submit,nohide
If !Strlen(Main_SQuery) ;; in case of searching for "0"
    {
    GuiControl,1:,Main_SMatchCount,0/0
    return
    }
SearchResult_AoO := []
Gui 1:default
Gui 1:TreeView,MainTreeHandle
cItemID := 0
SearchUI_Process_on := 1
Loop {
    cItemID := TV_GetNext(cItemID,"Full")
    If !cItemID
        break
    TV_GetText(ItemText, cItemID)
    if Instr(ItemText,Main_SQuery){
        o := {}, o["text"] := ItemText, o["id"] := cItemID
        SearchResult_AoO.push(o)
    }
}
SearchUI_Process_on := 0
If !SearchResult_AoO[1]
    GuiControl,1:,Main_SMatchCount,0/0
Else{
    GuiControl,1:,Main_SMatchCount,% "1/" SearchResult_AoO.MaxIndex()
    SearchUI_c_resultFocus := 1
    TV_Modify(SearchResult_AoO[SearchUI_c_resultFocus]["id"] , "Select Expand")
    SearchUI_highlight(SearchResult_AoO[SearchUI_c_resultFocus]["id"])
    prev_SearchUI_c_resultFocus_ID := SearchResult_AoO[SearchUI_c_resultFocus]["id"]
}
return