submit_JSON_to_treeview(inputOBJ,TreeViewHandle,GuiName := 1)
{
    GuiControl,%GuiName%:-Redraw, % TreeViewHandle
    TreeID := _obj_to_treeview_recurrsive(inputOBJ)
    GuiControl,%GuiName%:+Redraw, % TreeViewHandle
    return TreeID
}


_expand_treeview(TreeViewHandle,mod := 1,GuiName := 1)
{
    
    If (A_gui != GuiName)
        Gui %GuiName%:Default
    If (A_DefaultTreeView != TreeViewHandle)
        Gui %GuiName%:TreeView,% TreeViewHandle
    GuiControl,%GuiName%:-Redraw, % TreeViewHandle
    ItemID := 0
    s := !mod ? "-" : ""
    Loop {
        ItemID := TV_GetNext(ItemID, "Full")
        TV_Modify(ItemID , s . "Expand")
        If !ItemID
            break
    }
    GuiControl,%GuiName%:+Redraw, % TreeViewHandle
}

_treeview_to_obj_recurrsive(TreeViewHandle,submitParent := 0, GuiName := 1)
{
    If (A_gui != GuiName)
        Gui %GuiName%:Default
    If (A_DefaultTreeView != TreeViewHandle)
        Gui %GuiName%:TreeView,% TreeViewHandle
    ItemID := 0
    rObj := {}
    firstItemID := ""
    Loop,{
        ItemID := TV_GetNext(ItemID, "Full")
        If (firstItemID) && (firstItemID = ItemID) ;; repeat
            break
        If !firstItemID
            firstItemID := ItemID
        If (submitParent != TV_GetParent(ItemID))
            continue
        If !ItemID
            break
        TV_GetText(itemText, ItemID)
        arr := strsplit(itemText," : ")
        If arr[2]{ ;; item
            rObj[arr[1]] := Trim(arr[2],Chr(34))
        }
        else{ ;; object
            rObj[arr[1]] := _treeview_to_obj_recurrsive(TreeViewHandle,ItemID,GuiName)
        }
    }
    return rObj
}

_obj_to_treeview_recurrsive(submitObj,ParentItemID := 0)
{
    for k, v in submitObj
        {
        If IsObject(v)
            {
            cItemID := mainTree.Add({Label:k,Fore:clrObj["obj"],Back:clrObj["back"],parent:ParentItemID,Option:"icon" clrObj["icon"]["o"]}) ;,Option:"Expand"})
            _obj_to_treeview_recurrsive(v,cItemID)
            }
        else
            {
            if !IsNum(v)
                cItemID := mainTree.Add({Label:k " : " Chr(34) . v . Chr(34),Fore:clrObj["string"],Back:clrObj["back"],parent:ParentItemID,Option:"icon" clrObj["icon"]["s"]})                    
            else
                cItemID := mainTree.Add({Label:k " : " v,Fore:clrObj["int"],Back:clrObj["back"],parent:ParentItemID,Option:"icon" clrObj["icon"]["i"]})
            }
        }
    return cItemID
}

get_FamilyTree(ItemID, rArr := "")
{
    If !IsObject(rArr)
        {
        rArr := []
        TV_GetText(Name, ItemID)
        arr := strsplit(Name," : ")
        rArr.InsertAt(1, arr[1])
        }
    cParentID := TV_GetParent(ItemID)
    TV_GetText(cParentName, cParentID)
    If !cParentID
        return rArr
    rArr.InsertAt(1, cParentName)
    return get_FamilyTree(cParentID,rArr)
}

arr_of_obj_to_listview(arrOfObj,LV_handle,header_array, GuiNum := 1)
{
    Gui %GuiNum%: Default
    Gui %GuiNum%: ListView, %LV_handle%
    GuiControl,%GuiName%:-RedRaw,%LV_handle%
    LV_Delete()
    Loop, % header_array.MaxIndex()
        {
        error_ck := LV_ModifyCol(A_index,"AutoHdr CaseLocale", header_array[A_index])
        If (error_ck = 0)
            LV_InsertCol(A_index,"AutoHdr CaseLocale", header_array[A_index])
        }
    Loop,% arrOfObj.MaxIndex()
        {
        prim_index := A_index
        val_array := []
        Loop, % header_array.MaxIndex()
            val_array.push( arrOfObj[prim_index][ header_array[A_index] ] )
        iconNum := IsNum(val_array[2]) ? 1 : 2
        LV_Add("Icon" . iconNum, val_array*)
        }
    Loop, % header_array.MaxIndex()
        {
        error_ck := LV_ModifyCol(A_index,"AutoHdr", header_array[A_index])
        If (error_ck = 0)
            break
        }
    GuiControl,%GuiName%:+RedRaw,%LV_handle%
}

IsNum( str ) 
{
	if str is number
		return true
	return false
}
get_string_fm_array(array,d,Max := 0)
{
    for index, value in array {
        r .= value . d
        If (A_index = Max)
            break
    }
    return RTrim(r,d)
}