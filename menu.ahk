load_Menus:
;;loading menus

;ImportMenu
Menu,ImportMenu,add,File,MainMenuHandle
    Menu, ImportMenu,Icon,File,% AA_scriptdir "\uiicons.dll",% iconObj["File_26749"], 0
Menu,ImportMenu,add,URL,MainMenuHandle
    Menu, ImportMenu,Icon,URL,% AA_scriptdir "\uiicons.dll",% iconObj["internet_url_15894"], 0
Menu,ImportMenu,add,Clipboard,MainMenuHandle
    Menu, ImportMenu,Icon,Clipboard,% AA_scriptdir "\uiicons.dll",% iconObj["Paste_icon-icons.com_73699"], 0

Menu,MainMenu,add,Import,:ImportMenu
    Menu, MainMenu,Icon,Import,% AA_scriptdir "\uiicons.dll",% iconObj["open folder"], 0
Menu,MainMenu,add,Save,MainMenuHandle
    Menu, MainMenu,Icon,Save,% AA_scriptdir "\uiicons.dll",% iconObj["Save Disk"], 0

Menu,MainMenu,add,Expand All,MainMenuHandle
    Menu, MainMenu,Icon,Expand All,% AA_scriptdir "\uiicons.dll" ,% iconObj["plus_red"], 0
Menu,MainMenu,add,Colapse All,MainMenuHandle
    Menu, MainMenu,Icon,Colapse All,% AA_scriptdir "\uiicons.dll" ,% iconObj["circle"], 0
    ;theme menu
    for k, v in ThemeColor_OBJ{
        Menu,ThemeMenu,add,% k, ThemeMenuSubmit
            Menu,ThemeMenu,icon,% k,% AA_scriptdir "\uiicons.dll" ,% iconObj["let_" substr(k,1,1) ], 0
        if (cTheme = k)
            Menu,ThemeMenu,Check,% k
    }
    Menu,MainMenu,add,Theme,:ThemeMenu
        Menu, MainMenu,Icon,Theme,% AA_scriptdir "\uiicons.dll" ,% iconObj["4 arrows circle"], 0

Menu,MainMenu,add,Help,HelpSubmit
    Menu, MainMenu,Icon,Help,% AA_scriptdir "\uiicons.dll" ,% iconObj["help_question_1566"], 0


SOVM_Obj := {}
SOVM_Obj["Table"] := "table"
SOVM_Obj["Code"] := "code"
flip := (SOVM_set = "Table") ? "code" : "table"
Menu,MainMenu,add,% flip,SwitchObjViewMode
    Menu, MainMenu,Icon,% flip,% AA_scriptdir "\uiicons.dll" ,% iconObj[flip], 0

Gui 1:menu, MainMenu
;;TV Menu
Menu,TVMenu,add,Copy raw,TVMenuHandle
    Menu, TVMenu, Icon, Copy raw, % AA_scriptdir "\uiicons.dll", % iconObj["Save Disk"],0
Menu,TVMenu,add,Copy as JSON,TVMenuHandle
    Menu, TVMenu, Icon, Copy as JSON, % AA_scriptdir "\uiicons.dll", % iconObj["1455554314_line-15_icon-icons.com_53330"],0
Menu,TVMenu,add,Edit Name/Key,TVMenuHandle
    Menu, TVMenu, Icon, Edit Name/Key, % AA_scriptdir "\uiicons.dll", % iconObj["file_edit_14809"],0
Menu,TVMenu,add,Edit Value,TVMenuHandle
    Menu, TVMenu, Icon, Edit Value, % AA_scriptdir "\uiicons.dll", % iconObj["file-edit_114433"],0
Menu,TVMenu,add,Delete,TVMenuHandle
    Menu, TVMenu, Icon, Delete, % AA_scriptdir "\uiicons.dll", % iconObj["Red X"],0
Menu,TVMenu,add,Add Item,TVMenuHandle
    Menu, TVMenu, Icon, Add Item, % AA_scriptdir "\uiicons.dll", % iconObj["button_add_insert_new_14983"],0
Menu,TVMenu,add,Add Object,TVMenuHandle
    Menu, TVMenu, Icon, Add Object, % AA_scriptdir "\uiicons.dll", % iconObj["file-add_114479"],0
;;LV menu
Menu,LVMenu,add,Copy Value,LVMenuHandle
Menu,LVMenu,add,Copy Name/Key,LVMenuHandle
return

MainMenuHandle:
if (A_ThisMenu = "ImportMenu"){
    If (A_ThisMenuItem = "Clipboard"){
        try inputOBJ := Jxon_Load(clipboard)
        catch e{
            msgBox,0,Invalid JSON format,% e
            return
        }
    }
    If (A_ThisMenuItem = "URL"){
        Gui 1:+OwnDialogs
        InputBox, _fmURL , Insert URL, Enter direct URL to JSON, , 200, 150
        Gui 1:-OwnDialogs
        if ErrorLevel || !_fmURL
            return
        try{
            _WinHTTP := ComObjCreate("WinHTTP.WinHttpRequest.5.1")
            _WinHTTP.Open("get", _fmURL,false)
            _WinHTTP.send()
            _WinHTTP.waitforresponse(2)
        }
        try inputOBJ := jxon_load(_WinHTTP.ResponseText)
        catch e{
            Gui 1:+OwnDialogs
            MsgBox, 0, Error,% "URL link does not return JSON`.`n" e
            Gui 1:-OwnDialogs
            return
        }
    }
    If (A_ThisMenuItem = "File"){
        Gui 1:+OwnDialogs
        FileSelectFile, InputFileDir, 3, % A_scriptdir, Select JSON input, *txt; *json
        Gui 1:-OwnDialogs
        If !InputFileDir
            return
        FileRead, InputJSON, % InputFileDir
        try inputOBJ := jxon_load(InputJSON)
        catch e{
            Gui 1:+OwnDialogs
            MsgBox, 0, Error,% "File " InputFileDir " is not a valid JSON`.`n" e
            Gui 1:-OwnDialogs
            return
        }
    }
    TV_Delete()
    TreeID := submit_JSON_to_treeview(inputOBJ,"MainTreeHandle")
    gosub,Update_StatusBar
}
If (A_ThisMenuItem = "Save"){
    FileSelectFile, userSavePath, S2, % A_scriptdir "\newExportJson.json" , Save JSON Object, *json
    if ErrorLevel || !userSavePath
        return
    if (substr(userSavePath,-4,5) != ".json")
        userSavePath .= ".json"
    IfExist, % userSavePath
    {
        msgbox,3,File Already Exist,% "File " Chr(34) userSavePath Chr(34) " already exist. Would you like to overwrite it`?"
        ifmsgbox yes
            FileDelete, % userSavePath
        Else
            return
    }
    FileAppend,% Jxon_Dump(inputOBJ,"`t"),% userSavePath
    msgbox,0,File Saved,File saved in`n%userSavePath%
}
If (A_ThisMenuItem = "Expand All")
    _expand_treeview("MainTreeHandle")
If (A_ThisMenuItem = "Colapse All")
    _expand_treeview("MainTreeHandle",0)
return

TVMenuHandle:
If (Substr(A_ThisMenuItem,1,4) = "edit"){
    TV_GetText(ItemText, ItemID)
    arr := strsplit(ItemText," : ")
    If (A_ThisMenuItem = "Edit Name/Key"){
        w := arr[2] ? "Item" : "Object"
        InputBox, userInput, Insert %w%, Insert New %w% Name, , 300, 100, , , Segoue UI,,% arr[1]
        If !userInput || ErrorLevel
            return
        a := ["`n","`r","`t"]
        for index, value in a
            userInput := StrReplace(userInput,value)
        fin := (arr[2]) ? userInput " : " arr[2] : userInput
        TV_Modify(ItemID, "", fin)
    }
    If (A_ThisMenuItem = "Edit Value"){
        If !arr[2]
            return
        d := (substr(arr[2],1,1) . substr(arr[2],0,1) = Chr(34) . Chr(34)) ? substr(arr[2],2,-1) : arr[2]
        InputBox, userInput, Insert Item Value, Insert New Item Value, , 300, 100, , , Segoue UI,,% d
        if ErrorLevel
            Return
        If !IsNum(userInput) && (substr(userInput,1,1) . substr(userInput,0,1) != Chr(34) . Chr(34))
            userInput := Chr(34) . userInput . Chr(34)
        If IsNum(userInput){
            opt := "icon" clrObj["icon"]["i"]
            fore := clrObj["int"]
            back := clrObj["back"]
        } else {
            opt := "icon" clrObj["icon"]["s"]
            fore := clrObj["string"]
            back := clrObj["back"]
        }
        mainTree.Mod({ItemID:ItemID,fore:fore,back:back,option:opt,NewName:arr[1] " : " userInput})
        prevParentID :=
        gosub,MainTreeClick ;; to refresh listview with modified item
    }
    inputOBJ := _treeview_to_obj_recurrsive("MainTreeHandle")
    gosub,Update_StatusBar
}
If (A_ThisMenuItem = "Copy raw"){
    If TV_GetChild(ItemID) ;; key reference
        TV_GetText(v, ItemID)
    else
        {
        arr := get_FamilyTree(ItemID)
        v := 
        r := inputOBJ 
        for index, value in arr
            If IsObject(r[value])
                r := r[value]
            else
                v := r[value]
        }
    r := {}, r := ""
    msgbox,0,Copied,% clipboard := v
}
If (A_ThisMenuItem = "Copy as JSON"){
    arr := get_FamilyTree(ItemID)
    rObj := inputOBJ[arr[1]], arr.RemoveAt(1)
    for i, k in arr{
        if !IsObject(rObj[k])
            break
        else
            rObj := rObj[k]
    }
    Clipboard := jxon_dump(rObj," ")
    rObj := {}, rObj := ""
    msgbox,0,Copied,% Clipboard
}
If (A_ThisMenuItem = "Delete"){
    TV_GetText(ItemText, ItemID)
    arr := strsplit(ItemText," : ")
    w := !TV_GetChild(ItemID) ? "item" : "object"
    Gui 1:+OwnDialogs
    MsgBox,4,Confirm,% "Are you sure you want to delete " w " " Chr(34) arr[1] Chr(34) "`?"
    ifmsgbox YES
        {
        GuiControl,1:-Redraw, MainTreeHandle
        TV_Delete(ItemID)    
        prevParentID :=
        gosub,MainTreeClick
        inputOBJ := _treeview_to_obj_recurrsive("MainTreeHandle")
        GuiControl,1:+Redraw, MainTreeHandle
        gosub,Update_StatusBar
        }
    Gui 1:-OwnDialogs
}
If (A_ThisMenuItem = "Add Item"){
    InputBox, userInputKey, Insert Item Key, Insert New Item Key, , 300, 100, , , Segoue UI,,
    If !strlen(userInputKey) || ErrorLevel
        return
    if instr(userInputKey,":"){
        Gui 1:+OwnDialogs
        msgbox,0,Invalid Key Input,Invalid input entered`.
        Gui 1:-OwnDialogs
        return
    }
    InputBox, userInputValue, Insert Item Value, Insert New Item Value, , 300, 100, , , Segoue UI,,
    If ErrorLevel
        return
    if !IsNum(userInputValue)
        mainTree.Add({Label:userInputKey " : " Chr(34) . userInputValue . Chr(34),Fore:clrObj["string"],Back:clrObj["back"],parent:ParentID,Option:"icon" clrObj["icon"]["s"] " " ItemID})                    
    else
        mainTree.Add({Label:userInputKey " : " userInputValue,Fore:clrObj["int"],Back:clrObj["back"],parent:ParentID,Option:"icon" clrObj["icon"]["i"] " " ItemID})
    prevParentID :=
    gosub,MainTreeClick
    inputOBJ := _treeview_to_obj_recurrsive("MainTreeHandle")
    gosub,Update_StatusBar
}
If (A_ThisMenuItem = "Add Object"){
    gosub,AddObjGUI_clearAll
    Gui 1: +Disabled
    goto,show_AddObjGUI
}
return

LVMenuHandle:
If (A_ThisMenuItem = "Copy Value")
    clipboard := LV_selected_OBJ["Value"]
If (A_ThisMenuItem = "Copy Name/Key")
    clipboard := LV_selected_OBJ["Name"]
return

get_reference_fm_itemID(ItemID)
{
    arr := get_FamilyTree(ItemID)
    for index, value in arr {
        mV := !IsNum(value) ? Chr(34) . value . Chr(34) : value
        v .= "[" mV "]"
    }
    return v
}

SwitchObjViewMode:
Menu, MainMenu,Rename,% A_ThisMenuItem,% SOVM_set
s := SOVM_set
SOVM_set := CodeTable_switch(SOVM_set)
Menu, MainMenu,Icon,% s,% AA_scriptdir "\uiicons.dll" ,% iconObj[ SOVM_Obj[s] ], 0
;; icon does not refresh unless hovered over..
MouseMove, -60, 1 , 0, R
MouseMove, 0, 2, 0, R
MouseMove, +60, -3 , 0, R
return
CodeTable_switch(cMode)
{
    newMode := (cMode = "Code") ? "Table" : "Code"
    if (newMode = "Table"){
        GuiControl,1:hide,MainCodeEditHandle
        GuiControl,1:show,MainListViewHandle
    } else {
        GuiControl,1:hide,MainListViewHandle
        GuiControl,1:show,MainCodeEditHandle
    }
    return newMode
}