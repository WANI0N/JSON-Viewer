
ToolTipTimeOut:
If !ToolTipActive{
    return
}
If !ActiveToolTipCount{
    ToolTipActive := 0
    ToolTipMouseCoor := {}
    return
}
MouseGetPos, X, Y
If (Abs(X-ToolTipMouseCoor["x"]) > 10) || (Abs(Y-ToolTipMouseCoor["y"]) > 10){
    loop, % ActiveToolTipCount
        ToolTip,,,,% A_index
    ActiveToolTipCount := 0
    ToolTipActive := 0
    return
}
return

AddObjGUI_AddTypeDDClick:
ToolTipControlContentArray := []
GuiControlGet,AddObjGUI_AddTypeDD,AddObjGUI:
for k, AoO in AddObjGUI_HandleObj
    If (AddObjGUI_AddTypeDD != k)
        for key, obj in AoO
            GuiControl,AddObjGUI:Disable,% obj["control"]
loop, % ActiveToolTipCount
    ToolTip,,,,% A_index
ActiveToolTipCount := 0
for index, obj in AddObjGUI_HandleObj[AddObjGUI_AddTypeDD] {
    GuiControl,AddObjGUI:Enable,% obj["control"]
    if strlen(obj["description"]){
        ActiveToolTipCount += 1
        GuiControlGet, CtrlPos, AddObjGUI:Pos , % obj["control"]
        ToolTip, % "<- " obj["description"], % CtrlPosX+CtrlPosW+2, % CtrlPosY+CtrlPosH+2, % ActiveToolTipCount
    }
}
MouseGetPos, X, Y
ToolTipMouseCoor := {"x":X,"y":Y}, ToolTipActive := 1
return

AddObjGUI_fmDirSelect:
Gui AddObjGUI:+OwnDialogs
FileSelectFile, InputFileDir, 3, , Select JSON input, *txt; *json
Gui AddObjGUI:-OwnDialogs
If !InputFileDir || Errorlevel
    return
IfNotExist, % InputFileDir
    return
GuiControl,AddObjGUI:,AddObjGUI_fmDir,% InputFileDir
return
AddObjGUI_AddItem:
GuiControlGet,AddObjGUI_ItemName,AddObjGUI:
GuiControlGet,AddObjGUI_ItemValue,AddObjGUI:
errLog := []
If !strlen(AddObjGUI_ItemName) || !strlen(AddObjGUI_ItemValue)
    errLog.push("Item Key and Item Name must be entered`.")
If instr(AddObjGUI_ItemName,":")
    errLog.push("Column character (:) is not allowed in key name")
If errLog[1]{
    Gui AddObjGUI:+OwnDialogs
    msgbox,0,Error, % get_string_fm_array(errLog,"`n")
    Gui AddObjGUI:-OwnDialogs
    return
}
GuiControl,AddObjGUI:,AddObjGUI_ItemName,
GuiControl,AddObjGUI:,AddObjGUI_ItemValue,
LB_cObj[AddObjGUI_ItemName] := AddObjGUI_ItemValue
push_LB_cObj_toControl:
LB_cArr := []
for k, v in LB_cObj
    LB_cArr.push( k " : " v )
GuiControl,AddObjGUI:,AddObjGUI_LB,|
GuiControl,AddObjGUI:,AddObjGUI_LB,% get_string_fm_array(LB_cArr,"|")
return
AddObjGUI_LBClick:
If (A_GuiEvent = "DoubleClick")
    {
    GuiControlGet,AddObjGUI_LB,AddObjGUI:
    arr := strsplit(LB_cArr[AddObjGUI_LB]," : ")
    LB_cObj.Delete(arr[1])
    goto, push_LB_cObj_toControl
    }
return

AddObjGUI_AddObjectSubmit:
GuiControlGet,AddObjGUI_AddTypeDD,AddObjGUI:
GuiControlGet,AddObjGUI_ObjName,AddObjGUI:
If !strlen(AddObjGUI_ObjName) || instr(AddObjGUI_ObjName,":"){
    Gui AddObjGUI:+OwnDialogs
    msgbox,0,Error,Invalid object name`.
    Gui AddObjGUI:-OwnDialogs
    return
}

AddObjGUI_submitObj := {}
AddObjGUI_submitObj["name"] := AddObjGUI_ObjName

AddObjGUI_submitObj["content"] := {}, AddObjGUI_submitObj["content"] :=
Switch AddObjGUI_AddTypeDD
{
    Case "Define":
        AddObjGUI_submitObj["content"] := LB_cObj
    Case "Load From File":
    {
        GuiControlGet,AddObjGUI_fmDir,AddObjGUI:
        IfNotExist, % AddObjGUI_fmDir
        {
            MsgBox,0,File not Found,File %AddObjGUI_fmDir% does not exist.
            return
        }
        FileRead, FileContent, % AddObjGUI_fmDir
        try AddObjGUI_submitObj["content"] := jxon_load(FileContent)
        catch e{
            AddObjGUI_submitObj["content"] := {}, AddObjGUI_submitObj["content"] :=
            Gui AddObjGUI:+OwnDialogs
            MsgBox, 0, Error, Input File not in JSON format`.
            Gui AddObjGUI:-OwnDialogs
            return
        }
    }
    Case "Load from URL":
    {
        GuiControlGet,AddObjGUI_fmURL,AddObjGUI:
        _WinHTTP := ComObjCreate("WinHTTP.WinHttpRequest.5.1")
        _WinHTTP.Open("get", AddObjGUI_fmURL,false)
        try{
            _WinHTTP.send()
            _WinHTTP.waitforresponse(2)
        }
        try AddObjGUI_submitObj["content"] := jxon_load(_WinHTTP.ResponseText)
        catch e{
            AddObjGUI_submitObj["content"] := {}, AddObjGUI_submitObj["content"] :=
            Gui AddObjGUI:+OwnDialogs
            MsgBox, 0, Error, URL link does not return JSON`.
            Gui AddObjGUI:-OwnDialogs
            return
        }
    }
}

GuiControl,1:-Redraw, MainTreeHandle
Gui 1:Default
c_P_ItemID := mainTree.Add({Label:AddObjGUI_submitObj["name"],Fore:clrObj["obj"],Back:clrObj["back"],parent:ParentID,Option:"icon" clrObj["icon"]["o"]})
_obj_to_treeview_recurrsive(AddObjGUI_submitObj["content"],c_P_ItemID)
inputOBJ := {}
inputOBJ := _treeview_to_obj_recurrsive("MainTreeHandle")
GuiControl,1:+Redraw, MainTreeHandle

AddObjGUIGuiClose:
loop, % ActiveToolTipCount
        ToolTip,,,,% A_index
    ActiveToolTipCount := 0
Gui AddObjGUI:Cancel
Gui 1: -Disabled
gosub,Update_StatusBar
Gui 1: show
return

AddObjGUI_clearAll:
LB_cObj := {}
GuiControl,AddObjGUI:,AddObjGUI_LB,|
GuiControl,AddObjGUI:,AddObjGUI_ObjName,
GuiControl,AddObjGUI:choose,AddObjGUI_AddTypeDD,1
GuiControl,AddObjGUI:,AddObjGUI_ItemName,
GuiControl,AddObjGUI:,AddObjGUI_ItemValue,
GuiControl,AddObjGUI:,AddObjGUI_fmDir,
GuiControl,AddObjGUI:,AddObjGUI_fmURL,
return
load_AddObjGUI:
AddObjGUI_HandleObj := {}
Gui AddObjGUI:+Owner1
Gui AddObjGUI: margin, 5, 5
Gui AddObjGUI: font,s10 bold, Segoe UI
Gui AddObjGUI: color,% clrObj["TVMenu"]
Gui AddObjGUI: add, text, x5 y5 w99 h24 center, Object Name:
Gui AddObjGUI: add, edit, x+1 yp w99 hp vAddObjGUI_ObjName center,
Gui AddObjGUI: add, text, x5 y+5 w199 h1 0x7
Gui AddObjGUI: add, DropDownList, xp y+5 w199 vAddObjGUI_AddTypeDD gAddObjGUI_AddTypeDDClick choose1,Define|Load From File|Load from URL
Gui AddObjGUI: add, text, x5 y+5 w199 h1 0x7

Gui AddObjGUI: add, text, xp y+5 w99 h24 center, Item Name:
Gui AddObjGUI: add, edit, x+1 yp w99 hp vAddObjGUI_ItemName center,
Gui AddObjGUI: add, text, x5 y+5 w99 h24 center, Item Value:
Gui AddObjGUI: add, edit, x+1 yp w99 hp vAddObjGUI_ItemValue center,
Gui AddObjGUI: add, button, x5 y+5 w199 hp vAddObjGUI_AddItem gAddObjGUI_AddItem, Add Item
Gui AddObjGUI: add, listbox, xp y+3 wp h59 vAddObjGUI_LB gAddObjGUI_LBClick altsubmit,
AddObjGUI_HandleObj["Define"] := []
o := {}, o["control"] := "AddObjGUI_ItemName", o["description"] := "Enter item key/name"
AddObjGUI_HandleObj["define"].push(o)
o := {}, o["control"] := "AddObjGUI_ItemValue", o["description"] := "Enter item value"
AddObjGUI_HandleObj["define"].push(o)
o := {}, o["control"] := "AddObjGUI_AddItem", o["description"] := "Press to add current item"
AddObjGUI_HandleObj["define"].push(o)
o := {}, o["control"] := "AddObjGUI_LB", o["description"] := "List of currently added items in object"
AddObjGUI_HandleObj["define"].push(o)

Gui AddObjGUI: add, text, x5 y+5 w199 h1 0x7

Gui AddObjGUI: add, edit, xp y+5 w174 h24 readonly vAddObjGUI_fmDir,
Gui AddObjGUI: add, button, x+1 yp w24 h24 vAddObjGUI_fmDirSelect gAddObjGUI_fmDirSelect,📂
AddObjGUI_HandleObj["Load From File"] := []
o := {}, o["control"] := "AddObjGUI_fmDirSelect", o["description"] := "Click to select directory path to JSON object"
AddObjGUI_HandleObj["Load From File"].push(o)
o := {}, o["control"] := "AddObjGUI_fmDir"
AddObjGUI_HandleObj["Load From File"].push(o)

Gui AddObjGUI: add, text, x5 y+5 w199 h1 0x7

Gui AddObjGUI: add, text, x5 y+5 w49 h24 center,URL🔗
Gui AddObjGUI: add, edit, x+1 yp w149 h24 vAddObjGUI_fmURL,

AddObjGUI_HandleObj["Load From URL"] := []
o := {}, o["control"] := "AddObjGUI_fmURL", o["description"] := "Enter direct URL to JSON Object"
AddObjGUI_HandleObj["Load From URL"].push(o)

Gui AddObjGUI: add, text, x5 y+5 w199 h1 0x7

Gui AddObjGUI: add, button, xp y+3 wp h24 gAddObjGUI_AddObjectSubmit,Add Object
gosub,AddObjGUI_clearAll
return
show_AddObjGUI:
Gui AddObjGUI:show,,+Obj
gosub,AddObjGUI_AddTypeDDClick
return