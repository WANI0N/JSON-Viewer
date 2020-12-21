#SingleInstance, Force
SetWorkingDir, %A_ScriptDir%

Global ToolTipMouseCoor := {}
Global ToolTipActive := 0
Global ActiveToolTipCount := 0

#Persistent
SetTimer,ToolTipTimeOut,500

AA_scriptdir := A_ScriptDir

settingFileDir := AA_scriptdir "\cache\AHK_ObjViewer.ini"

;;loading settings
Global inputOBJ := {}
IniRead,rawJSON,% settingFileDir, settings, cObj
if (rawJSON != "ERROR")
    inputOBJ := jxon_load(rawJSON)
else{
    inputOBJ := {}
    inputOBJ["p1"] := {}
        cObj := {}
        cObj["i1"] := "asd"
        cObj["i2"] := 88
        cObj["Array"] := ["q","w","r"]
        cObj["i4"] := "zxczxcz"
    inputOBJ["p1"]["c1"] := cObj
    inputOBJ["p1"]["item2"] := "oauhsdouh"
    inputOBJ["p2"] := {}
    inputOBJ["p2"]["item1"] := "odfhodu"
    inputOBJ["p3"] := "paowowowo"
}


load_UI:
iconObj := {"1455554314_line-15_icon-icons.com_53330":1,"32_122669":2,"4 arrows circle":3,"applicationjson_92733":4,"arrowdown_111022":5,"arrowleft_111053":6,"arrowright_111004":7,"arrowup_111030":8,"button_add_insert_new_14983":9,"circle":10,"code":11,"eye":12,"file-add_114479":13,"file-edit_114433":14,"File_26749":15,"file_edit_14809":16,"folder_black":17,"help_question_1566":18,"internet_url_15414":19,"internet_url_15894":20,"let_B":21,"let_D":22,"let_G":23,"let_O":24,"let_P":25,"let_W":26,"new-file_40454":27,"Number-8-icon_34775":28,"number_one_1_17862":29,"onepage_un_3022":30,"open folder":31,"Paste_icon-icons.com_73699":32,"plus_red":33,"Red X":34,"Save Disk":35,"sublimetext_94866":36,"table":37,"xmag_search_find_export_locate_5984":38}
global ThemeColor_OBJ := {}
guitheme.load()

Global clrObj := {}
IniRead,cTheme,% settingFileDir, UI, Theme
cTheme := (cTheme = "ERROR") ? "blue" : cTheme

clrObj := ThemeColor_OBJ[cTheme]

clrObj["back"] := "0x452E08"
clrObj["highlight"] := "0xA00292"
clrObj["obj"] := "0xC8E2FA"
clrObj["string"] := "0x1C87E8"
clrObj["int"] := "0xD9F900"

o := {}
o["o"] := iconObj["32_122669"]
o["s"] := iconObj["sublimetext_94866"]
o["i"] := iconObj["Number-8-icon_34775"]
clrObj["icon"] := o



Gui 1: font, s10 BOLD, Segoe UI
cFontSize := 10
Gui 1: +resize
Gui 1: margin,5,5
b := clrObj["TVBack"]

ImageListID := IL_Create(10)  ; Create an ImageList with initial capacity for 10 icons.
for k, v in iconObj
    IL_Add(ImageListID, AA_scriptdir "\uiicons.dll" , A_Index)

LV_ImageList := IL_Create(2)
IL_Add(LV_ImageList,AA_scriptdir "\uiicons.dll" , clrObj["icon"]["i"])
IL_Add(LV_ImageList,AA_scriptdir "\uiicons.dll" , clrObj["icon"]["s"])

a := iconObj["xmag_search_find_export_locate_5984"]
Gui 1: add, picture, x5 y5 w24 h24 icon%a% vMain_SMagGlass,% AA_scriptdir "\uiicons.dll" ; x0.5+1 y=5 w=0.05 h0.05
Gui 1: add, edit, x+1 yp w119 hp vMain_SQuery hwndMain_SQueryHWND gSearchUI_Submit center, ; x0.55+1 y=5 w=0.15 h0.05
Gui 1: font, s12
Gui 1: add, text, x+1 yp w49 hp vMain_SMatchCount center, 0/0 ;x0.7+1 y=5 w0.1 h0.05
Gui 1: font, s10
upArrow := iconObj["arrowup_111030"], downArrow := iconObj["arrowdown_111022"]
Gui 1: add, Picture, x+1 yp w24 hp icon%upArrow% vMain_SButtonPrev gSearchUI_ButtonClick,% AA_scriptdir "\uiicons.dll" ;x0.8+1 y=5 w0.05 h0.05
Gui 1: add, Picture, x+1 yp w24 hp icon%downArrow% vMain_SButtonNext gSearchUI_ButtonClick,% AA_scriptdir "\uiicons.dll" ;x0.85+1 y=5 w0.05 h0.05
Gui 1: add, text,x+20 yp w1 hp vMain_line1 0x7
Gui 1: add, text,x+20 yp w69 hp vMain_RefTitle right ,Reference:
Gui 1: add, edit, x+1 yp w345 hp vMain_ObjReference hwndMain_ObjReferenceHWND left readonly,  ; x=5 y=5 w0.5 h0.05
Gui 1: add, treeview, x5 y+1 w600 h600 vMainTreeHandle hwndMainTreeHandleHWND gMainTreeClick ImageList%ImageListID% AltSubmit ReadOnly Background%b%, ; -Redraw,
Global mainTree := new treeview(MainTreeHandleHWND)
b := clrObj["LVBack"]
LV_headerArr := ["Name","Value"]
Gui 1: font,% "s12 c" clrObj["LV_f1"]
Gui 1: add, listview, x+5 yp w200 hp vMainListViewHandle hwndMainListViewHandleHWND gMainListViewHandleClick GRID AltSubmit ReadOnly Background%b% ,% get_string_fm_array(LV_headerArr,"|")
Gui 1: add, edit, xp yp wp hp vMainCodeEditHandle hwndMainCodeEditHandleHWND -Wrap,
IniRead,SOVM_set , % settingFileDir, UI, ObjViewMode
SOVM_set := (SOVM_set = "ERROR") ? "Table" : SOVM_set
EnvSet,MainCodeEditHandleHWND, % MainCodeEditHandleHWND
CtlColors.Attach(MainCodeEditHandleHWND,b,clrObj["LV_f1"])
if (SOVM_set = "table")
    GuiControl,1:Hide,MainCodeEditHandle
else
    GuiControl,1:Hide,MainListViewHandle
cViewMode := "table"
LV_SetImageList(LV_ImageList)
Gui 1: font,s10
Gui 1: add, StatusBar, vMainStatusBar,ready

gosub,load_Menus

TreeID := submit_JSON_to_treeview(inputOBJ,"MainTreeHandle")

Gosub, load_AddObjGUI

Gui 1: show,,JSON Object Visualizer
MainGuiHWND := WinExist("A")

Hotkey, IfWinActive, ahk_id %MainGuiHWND%
Hotkey, ^WheelUp, ZoomIn
Hotkey, ^WheelDown, ZoomOut
Hotkey, ^+, ZoomIn
Hotkey, ^-, ZoomOut
Hotkey, ^f, focus_search
Hotkey, RButton, select_reference
Hotkey, IfWinActive, ahk_id %MainGuiHWND% ; %MainTreeHandleHWND%
gosub,Update_StatusBar
return

select_reference:
If (Main_ObjReferenceHWND = GetFocusedControlHwnd()){
    Send,^a
    return
}
Send,{RButton}
return

ExitApplication:
GuiClose:
IfNotExist, % AA_scriptdir "\cache"
    FileCreateDir, % AA_scriptdir "\cache"
IniWrite,% SOVM_set , % settingFileDir, UI, ObjViewMode
IniWrite,% cTheme, % settingFileDir, UI, Theme
IniWrite,% jxon_dump(inputOBJ), % settingFileDir, settings, cObj
ExitWithOutSaving:
exitapp

GuiSize:
marginalized_GuiWidth := A_GuiWidth-10+3
marginalized_GuiHeight := A_GuiHeight-10-18

sx := 5
GuiControl,1:move,Main_SMagGlass,% "x" sx
sx += 25
GuiControl,1:move,Main_SQuery,% "x" sx 
sx += 120
GuiControl,1:move,Main_SMatchCount,% "x" sx 
sx += 50 
GuiControl,1:move,Main_SButtonPrev,% "x" sx 
sx += 25
GuiControl,1:move,Main_SButtonNext,% "x" sx 
sx += 55
GuiControl,1:move,Main_Line1,% "x" sx 
sx += 32
GuiControl,1:move,Main_RefTitle,% "x" sx 
sx += 70
GuiControl,1:move,Main_ObjReference,% "x" sx " w" marginalized_GuiWidth-sx+5

GuiControl,1:move,MainTreeHandle,% "x5 y30 w" Round(marginalized_GuiWidth*0.66) " h" marginalized_GuiHeight-25
GuiControl,1:move,MainListViewHandle,% "x" Round(marginalized_GuiWidth*0.66)+5 " y30 w" Round(marginalized_GuiWidth*0.34) " h" marginalized_GuiHeight-25
GuiControl,1:move,MainCodeEditHandle,% "x" Round(marginalized_GuiWidth*0.66)+5 " y30 w" Round(marginalized_GuiWidth*0.34) " h" marginalized_GuiHeight-25
return

Update_StatusBar:
_content_count_Obj := get_sb_content_recurrsive(inputOBJ)
Update_StatusBar_byPass:
contentLog := "Object(s) = " _content_count_Obj["objCount"] " | Array(s) = " _content_count_Obj["arrCount"] " | Item(s) = " _content_count_Obj["itemCount"]
if IsObject(_selected_count_obj)
    contentLog .= "   /   Selected: Object(s) = " _selected_count_obj["objCount"] " | Item(s) = " _selected_count_obj["itemCount"] 
GuiControl,1:,MainStatusBar, % "Total: " contentLog
return
get_sb_content_recurrsive(cOBJ,returnObj := 0)
{
    if !returnObj
        returnObj := {}, returnObj["itemCount"] := 0, returnObj["objCount"] := 0, returnObj["arrCount"] := 0
        
    for k, v in cOBJ{
        if v.MaxIndex(){
            returnObj["arrCount"] += 1
            returnObj := get_sb_content_recurrsive(v,returnObj)
        }else if IsObject(v) {
            returnObj["objCount"] += 1
            returnObj := get_sb_content_recurrsive(v,returnObj)
        }else
            returnObj["itemCount"] += 1
    }
    return returnObj
}
ZoomIn:
cFontSize += 1
Gui 1: font, s%cFontSize%
GuiControl,1:font,MainTreeHandle
return
ZoomOut:
cFontSize += -1
Gui 1: font, s%cFontSize%
GuiControl,1:font,MainTreeHandle
return

F12::
ExitApp


MainTreeClick:
ItemID := TV_GetSelection()
GuiControl,1:,Main_ObjReference,% get_reference_fm_itemID(ItemID)
ParentID := TV_GetParent(ItemID)
If !TV_GetChild(ItemID) && (prevParentID != ParentID){
    prevParentID := ParentID
    Topchild := TV_GetChild(ParentID)
    TV_GetText(ItemText, Topchild)
    arr := [ItemText]
    LV_AoO := []
    ItemID := Topchild
    Loop{
        ItemID := TV_GetNext(ItemID, "Full")
        
        if not ItemID  ; No more items in tree.
            break
        TV_GetText(ItemText, ItemID)
        If (ParentID = TV_GetParent(ItemID))
            arr.push(ItemText)
    }
    for i, v in arr{
        o := {}, cArr := StrSplit(v," : "), o["Name"] := cArr[1]
        cArr.RemoveAt(1)
        o["Value"] := strlen(cArr[1]) ? get_string_fm_array(cArr," : ") : "<obj>"
        LV_AoO.push(o)
    }
    arr_of_obj_to_listview(LV_AoO,"MainListViewHandle",LV_headerArr)
    _cs_obj := {}
    _selected_count_obj := {}, _selected_count_obj["objCount"] := 0, _selected_count_obj["itemCount"] := 0
    for i, o in LV_AoO{
        v := o["value"]
        if !IsNum(v) && (v != "<obj>")
            v := substr(v,2,-1)
        _cs_obj[o["name"]] := v
        if (v = "<obj>")
            _selected_count_obj["objCount"] += 1
        else
            _selected_count_obj["itemCount"] += 1
    }
    GuiControl,1:,MainCodeEditHandle, % jxon_dump(_cs_obj,"    ")
    gosub,Update_StatusBar_byPass
}

If (A_GuiEvent = "RightClick"){
    Menu,TVMenu,show
}
return

MainListViewHandleClick:
RowNumber := 0
Loop {
    RowNumber := LV_GetNext(RowNumber) 
    If (RowNumber = 0)
        break
    LV_selected_OBJ := LV_AoO[RowNumber]
    ;LV_GetText(RetrievedText, RowNumber)
    }
If (A_GuiEvent = "RightClick"){
    Menu,LVMenu,show
}
return


#Include, Themes.ahk
#Include, search.ahk
#Include, AddObj.ahk
#Include, help.ahk
#Include, menu.ahk

#Include, libraries/JSON_lib.ahk
#include, libraries/class treeview.ahk
#include, libraries/functions.ahk
#Include, libraries/control_coloring_library.ahk

