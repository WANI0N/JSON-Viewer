ThemeMenuSubmit:
Menu,ThemeMenu,ToggleCheck,% cTheme
cTheme := guitheme.set(A_ThisMenuItem)
Menu,ThemeMenu,Check,% cTheme
return

class guitheme
{
    load()
    {
    o := {}
    o["TVBack"] := "629EF1"
    o["LVBack"] := "456EA7"
    o["TVMenu"] := "7FB1F7"
    o["LVMenu"] := "4E81C8"
    o["LV_f1"] := "E0EA10"
    ThemeColor_OBJ["blue"] := o

    o := {}
    o["TVBack"] := "2E2F3D"
    o["LVBack"] := "4D4E64"
    o["TVMenu"] := "AFAFAF"
    o["LVMenu"] := "959595"
    o["LV_f1"] := "E0EA10"
    ThemeColor_OBJ["dark"] := o

    o := {}
    o["TVBack"] := "416F43"
    o["LVBack"] := "385D39"
    o["TVMenu"] := "6ACB65"
    o["LVMenu"] := "6ACB65"
    o["LV_f1"] := "E0EA10"
    ThemeColor_OBJ["green"] := o

    o := {}
    o["TVBack"] := "EFEFEF"
    o["LVBack"] := "D7D7D7"
    o["TVMenu"] := "C8C7C7"
    o["LVMenu"] := "B9B9B9"
    o["LV_f1"] := "494944"
    ThemeColor_OBJ["white"] := o

    o := {}
    o["TVBack"] := "A5904C"
    o["LVBack"] := "948246"
    o["TVMenu"] := "A78C32"
    o["LVMenu"] := "90792D"
    o["LV_f1"] := "000000"
    ThemeColor_OBJ["orange"] := o

    o := {}
    o["TVBack"] := "7A4F85"
    o["LVBack"] := "63416C"
    o["TVMenu"] := "A041B9"
    o["LVMenu"] := "A921CC"
    o["LV_f1"] := "FEFE6C"
    ThemeColor_OBJ["pink"] := o
    }
    set(type)
    {
        GuiControl,% "1:+Background" ThemeColor_OBJ[type]["TVBack"],MainTreeHandle
        GuiControl,% "1:+Background" ThemeColor_OBJ[type]["LVBack"],MainListViewHandle
        Gui,1:font,% "c" ThemeColor_OBJ[type]["LV_f1"]
        CtlColors.Change(MainCodeEditHandleHWND,ThemeColor_OBJ[type]["LVBack"],ThemeColor_OBJ[type]["LV_f1"])
        GuiControl,1:Font,MainListViewHandle
        Gui AddObjGUI: color,% ThemeColor_OBJ[type]["TVMenu"]
        return type
    }
}
