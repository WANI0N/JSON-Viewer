

class treeview{
	static list:=[]
	__New(hwnd){
		this.list[hwnd]:=this
		OnMessage(0x4e,"WM_NOTIFY")
		this.hwnd:=hwnd
	}
	add(info){
		Gui,TreeView,% this.hwnd
		hwnd:=TV_Add(info.Label,info.parent,info.option)
		if info.fore!=""
		this.control[hwnd,"fore"]:=info.fore
		if info.back!=""
		this.control[hwnd,"back"]:=info.back
		this.control[hwnd]
		return hwnd
	}
	mod(info){
		Gui,TreeView,% this.hwnd
		hwnd:=TV_Modify(info.ItemID,info.option,info.NewName)
		if info.fore!=""
		this.control[hwnd,"fore"]:=info.fore
		if info.back!=""
		this.control[hwnd,"back"]:=info.back
		this.control[hwnd]
		return hwnd
	}
}
WM_NOTIFY(Param*){
	control:=
	if (this:=treeview.list[NumGet(Param.2)])&&(NumGet(Param.2,2*A_PtrSize,"int")=-12){
		stage:=NumGet(Param.2,3*A_PtrSize,"uint")
		if (stage=1)
		return 0x20 ;sets CDRF_NOTIFYITEMDRAW
		if (stage=0x10001&&info:=this.control[numget(Param.2,A_PtrSize=4?9*A_PtrSize:7*A_PtrSize,"uint")]){ ;NM_CUSTOMDRAW && Control is in the list
			if info.fore!=""
			NumPut(info.fore,Param.2,A_PtrSize=4?12*A_PtrSize:10*A_PtrSize,"int") ;sets the foreground
			if info.back!=""
			NumPut(info.back,Param.2,A_PtrSize=4?13*A_PtrSize:10.5*A_PtrSize,"int") ;sets the background
		}
	}
}