$PBExportHeader$w_main.srw
forward
global type w_main from window
end type
type dw_indent from datawindow within w_main
end type
type cb_pbformatter from commandbutton within w_main
end type
type uo_pbscript from uo_scilexer within w_main
end type
end forward

global type w_main from window
integer width = 2263
integer height = 2636
boolean titlebar = true
string title = "PB Formatter"
boolean controlmenu = true
boolean minbox = true
boolean maxbox = true
boolean resizable = true
long backcolor = 67108864
string icon = "AppIcon!"
boolean center = true
dw_indent dw_indent
cb_pbformatter cb_pbformatter
uo_pbscript uo_pbscript
end type
global w_main w_main

on w_main.create
this.dw_indent=create dw_indent
this.cb_pbformatter=create cb_pbformatter
this.uo_pbscript=create uo_pbscript
this.Control[]={this.dw_indent,&
this.cb_pbformatter,&
this.uo_pbscript}
end on

on w_main.destroy
destroy(this.dw_indent)
destroy(this.cb_pbformatter)
destroy(this.uo_pbscript)
end on

event resize;dw_indent.Move(5,5)
uo_pbscript.Move(5,dw_indent.y + dw_indent.height +  5)
uo_pbscript.Resize( newwidth - 10, newheight - 10 - uo_pbscript.y - 5)


end event

type dw_indent from datawindow within w_main
integer width = 1682
integer height = 1184
integer taborder = 20
string title = "none"
string dataobject = "d_indent"
boolean livescroll = true
borderstyle borderstyle = stylelowered!
end type

type cb_pbformatter from commandbutton within w_main
integer x = 1719
integer y = 32
integer width = 402
integer height = 112
integer taborder = 20
integer textsize = -10
integer weight = 400
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Tahoma"
string text = "PB Formatter"
end type

event clicked;String ls_pbscript, ls_indentformat, ls_value
Int li_idx, li_item
nvo_pbformatter lnvo_pb

//[U|L|F|F]  SQL + Statements + Reserved + Scripts + Other
ls_indentformat = Space(5)
For li_idx = 1 To dw_indent.RowCount()
	li_item = dw_indent.GetItemNumber(li_idx,"id")
	ls_value = dw_indent.GetItemString(li_idx,"value")
	ls_indentformat = Replace(ls_indentformat,li_item,1,ls_value)
Next

ls_pbscript = uo_pbscript.of_gettext()
If IsNull(ls_pbscript) Or Len(Trim(ls_pbscript)) = 0 Then Return
ls_pbscript = lnvo_pb.of_indent(ls_pbscript,ls_indentformat)

If ls_pbscript <> "" And Not IsNull(ls_pbscript) Then
	uo_pbscript.of_settext(ls_pbscript)
End If

end event

type uo_pbscript from uo_scilexer within w_main
integer y = 1280
integer width = 2011
integer height = 1120
integer taborder = 10
end type

event constructor;call super::constructor;uo_pbscript.of_SetFont("System")
uo_pbscript.of_setfontsize( 12)
uo_pbscript.of_SetEncoding(EncodingUTF8!)
uo_pbscript.of_set_powerbuilder( )
end event

