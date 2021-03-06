$PBExportHeader$nvo_pbformatter.sru
forward
global type nvo_pbformatter from nonvisualobject
end type
type s_indent_info from structure within nvo_pbformatter
end type
end forward

type s_indent_info from structure
	string		source
	string		source_new
	string		pre_this
	string		line
	string		line_new
	string		char
	integer		tab_next
	integer		tab_this
	integer		pos
	boolean		isampersand
	boolean		ischoosecase
	boolean		issqlline
	boolean		ismultilinenoendif
	string		words[]
	boolean		isampersandend
end type

global type nvo_pbformatter from nonvisualobject autoinstantiate
event ue_note ( )
end type

type prototypes


end prototypes

type variables
constant string  CONST_SPACE                = " "
constant string  CONST_TAB                     = "~t"
constant string  CONST_CR                       = "~r"
constant string  CONST_LF                        = "~n"
constant string  CONST_CRLF                   = "~r~n"
constant string  CONST_SINGLEQUOTE   = "'"
constant string  CONST_DOUBLEQUOTE = "~""
constant string  CONST_TILDE                  = "~~"
constant string  CONST_SEMICOLON       = ";" 
constant string  CONST_AMPERSAND      = "&"
constant string  CONST_SLASHLEFT        = "/" 
constant string  CONST_ASTERISK           = "*" 
constant string  CONST_COMMENTS1      = "//" 
constant string  CONST_COMMENTS2      = "/*" 
constant string  CONST_COMMENTS3      = "*/" 

//
string    PB_ScriptWord
string    PB_ReservedWord
string    PB_SqlWord

private:
s_Indent_Info  Indent_Info



end variables

forward prototypes
public function string of_remove_noprintable (string as_line)
public function string of_replace_tab2space (string as_line)
public function boolean of_isidentifiers (string as_char)
public function boolean of_isidentifiers_first (string as_char)
public subroutine z_pb_data ()
public function integer of_save_new_words (string as_word, ref string rsa_words[])
public function long of_search_new_word (string as_word, string asa_words[])
public function boolean of_isemptyline (string as_line)
public function string of_get_word (string as_source, ref integer ai_pos, ref boolean ab_isfunction)
public function integer of_indent_code (string as_alphatype, ref s_indent_info asu_indent)
public function integer of_indent_expression (s_indent_info asu_indent, ref string rs_return)
public function integer of_indent_quote (ref s_indent_info asu_indent)
public function integer of_indent_semicolon (ref s_indent_info asu_indent)
public function integer of_indent_reset (ref s_indent_info asu_indent)
public function string of_get_next_line (ref string as_source)
public function string of_convert_word (string as_word, ref string as_type)
public function integer of_indent_slash (ref s_indent_info asu_indent)
public function string of_trimleft (string as_text)
public function string of_trimright (string as_text)
public function string of_trim (string as_text)
public function string of_remove_comments (string as_source)
public subroutine of_get_line_prefix (ref s_indent_info asu_indent)
public function string of_remove_quote (string as_text)
public function integer of_match_sql (ref s_indent_info asu_indent, string as_line, ref integer ai_self, ref integer ai_next)
public function string of_file_indent (string as_source, string as_parsemode)
public function string of_indent (string as_source, string as_alphatype)
public function integer of_checkstatement (string as_line)
public function long of_lastpos (string as_source, string as_target, long al_start)
public function long of_lastpos (string as_source, string as_target)
end prototypes

event ue_note;//====================================================================
// Please write "TO DO LIST" 
//====================================================================

end event

public function string of_remove_noprintable (string as_line);//====================================================================
// Function: nvo_pbformater.of_remove_noprintable()
//--------------------------------------------------------------------
// Description:	Delete the spaces and TAB characters before and after each line of code Remove non-PB script characters
//--------------------------------------------------------------------
// Arguments:
// 	string	as_line	
//--------------------------------------------------------------------
// Returns:  string
//--------------------------------------------------------------------
// Author:	PB.BaoGa		Date: 2021/11/03
//--------------------------------------------------------------------
// Usage: nvo_pbformater.of_remove_noprintable ( string as_line )
//--------------------------------------------------------------------
//	Copyright (c) PB.BaoGa(TM), All rights reserved.
//--------------------------------------------------------------------
// Modify History:
//
//====================================================================

Boolean lb_IsPrintableChar
String  ls_line,lch,lch2,lch1
String  ls_CommentText
Integer li_Pos


ls_line 	 = as_line
li_Pos 	 = of_LastPos(ls_line,  "//" )
If IsNull(li_Pos) Then li_Pos = 0

If li_Pos > 0 Then

	Integer  li_pos1 = 1
	Integer  li_c1 = 0
	String	ls_line_2
	ls_line_2 = Left(ls_line, li_Pos - 1)
	Do While li_pos1 <= li_Pos
		
		Integer li_pos11
		
		li_pos11 = Pos(ls_line_2, "'", li_pos1)
		
		If IsNull(li_pos11) Or li_pos11 < 1 Then
			li_pos11 = Pos(ls_line_2, "~"", li_pos1)
		End If
		
		If li_pos11 > 0 Then
			li_c1 ++
			li_pos1 = li_pos11 + 1
		Else
			Exit
		End If
		
	Loop
	
	If ( Mod(li_c1, 2) <> 0 ) Then Goto Label_Next
	//====================================================================
	
	// Save the back string after "//" flag string
	ls_CommentText = Mid(ls_line, li_Pos)
	ls_line			 = Left(ls_line, li_Pos - 1)
End If

Label_Next:


lb_IsPrintableChar = True
Do While Len (ls_line) > 0 And lb_IsPrintableChar
	lch = Left (ls_line, 1)
	lch2 = Mid (ls_line, 2, 1)
	If ( Asc(lch) < 32 Or Asc(lch) > 126 ) And &
		(Not ( ( Asc(lch) >= 129) And ( Asc(lch2) >= 64) ) ) Then
		ls_line = Mid (ls_line, 2)
	Else
		lb_IsPrintableChar = False
	End If
Loop

lb_IsPrintableChar = True
Do While Len (ls_line) > 0 And lb_IsPrintableChar
	lch = Right (ls_line, 1)
	lch1 = Mid (ls_line, Len(ls_line) - 1, 1)
	If Asc(lch) < 32 Or Asc(lch) > 126  And &
		(Not ( ( Asc(lch1) >= 129) And ( Asc(lch) >= 64) ) ) Then
		ls_line = Left (ls_line, Len (ls_line) - 1)
	Else
		lb_IsPrintableChar = False
	End If
Loop
ls_line = Trim(ls_line)

If Len(ls_CommentText) > 0 Then
	If Len(Trim(ls_line)) > 0 Then
		Return ls_line +  " " + ls_CommentText
	Else
		Return ls_CommentText
	End If
Else
	Return ls_line
End If

end function

public function string of_replace_tab2space (string as_line);//====================================================================
// Function: nvo_pbformater.of_replace_tab2space()
//--------------------------------------------------------------------
// Description:
//--------------------------------------------------------------------
// Arguments:
// 	string	as_line	
//--------------------------------------------------------------------
// Returns:  string
//--------------------------------------------------------------------
// Author:	PB.BaoGa		Date: 2021/11/03
//--------------------------------------------------------------------
// Usage: nvo_pbformater.of_replace_tab2space ( string as_line )
//--------------------------------------------------------------------
//	Copyright (c) PB.BaoGa(TM), All rights reserved.
//--------------------------------------------------------------------
// Modify History:
//
//====================================================================

String  ls_line
Integer li_pos

ls_line = as_line
// replace TAB => SPACE
li_pos = 1
Do While li_pos > 0
	li_pos = Pos(ls_line,CONST_TAB,li_pos)
	If li_pos > 0 Then ls_line = Replace(ls_line,li_pos,1,CONST_SPACE)
Loop

Return ls_line


end function

public function boolean of_isidentifiers (string as_char);//====================================================================
// Function: nvo_pbformater.of_isidentifiers()
//--------------------------------------------------------------------
// Description:	Is the character of the identifier
//--------------------------------------------------------------------
// Arguments:
// 	string	as_char	
//--------------------------------------------------------------------
// Returns:  boolean
//--------------------------------------------------------------------
// Author:	PB.BaoGa		Date: 2021/11/03
//--------------------------------------------------------------------
// Usage: nvo_pbformater.of_isidentifiers ( string as_char )
//--------------------------------------------------------------------
//	Copyright (c) PB.BaoGa(TM), All rights reserved.
//--------------------------------------------------------------------
// Modify History:
//
//====================================================================

Integer	li_ascii

//Get ASC code of character.
li_ascii = Asc (as_char)

// '0'= 48, '9'=57, 'A'=65, 'Z'=90, 'a'=97, 'z'=122
If li_ascii < 48 Or (li_ascii > 57 And li_ascii < 65) Or &
	(li_ascii > 90 And li_ascii < 97) Or li_ascii > 122 Then
	If as_char = '_' Or as_char = "#" Or as_char = "$" Or as_char = "%" Or as_char = "-" Then
		Return True
	Else
		Return False
	End If
Else
	Return True
End If
end function

public function boolean of_isidentifiers_first (string as_char);//====================================================================
// Function: nvo_pbformater.of_isidentifiers_first()
//--------------------------------------------------------------------
// Description:
//--------------------------------------------------------------------
// Arguments:
// 	string	as_char	
//--------------------------------------------------------------------
// Returns:  boolean
//--------------------------------------------------------------------
// Author:	PB.BaoGa		Date: 2021/11/03
//--------------------------------------------------------------------
// Usage: nvo_pbformater.of_isidentifiers_first ( string as_char )
//--------------------------------------------------------------------
//	Copyright (c) PB.BaoGa(TM), All rights reserved.
//--------------------------------------------------------------------
// Modify History:
//
//====================================================================

Integer	li_ascii

//Get ASC code of character.
li_ascii = Asc (as_char)

// 'A'=65, 'Z'=90, 'a'=97, 'z'=122
If (li_ascii > 64 And li_ascii < 91 ) Or &
	(li_ascii > 96 And li_ascii < 123) Or as_char = '_'  Then
	Return True
Else
	Return False
End If

end function

public subroutine z_pb_data ();/*----------------------------------------------------------------
PowerBuilder Object Functions
------------------------------------------------------------------
CheckBox	ClassName	String
CheckBox	Drag	Integer
CheckBox	GetContextService	Integer
CheckBox	GetParent	PowerObject
CheckBox	Hide	Integer
CheckBox	Move	Integer
CheckBox	PointerX	Integer
CheckBox	PointerY	Integer
CheckBox	PostEvent	Boolean
CheckBox	Print	Integer
CheckBox	Resize	Integer
CheckBox	SetFocus	Integer
CheckBox	SetPosition	Integer
CheckBox	SetRedraw	Integer
CheckBox	Show	Integer
CheckBox	TriggerEvent	Integer
CheckBox	TypeOf	Object
CommandButton	ClassName	String
CommandButton	Drag	Integer
CommandButton	GetContextService	Integer
CommandButton	GetParent	PowerObject
CommandButton	Hide	Integer
CommandButton	Move	Integer
CommandButton	PointerX	Integer
CommandButton	PointerY	Integer
CommandButton	PostEvent	Boolean
CommandButton	Print	Integer
CommandButton	Resize	Integer
CommandButton	SetFocus	Integer
CommandButton	SetPosition	Integer
CommandButton	SetRedraw	Integer
CommandButton	Show	Integer
CommandButton	TriggerEvent	Integer
CommandButton	TypeOf	Object
DataWindow 	AcceptText	Integer
DataWindow 	CanUndo	Boolean
DataWindow 	CategoryCount	Integer
DataWindow 	CategoryName	String
DataWindow 	ClassName	String
DataWindow 	Clear	Integer
DataWindow 	ClearValues	Integer
DataWindow 	Clipboard	Integer
DataWindow 	Copy	Integer
DataWindow 	CopyRTF	String
DataWindow 	Create	Integer
DataWindow 	CrosstabDialog	Integer	
DataWindow 	Cut	Integer	
DataWindow 	DataCount	Long	
DataWindow 	DBCancel	Integer	
DataWindow 	DBErrorCode	Long	
DataWindow 	DBErrorMessage	String	/*----------------------------------------------------------------
PowerBuilder Object Functions
------------------------------------------------------------------
CheckBox	ClassName	String
CheckBox	Drag	Integer
CheckBox	GetContextService	Integer
CheckBox	GetParent	PowerObject
CheckBox	Hide	Integer
CheckBox	Move	Integer
CheckBox	PointerX	Integer
CheckBox	PointerY	Integer
CheckBox	PostEvent	Boolean
CheckBox	Print	Integer
CheckBox	Resize	Integer
CheckBox	SetFocus	Integer
CheckBox	SetPosition	Integer
CheckBox	SetRedraw	Integer
CheckBox	Show	Integer
CheckBox	TriggerEvent	Integer
CheckBox	TypeOf	Object
CommandButton	ClassName	String
CommandButton	Drag	Integer
CommandButton	GetContextService	Integer
CommandButton	GetParent	PowerObject
CommandButton	Hide	Integer
CommandButton	Move	Integer
CommandButton	PointerX	Integer
CommandButton	PointerY	Integer
CommandButton	PostEvent	Boolean
CommandButton	Print	Integer
CommandButton	Resize	Integer
CommandButton	SetFocus	Integer
CommandButton	SetPosition	Integer
CommandButton	SetRedraw	Integer
CommandButton	Show	Integer
CommandButton	TriggerEvent	Integer
CommandButton	TypeOf	Object
DataWindow 	AcceptText	Integer
DataWindow 	CanUndo	Boolean
DataWindow 	CategoryCount	Integer
DataWindow 	CategoryName	String
DataWindow 	ClassName	String
DataWindow 	Clear	Integer
DataWindow 	ClearValues	Integer
DataWindow 	Clipboard	Integer
DataWindow 	Copy	Integer
DataWindow 	CopyRTF	String
DataWindow 	Create	Integer
DataWindow 	CrosstabDialog	Integer	
DataWindow 	Cut	Integer	
DataWindow 	DataCount	Long	
DataWindow 	DBCancel	Integer	
DataWindow 	DBErrorCode	Long	
DataWindow 	DBErrorMessage	String	
DataWindow 	DeletedCount	Long	
DataWindow 	DeleteRow	Integer	
DataWindow 	Describe	String	
DataWindow 	Drag	Integer	
DataWindow 	Filter	Integer	
DataWindow 	FilteredCount	Integer	
DataWindow 	Find	Long	
DataWindow 	FindCategory	Integer	
DataWindow 	FindGroupChange	Long	
DataWindow 	FindNext	Integer	
DataWindow 	FindRequired	Integer
DataWindow 	FindSeries	Integer
DataWindow 	GenerateHTMLForm	Integer
DataWindow 	GetBandAtPointer	String
DataWindow 	GetBorderStyle	Border (enumerated)
DataWindow 	GetChanges	Long
DataWindow 	GetChild	Integer
DataWindow 	GetClickedColumn	Integer
DataWindow 	GetClickedRow	Long
DataWindow 	GetColumn	Integer
DataWindow 	GetColumnName	String
DataWindow 	GetContextService	Integer
DataWindow 	GetData	Double
DataWindow 	GetDataPieExplode	Integer
DataWindow 	GetDataStyle	Integer
DataWindow 	GetDataValue	Integer
DataWindow 	GetFormat	String
DataWindow 	GetFullState	Long
DataWindow 	GetItemDate	Date
DataWindow 	GetItemDateTime	DateTime
DataWindow 	GetItemDecimal	Decimal
DataWindow 	GetItemNumber	Double
DataWindow 	GetItemStatus	dwItemStatus (enumerated)
DataWindow 	GetItemString	String
DataWindow 	GetItemTime	Time
DataWindow 	GetMessageText	String
DataWindow 	GetNextModified	Long
DataWindow 	GetObjectAtPointer	String
DataWindow 	GetParent	PowerObject
DataWindow 	GetRow	Long
DataWindow 	GetSelectedRow	Integer
DataWindow 	GetSeriesStyle	Integer
DataWindow 	GetSQLPreview	String	
DataWindow 	GetSQLSelect	String	
DataWindow 	GetStateStatus	Long	
DataWindow 	GetText	String	
DataWindow 	GetTrans	Integer	
DataWindow 	GetUpdateStatus	Integer	
DataWindow 	GetValidate	String	
DataWindow 	GetValue	String	
DataWindow 	GroupCalc	Integer	
DataWindow 	Hide	Integer	
DataWindow 	ImportClipboard 	Long	
DataWindow 	ImportFile 	Long	
DataWindow 	ImportString	Long	
DataWindow 	InsertDocument	Integer	
DataWindow 	InsertRow	Long	
DataWindow 	IsSelected	Boolean	
DataWindow 	LineCount	Integer	
DataWindow 	ModifiedCount	Long	
DataWindow 	Modify	String	
DataWindow 	Move	Integer	
DataWindow 	ObjectAtPointer	grObjectType	
DataWindow 	OLEActivate	Integer	
DataWindow 	Paste	Integer	
DataWindow 	PasteRTF	Long	
DataWindow 	PointerX	Integer	
DataWindow 	PointerY	Integer	
DataWindow 	Position	Integer	
DataWindow 	PostEvent	Boolean	
DataWindow 	Print	Integer	
DataWindow 	PrintCancel	Integer	
DataWindow 	ReplaceText	Integer	
DataWindow 	ReselectRow	Integer	
DataWindow 	Reset	Integer	
DataWindow 	ResetDataColors	Integer	
DataWindow 	ResetTransObject	Integer	
DataWindow 	ResetUpdate	Integer	
DataWindow 	Resize	Integer	
DataWindow 	Retrieve	Long	
DataWindow 	RowCount	Long	
DataWindow 	RowsCopy	Integer	
DataWindow 	RowsDiscard	Integer	
DataWindow 	RowsMove	Integer	
DataWindow 	SaveAs	Integer	
DataWindow 	SaveAsAscii	Long	
DataWindow 	Scroll	Integer	
DataWindow 	ScrollNextPage	Long	
DataWindow 	ScrollNextRow	Long	
DataWindow 	ScrollPriorPage	Long	
DataWindow 	ScrollPriorRow	Long	
DataWindow 	ScrollToRow	Integer	
DataWindow 	SelectedLength	Integer	
DataWindow 	SelectedLine	Integer	
DataWindow 	SelectedStart	Integer	
DataWindow 	SelectedText	String	
DataWindow 	SelectRow	Integer	
DataWindow 	SelectText	Integer	
DataWindow 	SelectTextAll	Integer	
DataWindow 	SelectTextLine	Integer	
DataWindow 	SelectTextWord	Integer	
DataWindow 	SeriesCount	Integer	
DataWindow 	SeriesName	String	
DataWindow 	SetActionCode	Integer	
DataWindow 	SetBorderStyle	Integer	
DataWindow 	SetChanges	Long	
DataWindow 	SetColumn	Integer	
DataWindow 	SetDataPieExplode	Integer	
DataWindow 	SetDataStyle	Integer	
DataWindow 	SetDetailHeight	Integer	
DataWindow 	SetFilter	Integer	
DataWindow 	SetFocus	Integer	
DataWindow 	SetFormat	Integer	
DataWindow 	SetFullState	Long	
DataWindow 	SetItem	Integer	
DataWindow 	SetItemStatus	Integer	
DataWindow 	SetPosition	Integer	
DataWindow 	SetRedraw	Integer	
DataWindow 	SetRow	Integer	
DataWindow 	SetRowFocusIndicator	Integer	
DataWindow 	SetSeriesStyle	Integer	
DataWindow 	SetSort	Integer	
DataWindow 	SetSQLPreview	Integer
DataWindow 	SetSQLSelect	Integer
DataWindow 	SetTabOrder	Integer
DataWindow 	SetText	Integer
DataWindow 	SetTrans	Integer
DataWindow 	SetTransObject	Integer
DataWindow 	SetValidate	Integer
DataWindow 	SetValue	Integer
DataWindow 	ShareData	Integer
DataWindow 	ShareDataOff	Integer
DataWindow 	Show	Integer
DataWindow 	ShowHeadFoot	Integer
DataWindow 	Sort	Integer
DataWindow 	TextLine	String
DataWindow 	TriggerEvent	Integer
DataWindow 	TypeOf	Object
DataWindow 	Undo	Integer
DataWindow 	Update	Integer
DropDownListBox	AddItem	Integer
DropDownListBox	ClassName	String
DropDownListBox	Clear	Integer
DropDownListBox	Copy	Integer
DropDownListBox	Cut	Integer
DropDownListBox	DeleteItem	Integer
DropDownListBox	DirList	Boolean
DropDownListBox	DirSelect	Boolean
DropDownListBox	Drag	Integer
DropDownListBox	FindItem	Integer
DropDownListBox	GetContextService	Integer
DropDownListBox	GetParent	PowerObject
DropDownListBox	Hide	Integer
DropDownListBox	InsertItem	Integer
DropDownListBox	Move	Integer
DropDownListBox	Paste	Integer
DropDownListBox	PointerX	Integer
DropDownListBox	PointerY	Integer
DropDownListBox	Position	Integer
DropDownListBox	PostEvent	Boolean
DropDownListBox	Print	Integer
DropDownListBox	ReplaceText	Integer
DropDownListBox	Reset	Integer
DropDownListBox	Resize	Integer
DropDownListBox	SelectedLength	Integer
DropDownListBox	SelectedStart	Integer
DropDownListBox	SelectedText	String
DropDownListBox	SelectItem	Integer
DropDownListBox	SelectText	Integer
DropDownListBox	SetFocus	Integer
DropDownListBox	SetPosition	Integer
DropDownListBox	SetRedraw	Integer
DropDownListBox	Show	Integer
DropDownListBox	Text	String
DropDownListBox	TotalItems	Integer
DropDownListBox	TriggerEvent	Integer
DropDownListBox	TypeOf	Control
DropDownPicture	AddItem	Integer
DropDownPicture	AddPicture	Integer
DropDownPicture	ClassName	String
DropDownPicture	Clear	Integer
DropDownPicture	Copy	Integer
DropDownPicture	Cut	Integer
DropDownPicture	DeleteItem	Integer
DropDownPicture	DeletePicture	Integer
DropDownPicture	DeletePictures	Integer
DropDownPicture	DirList	Boolean
DropDownPicture	DirSelect	Boolean
DropDownPicture	Drag	Integer
DropDownPicture	FindItem	Integer
DropDownPicture	GetContextService	Integer
DropDownPicture	GetParent	PowerObject
DropDownPicture	Hide	Integer
DropDownPicture	InsertItem	Integer
DropDownPicture	Move	Integer
DropDownPicture	Paste	Integer
DropDownPicture	PointerX	Integer
DropDownPicture	PointerY	Integer
DropDownPicture	Position	Integer
DropDownPicture	PostEvent	Boolean
DropDownPicture	Print	Integer
DropDownPicture	ReplaceText	Integer
DropDownPicture	Reset	Integer
DropDownPicture	Resize	Integer
DropDownPicture	SelectedLength	Integer
DropDownPicture	SelectedStart	Integer
DropDownPicture	SelectedText	String
DropDownPicture	SelectItem	Integer
DropDownPicture	SelectText	Integer
DropDownPicture	SetFocus	Integer
DropDownPicture	SetPosition	Integer
DropDownPicture	SetRedraw	Integer
DropDownPicture	Show	Integer
DropDownPicture	Text	String
DropDownPicture	TotalItems	Integer
DropDownPicture	TriggerEvent	Integer
DropDownPicture	TypeOf	Control
EditMask	ClassName	String
EditMask	Clear	Integer
EditMask	Copy	Integer
EditMask	Cut	Integer
EditMask	Drag	Integer
EditMask	GetContextService	Integer
EditMask	GetData	Integer
EditMask	GetParent	PowerObject
EditMask	Hide	Integer
EditMask	LineCount	Integer
EditMask	LineLength	Integer
EditMask	Move	Integer
EditMask	Paste	Integer
EditMask	PointerX	Integer
EditMask	PointerY	Integer
EditMask	Position	Integer
EditMask	PostEvent	Boolean
EditMask	Print	Integer
EditMask	ReplaceText	Integer
EditMask	Resize	Integer
EditMask	Scroll	Integer
EditMask	SelectedLength	Integer
EditMask	SelectedLine	Integer
EditMask	SelectedStart	Integer
EditMask	SelectedText	String
EditMask	SelectText	Integer
EditMask	SetFocus	Integer
EditMask	SetMask	Integer
EditMask	SetPosition	Integer
EditMask	SetRedraw	Integer
EditMask	Show	Integer
EditMask	TextLine	String
EditMask	TriggerEvent	Integer
EditMask	TypeOf	Object
Graph	AddCategory	Integer
Graph	AddData	Long
Graph	AddSeries	Integer
Graph	CategoryCount	Integer
Graph	CategoryName	String
Graph	ClassName	String
Graph	Clipboard	Integer
Graph	DataCount	Long
Graph	DeleteCategory	Integer
Graph	DeleteData	Integer
Graph	DeleteSeries	Integer
Graph	Drag	Integer	
Graph	FindCategory	Integer	
Graph	FindSeries	Integer	
Graph	GetContextService	Integer	
Graph	GetData	Double	
Graph	GetDataPieExplode	Integer	
Graph	GetDataStyle	Integer	
Graph	GetDataValue	Integer	
Graph	GetSeriesStyle	Integer	
Graph	GetParent	PowerObject	
Graph	Hide	Integer	
Graph	ImportClipboard	Long	
Graph	ImportFile	Long	
Graph	ImportString	Long	
Graph	InsertCategory	Integer	
Graph	InsertData	Long	
Graph	InsertSeries	Integer
Graph	ModifyData	Integer
Graph	Move	Integer
Graph	ObjectAtPointer	GrObjectType
Graph	PointerX	Integer
Graph	PointerY	Integer
Graph	PostEvent	Boolean
Graph	Print	Integer
Graph	Reset	Integer
Graph	ResetDataColors	Integer
Graph	Resize	Integer
Graph	SaveAs	Integer
Graph	SeriesCount	Integer
Graph	SeriesName	String
Graph	SetDataPieExplode	Integer
Graph	SetDataStyle	Integer
Graph	SetFocus	Integer
Graph	SetPosition	Integer
Graph	SetRedraw	Integer
Graph	SetSeriesStyle	Integer
Graph	Show	Integer
Graph	TriggerEvent	Integer
Graph	TypeOf	Object
GroupBox 	ClassName	String
GroupBox 	Drag	Integer
GroupBox 	GetContextService	Integer
GroupBox 	GetParent	PowerObject
GroupBox 	Hide	Integer
GroupBox 	Move	Integer
GroupBox 	PointerX	Integer
GroupBox 	PointerY	Integer
GroupBox 	Print	Integer
GroupBox 	Resize	Integer
GroupBox 	SetFocus	Integer
GroupBox 	SetPosition	Integer
GroupBox 	SetRedraw	Integer
GroupBox 	Show	Integer
GroupBox 	TypeOf	Object
HScrollBar	ClassName	String
HScrollBar	Drag	Integer
HScrollBar	GetContextService	Integer
HScrollBar	GetParent	PowerObject
HScrollBar	Hide	Integer
HScrollBar	Move	Integer
HScrollBar	PointerX	Integer
HScrollBar	PointerY	Integer
HScrollBar	PostEvent	Boolean
HScrollBar	Print	Integer
HScrollBar	Resize	Integer
HScrollBar	SetFocus	Integer
HScrollBar	SetPosition	Integer
HScrollBar	SetRedraw	Integer
HScrollBar	Show	Integer
HScrollBar	TriggerEvent	Integer
HScrollBar	TypeOf	Object
Line	ClassName	String
Line	GetContextService	Integer
Line	GetParent	PowerObject
Line	Hide	Integer
Line	Move	Integer
Line	Resize	Integer
Line	Show	Integer
Line	TypeOf	Object
ListBox 	AddItem	Integer
ListBox 	ClassName	String
ListBox 	DeleteItem	Integer
ListBox 	DirList	Boolean
ListBox 	DirSelect	Boolean
ListBox 	Drag	Integer
ListBox 	FindItem	Integer
ListBox 	GetContextService	Integer
ListBox 	GetParent	PowerObject
ListBox 	Hide	Integer
ListBox 	InsertItem	Integer
ListBox 	Move	Integer
ListBox 	PointerX	Integer
ListBox 	PointerY	Integer	
ListBox 	PostEvent	Boolean	
ListBox 	Print	Integer	
ListBox 	Reset	Integer	
ListBox 	Resize	Integer	
ListBox 	SelectedIndex	Integer	
ListBox 	SelectedItem	String	
ListBox 	SelectItem	Integer	
ListBox 	SetFocus	Integer	
ListBox 	SetPosition	Integer	
ListBox 	SetRedraw	Integer	
ListBox 	SetState	Integer	
ListBox 	SetTop	Integer	
ListBox 	Show	Integer	
ListBox 	State	Integer	
ListBox 	Text	String	
ListBox 	Top	Integer
ListBox 	TotalItems	Integer
ListBox 	TotalSelected	Integer
ListBox 	TriggerEvent	Integer
ListBox 	TypeOf	Object
ListView	AddColumn	Integer
ListView	AddItem	Integer
ListView	AddLargePicture	Integer 
ListView	AddSmallPicture	Integer 
ListView	AddstatePicture	Integer 
ListView	Arrange	Integer 
ListView	ClassName	String
ListView	DeleteColumn	Integer 
ListView	DeleteColumns	Integer 
ListView	DeleteItem	Integer 
ListView	DeleteItems	Integer 
ListView	DeleteLargePicture	Integer 
ListView	DeleteLargePictures	Integer 
ListView	DeleteSmallPicture	Integer 
ListView	DeleteSmallPictures	Integer 
ListView	DeleteStatePicture	Integer 
ListView	DeleteStatePictures	Integer 
ListView	Drag	Integer 
ListView	EditLabel	Integer 
ListView	FindItem	Integer 
ListView	GetColumn	Integer 
ListView	GetContextService	Integer
ListView	GetItem	Integer 
ListView	GetOrigin	Integer 
ListView	GetParent	PowerObject 
ListView	Hide	Integer 
ListView	InsertColumn	Integer 
ListView	InsertItem	Integer 
ListView	Move	Integer 
ListView	PointerX	Integer 
ListView	PointerY	Integer 
ListView	PostEvent	Boolean
ListView	Print	Integer 
ListView	Resize	Integer 
ListView	SelectedIndex	Integer 
ListView	SetColumn	Integer 
ListView	SetFocus	Integer 
ListView	SetItem	Integer 
ListView	SetOverlayPicture	Integer 
ListView	SetPosition	Integer 
ListView	SetRedraw	Integer 
ListView	Show	Integer 
ListView	Sort	Integer 
ListView	TotalColumns	Integer 
ListView	TotalItems	Integer 
ListView	TotalSelected	Integer 
ListView	TriggerEvent	Integer
ListView	TypeOf	Object
MultiLineEdit 	CanUndo	Boolean
MultiLineEdit 	ClassName	String
MultiLineEdit 	Clear	Integer
MultiLineEdit 	Copy	Integer
MultiLineEdit 	Cut	Integer
MultiLineEdit 	Drag	Integer
MultiLineEdit 	GetContextService	Integer
MultiLineEdit 	GetParent	PowerObject
MultiLineEdit 	Hide	Integer
MultiLineEdit 	LineCount	Integer
MultiLineEdit 	LineLength	Integer
MultiLineEdit 	Move	Integer
MultiLineEdit 	Paste	Integer
MultiLineEdit 	PointerX	Integer
MultiLineEdit 	PointerY	Integer
MultiLineEdit 	Position	Integer
MultiLineEdit 	PostEvent	Boolean
MultiLineEdit 	Print	Integer
MultiLineEdit 	ReplaceText	Integer
MultiLineEdit 	Resize	Integer
MultiLineEdit 	Scroll	Integer
MultiLineEdit 	SelectedLength	Integer
MultiLineEdit 	SelectedLine	Integer
MultiLineEdit 	SelectedStart	Integer
MultiLineEdit 	SelectedText	String
MultiLineEdit 	SelectText	Integer
MultiLineEdit 	SetFocus	Integer
MultiLineEdit 	SetPosition	Integer
MultiLineEdit 	SetRedraw	Integer
MultiLineEdit 	Show	Integer
MultiLineEdit 	TextLine	String
MultiLineEdit 	TriggerEvent	Integer
MultiLineEdit 	TypeOf	Object
MultiLineEdit 	Undo	Integer
OLEControl 	Activate	Integer
OLEControl 	ClassName	String
OLEControl 	Clear	Integer
OLEControl 	Copy	Integer
OLEControl 	Cut	Integer
OLEControl 	DoVerb	Integer
OLEControl 	Drag	Integer
OLEControl 	GetContextService	Integer
OLEControl 	GetData	Integer
OLEControl 	GetNativePointer	Integer
OLEControl 	GetParent	PowerObject
OLEControl 	Hide	Integer
OLEControl 	InsertClass	Integer
OLEControl 	InsertFile	Integer
OLEControl 	InsertObject	Integer
OLEControl 	LinkTo	Integer
OLEControl 	Move	Integer
OLEControl 	Open	Integer
OLEControl 	Paste	Integer
OLEControl 	PasteLink	Integer
OLEControl 	PasteSpecial	Integer
OLEControl 	PointerX	Integer
OLEControl 	PointerY	Integer
OLEControl 	PostEvent	Boolean
OLEControl 	Print	Integer
OLEControl 	ReleaseNativePointer	Integer
OLEControl 	Resize	Integer
OLEControl 	Save	Integer
OLEControl 	SaveAs	Integer
OLEControl 	SelectObject	Integer
OLEControl 	SetData	Integer
OLEControl 	SetFocus	Integer
OLEControl 	SetPosition	Integer
OLEControl 	SetRedraw	Integer
OLEControl 	Show	Integer
OLEControl 	TriggerEvent	Integer
OLEControl 	TypeOf	Object
OLEControl 	UpdateLinksDialog	Integer
OLECustomControl 	ClassName	String
OLECustomControl 	Drag	Integer
OLECustomControl 	GetContextService	Integer
OLECustomControl 	GetData	Integer
OLECustomControl 	GetNativePointer	Integer
OLECustomControl 	GetParent	PowerObject 
OLECustomControl 	Hide	Integer
OLECustomControl 	Move	Integer
OLECustomControl 	PointerX	Integer
OLECustomControl 	PointerY	Integer
OLECustomControl 	PostEvent	Boolean
OLECustomControl 	Print	Integer
OLECustomControl 	ReleaseNativePointer	Integer
OLECustomControl 	Resize	Integer
OLECustomControl 	SetAutomationLocale	Integer
OLECustomControl 	SetData	Integer
OLECustomControl 	SetFocus	Integer
OLECustomControl 	SetPosition	Integer
OLECustomControl 	SetRedraw	Integer
OLECustomControl 	Show	Integer
OLECustomControl 	TriggerEvent	Integer
OLECustomControl 	TypeOf	Object
Oval 	ClassName	String
Oval 	GetContextService	Integer
Oval 	GetParent	PowerObject
Oval 	Hide	Integer
Oval 	Move	Integer
Oval 	Resize	Integer
Oval 	Show	Integer
Oval 	TypeOf	Object
Picture 	ClassName	String
Picture 	Drag	Integer
Picture 	Draw	Integer
Picture 	GetContextService	Integer
Picture 	GetParent	PowerObject
Picture 	Hide	Integer
Picture 	Move	Integer
Picture 	PointerX	Integer
Picture 	PointerY	Integer
Picture 	PostEvent	Boolean
Picture 	Print	Integer
Picture 	Resize	Integer
Picture 	SetFocus	Integer
Picture 	SetPicture	Integer
Picture 	SetPosition	Integer
Picture 	SetRedraw	Integer
Picture 	Show	Integer
Picture 	TriggerEvent	Integer
Picture 	TypeOf	Object
PictureButton 	ClassName	String
PictureButton 	Drag	Integer
PictureButton 	GetContextService	Integer
PictureButton 	GetParent	PowerObject
PictureButton 	Hide	Integer
PictureButton 	Move	Integer
PictureButton 	PointerX	Integer
PictureButton 	PointerY	Integer
PictureButton 	PostEvent	Boolean
PictureButton 	Print	Integer
PictureButton 	Resize	Integer
PictureButton 	SetFocus	Integer
PictureButton 	SetPosition	Integer
PictureButton 	SetRedraw	Integer
PictureButton 	Show	Integer
PictureButton 	TriggerEvent	Integer
PictureButton 	TypeOf	Object
PictureListBox	AddItem	Integer
PictureListBox	AddPicture	Integer
PictureListBox	ClassName	String
PictureListBox	DeleteItem	Integer
PictureListBox	DeletePicture	Integer
PictureListBox	DeletePictures	Integer
PictureListBox	DirList	Boolean
PictureListBox	DirSelect	Boolean
PictureListBox	Drag	Integer
PictureListBox	FindItem	Integer	
PictureListBox	GetContextService	Integer	
PictureListBox	GetParent	PowerObject	
PictureListBox	Hide	Integer	
PictureListBox	InsertItem	Integer	
PictureListBox	Move	Integer	
PictureListBox	PointerX	Integer	
PictureListBox	PointerY	Integer	
PictureListBox	PostEvent	Boolean	
PictureListBox	Print	Integer	
PictureListBox	Reset	Integer	
PictureListBox	Resize	Integer	
PictureListBox	SelectedIndex	Integer	
PictureListBox	SelectedItem	String	
PictureListBox	SelectItem	Integer	
PictureListBox	SetFocus	Integer	
PictureListBox	SetPosition	Integer
PictureListBox	SetRedraw	Integer
PictureListBox	SetState	Integer
PictureListBox	SetTop	Integer
PictureListBox	Show	Integer
PictureListBox	State	Integer
PictureListBox	Text	String
PictureListBox	Top	Integer
PictureListBox	TotalItems	Integer
PictureListBox	TotalSelected	Integer
PictureListBox	TriggerEvent	Integer
PictureListBox	TypeOf	Object
RadioButton	ClassName	String
RadioButton	Drag	Integer
RadioButton	GetContextService	Integer
RadioButton	GetParent	PowerObject
RadioButton	Hide	Integer
RadioButton	Move	Integer
RadioButton	PointerX	Integer
RadioButton	PointerY	Integer
RadioButton	PostEvent	Boolean
RadioButton	Print	Integer
RadioButton	Resize	Integer
RadioButton	SetFocus	Integer
RadioButton	SetPosition	Integer
RadioButton	SetRedraw	Integer
RadioButton	Show	Integer
RadioButton	TriggerEvent	Integer
RadioButton	TypeOf	Object
Rectangle 	ClassName	String
Rectangle 	GetContextService	Integer
Rectangle 	GetParent	PowerObject
Rectangle 	Hide	Integer
Rectangle 	Move	Integer
Rectangle 	Resize	Integer
Rectangle 	Show	Integer
Rectangle 	TypeOf	Object
RichTextEdit 	CanUndo	Boolean
RichTextEdit 	ClassName	String
RichTextEdit 	Clear	Long
RichTextEdit 	Copy	Long
RichTextEdit 	CopyRTF	String
RichTextEdit 	Cut	Long
RichTextEdit 	DataSource	Integer
RichTextEdit 	Drag	Integer
RichTextEdit 	Find	Integer
RichTextEdit 	FindNext	Integer
RichTextEdit 	GetAlignment	Alignment
RichTextEdit 	GetContextService	Integer
RichTextEdit 	GetParagraphSetting	Long
RichTextEdit 	GetParent	PowerObject
RichTextEdit 	GetSpacing	Spacing
RichTextEdit 	GetTextColor	Long
RichTextEdit 	GetTextStyle	Boolean
RichTextEdit 	Hide	Integer
RichTextEdit 	InputFieldChangeData	Integer
RichTextEdit 	InputFieldCurrentName	String
RichTextEdit 	InputFieldDeleteCurrent	Integer
RichTextEdit 	InputFieldGetData	String
RichTextEdit 	InputFieldInsert	Integer
RichTextEdit 	InputFieldLocate	String
RichTextEdit 	InsertDocument	Integer
RichTextEdit 	InsertPicture	Integer
RichTextEdit 	IsPreview	Boolean
RichTextEdit 	LineCount	Integer
RichTextEdit 	LineLength	Integer
RichTextEdit 	Move	Integer
RichTextEdit 	PageCount	Integer
RichTextEdit 	Paste	Integer
RichTextEdit 	PasteRTF	Long
RichTextEdit 	PointerX	Integer
RichTextEdit 	PointerY	Integer
RichTextEdit 	Position	Integer
RichTextEdit 	PostEvent	Integer
RichTextEdit 	Preview	Integer
RichTextEdit 	Print	Integer
RichTextEdit 	ReplaceText	Integer
RichTextEdit 	Resize	Integer
RichTextEdit 	SaveDocument	Integer
RichTextEdit 	Scroll	Integer
RichTextEdit 	ScrollNextPage	Integer
RichTextEdit 	ScrollNextRow	Long
RichTextEdit 	ScrollPriorPage	Long
RichTextEdit 	ScrollPriorRow	Long
RichTextEdit 	ScrollToRow	Long
RichTextEdit 	SelectedColumn	Integer
RichTextEdit 	SelectedLength	Long
RichTextEdit 	SelectedLine	Long
RichTextEdit 	SelectedPage	Long
RichTextEdit 	SelectedStart	Integer
RichTextEdit 	SelectedText	String
RichTextEdit 	SelectText	Long
RichTextEdit 	SelectTextAll	Integer
RichTextEdit 	SelectTextLine	Integer
RichTextEdit 	SelectTextWord	Integer
RichTextEdit 	SetAlignment	Integer`
RichTextEdit 	SetFocus	Integer
RichTextEdit 	SetParagraphSetting	Integer
RichTextEdit 	SetPosition	Integer
RichTextEdit 	SetRedraw	Integer
RichTextEdit 	SetSpacing	Integer
RichTextEdit 	SetTextColor	Integer
RichTextEdit 	SetTextStyle	Integer
RichTextEdit 	Show	Integer
RichTextEdit 	ShowHeadFoot	Integer
RichTextEdit 	TextLine	String
RichTextEdit 	TriggerEvent	Integer
RichTextEdit 	TypeOf	Object
RichTextEdit 	Undo	Integer
RoundRectangle 	ClassName	String
RoundRectangle 	GetContextService	Integer
RoundRectangle 	GetParent	PowerObject
RoundRectangle 	Hide	Integer
RoundRectangle 	Move	Integer
RoundRectangle 	Resize	Integer
RoundRectangle 	Show	Integer
RoundRectangle 	TypeOf	Object
SingleLineEdit	CanUndo	Boolean
SingleLineEdit	ClassName	String
SingleLineEdit	Clear	Integer
SingleLineEdit	Copy	Integer
SingleLineEdit	Cut	Integer
SingleLineEdit	Drag	Integer
SingleLineEdit	GetContextService	Integer
SingleLineEdit	GetParent	PowerObject
SingleLineEdit	Hide	Integer
SingleLineEdit	Move	Integer
SingleLineEdit	Paste	Integer
SingleLineEdit	PointerX	Integer
SingleLineEdit	PointerY	Integer
SingleLineEdit	Position	Integer
SingleLineEdit	PostEvent	Boolean
SingleLineEdit	Print	Integer
SingleLineEdit	ReplaceText	Integer
SingleLineEdit	Resize	Integer
SingleLineEdit	SelectedLength	Integer
SingleLineEdit	SelectedStart	Integer
SingleLineEdit	SelectedText	String
SingleLineEdit	SelectText	Integer
SingleLineEdit	SetFocus	Integer
SingleLineEdit	SetPosition	Integer
SingleLineEdit	SetRedraw	Integer
SingleLineEdit	Show	Integer
SingleLineEdit	TriggerEvent	Integer
SingleLineEdit	TypeOf	Object
SingleLineEdit	Undo	Integer
StaticText 	ClassName	String
StaticText 	Drag	Integer
StaticText 	GetContextService	Integer
StaticText 	GetParent	PowerObject
StaticText 	Hide	Integer
StaticText 	Move	Integer
StaticText 	PointerX	Integer
StaticText 	PointerY	Integer
StaticText 	PostEvent	Boolean
StaticText 	Print	Integer
StaticText 	Resize	Integer
StaticText 	SetFocus	Integer
StaticText 	SetPosition	Integer
StaticText 	SetRedraw	Integer
StaticText 	Show	Integer
StaticText 	TriggerEvent	Integer
StaticText 	TypeOf	Object
Tab	ClassName	String
Tab	CloseTab	Integer
Tab	Drag	Integer
Tab	GetContextService	Integer
Tab	GetParent	PowerObject
Tab	Hide	Integer
Tab	Move	Integer
Tab	MoveTab	Integer
Tab	OpenTab	Integer
Tab	OpenTabWithParm	Integer
Tab	PointerX	Integer
Tab	PointerY	Integer
Tab	PostEvent	Integer
Tab	Print	Integer
Tab	Resize	Integer
Tab	SelectTab	Integer
Tab	SetFocus	Integer
Tab	SetPosition	Integer
Tab	SetRedraw	Integer
Tab	Show	Integer
Tab	TabPostEvent	Integer
Tab	TabTriggerEvent	Integer
Tab	TriggerEvent	Integer
Tab	TypeOf	Object
TreeView	AddPicture	Integer
TreeView	AddStatePicture	Integer
TreeView	ClassName	String
TreeView	CollapseItem	Integer
TreeView	DeleteItem	Integer
TreeView	DeletePicture 	Integer
TreeView	DeletePictures	Integer
TreeView	DeleteStatePicture	Integer
TreeView	DeleteStatePictures	Integer
TreeView	Drag	Integer 
TreeView	EditLabel	Integer 
TreeView	ExpandAll	Integer
TreeView	ExpandItem	Integer
TreeView	FindItem	Long
TreeView	GetContextService	Integer
TreeView	GetItem	Integer
TreeView	GetParent	PowerObject
TreeView	Hide	Integer
TreeView	InsertItem	Long
TreeView	InsertItemFirst	Long
TreeView	InsertItemLast	Long
TreeView	InsertItemSort	Long
TreeView	Move	Integer 
TreeView	PointerX	Integer 
TreeView	PointerY	Integer 
TreeView	PostEvent	Boolean
TreeView	Print	Integer 
TreeView	Resize	Integer 
TreeView	SelectItem	Integer
TreeView	SetDropHighlight	Integer
TreeView	SetFirstVisible	Integer
TreeView	SetFocus	Integer 
TreeView	SetItem	Integer
TreeView	SetLevelPictures	Integer
TreeView	SetOverlayPicture	Integer
TreeView	SetPosition	Integer
TreeView	SetRedraw	Integer
TreeView	Show	Integer
TreeView	Sort	Integer
TreeView	SortAll	Integer
TreeView	TriggerEvent	Integer
TreeView	TypeOf	Object
UserObject 	AddItem	Integer
UserObject 	ClassName	String
UserObject 	DeleteItem	Integer
UserObject 	Drag	Integer
UserObject 	EventParmDouble	Integer
UserObject 	EventParmString	Integer
UserObject 	GetContextService	Integer
UserObject 	GetParent	PowerObject
UserObject 	Hide	Integer
UserObject 	InsertItem	Integer
UserObject 	Move	Integer
UserObject 	PointerX	Integer
UserObject 	PointerY	Integer
UserObject 	PostEvent	Boolean
UserObject 	Print	Integer
UserObject 	Resize	Integer
UserObject 	SetFocus	Integer
UserObject 	SetPosition	Integer
UserObject 	SetRedraw	Integer
UserObject 	Show	Integer
UserObject 	TriggerEvent	Integer
UserObject 	TypeOf	Object
VScrollBar 	ClassName	String
VScrollBar 	Drag	Integer
VScrollBar 	GetContextService	Integer
VScrollBar 	GetParent	PowerObject
VScrollBar 	Hide	Integer
VScrollBar 	Move	Integer
VScrollBar 	PointerX	Integer
VScrollBar 	PointerY	Integer
VScrollBar 	PostEvent	Boolean
VScrollBar 	Print	Integer
VScrollBar 	Resize	Integer
VScrollBar 	SetFocus	Integer
VScrollBar 	SetPosition	Integer
VScrollBar 	SetRedraw	Integer
VScrollBar 	Show	Integer
VScrollBar 	TriggerEvent	Integer
VScrollBar 	TypeOf	Object
Application	ClassName	String
Application	GetContextService	Integer
Application	GetParent	PowerObject
Application	PostEvent	Boolean
Application	SetLibraryList	Integer
Application	SetTransPool	Integer
Application	TriggerEvent	Integer
Application	TypeOf	Object
ArrayBounds 	ClassName	String
ArrayBounds 	GetContextService	Integer
ArrayBounds 	GetParent	PowerObject
ArrayBounds 	TypeOf	Object
ClassDefinition	ClassName	String
ClassDefinition	FindMatchingFunction	ScriptDefinition
ClassDefinition	GetContextService	Integer
ClassDefinition	GetParent	PowerObject
ClassDefinition	TypeOf	Object
Connection	ClassName	String
Connection	ConnectToServer	Long
Connection	CreateInstance	Long
Connection	DisconnectServer	Long
Connection	GetContextService	Integer
Connection	GetParent	PowerObject
Connection	GetServerInfo	Long
Connection	PostEvent	Boolean
Connection	RemoteStopConnection	Long
Connection	RemoteStopListening	Long
Connection	TriggerEvent	Integer
Connection	TypeOf	Object
ConnectionInfo 	ClassName	String
ConnectionInfo 	GetContextService	Integer
ConnectionInfo 	GetParent	PowerObject
ConnectionInfo 	TypeOf	Object
ContextInformation	ClassName	String
ContextInformation	GetCompanyName	Integer
ContextInformation	GetContextService	Integer
ContextInformation	GetFixesVersion	Integer
ContextInformation	GetHostObject	Integer
ContextInformation	GetMajorVersion	Integer
ContextInformation	GetMinorVersion	Integer
ContextInformation	GetName	Integer
ContextInformation	GetParent	PowerObject
ContextInformation	GetShortName	Integer
ContextInformation	GetVersionName	Integer
ContextInformation	PostEvent	Boolean
ContextInformation	TriggerEvent	Integer
ContextInformation	TypeOf	Object
ContextKeyword	ClassName	String
ContextKeyword	GetContextKeywords	Integer
ContextKeyword	GetContextService	Integer
ContextKeyword	GetName	Integer
ContextKeyword	GetParent	PowerObject
ContextKeyword	PostEvent	Boolean
ContextKeyword	TriggerEvent	Integer
ContextKeyword	TypeOf	Object
CPlusPlus 	ClassName	String
CPlusPlus 	GetContextService	Integer
CPlusPlus 	GetParent	PowerObject
CPlusPlus 	PostEvent	Boolean
CPlusPlus 	TriggerEvent	Integer
CPlusPlus 	TypeOf	Object
DataStore 	AcceptText	Integer
DataStore 	CategoryCount	Integer
DataStore 	CategoryName	String
DataStore 	ClassName	String
DataStore 	ClearValues	Integer
DataStore 	Clipboard	Integer
DataStore 	CopyRTF	String
DataStore 	Create	Integer
DataStore 	DataCount	Long
DataStore 	DBCancel	Integer
DataStore 	DeletedCount	Long
DataStore 	DeleteRow	Integer
DataStore 	Describe	String
DataStore 	Filter	Integer
DataStore 	FilteredCount	Integer
DataStore 	Find	Long
DataStore 	FindCategory	Integer
DataStore 	FindGroupChange	Long
DataStore 	FindRequired	Integer
DataStore 	FindSeries	Integer
DataStore 	GenerateHTMLForm	Integer
DataStore 	GetBorderStyle	Border (enumerated)
DataStore 	GetChanges	Long
DataStore 	GetChild	Integer
DataStore 	GetColumn	Integer
DataStore 	GetColumnName	String
DataStore 	GetContextService	Integer
DataStore 	GetData	Double
DataStore 	GetDataPieExplode	Integer
DataStore 	GetDataStyle	Integer
DataStore 	GetDataValue	Integer
DataStore 	GetFormat	String
DataStore 	GetFullState	Long
DataStore 	GetItemDate	Date
DataStore 	GetItemDateTime	DateTime
DataStore 	GetItemDecimal	Decimal
DataStore 	GetItemNumber	Double
DataStore 	GetItemStatus	dwItemStatus (enumerated)
DataStore 	GetItemString	String
DataStore 	GetItemTime	Time
DataStore 	GetNextModified	Long
DataStore 	GetParent	PowerObject
DataStore 	GetRow	Long
DataStore 	GetSelectedRow	Integer
DataStore 	GetSeriesStyle	Integer
DataStore 	GetSQLSelect	String
DataStore 	GetStateStatus	Long
DataStore 	GetText	String
DataStore 	GetTrans	Integer
DataStore 	GetValidate	String
DataStore 	GetValue	String
DataStore 	GroupCalc	Integer
DataStore 	ImportClipboard 	Long	
DataStore 	ImportFile 	Long	
DataStore 	ImportString	Long	
DataStore 	InsertDocument	Integer	
DataStore 	InsertRow	Long	
DataStore 	IsSelected	Boolean	
DataStore 	ModifiedCount	Long	
DataStore 	Modify	String	
DataStore 	PasteRTF	Long	
DataStore 	PostEvent	Boolean	
DataStore 	Print	Integer	
DataStore 	PrintCancel	Integer	
DataStore 	ReselectRow	Integer	
DataStore 	Reset	Integer	
DataStore 	ResetDataColors	Integer	
DataStore 	ResetTransObject	Integer	
DataStore 	ResetUpdate	Integer	
DataStore 	Retrieve	Long	
DataStore 	RowCount	Long	
DataStore 	RowsCopy	Integer	
DataStore 	RowsDiscard	Integer	
DataStore 	RowsMove	Integer	
DataStore 	SaveAs	Integer	
DataStore 	SaveAs	Integer	
DataStore 	SaveAsAscii	Long	
DataStore 	SelectRow	Integer	
DataStore 	SeriesCount	Integer	
DataStore 	SeriesName	String	
DataStore 	SetBorderStyle	Integer	
DataStore 	SetChanges	Long	
DataStore 	SetColumn	Integer	
DataStore 	SetDataPieExplode	Integer	
DataStore 	SetDataStyle	Integer	
DataStore 	SetDetailHeight	Integer	
DataStore 	SetFilter	Integer	
DataStore 	SetFormat	Integer	
DataStore 	SetFullState	Long	
DataStore 	SetItem	Integer	
DataStore 	SetItemStatus	Integer	
DataStore 	SetPosition	Integer	
DataStore 	SetRow	Integer	
DataStore 	SetSeriesStyle	Integer	
DataStore 	SetSort	Integer	
DataStore 	SetSQLPreview	Integer	
DataStore 	SetSQLSelect	Integer	
DataStore 	SetText	Integer	
DataStore 	SetTrans	Integer	
DataStore 	SetTransObject	Integer	
DataStore 	SetValidate	Integer
DataStore 	SetValue	Integer
DataStore 	ShareData	Integer
DataStore 	ShareDataOff	Integer
DataStore 	Sort	Integer
DataStore 	TriggerEvent	Integer
DataStore 	TypeOf	Object
DataStore 	Update	Integer
DataWindowChild	AcceptText	Integer
DataWindowChild	ClassName	String
DataWindowChild	ClearValues	Integer
DataWindowChild	CrosstabDialog	Integer
DataWindowChild	DBCancel	Integer
DataWindowChild	DBErrorCode	Long
DataWindowChild	DBErrorMessage	String
DataWindowChild	DeletedCount	Long
DataWindowChild	DeleteRow	Integer
DataWindowChild	Describe	String
DataWindowChild	Filter	Integer
DataWindowChild	FilteredCount	Integer
DataWindowChild	Find	Long
DataWindowChild	FindGroupChange	Long
DataWindowChild	FindRequired	Integer
DataWindowChild	GetBandAtPointer	String
DataWindowChild	GetBorderStyle	Border (enumerated)
DataWindowChild	GetClickedColumn	Integer
DataWindowChild	GetClickedRow	Long
DataWindowChild	GetColumn	Integer
DataWindowChild	GetColumnName	String
DataWindowChild	GetContextService	Integer
DataWindowChild	GetFormat	String
DataWindowChild	GetItemDate	Date
DataWindowChild	GetItemDateTime	DateTime
DataWindowChild	GetItemDecimal	Decimal
DataWindowChild	GetItemNumber	Double
DataWindowChild	GetItemStatus	dwItemStatus (enumerated)
DataWindowChild	GetItemString	String
DataWindowChild	GetItemTime	Time
DataWindowChild	GetNextModified	Long
DataWindowChild	GetObjectAtPointer	String
DataWindowChild	GetParent	PowerObject
DataWindowChild	GetRow	Long
DataWindowChild	GetSelectedRow	Integer
DataWindowChild	GetSQLPreview	String
DataWindowChild	GetSQLSelect	String
DataWindowChild	GetText	String
DataWindowChild	GetTrans	Integer
DataWindowChild	GetUpdateStatus	Integer
DataWindowChild	GetValidate	String
DataWindowChild	GetValue	String
DataWindowChild	GroupCalc	Integer
DataWindowChild	ImportClipboard 	Long
DataWindowChild	ImportFile 	Long
DataWindowChild	ImportString	Long
DataWindowChild	InsertRow	Long
DataWindowChild	IsSelected	Boolean
DataWindowChild	ModifiedCount	Long
DataWindowChild	Modify	String
DataWindowChild	OLEActivate	Integer
DataWindowChild	ReselectRow	Integer
DataWindowChild	Reset	Integer
DataWindowChild	ResetTransObject	Integer
DataWindowChild	ResetUpdate	Integer
DataWindowChild	Resize	Integer	
DataWindowChild	Retrieve	Long	
DataWindowChild	RowCount	Long	
DataWindowChild	RowsCopy	Integer	
DataWindowChild	RowsDiscard	Integer	
DataWindowChild	RowsMove	Integer	
DataWindowChild	SaveAs	Integer	
DataWindowChild	ScrollNextPage	Long	
DataWindowChild	ScrollNextRow	Long	
DataWindowChild	ScrollPriorPage	Long	
DataWindowChild	ScrollPriorRow	Long	
DataWindowChild	ScrollToRow	Integer	
DataWindowChild	SelectRow	Integer	
DataWindowChild	SetActionCode	Integer	
DataWindowChild	SetBorderStyle	Integer	
DataWindowChild	SetColumn	Integer	
DataWindowChild	SetDetailHeight	Integer
DataWindowChild	SetFilter	Integer
DataWindowChild	SetFormat	Integer
DataWindowChild	SetItem	Integer
DataWindowChild	SetItemStatus	Integer
DataWindowChild	SetPosition	Integer
DataWindowChild	SetRedraw	Integer
DataWindowChild	SetRow	Integer
DataWindowChild	SetRowFocusIndicator	Integer
DataWindowChild	SetSort	Integer
DataWindowChild	SetSQLPreview	Integer
DataWindowChild	SetSQLSelect	Integer
DataWindowChild	SetTabOrder	Integer
DataWindowChild	SetText	Integer
DataWindowChild	SetTrans	Integer
DataWindowChild	SetTransObject	Integer
DataWindowChild	SetValidate	Integer	
DataWindowChild	SetValue	Integer	
DataWindowChild	ShareData	Integer	
DataWindowChild	ShareDataOff	Integer	
DataWindowChild	Sort	Integer	
DataWindowChild	TypeOf	Object	
DataWindowChild	Update	Integer	
DynamicDescriptionArea 	ClassName	String	
DynamicDescriptionArea 	GetContextService	Integer	
DynamicDescriptionArea 	GetDynamicDate	Date	
DynamicDescriptionArea 	GetDynamicDateTime	DateTime	
DynamicDescriptionArea 	GetDynamicNumber	Double	
DynamicDescriptionArea 	GetDynamicString	String	
DynamicDescriptionArea 	GetDynamicTime	Time	
DynamicDescriptionArea 	GetParent	PowerObject	
DynamicDescriptionArea 	PostEvent	Boolean
DynamicDescriptionArea 	SetDynamicParm	Integer
DynamicDescriptionArea 	TriggerEvent	Integer
DynamicDescriptionArea 	TypeOf	Object
EnumerationDefinition	ClassName	String
EnumerationDefinition	GetContextService	Integer
EnumerationDefinition	GetParent	PowerObject
EnumerationDefinition	TypeOf	Object
EnumerationItemDefinition	ClassName	String
EnumerationItemDefinition	GetContextService	Integer
EnumerationItemDefinition	GetParent	PowerObject
EnumerationItemDefinition	TypeOf	Object
Environment	ClassName	String
Environment	GetContextService	Integer
Environment	GetParent	PowerObject
Environment	TypeOf	Object
Error	ClassName	String
Error	GetContextService	Integer
Error	GetParent	PowerObject
Error	PostEvent	Boolean
Error	TriggerEvent	Integer
Error	TypeOf	Object
grAxis	ClassName	String
grAxis	GetContextService	Integer
grAxis	GetParent	PowerObject
grAxis	TypeOf	Object
grDispAttr	ClassName	String
grDispAttr	GetContextService	Integer
grDispAttr	GetParent	PowerObject
grDispAttr	TypeOf	Object
Inet	ClassName	String
Inet	GetContextService	Integer
Inet	GetParent	PowerObject
Inet	GetURL	Integer
Inet	HyperLinkToURL	Integer
Inet	PostEvent	Boolean
Inet	PostURL	Integer
Inet	TriggerEvent	Integer
Inet	TypeOf	Object
InternetResult 	ClassName	String
InternetResult 	GetContextService	Integer
InternetResult 	GetParent	PowerObject
InternetResult 	InternetData	Integer
InternetResult 	PostEvent	Boolean
InternetResult 	TriggerEvent	Integer
InternetResult 	TypeOf	Object
ListViewItem 	ClassName	String
ListViewItem 	GetContextService	Integer
ListViewItem 	GetParent	PowerObject
ListViewItem 	TypeOf	Object
mailFileDescription	Classname	String
mailFileDescription	GetContextService	Integer
mailFileDescription	GetParent	PowerObject
mailFileDescription	TypeOf	Object
mailMessage 	Classname	String
mailMessage 	GetContextService	Integer
mailMessage 	GetParent	PowerObject
mailMessage 	TypeOf	Object
mailRecipient 	Classname	String
mailRecipient 	GetContextService	Integer
mailRecipient 	GetParent	PowerObject
mailRecipient 	TypeOf	Object
mailSession 	Classname	String
mailSession 	GetContextService	Integer
mailSession 	GetParent	PowerObject
mailSession 	mailAddress	mailReturnCode 
mailSession 	mailDeleteMessage	mailReturnCode 
mailSession 	mailGetMessages	mailReturnCode 
mailSession 	mailHandle	UnsignedLong
mailSession 	mailLogoff	mailReturnCode 
mailSession 	mailLogon	mailReturnCode
mailSession 	mailReadMessage	mailReturnCode
mailSession 	mailRecipientDetails	mailReturnCode
mailSession 	mailResolveRecipient	mailReturnCode
mailSession 	mailSaveMessage	mailReturnCode
mailSession 	mailSend	mailReturnCode 
mailSession 	PostEvent	Boolean
mailSession 	TriggerEvent	Integer
mailSession 	TypeOf	Object
MDIClient 	ClassName	String
MDIClient 	GetContextService	Integer
MDIClient 	GetParent	PowerObject
MDIClient 	Hide	Integer
MDIClient 	Move	Integer
MDIClient 	Resize	Integer
MDIClient 	SetRedraw	Integer
MDIClient 	Show	Integer
MDIClient 	TypeOf	Object
Menu	Check	Integer
Menu	ClassName	String
Menu	Disable	Integer
Menu	Enable	Integer
Menu	GetContextService	Integer
Menu	GetParent	PowerObject
Menu	Hide	Integer
Menu	PopMenu	Integer
Menu	PostEvent	Integer
Menu	Show	Integer
Menu	TriggerEvent	Integer
Menu	TypeOf	Object
Menu	Uncheck	Integer
MenuCascade 	Check	Integer
MenuCascade 	ClassName	String
MenuCascade 	Disable	Integer
MenuCascade 	Enable	Integer
MenuCascade 	GetContextService	Integer
MenuCascade 	GetParent	PowerObject
MenuCascade 	Hide	Integer
MenuCascade 	PopMenu	Integer
MenuCascade 	PostEvent	Integer
MenuCascade 	Show	Integer
MenuCascade 	TriggerEvent	Integer
MenuCascade 	TypeOf	Object
MenuCascade 	Uncheck	Integer
Message 	ClassName	String
Message 	GetContextService	Integer
Message 	GetParent	PowerObject
Message 	PostEvent	Boolean
Message 	TriggerEvent	Integer
Message 	TypeOf	Object
OLEObject 	ClassName	String
OLEObject 	ConnectToNewObject	Integer
OLEObject 	ConnectToNewRemoteObject	Integer
OLEObject 	ConnectToObject	Integer
OLEObject 	ConnectToRemoteObject	Integer
OLEObject 	DisconnectObject	Integer
OLEObject 	GetAutomationNative- 	
OLEObject 	Pointer	Integer
OLEObject 	GetContextService	Integer
OLEObject 	GetParent	PowerObject
OLEObject 	PostEvent	Boolean
OLEObject 	ReleaseAutomation- 	
OLEObject 	NativePointer 	Integer
OLEObject 	SetAutomationLocale	Integer
OLEObject 	SetAutomationPointer	Integer
OLEObject 	SetAutomationTimeout	Integer
OLEObject 	TriggerEvent	Integer
OLEObject 	TypeOf	Object
OLEStorage 	ClassName	String
OLEStorage 	Clear	Integer
OLEStorage 	Close	Integer
OLEStorage 	GetContextService	Integer
OLEStorage 	GetParent	PowerObject
OLEStorage 	MemberDelete	Integer
OLEStorage 	MemberExists	Integer
OLEStorage 	MemberRename	Integer
OLEStorage 	Open	Integer
OLEStorage 	PostEvent	Boolean
OLEStorage 	Save	Integer
OLEStorage 	SaveAs	Integer
OLEStorage 	TriggerEvent	Integer
OLEStorage 	TypeOf	Object
OLEStream 	ClassName	String
OLEStream 	Close	Integer
OLEStream 	GetContextService	Integer
OLEStream 	GetParent	PowerObject
OLEStream 	Length	Integer
OLEStream 	Open	Integer
OLEStream 	PostEvent	Boolean
OLEStream 	Read	Integer
OLEStream 	Seek	Integer
OLEStream 	TriggerEvent	Integer
OLEStream 	TypeOf	Object
OLEStream 	Write	Long
Pipeline 	Cancel	Integer
Pipeline 	ClassName	String
Pipeline 	GetContextService	Integer
Pipeline 	GetParent	PowerObject
Pipeline 	PostEvent	Boolean
Pipeline 	Repair	Integer
Pipeline 	Start	Integer
Pipeline 	TriggerEvent	Integer
Pipeline 	TypeOf	Object
ProfileCall	ClassName	String
ProfileCall	GetContextService	Integer
ProfileCall	GetParent	PowerObject
ProfileCall	TypeOf	Object
ProfileClass 	ClassName	String
ProfileClass 	GetContextService	Integer
ProfileClass 	GetParent	PowerObject
ProfileClass 	RoutineList	ErrorReturn (enumerated)
ProfileClass 	TypeOf	Object
ProfileLine	ClassName	String
ProfileLine	GetContextService	Integer
ProfileLine	GetParent	PowerObject
ProfileLine	OutGoingCallList	ErrorReturn (enumerated)
ProfileLine	RoutineList	ErrorReturn (enumerated)
ProfileLine	TypeOf	Object
ProfileRoutine 	ClassName	String
ProfileRoutine 	GetContextService	Integer
ProfileRoutine 	GetParent	PowerObject
ProfileRoutine 	IncomingCallList	ErrorReturn (enumerated)
ProfileRoutine 	LineList	ErrorReturn (enumerated)
ProfileRoutine 	OutgoingCallList	ErrorReturn (enumerated)
ProfileRoutine 	TypeOf	Object
Profiling	BuildModel	ErrorReturn (enumerated)
Profiling	ClassList	ErrorReturn (enumerated)
Profiling	ClassName	String
Profiling	DestroyModel	ErrorReturn (enumerated)
Profiling	GetContextService	Integer
Profiling	GetParent	PowerObject
Profiling	RoutineList	ErrorReturn (enumerated)
Profiling	SetTraceFileName	ErrorReturn
Profiling	SystemRoutine	ProfileRoutine
Profiling	TypeOf	Object
ScriptDefinition 	ClassName	String
ScriptDefinition 	GetContextService	Integer
ScriptDefinition 	GetParent	PowerObject
ScriptDefinition 	TypeOf	Object
TraceActivityNode	ClassName	String
TraceActivityNode	GetContextService	Integer
TraceActivityNode	GetParent	PowerObject
TraceActivityNode	TypeOf	Object
TraceBeginEnd	ClassName	String
TraceBeginEnd	GetContextService	Integer
TraceBeginEnd	GetParent	PowerObject
TraceBeginEnd	TypeOf	Object
TraceError	ClassName	String
TraceError	GetContextService	Integer
TraceError	GetParent	PowerObject
TraceError	TypeOf	Object
TraceESQL 	ClassName	String
TraceESQL 	GetContextService	Integer
TraceESQL 	GetParent	PowerObject
TraceESQL 	TypeOf	Object
TraceFile	ClassName	String
TraceFile	Close	ErrorReturn (enumerated)
TraceFile	GetContextService	Integer
TraceFile	GetParent	PowerObject
TraceFile	NextActivity	TraceActivityNode
TraceFile	Open	ErrorReturn (enumerated)
TraceFile	Reset	ErrorReturn (enumerated)
TraceFile	TypeOf	Object
TraceGarbageCollect	ClassName	String
TraceGarbageCollect	GetContextService	Integer
TraceGarbageCollect	GetParent	PowerObject
TraceGarbageCollect	TypeOf	Object
TraceLine	ClassName	String
TraceLine	GetContextService	Integer
TraceLine	GetParent	PowerObject
TraceLine	TypeOf	Object
TraceObject	ClassName	String
TraceObject	GetContextService	Integer
TraceObject	GetParent	PowerObject
TraceObject	TypeOf	Object
TraceRoutine	ClassName	String
TraceRoutine	GetContextService	Integer
TraceRoutine	GetParent	PowerObject
TraceRoutine	TypeOf	Object
TraceTree	BuildModel	ErrorReturn(enumerated)
TraceTree	ClassName	String
TraceTree	DestroyModel	ErrorReturn(enumerated)
TraceTree	EntryList	ErrorReturn(enumerated)
TraceTree	GetContextService	Integer
TraceTree	GetParent	PowerObject
TraceTree	SetTraceFileName	ErorReturn
TraceTree	TypeOf	Object
TraceTreeError	ClassName	String
TraceTreeError	GetContextService	Integer
TraceTreeError	GetParent	PowerObject
TraceTreeError	TypeOf	Object
TraceTreeESQL 	ClassName	String
TraceTreeESQL 	GetContextService	Integer
TraceTreeESQL 	GetParent	PowerObject
TraceTreeESQL 	TypeOf	Object
TraceTreeGarbageCollect 	ClassName	String
TraceTreeGarbageCollect 	GetChildrenList	ErrorReturn (enumerated)
TraceTreeGarbageCollect 	GetContextService	Integer
TraceTreeGarbageCollect 	GetParent	PowerObject
TraceTreeGarbageCollect 	TypeOf	Object
TraceTreeLine 	ClassName	String
TraceTreeLine 	GetContextService	Integer
TraceTreeLine 	GetParent	PowerObject
TraceTreeLine 	TypeOf	Object
TraceTreeNode 	ClassName	String
TraceTreeNode 	GetContextService	Integer
TraceTreeNode 	GetParent	PowerObject
TraceTreeNode 	TypeOf	Object
TraceTreeObject 	ClassName	String
TraceTreeObject 	GetChildrenList	
TraceTreeObject 	GetContextService	Integer
TraceTreeObject 	GetParent	PowerObject
TraceTreeObject 	TypeOf	Object
TraceTreeRoutine	ClassName	String
TraceTreeRoutine	GetChildrenList	ErrorReturn(enumerated)
TraceTreeRoutine	GetContextService	Integer
TraceTreeRoutine	GetParent	PowerObject
TraceTreeRoutine	TypeOf	Object
TraceTreeUser 	ClassName	String
TraceTreeUser 	GetContextService	Integer
TraceTreeUser 	GetParent	PowerObject
TraceTreeUser 	TypeOf	Object
TraceUser	ClassName	String
TraceUser	GetContextService	Integer
TraceUser	GetParent	PowerObject
TraceUser	TypeOf	Object
Timing 	ClassName	String
Timing 	GetContextService	Integer
Timing 	GetParent	PowerObject
Timing 	PostEvent	Boolean
Timing 	Start	Integer
Timing 	Stop	Integer
Timing 	TriggerEvent	Integer
Timing 	TypeOf	Object
Transaction 	ClassName	String
Transaction 	DBHandle	Long
Transaction 	GetContextService	Integer
Transaction 	GetParent	PowerObject
Transaction 	PostEvent	Boolean
Transaction 	SyntaxFromSQL	String
Transaction 	TriggerEvent	Integer
Transaction 	TypeOf	Object
Transport 	ClassName	String
Transport 	GetContextService	Integer
Transport 	GetParent	PowerObject
Transport 	Listen	Long
Transport 	StopListening	Long
Transport 	TypeOf	Object
TreeViewItem	ClassName	String
TreeViewItem	GetContextService	Integer
TreeViewItem	GetParent	PowerObject
TreeViewItem	TypeOf	Object
TypeDefinition 	ClassName	String
TypeDefinition 	GetContextService	Integer
TypeDefinition 	GetParent	PowerObject
TypeDefinition 	TypeOf	Object
UserObject	AddItem	Integer
UserObject	ClassName	String
UserObject	DeleteItem	Integer
UserObject	Drag	Integer
UserObject	EventParmDouble	Integer
UserObject	EventParmString	Integer
UserObject	GetContextService	Integer
UserObject	GetParent	PowerObject
UserObject	Hide	Integer
UserObject	InsertItem	Integer
UserObject	Move	Integer
UserObject	PointerX	Integer
UserObject	PointerY	Integer
UserObject	PostEvent	Boolean
UserObject	Print	Integer
UserObject	Resize	Integer
UserObject	SetFocus	Integer
UserObject	SetPosition	Integer
UserObject	SetRedraw	Integer
UserObject	Show	Integer
UserObject	TriggerEvent	Integer
UserObject	TypeOf	Object
VariableCardinality 	ClassName	String
VariableCardinality 	GetContextService	Integer
VariableCardinality 	GetParent	PowerObject
VariableCardinality 	TypeOf	Object
VariableDefinition 	ClassName	String
VariableDefinition 	GetContextService	Integer
VariableDefinition 	GetParent	PowerObject
VariableDefinition 	TypeOf	Object
Window	ArrangeSheets	Integer
Window	ChangeMenu	Integer
Window	ClassName	String
Window	CloseUserObject	Integer
Window	GetActiveSheet	Window
Window	GetContextService	Integer
Window	GetFirstSheet	Window
Window	GetNextSheet	Window
Window	GetParent	PowerObject
Window	GetToolbar	Integer
Window	GetToolbarPos	Integer
Window	Hide	Integer
Window	Move	Integer
Window	OpenUserObject	Integer
Window	OpenUserObjectWithParm	Integer
Window	ParentWindow	Window
Window	PointerX	Integer
Window	PointerY	Integer
Window	PostEvent	Boolean
Window	Print	Integer
Window	Resize	Integer
Window	SetFocus	Integer	
Window	SetMicroHelp	Integer	
Window	SetPosition	Integer	
Window	SetRedraw	Integer	
Window	SetToolbar	Integer	
Window	SetToolbarPosition	Integer	
Window	Show	Integer	
Window	TriggerEvent	Integer	
Window	TypeOf	Object	
Window	WorkSpaceHeight	Integer	
Window	WorkSpaceWidth	Integer	
Window	WorkSpaceX	Integer	
Window	WorkSpaceY	Integer	
SystemFunction	LowerBound	  	
SystemFunction	UpperBound	  	
SystemFunction	Blob	  
SystemFunction	BlobEdit	  
SystemFunction	BlobMid	  
SystemFunction	Len	  
SystemFunction	String	  
SystemFunction	Asc	  
SystemFunction	Char	  
SystemFunction	Dec	  
SystemFunction	Double	  
SystemFunction	Integer	  
SystemFunction	Long	  
SystemFunction	Real	  
SystemFunction	Date	  
SystemFunction	DateTime	  
SystemFunction	IsDate	  
SystemFunction	IsNull	  
SystemFunction	IsNumber	  
SystemFunction	IsTime	  
SystemFunction	String	  
SystemFunction	Time	  
SystemFunction	Day	  
SystemFunction	DayName	  
SystemFunction	DayNumber	  
SystemFunction	DaysAfter	  
SystemFunction	Hour	  
SystemFunction	Minute	  
SystemFunction	Month	  
SystemFunction	Now	  
SystemFunction	RelativeDate	  
SystemFunction	RelativeTime	  
SystemFunction	Second	  
SystemFunction	Today	  
SystemFunction	Year	  
SystemFunction	CloseChannel	  
SystemFunction	ExecRemote 	  
SystemFunction	GetDataDDE	  
SystemFunction	GetDataDDEOrigin	  
SystemFunction	GetRemote 	  
SystemFunction	OpenChannel	  
SystemFunction	RespondRemote	  
SystemFunction	SetRemote 	  
SystemFunction	StartHotLink	  
SystemFunction	StopHotLink	  
SystemFunction	GetCommandDDE	  
SystemFunction	GetCommandDDEOrigin	  
SystemFunction	GetDataDDE	  
SystemFunction	GetDataDDEOrigin	  
SystemFunction	RespondRemote	  
SystemFunction	SetDataDDE	  
SystemFunction	StartServerDDE	  
SystemFunction	StopServerDDE	  
SystemFunction	FileClose	  
SystemFunction	FileDelete	  
SystemFunction	FileExists	  
SystemFunction	FileLength	  
SystemFunction	FileOpen	  
SystemFunction	FileRead	  
SystemFunction	FileSeek	  
SystemFunction	FileWrite	  
SystemFunction	GetFileOpenName	  
SystemFunction	GetFileSaveName	  
SystemFunction	IsAllArabic	  
SystemFunction	IsAllHebrew	  
SystemFunction	IsAnyArabic	  
SystemFunction	IsAnyHebrew	  
SystemFunction	IsArabic	  
SystemFunction	IsArabicAndNumbers	  
SystemFunction	IsHebrew	  
SystemFunction	IsHebrewAndNumbers	  
SystemFunction	Reverse	  
SystemFunction	ToAnsi	  
SystemFunction	ToUnicode	  
SystemFunction	LibraryCreate	  
SystemFunction	LibraryDelete	  
SystemFunction	LibraryDirectory	  
SystemFunction	LibraryExport	  
SystemFunction	LibraryImport	  
SystemFunction	mailAddress	  
SystemFunction	mailDeleteMessage	  
SystemFunction	mailGetMessages	  
SystemFunction	mailHandle	  
SystemFunction	mailLogoff	  
SystemFunction	mailLogon	  
SystemFunction	mailReadMessage	  
SystemFunction	mailRecipientDetails	  
SystemFunction	mailResolveRecipient	  
SystemFunction	mailSaveMessage	  
SystemFunction	mailSend	  
SystemFunction	Beep	  
SystemFunction	ClassName	  
SystemFunction	DebugBreak	  
SystemFunction	DraggedObject	  
SystemFunction	IntHigh	  
SystemFunction	IntLow	  
SystemFunction	IsValid	  
SystemFunction	KeyDown	  
SystemFunction	MessageBox	  
SystemFunction	PixelsToUnits	  
SystemFunction	PopulateError	  
SystemFunction	RGB	  
SystemFunction	SetNull	  
SystemFunction	SetPointer	  
SystemFunction	SignalError	  
SystemFunction	UnitsToPixels	  
SystemFunction	Abs	  
SystemFunction	Ceiling	  
SystemFunction	Cos	  
SystemFunction	Exp	  
SystemFunction	Fact	  
SystemFunction	Int	  
SystemFunction	Log	  
SystemFunction	LogTen	  
SystemFunction	Max	  
SystemFunction	Min	  
SystemFunction	Mod	  
SystemFunction	Pi	  
SystemFunction	Rand	  
SystemFunction	Randomize	  
SystemFunction	Round	  
SystemFunction	Sign	  
SystemFunction	Sin	  
SystemFunction	Sqrt	  
SystemFunction	Tan	  
SystemFunction	Truncate	  
SystemFunction	Print	  
SystemFunction	PrintBitmap	  
SystemFunction	PrintCancel	  
SystemFunction	PrintClose	  
SystemFunction	PrintDataWindow	  
SystemFunction	PrintDefineFont	  
SystemFunction	PrintLine	  
SystemFunction	PrintOpen	  
SystemFunction	PrintOval	  
SystemFunction	PrintPage	  
SystemFunction	PrintRect	  
SystemFunction	PrintRoundRect	  
SystemFunction	PrintScreen	  
SystemFunction	PrintSend	  
SystemFunction	PrintSetFont	  
SystemFunction	PrintSetSpacing	  
SystemFunction	PrintSetup	  
SystemFunction	PrintText	  
SystemFunction	PrintWidth	  
SystemFunction	PrintX	  
SystemFunction	PrintY	  
SystemFunction	RegistryDelete	  
SystemFunction	RegistryGet	  
SystemFunction	RegistryKeys	  
SystemFunction	RegistrySet	  
SystemFunction	RegistryValues	  
SystemFunction	Asc	  
SystemFunction	Char	  
SystemFunction	Fill	  
SystemFunction	Left	  
SystemFunction	LeftTrim	  
SystemFunction	Len	  
SystemFunction	Lower	  
SystemFunction	Match	  
SystemFunction	Mid	  
SystemFunction	Pos	  
SystemFunction	Replace	  
SystemFunction	Reverse	  
SystemFunction	Right	  
SystemFunction	RightTrim	  
SystemFunction	Space	  
SystemFunction	Trim	  
SystemFunction	Upper	  
SystemFunction	Clipboard	  
SystemFunction	CommandParm	  
SystemFunction	DoScript	  
SystemFunction	GetApplication	  
SystemFunction	GetEnvironment	  
SystemFunction	GetFocus	  
SystemFunction	Post	  
SystemFunction	ProfileInt	  
SystemFunction	ProfileString	  
SystemFunction	Restart	  
SystemFunction	Run	  
SystemFunction	Send	  
SystemFunction	SetProfileString	  
SystemFunction	ShowHelp	  
SystemFunction	SignalError	  
SystemFunction	Yield	  
SystemFunction	CPU	  
SystemFunction	Idle	  
SystemFunction	Timer	  
SystemFunction	Close	  
SystemFunction	CloseWithReturn	  
SystemFunction	Open	  
SystemFunction	OpenSheet	  
SystemFunction	OpenSheetWithParm	  
SystemFunction	OpenWithParm	  
----------------------------------------------------------------*/
/*----------------------------------------------------------------
PowerBuilder Object Properties
------------------------------------------------------------------
CheckBox	Automatic	Boolean	
CheckBox	BackColor	Long	
CheckBox	BorderStyle	BorderStyle (enumerated)	
CheckBox	BringToTop	Boolean	
CheckBox	Checked	Boolean	
CheckBox	DragAuto	Boolean	
CheckBox	DragIcon	String	
CheckBox	Enabled	Boolean	
CheckBox	FaceName	String	
CheckBox	FontCharSet	FontCharSet (enumerated)	
CheckBox	FontFamily	FontFamily (enumerated)	
CheckBox	FontPitch	FontPitch (enumerated)	
CheckBox	Height	Integer	
CheckBox	Italic	Boolean	
CheckBox	LeftText	Boolean	
CheckBox	Pointer	String	
CheckBox	RightToLeft	Boolean	
CheckBox	TabOrder	Integer	
CheckBox	Tag	String	
CheckBox	Text	String	
CheckBox	TextColor	Long	
CheckBox	TextSize	Integer	
CheckBox	ThirdState	Boolean	
CheckBox	ThreeState	Boolean	
CheckBox	Underline	Boolean	
CheckBox	Visible	Boolean	
CheckBox	Weight	Integer	
CheckBox	Width	Integer	
CheckBox	X	Integer	
CheckBox	Y	Integer	
CommandButton	BringToTop	Boolean	
CommandButton	Cancel	Boolean	
CommandButton	Default	Boolean	
CommandButton	DragAuto	Boolean	
CommandButton	DragIcon	String	
CommandButton	Enabled	Boolean	
CommandButton	FaceName	String	
CommandButton	FontCharSet	FontCharSet (enumerated)	
CommandButton	FontFamily	FontFamily (enumerated)	
CommandButton	FontPitch	FontPitch (enumerated)	
CommandButton	Height	Integer	
CommandButton	Italic	Boolean	
CommandButton	Pointer	String	
CommandButton	TabOrder	Integer	
CommandButton	Tag	String	
CommandButton	Text	String	
CommandButton	TextSize	Integer	
CommandButton	Underline	Boolean	
CommandButton	Visible	Boolean	
CommandButton	Weight	Integer	
CommandButton	Width	Integer	
CommandButton	X	Integer	
CommandButton	Y	Integer	
DataWindow 	Border	Boolean	
DataWindow 	BorderStyle	BorderStyle (enumerated)	
DataWindow 	BringToTop	Boolean	
DataWindow 	ControlMenu	Boolean	
DataWindow 	DataObject	String	
DataWindow 	DragAuto	Boolean	
DataWindow 	DragIcon	String	
DataWindow 	Enabled	Boolean	
DataWindow 	Height	Integer	
DataWindow 	HScrollBar	Boolean	
DataWindow 	HSplitScroll	Boolean	
DataWindow 	Icon	String	
DataWindow 	LiveScroll	Boolean	
DataWindow 	MaxBox	Boolean	
DataWindow 	MinBox	Boolean	
DataWindow 	Object	DWObject	
DataWindow 	Resizable	Boolean	
DataWindow 	RightToLeft	Boolean	
DataWindow 	TabOrder	Integer	
DataWindow 	Tag	String	
DataWindow 	Title	String	
DataWindow 	TitleBar	Boolean	
DataWindow 	Visible	Boolean	
DataWindow 	VScrollBar	Boolean	
DataWindow 	Width	Integer	
DataWindow 	X	Integer	
DataWindow 	Y	Integer	
DropDownListBox	Accelerator	Integer	
DropDownListBox	AllowEdit	Boolean	
DropDownListBox	AutoHScroll	Boolean	
DropDownListBox	BackColor	Long	
DropDownListBox	Border	Boolean	
DropDownListBox	BorderStyle	BorderStyle (enumerated)	
DropDownListBox	BringToTop	Boolean	
DropDownListBox	DragAuto	Boolean	
DropDownListBox	DragIcon	String	
DropDownListBox	Enabled	Boolean	
DropDownListBox	FaceName	String	
DropDownListBox	FontCharSet	FontCharSet (enumerated)	
DropDownListBox	FontFamily	FontFamily (enumerated)	
DropDownListBox	FontPitch	FontPitch (enumerated)	
DropDownListBox	Height	Integer	
DropDownListBox	HScrollBar	Boolean	
DropDownListBox	Italic	Boolean	
DropDownListBox	Item[ ]	String array	
DropDownListBox	Limit	Integer	
DropDownListBox	Pointer	String	
DropDownListBox	RightToLeft	Boolean	
DropDownListBox	ShowList	Boolean	
DropDownListBox	Sorted	Boolean	
DropDownListBox	TabOrder	Integer	
DropDownListBox	Tag	String	
DropDownListBox	Text	String	
DropDownListBox	TextColor	Long	
DropDownListBox	TextSize	Integer	
DropDownListBox	Underline	Boolean	
DropDownListBox	Visible	Boolean	
DropDownListBox	VScrollBar	Boolean	
DropDownListBox	Weight	Integer	
DropDownListBox	Width	Integer	
DropDownListBox	X	Integer	
DropDownListBox	Y	Integer	
DropDownPicture	 Accelerator	Integer	
DropDownPicture	AllowEdit	Boolean	
DropDownPicture	AutoHScroll	Boolean	
DropDownPicture	BackColor	Long	
DropDownPicture	Border	Boolean	
DropDownPicture	BorderStyle	BorderStyle (enumerated)	
DropDownPicture	BringToTop	Boolean	
DropDownPicture	DragAuto	Boolean	
DropDownPicture	DragIcon	String	
DropDownPicture	Enabled	Boolean	
DropDownPicture	FaceName	String	
DropDownPicture	FontCharSet	FontCharSet (enumerated)	
DropDownPicture	FontFamily	FontFamily (enumerated)	
DropDownPicture	FontPitch	FontPitch (enumerated)	
DropDownPicture	Height	Integer	
DropDownPicture	HScrollBar	Boolean	
DropDownPicture	Italic	Boolean	
DropDownPicture	Item[ ]	String array	
DropDownPicture	ItemPictureIndex[ ]	Integer	
DropDownPicture	Limit	Integer	
DropDownPicture	PictureHeight	Integer	
DropDownPicture	PictureWidth	Integer	
DropDownPicture	PictureMaskColor	Long	
DropDownPicture	PictureName[ ]	String	
DropDownPicture	Pointer	String	
DropDownPicture	RightToLeft	Boolean	
DropDownPicture	ShowList	Boolean	
DropDownPicture	Sorted	Boolean	
DropDownPicture	TabOrder	Integer	
DropDownPicture	Tag	String	
DropDownPicture	Text	String	
DropDownPicture	TextColor	Long	
DropDownPicture	TextSize	Integer	
DropDownPicture	Underline	Boolean	
DropDownPicture	Visible	Boolean	
DropDownPicture	VScrollBar	Boolean	
DropDownPicture	Weight	Integer	
DropDownPicture	Width	Integer	
DropDownPicture	X	Integer	
DropDownPicture	Y	Integer	
EditMask	Accelerator	Integer	
EditMask	Alignment	Alignment 	
EditMask	(enumerated)	Specifies the alignment of text in the control. Values are:Center!Justify!Left!Right!	
EditMask	AutoHScroll	Boolean	
EditMask	AutoSkip	Boolean	
EditMask	AutoVScroll	Boolean	
EditMask	BackColor	Long	
EditMask	Border	Boolean	
EditMask	BorderStyle	BorderStyle (enumerated)	
EditMask	BringToTop	Boolean	
EditMask	DisplayData	String	
EditMask	DisplayOnly	Boolean	
EditMask	DragAuto	Boolean	
EditMask	DragIcon	String	
EditMask	Enabled	Boolean	
EditMask	FaceName	String	
EditMask	FontCharSet	FontCharSet (enumerated)	
EditMask	FontFamily	FontFamily (enumerated)	
EditMask	FontPitch	FontPitch (enumerated)	
EditMask	Height	Integer	
EditMask	HScrollBar	Boolean	
EditMask	HideSelection	Boolean	
EditMask	IgnoreDefaultButton	Boolean	
EditMask	Increment	Double	
EditMask	Italic	Boolean	
EditMask	Limit	Integer	
EditMask	Mask	String	
EditMask	MaskDataType	MaskDataType (enumerated)	
EditMask	MinMax	String	
EditMask	Pointer	String	
EditMask	RightToLeft	Boolean	
EditMask	Spin	Boolean	
EditMask	TabOrder	Integer	
EditMask	TabStop[ ]	Integer	
EditMask	Tag	String	
EditMask	Text	String	
EditMask	TextColor	Long	
EditMask	TextCase	TextCase (enumerated)	
EditMask	TextSize	Integer	
EditMask	UnderLine	Boolean	
EditMask	UseCodeTable	Boolean	
EditMask	Visible	Boolean	
EditMask	VScrollBar	Boolean	
EditMask	Weight	Integer	
EditMask	Width	Integer	
EditMask	X	Integer	
EditMask	Y	Integer	
Graph	BackColor	Long	
Graph	Border	Boolean	
Graph	BorderStyle	BorderStyle (enumerated)	
Graph	BringToTop	Boolean	
Graph	Category	grAxis	
Graph	CategorySort	grSortType	
Graph	Depth	Integer	
Graph	DragAuto	Boolean	
Graph	DragIcon	String	
Graph	Elevation	Integer	
Graph	Enabled	Boolean	
Graph	FocusRectangle	Boolean	
Graph	GraphType	grGraphType (enumerated)	
Graph	Height	Integer	
Graph	Legend	grLegendType (enumerated)	
Graph	LegendDispAttr	grDispAttr
Graph	OverlapPercent	Integer
Graph	Perspective	Integer
Graph	PieDispAttr	grDispAttr
Graph	Pointer	String
Graph	Rotation	Integer
Graph	Series	grAxis
Graph	SeriesSort	grSortType
Graph	ShadeColor	Long
Graph	Spacing	Integer
Graph	TabOrder	Integer
Graph	Tag	String
Graph	TextColor	Long
Graph	Title	String
Graph	TitleDispAttr	grDispAttr
Graph	Values	grAxis
Graph	Visible	Boolean	
Graph	Width	Integer	
Graph	X	Integer	
Graph	Y	Integer	
GroupBox 	BackColor	Long	
GroupBox 	BorderStyle	BorderStyle (enumerated)	
GroupBox 	BringToTop	Boolean	
GroupBox 	DragAuto	Boolean	
GroupBox 	DragIcon	String	
GroupBox 	Enabled	Boolean	
GroupBox 	FaceName	String	
GroupBox 	FontCharSet	FontCharSet (enumerated)	
GroupBox 	FontFamily	FontFamily (enumerated)	
GroupBox 	FontPitch	FontPitch (enumerated)	
GroupBox 	Height	Integer	
GroupBox 	Italic	Boolean	
GroupBox 	Pointer	String	
GroupBox 	RightToLeft 	Boolean	
GroupBox 	TabOrder	Integer	
GroupBox 	Tag	String	
GroupBox 	Text	String	
GroupBox 	TextColor	Long	
GroupBox 	TextSize	Integer	
GroupBox 	Underline	Boolean	
GroupBox 	Visible	Boolean	
GroupBox 	Weight	Integer	
GroupBox 	Width	Integer	
GroupBox 	X	Integer	
GroupBox 	Y	Integer	
HScrollBar	BringToTop	Boolean	
HScrollBar	DragAuto	Boolean	
HScrollBar	DragIcon	String	
HScrollBar	Height	Integer	
HScrollBar	MaxPosition	Integer	
HScrollBar	MinPosition	Integer	
HScrollBar	Pointer	String	
HScrollBar	Position	Integer	
HScrollBar	StdHeight	Boolean	
HScrollBar	TabOrder	Integer	
HScrollBar	Tag	String	
HScrollBar	Visible	Boolean	
Line	BeginX	Integer	
Line	BeginY	Integer	
Line	EndX	Integer	
Line	EndY	Integer	
Line	LineColor	Long	
Line	LineStyle	LineStyle (enumerated)	
Line	LineThickness	Integer	
Line	Tag	String	
Line	Visible	Boolean	
ListBox 	Accelerator	Integer	
ListBox 	BackColor	Long	
ListBox 	Border	Boolean	
ListBox 	BorderStyle	BorderStyle (enumerated)	
ListBox 	BringToTop	Boolean	
ListBox 	DisableNoScroll	Boolean	
ListBox 	DragAuto	Boolean	
ListBox 	DragIcon	String	
ListBox 	Enabled	Boolean	
ListBox 	ExtendedSelect	Boolean	
ListBox 	FaceName	String	
ListBox 	FontCharSet	FontCharSet (enumerated)	
ListBox 	FontFamily	FontFamily (enumerated)	
ListBox 	FontPitch	FontPitch (enumerated)	
ListBox 	Height	Integer	
ListBox 	HScrollBar	Boolean	
ListBox 	Italic	Boolean	
ListBox 	Item[ ]	String	
ListBox 	MultiSelect	Boolean	
ListBox 	Pointer	String	
ListBox 	RightToLeft	Boolean	
ListBox 	Sorted	Boolean	
ListBox 	TabOrder	Integer	
ListBox 	TabStop[ ]	Integer array	
ListBox 	Tag	String	
ListBox 	TextColor	Long	
ListBox 	TextSize	Integer
ListBox 	Underline	Boolean
ListBox 	Visible	Boolean
ListBox 	VScrollBar	Boolean
ListBox 	Weight	Integer
ListBox 	Width	Integer
ListBox 	X	Integer
ListBox 	Y	Integer
ListView	Accelerator	Integer
ListView	AutoArrange	Boolean
ListView	BackColor	Long
ListView	Border	Boolean 
ListView	BorderStyle	BorderStyle (enumerated)
ListView	BringToTop	Boolean 
ListView	ButtonHeader	Boolean 
ListView	DeleteItems	Boolean 	
ListView	DragAuto 	Boolean 	
ListView	DragIcon	String	
ListView	EditLabels	Boolean 	
ListView	Enabled	Boolean	
ListView	ExtendedSelect	Boolean	
ListView	FaceName	String	
ListView	FixedLocations 	Boolean 	
ListView	FontCharSet	FontCharSet (enumerated) 	
ListView	FontFamily	FontFamily (enumerated) 	
ListView	FontPitch	FontPitch (enumerated) 	
ListView	Height	Integer	
ListView	HideSelection	Boolean	
ListView	Italic	Boolean	
ListView	Item[ ]	String	
ListView	ItemPictureIndex[ ]	Integer	
ListView	LabelWrap	Boolean 	
ListView	LargePictureHeight 	Integer	
ListView	LargePictureMaskColor	Long	
ListView	LargePictureName[ ]	String	
ListView	LargePictureWidth	Integer	
ListView	Pointer	String	
ListView	Scrolling	Boolean 	
ListView	ShowHeader 	Boolean 	
ListView	SmallPictureHeight 	Integer	
ListView	SmallPictureMaskColor	Long	
ListView	SmallPictureName[ ]	String	
ListView	SmallPictureWidth	Integer	
ListView	SortType	grSortType	
ListView	StatePictureHeight	Integer	
ListView	StatePictureMaskColor	Long	
ListView	StatePictureName[ ]	String	
ListView	StatePictureWidth	Integer	
ListView	TabOrder	Integer	
ListView	Tag	String	
ListView	TextColor	Long	
ListView	TextSize	Integer	
ListView	Underline	Boolean	
ListView	View	ListViewView 	
ListView	Visible	Boolean	
ListView	Weight	Integer	
ListView	Width	Integer	
ListView	X	Integer	
ListView	Y	Integer	
MultiLineEdit 	Accelerator	Integer	
MultiLineEdit 	Alignment	Alignment (enumerated)	
MultiLineEdit 	AutoHScroll	Boolean	
MultiLineEdit 	AutoVScroll	Boolean	
MultiLineEdit 	BackColor	Long	
MultiLineEdit 	Border	Boolean	
MultiLineEdit 	BorderStyle	BorderStyle (enumerated)	
MultiLineEdit 	BringToTop	Boolean	
MultiLineEdit 	DisplayOnly	Boolean	
MultiLineEdit 	DragAuto	Boolean	
MultiLineEdit 	DragIcon	String	
MultiLineEdit 	Enabled	Boolean	
MultiLineEdit 	FaceName	String	
MultiLineEdit 	FontCharSet	FontCharSet (enumerated)	
MultiLineEdit 	FontFamily	FontFamily (enumerated)	
MultiLineEdit 	FontPitch	FontPitch (enumerated)	
MultiLineEdit 	Height	Integer	
MultiLineEdit 	HideSelection	Boolean	
MultiLineEdit 	HScrollBar	Boolean	
MultiLineEdit 	IgnoreDefaultButton	Boolean	
MultiLineEdit 	Italic	Boolean	
MultiLineEdit 	Limit	Integer	
MultiLineEdit 	Pointer	String	
MultiLineEdit 	RightToLeft	Boolean	
MultiLineEdit 	TabOrder	Integer	
MultiLineEdit 	TabStop[ ]	Integer	
MultiLineEdit 	Tag	String	
MultiLineEdit 	Text	String	
MultiLineEdit 	TextCase	TextCase (enumerated)	
MultiLineEdit 	TextColor	Long	
MultiLineEdit 	TextSize	Integer	
MultiLineEdit 	Underline	Boolean	
MultiLineEdit 	Visible	Boolean	
MultiLineEdit 	VScrollBar	Boolean	
MultiLineEdit 	Weight	Integer	
MultiLineEdit 	Width	Integer	
MultiLineEdit 	X	Integer	
MultiLineEdit 	Y	Integer	
OLEControl 	Activation	omActivation	
OLEControl 	BackColor	Long	
OLEControl 	Border	Boolean	
OLEControl 	BorderStyle	BorderStyle (enumerated)	
OLEControl 	BringToTop	Boolean	
OLEControl 	ClassLongName	String	
OLEControl 	ClassShortName	String	
OLEControl 	ContentsAllowed	omContents	
OLEControl 	Allowed	Specifies whether the OLE object in the control must be embedded or linked or whether either method is allowed when Insert is called at runtime.	
OLEControl 	DisplayName	String	
OLEControl 	DisplayType	omDisplayType	
OLEControl 	DocFileName	String	
OLEControl 	DragAuto	Boolean	
OLEControl 	DragIcon	String	
OLEControl 	Enabled	Boolean	
OLEControl 	FocusRectangle	Boolean	
OLEControl 	Height	Integer	
OLEControl 	IsDragTarget	Boolean	
OLEControl 	LinkItem	String	
OLEControl 	LinkUpdateOptions	omLinkUpdateOptions	
OLEControl 	Object	omObject	
OLEControl 	ObjectData	Blob	
OLEControl 	ParentStorage	omStorage	
OLEControl 	Pointer	String	
OLEControl 	Resizable	Boolean	
OLEControl 	TabOrder	Integer	
OLEControl 	Tag	String	
OLEControl 	Visible	Boolean	
OLEControl 	Width	Integer	
OLEControl 	X	Integer	
OLEControl 	Y	Integer	
OLECustomControl 	Alignment	Alignment (enumerated)	
OLECustomControl 	BackColor	Long	
OLECustomControl 	Border	Boolean	
OLECustomControl 	BorderStyle	BorderStyle (enumerated)	
OLECustomControl 	BringToTop	Boolean	
OLECustomControl 	Cancel	Boolean	
OLECustomControl 	ClassLongName	String	
OLECustomControl 	ClassShortName	String	
OLECustomControl 	DisplayName	String	
OLECustomControl 	Default	Boolean	
OLECustomControl 	DragAuto	Boolean	
OLECustomControl 	DragIcon	String	
OLECustomControl 	Enabled	Boolean
OLECustomControl 	FaceName	String
OLECustomControl 	FocusRectangle	Boolean
OLECustomControl 	FontCharSet	FontCharSet (enumerated)
OLECustomControl 	FontFamily	FontFamily (enumerated)
OLECustomControl 	FontPitch	FontPitch (enumerated)
OLECustomControl 	Height	Integer
OLECustomControl 	IsDragTarget	Boolean
OLECustomControl 	Italic	Boolean
OLECustomControl 	Object	omObject
OLECustomControl 	Pointer	String
OLECustomControl 	TabOrder	Integer
OLECustomControl 	Tag	String
OLECustomControl 	TextColor	Long
OLECustomControl 	TextSize	Integer
OLECustomControl 	Underline	Boolean
OLECustomControl 	Visible	Boolean	
OLECustomControl 	Weight	Integer	
OLECustomControl 	Width	Integer	
OLECustomControl 	X	Integer	
OLECustomControl 	Y	Integer	
Oval 	FillColor	Long	
Oval 	FillPattern	FillPattern (enumerated)	
Oval 	Height	Integer	
Oval 	LineColor	Long	
Oval 	LineStyle	LineStyle (enumerated)	
Oval 	LineThickness	Integer	
Oval 	Tag	String	
Oval 	Visible	Boolean	
Oval 	Width	Integer	
Oval 	X	Integer	
Oval 	Y	Integer	
Picture 	Border	Boolean	
Picture 	BorderStyle	BorderStyle (enumerated)	
Picture 	BringToTop	Boolean	
Picture 	DragAuto	Boolean	
Picture 	DragIcon	String	
Picture 	Enabled	Boolean	
Picture 	FocusRectangle	Boolean	
Picture 	Height	Integer	
Picture 	Invert	Boolean	
Picture 	OriginalSize	Boolean	
Picture 	PictureName	String	
Picture 	Pointer	String	
Picture 	TabOrder	Integer	
Picture 	Tag	String	
Picture 	Visible	Boolean	
Picture 	Width	Integer	
Picture 	X	Integer	
Picture 	Y	Integer	
PictureButton 	HTextAlign	Alignment (enumerated)	
PictureButton 	BringToTop	Boolean	
PictureButton 	Cancel	Boolean	
PictureButton 	Default	Boolean	
PictureButton 	DisabledName	String	
PictureButton 	DragAuto	Boolean	
PictureButton 	DragIcon	String	
PictureButton 	Enabled	Boolean	
PictureButton 	FaceName	String	
PictureButton 	FontCharSet	FontCharSet (enumerated)	
PictureButton 	FontFamily	FontFamily (enumerated)	
PictureButton 	FontPitch	FontPitch (enumerated)	
PictureButton 	Height	Integer	
PictureButton 	Italic	Boolean	
PictureButton 	OriginalSize	Boolean	
PictureButton 	PictureName	String	
PictureButton 	Pointer	String	
PictureButton 	TabOrder	Integer	
PictureButton 	Tag	String	
PictureButton 	Text	String	
PictureButton 	TextSize	Integer	
PictureButton 	Underline	Boolean	
PictureButton 	Visible	Boolean	
PictureButton 	VTextAlign	VTextAlign (enumerated)	
PictureButton 	Weight	Integer	
PictureButton 	Width	Integer	
PictureButton 	X	Integer	
PictureButton 	Y	Integer	
PictureListBox	Accelerator	Integer	
PictureListBox	BackColor	Long	
PictureListBox	Border	Boolean	
PictureListBox	BorderStyle	BorderStyle (enumerated)	
PictureListBox	BringToTop	Boolean	
PictureListBox	DisableNoScroll	Boolean	
PictureListBox	DragAuto	Boolean	
PictureListBox	DragIcon	String	
PictureListBox	Enabled	Boolean	
PictureListBox	ExtendedSelect	Boolean	
PictureListBox	FaceName	String	
PictureListBox	FontCharSet	FontCharSet (enumerated)	
PictureListBox	FontFamily	FontFamily (enumerated)	
PictureListBox	FontPitch	FontPitch (enumerated)	
PictureListBox	Height	Integer	
PictureListBox	HScrollBar	Boolean	
PictureListBox	Italic	Boolean	
PictureListBox	Item[ ]	String	
PictureListBox	ItemPictureIndex[ ]	Integer	
PictureListBox	MultiSelect	Boolean	
PictureListBox	PictureHeight	Integer	
PictureListBox	PictureWidth	Integer	
PictureListBox	PictureMaskColor	Long	
PictureListBox	PictureName[ ]	String	
PictureListBox	Pointer	String	
PictureListBox	RightToLeft	Boolean	
PictureListBox	Sorted	Boolean	
PictureListBox	TabOrder	Integer	
PictureListBox	TabStop[ ]	Integer array	
PictureListBox	Tag	String	
PictureListBox	TextColor	Long	
RadioButton	Automatic	Boolean	
RadioButton	BackColor	Long	
RadioButton	BorderStyle	BorderStyle (enumerated)	
RadioButton	BringToTop	Boolean	
RadioButton	Checked	Boolean	
RadioButton	DragAuto	Boolean	
RadioButton	DragIcon	String	
RadioButton	Enabled	Boolean	
RadioButton	FaceName	String	
RadioButton	FontCharSet	FontCharSet (enumerated)	
RadioButton	FontFamily	FontFamily (enumerated)	
RadioButton	FontPitch	FontPitch (enumerated)	
RadioButton	Height	Integer	
RadioButton	Italic	Boolean	
RadioButton	LeftText	Boolean	
RadioButton	Pointer	String	
RadioButton	RightToLeft	Boolean	
RadioButton	TabOrder	Integer	
RadioButton	Tag	String	
RadioButton	Text	String	
RadioButton	TextColor	Long	
RadioButton	TextSize	Integer	
RadioButton	Underline	Boolean	
RadioButton	Visible	Boolean	
RadioButton	Weight	Integer	
RadioButton	Width	Integer	
RadioButton	X	Integer	
RadioButton	Y	Integer	
Rectangle 	FillColor	Long	
Rectangle 	FillPattern	FillPattern (enumerated)	
Rectangle 	Height	Integer	
Rectangle 	LineColor	Long	
Rectangle 	LineStyle	LineStyle (enumerated)	
Rectangle 	LineThickness	Integer	
Rectangle 	Tag	String	
Rectangle 	Visible	Boolean	
Rectangle 	Width	Integer	
Rectangle 	X	Integer	
Rectangle 	Y	Integer	
RichTextEdit 	Accelerator	Integer	
RichTextEdit 	BackColor	Long	
RichTextEdit 	Border	Boolean	
RichTextEdit 	BorderStyle	BorderStyle (enumerated)	
RichTextEdit 	BottomMargin	Long	
RichTextEdit 	BringToTop	Boolean	
RichTextEdit 	DisplayOnly	Boolean	
RichTextEdit 	DocumentName	String	
RichTextEdit 	DragAuto	Boolean	
RichTextEdit 	DragIcon	String	
RichTextEdit 	Enabled	Boolean	
RichTextEdit 	HeaderFooter	Boolean	
RichTextEdit 	Height	Integer	
RichTextEdit 	HScrollBar	Boolean	
RichTextEdit 	InputFieldBackColor	Long	
RichTextEdit 	InputFieldNamesVisible	Boolean	
RichTextEdit 	InputFieldsVisible	Boolean	
RichTextEdit 	LeftMargin	Long	
RichTextEdit 	Modified	Boolean	
RichTextEdit 	PicturesAsFrame	Boolean	
RichTextEdit 	Pointer	String	
RichTextEdit 	PopMenu	Boolean	
RichTextEdit 	Resizable	Boolean	
RichTextEdit 	ReturnsVisible	Boolean	
RichTextEdit 	RightMargin	Long	
RichTextEdit 	RulerBar	Boolean	
RichTextEdit 	SpacesVisible	Boolean	
RichTextEdit 	TabBar	Boolean	
RichTextEdit 	TabOrder	Integer	
RichTextEdit 	TabsVisible	Boolean	
RichTextEdit 	Tag	String	
RichTextEdit 	ToolBar	Boolean	
RichTextEdit 	TopMargin	Long	
RichTextEdit 	UndoDepth	Integer	
RichTextEdit 	Visible	Boolean	
RichTextEdit 	VScrollBar	Boolean	
RichTextEdit 	Width	Integer	
RichTextEdit 	WordWrap	Boolean	
RichTextEdit 	X	Integer	
RichTextEdit 	Y	Integer	
RoundRectangle 	CornerHeight	Integer	
RoundRectangle 	CornerWidth	Integer	
RoundRectangle 	FillColor	Long	
RoundRectangle 	FillPattern	FillPattern (enumerated)	
RoundRectangle 	Height	Integer	
RoundRectangle 	LineColor	Long	
RoundRectangle 	LineStyle	LineStyle (enumerated)	
RoundRectangle 	LineThickness	Integer	
RoundRectangle 	Tag	String	
RoundRectangle 	Visible	Boolean	
RoundRectangle 	Width	Integer	
RoundRectangle 	X	Integer	
RoundRectangle 	Y	Integer	
SingleLineEdit	Accelerator	Integer	
SingleLineEdit	AutoHScroll	Boolean	
SingleLineEdit	BackColor	Long	
SingleLineEdit	Border	Boolean	
SingleLineEdit	BorderStyle	BorderStyle (enumerated)	
SingleLineEdit	BringToTop	Boolean	
SingleLineEdit	DisplayOnly	Boolean	
SingleLineEdit	DragAuto	Boolean	
SingleLineEdit	DragIcon	String	
SingleLineEdit	Enabled	Boolean	
SingleLineEdit	FaceName	String	
SingleLineEdit	FontCharSet	FontCharSet (enumerated)	
SingleLineEdit	FontFamily	FontFamily (enumerated)	
SingleLineEdit	FontPitch	FontPitch (enumerated)	
SingleLineEdit	Height	Integer	
SingleLineEdit	HideSelection	Boolean	
SingleLineEdit	Italic	Boolean	
SingleLineEdit	Limit	Integer	
SingleLineEdit	Password	Boolean	
SingleLineEdit	Pointer	String	
SingleLineEdit	RightToLeft	Boolean	
SingleLineEdit	TabOrder	Integer	
SingleLineEdit	Tag	String	
SingleLineEdit	Text	String	
SingleLineEdit	TextCase	TextCase (enumerated)	
SingleLineEdit	TextColor	Long	
SingleLineEdit	TextSize	Integer	
SingleLineEdit	Underline	Boolean	
SingleLineEdit	Visible	Boolean	
SingleLineEdit	Weight	Integer	
SingleLineEdit	Width	Integer	
SingleLineEdit	X	Integer	
SingleLineEdit	Y	Integer	
StaticText 	Alignment	Alignment (enumerated)	
StaticText 	BackColor	Long	
StaticText 	Border	Boolean	
StaticText 	BorderColor	Long	
StaticText 	BorderStyle	BorderStyle (enumerated)	
StaticText 	BringToTop	Boolean	
StaticText 	DragAuto	Boolean	
StaticText 	DragIcon	String	
StaticText 	Enabled	Boolean	
StaticText 	FaceName	String	
StaticText 	FillPattern	FillPattern (enumerated)	
StaticText 	FocusRectangle	Boolean	
StaticText 	FontCharSet	FontCharSet (enumerated)	
StaticText 	FontFamily	FontFamily (enumerated)	
StaticText 	FontPitch	FontPitch (enumerated)	
StaticText 	Height	Integer	
StaticText 	Italic	Boolean	
StaticText 	Pointer	String	
StaticText 	RightToLeft	Boolean	
StaticText 	TabOrder	Integer	
StaticText 	Tag	String	
StaticText 	Text	String	
StaticText 	TextColor	Long	
StaticText 	TextSize	Integer	
StaticText 	Underline	Boolean	
StaticText 	Visible	Boolean	
StaticText 	Weight	Integer	
StaticText 	Width	Integer	
StaticText 	X	Integer	
StaticText 	Y	Integer	
Tab	Alignment	Alignment (enumerated)	
Tab	BackColor	Long	
Tab	BoldSelectedText	Boolean	
Tab	BringToTop	Boolean	
Tab	CreateOnDemand	Boolean	
Tab	Control[ ]	UserObject	
Tab	DragAuto	Boolean	
Tab	DragIcon	String	
Tab	Enabled	Boolean	
Tab	FaceName	String	
Tab	FixedWidth	Boolean	
Tab	FocusOnButtonDown	Boolean	
Tab	FontCharSet	FontCharSet (enumerated)	
Tab	FontFamily	FontFamily (enumerated)	
Tab	FontPitch	FontPitch (enumerated)	
Tab	Height	Integer	
Tab	Italic	Boolean	
Tab	Multiline	Boolean	
Tab	PerpendicularText	Boolean	
Tab	PictureOnRight	Boolean	
Tab	Pointer	String	
Tab	PowerTips	Boolean	
Tab	RaggedRight	Boolean	
Tab	SelectedTab	Integer	
Tab	ShowPicture	Boolean	
Tab	ShowText	Boolean	
Tab	TabOrder	Integer	
Tab	TabPosition	TabPosition (enumerated)	
Tab	Tag	String	
Tab	TextSize	Integer	
Tab	Underline	Boolean	
Tab	Visible	Boolean	
Tab	Weight	Integer	
Tab	Width	Integer	
Tab	X	Integer	
Tab	Y	Integer	
TreeView	Accelerator	Integer	
TreeView	BackColor	Long	
TreeView	Border	Boolean 	
TreeView	BorderStyle	BorderStyle (enumerated)	
TreeView	BringToTop	Boolean 	
TreeView	DeleteItems	Boolean 	
TreeView	DisableDragDrop	Boolean 	
TreeView	DragAuto 	Boolean 	
TreeView	DragIcon	String	
TreeView	EditLabels	Boolean 	
TreeView	Enabled	Boolean	
TreeView	FaceName	String	
TreeView	FontCharSet	FontCharSet (enumerated)	
TreeView	FontFamily	FontFamily (enumerated)	
TreeView	FontPitch	FontPitch (enumerated)	
TreeView	HasButtons	Boolean 	
TreeView	HasLines	Boolean 	
TreeView	Height	Integer	
TreeView	HideSelection	Boolean	
TreeView	Indent	Integer	
TreeView	Italic	Boolean	
TreeView	LinesAtRoot	Boolean 	
TreeView	PictureHeight	Integer	
TreeView	PictureMaskColor	Long	
TreeView	PictureName	String	
TreeView	PictureWidth	Integer	
TreeView	Pointer	String	
TreeView	SortType	grSortType	
TreeView	StatePictureHeight	Integer	
TreeView	StatePictureMask- 		
TreeView	Color	Long	
TreeView	StatePictureName	String	
TreeView	StatePictureWidth	Integer	
TreeView	TabOrder	Integer	
TreeView	Tag	String	
TreeView	TextColor	Long	
TreeView	TextSize	Integer	
TreeView	Underline	Boolean	
TreeView	Visible	Boolean	
TreeView	Weight	Integer	
TreeView	Width	Integer	
TreeView	X	Integer	
TreeView	Y	Integer	
UserObject 	BackColor	Long	
UserObject 	Border	Boolean	
UserObject 	BorderStyle	BorderStyle (enumerated)	
UserObject 	BringToTop	Boolean	
UserObject 	ClassName	String	
UserObject 	ColumnsPerPage	Integer	
UserObject 	Control[ ]	WindowObject	
UserObject 	DragAuto	Boolean	
UserObject 	DragIcon	String	
UserObject 	Enabled	Boolean	
UserObject 	Height	Integer	
UserObject 	HScrollBar	Boolean	
UserObject 	LibraryName	String	
UserObject 	LinesPerPage	Integer	
UserObject 	ObjectType	UserObjects (enumerated)	
UserObject 	PictureMaskColor	Long	
UserObject 	PictureName	String	
UserObject 	Pointer	String	
UserObject 	PowerTipText	String	
UserObject 	Style	Long	
UserObject 	TabBackColor	Long	
UserObject 	TabTextColor	Long	
UserObject 	TabOrder	Integer	
UserObject 	Tag	String	
UserObject 	Text	String	
UserObject 	UnitsPerColumn	Integer	
UserObject 	UnitsPerLine	Integer	
UserObject 	Visible	Boolean	
UserObject 	VScrollBar	Boolean	
UserObject 	Width	Integer	
UserObject 	X	Integer	
UserObject 	Y	Integer	
VScrollBar 	BringToTop	Boolean	
VScrollBar 	DragAuto	Boolean	
VScrollBar 	DragIcon	String	
VScrollBar 	Height	Integer	
VScrollBar 	MaxPosition	Integer	
VScrollBar 	MinPosition	Integer	
VScrollBar 	Pointer	String	
VScrollBar 	Position	Integer	
VScrollBar 	StdWidth	Boolean	
VScrollBar 	TabOrder	Integer	
VScrollBar 	Tag	String	
VScrollBar 	Visible	Boolean	
VScrollBar 	Width	Integer	
VScrollBar 	X	Integer	
VScrollBar 	Y	Integer	
Application	AppName	String	
Application	DDETimeOut	Integer	
Application	DisplayName	String	
Application	DWMessageTitle	String	
Application	MicroHelpDefault	String	
Application	RightToLeft	Boolean	
Application	ToolbarFrameTitle	String	
Application	ToolbarPopMenuText	String	
Application	ToolbarSheetTitle	String	
Application	ToolbarText	Boolean	
Application	ToolbarTips	Boolean	
Application	ToolbarUserControl	Boolean	
ArrayBounds 	ClassDefinition	PowerObject	
ArrayBounds 	LowerBound	Long	
ArrayBounds 	UpperBound	Long	
ClassDefinition	Ancestor	ClassDefinition	
ClassDefinition	Category	TypeCategory	
ClassDefinition	ClassDefinition	PowerObject	
ClassDefinition	DataTypeOf	String	
ClassDefinition	IsAutoinstantiate	Boolean	
ClassDefinition	IsStructure	Boolean	
ClassDefinition	IsSystemType	Boolean	
ClassDefinition	IsVariableLength	Boolean	
ClassDefinition	IsVisualType	Boolean	
ClassDefinition	LibraryName	String	
ClassDefinition	Name	String	
ClassDefinition	NestedClassList[ ]	ClassDefinition	
ClassDefinition	ParentClass	ClassDefinition	
ClassDefinition	ScriptList[ ]	ScriptDefinition	
ClassDefinition	VariableList[ ]	VariableDefinition	
Connection	Application	String	
Connection	ConnectString	String	
Connection	Driver	String	
Connection	ErrCode	Long	
Connection	ErrText	String	
Connection	Location	String	
Connection	Options	String	
Connection	Password	String	
Connection	Trace	String	
Connection	UserID	String	
ConnectionInfo 	Busy	Boolean
ConnectionInfo 	CallCount	Long
ConnectionInfo 	ClientID	String
ConnectionInfo 	ConnectTime	DateTime
ConnectionInfo 	ConnectUserID	String
ConnectionInfo 	LastCallTime	DateTime
ConnectionInfo 	Location	String
ConnectionInfo 	UserID	String
ContextInformation	ClassDefinition	PowerObject
ContextKeyword	ClassDefinition	PowerObject
CPlusPlus 	LibraryName	String
DataStore 	DataObject	String	
DataStore 	Object	DWObject	
DynamicDescriptionArea 	NumInputs	Integer	
DynamicDescriptionArea 	NumOutputs	Integer	
DynamicDescriptionArea 	InParmType[ ]	ParmType (enumerated)	
DynamicDescriptionArea 	OutParmType[ ]	ParmType (enumerated)	
EnumerationDefinition	Category 	TypeCategory	
EnumerationDefinition	ClassDefinition	PowerObject	
EnumerationDefinition	DataTypeOf	String	
EnumerationDefinition	Enumeration[ ]	Enumeration-	
EnumerationDefinition	ItemDefinition	An array of the name-value pairs for all the items in the enumeration.	
EnumerationDefinition	IsStructure	Boolean	
EnumerationDefinition	IsSystemType 	Boolean	
EnumerationDefinition	 IsVariableLength	Boolean	
EnumerationDefinition	IsVisualType	Boolean	
EnumerationDefinition	LibraryName	String	
EnumerationDefinition	Name	String	
EnumerationItemDefinition	ClassDefinition	PowerObject	
EnumerationItemDefinition	Name	String	
EnumerationItemDefinition	Value	Long	
Environment	CPUType	CPUTypes (enumerated)	
Environment	MachineCode	Boolean	
Environment	OSFixesRevision	Integer	
Environment	OSMajorRevision	Integer	
Environment	OSMinorRevision	Integer	
Environment	PBFixesRevision	Integer	
Environment	PBMajorRevision	Integer	
Environment	PBMinorRevision	Integer	
Environment	NumberOfColors	Long
Environment	ScreenHeight	Long
Environment	ScreenWidth	Long
Environment	OSType	OSTypes (enumerated)
Environment	PBType	PBTypes (enumerated)
Environment	Win16	Boolean
Error	Line	Integer
Error	Number	Integer
Error	Object	String
Error	ObjectEvent	String
Error	Text	String
Error	WindowMenu	String
grAxis	AutoScale	Boolean
grAxis	DataType	grAxisDataType(enumerated)
grAxis	DisplayAttr	grDispAttr (object)
grAxis	DisplayEveryNLabels	Integer
grAxis	DropLines	LineStyle (enumerated)
grAxis	Frame	LineStyle (enumerated)
grAxis	Label	String
grAxis	LabelDispAttr	grDispAttr (object)
grAxis	MajorDivisions	Integer
grAxis	MajorGridLine	LineStyle (enumerated)
grAxis	MajorTic	grTicType (enumerated)
grAxis	MaximumValue	Double
grAxis	MaxValDateTime	DateTime
grAxis	MinimumValue	Double
grAxis	MinorDivisions	Integer
grAxis	MinorGridLine	LineStyle (enumerated)
grAxis	MinorTic	grTicType (enumerated)
grAxis	MinValDateTime	DateTime
grAxis	OriginLine	LineStyle (enumerated)	
grAxis	PrimaryLine	LineStyle (enumerated)	
grAxis	RoundTo	Double	
grAxis	RoundToUnitTo	grRoundToType (enumerated)	
grAxis	ScaleType	grScaleType (enumerated)	
grAxis	ScaleValue	grScaleValue (enumerated)	
grAxis	SecondaryLine	LineStyle (enumerated)	
grAxis	ShadeBackEdge	Boolean	
grDispAttr	Alignment	Alignment (enumerated)	
grDispAttr	AutoSize	Boolean	
grDispAttr	BackColor	Long	
grDispAttr	DisplayExpression	String	
grDispAttr	Escapement	Integer	
grDispAttr	FaceName	String	
grDispAttr	FillPattern	FillPattern (enumerated)	
grDispAttr	FontCharSet	FontCharSet (enumerated)
grDispAttr	FontFamily	FontFamily (enumerated)
grDispAttr	FontPitch	FontPitch (enumerated)
grDispAttr	Format	String
grDispAttr	Italic	Boolean
grDispAttr	TextColor	Long
grDispAttr	TextSize	Integer
grDispAttr	Underline	Boolean
grDispAttr	Weight	Integer
Inet	ClassDefinition	PowerObject
InternetResult 	lassDefinition	PowerObject
ListViewItem 	CutHighlighted	Boolean 
ListViewItem 	Data	Any
ListViewItem 	DropHighlighted	Boolean 
ListViewItem 	HasFocus	Boolean 
ListViewItem 	ItemX	Integer
ListViewItem 	ItemY	Integer
ListViewItem 	Label	String
ListViewItem 	OverlayPictureIndex	Integer
ListViewItem 	PictureIndex	Integer
ListViewItem 	Selected	Boolean 
ListViewItem 	StatePictureIndex	Integer
mailFileDescription	FileType	mailFileType(enumerated) 
mailFileDescription	Filename	String
mailFileDescription	Pathname	String
mailFileDescription	Position	Unsignedlong
mailMessage 	AttachmentFile[ ]	mailFileDescription
mailMessage 	ConversationID	String
mailMessage 	DateReceived	String
mailMessage 	MessageSent	Boolean
mailMessage 	MessageType	String
mailMessage 	NoteText	String
mailMessage 	ReceiptRequested	Boolean
mailMessage 	Recipient[ ]	mailRecipient
mailMessage 	Subject	String
mailMessage 	Unread	Boolean
mailRecipient 	Address	String
mailRecipient 	EntryID	Blob
mailRecipient 	Name	String
mailRecipient 	RecipientType	mailRecipientType (enumerated)
mailSession 	MessageID[ ]	String
mailSession 	SessionID	Long
MDIClient 	BackColor	Long
MDIClient 	BringToTop	Boolean
MDIClient 	Height	Integer
MDIClient 	MicroHelpHeight	Integer
MDIClient 	Tag	String
MDIClient 	Visible	Boolean
MDIClient 	Width	Integer
MDIClient 	X	Integer
MDIClient 	Y	Integer
Menu	Checked	Boolean
Menu	Enabled	Boolean
Menu	Item[ ]	Menu
Menu	MenuItemType	MenuItemType (enumerated)
Menu	MergeOption	MenuMerge Option (enumerated)	
Menu	MicroHelp	String	
Menu	ParentWindow	Window	
Menu	ShiftToRight	Boolean	
Menu	Shortcut	Integer	
Menu	Tag	String	
Menu	Text	String	
Menu	ToolbarItemDown	Boolean	
Menu	ToolbarItemDownName	String	
Menu	ToolbarItemBarIndex	Integer	
Menu	ToolbarItemName	String	
Menu	ToolbarItemOrder	Integer	
Menu	ToolbarItemSpace	Integer	
Menu	ToolbarItemText	String	
Menu	ToolbarItemVisible	Boolean	
Menu	Visible	Boolean	
MenuCascade 	Checked	Boolean	
MenuCascade 	Columns	Integer	
MenuCascade 	CurrentItem	Menu	
MenuCascade 	DropDown	Boolean	
MenuCascade 	Enabled	Boolean	
MenuCascade 	Item[ ]	Menu	
MenuCascade 	MenuItemType	MenuItemType (enumerated)	
MenuCascade 	MergeOption	MenuMergeOption (enumerated) 	
MenuCascade 	"This and other OLE functions are only available on the Windows platform.? For more information about MergeOption, see the chapter on using OLE in Application Techniques."		
MenuCascade 	MicroHelp	String	
MenuCascade 	ParentWindow	Window	
MenuCascade 	ShiftToRight	Boolean	
MenuCascade 	Shortcut	Integer	
MenuCascade 	Tag	String	
MenuCascade 	Text	String	
MenuCascade 	ToolbarItemDown	Boolean	
MenuCascade 	ToolbarItemDownName	String	
MenuCascade 	ToolbarItemBarIndex	Integer	
MenuCascade 	ToolbarItemName	String	
MenuCascade 	ToolbarItemOrder	Integer	
MenuCascade 	ToolbarItemSpace	Integer	
MenuCascade 	ToolbarItemText	String	
MenuCascade 	ToolbarItemVisible	Boolean	
MenuCascade 	Visible	Boolean	
Message 	Handle	Long	
Message 	Number	UnsignedInt	
Message 	WordParm	Long	
Message 	LongParm	Long	
Message 	DoubleParm	Double	
Message 	StringParm	String	
Message 	PowerObjectParm	PowerObject	
Message 	Processed	Boolean	
Message 	ReturnValue	Long	
OLEStorage 	DocumentName	String	
OLEStream 	Name	String	
OLEStream 	Storage	OMStorage	
Pipeline 	DataObject	String	
Pipeline 	RowsInError	Long	
Pipeline 	RowsRead	Long	
Pipeline 	RowsWritten	Long	
Pipeline 	Syntax	String	
ProfileCall	AbsoluteSelfTime	Decimal	
ProfileCall	AbsoluteTotalTime	Decimal
ProfileCall	CalledRoutine	ProfileRoutine
ProfileCall	CallingLine	ProfileLine
ProfileCall	CallingRoutine	ProfileRoutine
ProfileCall	HitCount	Long 
ProfileCall	PercentCalleeSelfTime	Double 
ProfileCall	PercentCalleeTotalTime	Double
ProfileCall	PercentCallerTotalTime	Double 
ProfileClass 	LibraryName	String
ProfileClass 	Name	String
ProfileLine	AbsoluteSelfTime	Decimal
ProfileLine	AbsoluteTotalTime	Decimal
ProfileLine	HitCount	Long
ProfileLine	LineNumber	Long
ProfileLine	MaxSelfTime	Decimal	
ProfileLine	MaxTotalTime	Decimal	
ProfileLine	MinSelfTime	Decimal	
ProfileLine	MinTotalTime	Decimal	
ProfileLine	PercentSelfTime	Double	
ProfileLine	PercentTotalTime	Double	
ProfileLine	Routine	ProfileRoutine	
ProfileRoutine 	AbsoluteSelfTime	Decimal	
ProfileRoutine 	AbsoluteTotalTime	Decimal	
ProfileRoutine 	Class	ProfileClass	
ProfileRoutine 	HitCount	Long	
ProfileRoutine 	Kind	ProfileRoutineKind (enumerated) 	
ProfileRoutine 	MaxSelfTime	Decimal	
ProfileRoutine 	MaxTotalTime	Decimal	
ProfileRoutine 	MinSelfTime	Decimal	
ProfileRoutine 	MinTotalTime	Decimal	
ProfileRoutine 	Name	String 	
ProfileRoutine 	PercentSelfTime	Double	
ProfileRoutine 	PercentTotalTime	Double	
Profiling	ApplicationName	String	
Profiling	CollectionTime	Decimal	
Profiling	NumberOfActivities	Long	
Profiling	TraceFileName	String	
ScriptDefinition 	Access	VarAccess	
ScriptDefinition 	AliasName	String	
ScriptDefinition 	ArgumentList	VariableDefinition	
ScriptDefinition 	ClassDefinition	PowerObject	
ScriptDefinition 	EventId	Long	
ScriptDefinition 	EventIdName	String	
ScriptDefinition 	ExternalUserFunction	String	
ScriptDefinition 	IsExternalEvent	Boolean	
ScriptDefinition 	IsLocallyDefined	Boolean	
ScriptDefinition 	IsLocallyScripted	Boolean	
ScriptDefinition 	IsRPCFunction	Boolean	
ScriptDefinition 	IsScripted	Boolean	
ScriptDefinition 	Kind	ScriptKind 	
ScriptDefinition 	LocalVariableList	VariableDefinition	
ScriptDefinition 	Name	String	
ScriptDefinition 	ReturnType	TypeDefinition	
ScriptDefinition 	Source	String	
ScriptDefinition 	SystemFunction	String	
TraceActivityNode	ActivityType	TraceActivity (enumerated)	
TraceActivityNode	Category	TraceCategory (enumerated)	
TraceActivityNode	TimerValue	Decimal	
TraceBeginEnd	ActivityType	TraceActivity (enumerated)
TraceBeginEnd	Category	TraceCategory (enumerated)
TraceBeginEnd	Message	String
TraceBeginEnd	TimerValue	Decimal
TraceError	ActivityType	TraceActivity (enumerated)
TraceError	Category	TraceCategory (enumerated)
TraceError	Message	String
TraceError	Severity	Long
TraceError	TimerValue	Decimal
TraceESQL 	ActivityNode	TraceActivity
TraceESQL 	Category	TraceCategory
TraceESQL 	Name	String
TraceESQL 	TimerValue	Decimal
TraceFile	ApplicationName	String	
TraceFile	CollectionTime	Decimal	
TraceFile	LastError	ErrorReturn (enumerated)	
TraceFile	NumberOfActivities	Long	
TraceFile	FileName	String	
TraceGarbageCollect	ActivityType	TraceActivity (enumerated)	
TraceGarbageCollect	Category	TraceCategory (enumerated)	
TraceGarbageCollect	TimerValue	Decimal	
TraceLine	ActivityType	TraceActivity (enumerated)	
TraceLine	Category	TraceCategory (enumerated)	
TraceLine	LineNumber	UnsignedLong	
TraceLine	TimerValue	Decimal	
TraceObject	ActivityType	TraceActivity (enumerated)
TraceObject	Category	TraceCategory (enumerated)
TraceObject	ClassName	String
TraceObject	IsCreate	Boolean
TraceObject	LibraryName	String
TraceObject	ObjectID	UnsignedLong
TraceObject	TimerValue	Decimal
TraceRoutine	ActivityType	TraceActivity (enumerated)
TraceRoutine	Category	TraceCategory (enumerated)
TraceRoutine	ClassName	String
TraceRoutine	IsEvent	Boolean
TraceRoutine	LibraryName	String
TraceRoutine	Name	String
TraceRoutine	ObjectID	UnsignedLong
TraceRoutine	TimerValue	Decimal
TraceTree	ApplicationName	String	
TraceTree	CollectionTime	Decimal	
TraceTree	NumberOfActivities	Long	
TraceTree	TraceFileName	String	
TraceTreeError	ActivityType	TraceActivity (enumerated)	
TraceTreeError	Message	String	
TraceTreeError	ParentNode	TraceTreeNode	
TraceTreeError	Severity	Long	
TraceTreeError	TimerValue	Decimal	
TraceTreeESQL 	ActivityNode	TraceActivity (enumerated)	
TraceTreeESQL 	EnterTimerValue	Decimal	
TraceTreeESQL 	ExitTimerValue	Decimal	
TraceTreeESQL 	Name	String	
TraceTreeESQL 	ParentNode	TraceTreeNode	
TraceTreeGarbageCollect 	ActivityType	TraceActivity (enumerated)	
TraceTreeGarbageCollect 	EnterTimerValue	Decimal	
TraceTreeGarbageCollect 	ExitTimerValue	Decimal	
TraceTreeGarbageCollect 	ParentNode	TraceTreeNode	
TraceTreeLine 	ActivityType	TraceActivity (enumerated)	
TraceTreeLine 	LineNumber	UnsignedLong	
TraceTreeLine 	ParentNode	TraceTreeNode	
TraceTreeLine 	TimerValue	Decimal	
TraceTreeNode 	ActivityType	TraceActivity (enumerated)	
TraceTreeNode 	ParentNode	TraceTreeNode	
TraceTreeObject 	ActivityType	TraceActivity (enumerated)	
TraceTreeObject 	ClassName	String
TraceTreeObject 	Create	Boolean
TraceTreeObject 	EnterTimerValue	Decimal
TraceTreeObject 	ExitTimerValue	Decimal 
TraceTreeObject 	LibraryName	String
TraceTreeObject 	ObjectID	UnsignedLong
TraceTreeObject 	ParentNode	TraceTreeNode
TraceTreeRoutine	ActivityType	TraceActivity (enumerated)
TraceTreeRoutine	ClassName	String
TraceTreeRoutine	EnterTimerValue	Decimal
TraceTreeRoutine	ExitTimerValue	Decimal
TraceTreeRoutine	IsEvent	Boolean
TraceTreeRoutine	LibraryName	String
TraceTreeRoutine	Name	String
TraceTreeRoutine	ObjectID	UnsignedLong
TraceTreeRoutine	ParentNode	TraceTreeNode
TraceTreeUser 	ActivityType	TraceActivity (enumerated)
TraceTreeUser 	Argument	Long
TraceTreeUser 	Message	String
TraceTreeUser 	ParentNode	TraceTreeNode
TraceTreeUser 	TimerValue	Decimal
TraceUser	ActivityType	TraceActivity (enumerated)
TraceUser	Argument	Long
TraceUser	Category	TraceCategory (enumerated)
TraceUser	Message	String
TraceUser	TimerValue	Decimal
Timing 	ClassDefinition	PowerObject
Timing 	Interval	Double
Timing 	Running	Boolean
Transaction 	AutoCommit	Boolean
Transaction 	Database	String
Transaction 	DBMS	String
Transaction 	DBParm	String
Transaction 	DBPass	String
Transaction 	Lock	String
Transaction 	LogID	String
Transaction 	LogPass	String
Transaction 	ServerName	String
Transaction 	SQLCode	Long
Transaction 	SQLDBCode	Long
Transaction 	SQLErrText	String
Transaction 	SQLNRows	Long
Transaction 	SQLReturnData	String
Transaction 	UserID	String	
Transport 	Application	String	
Transport 	Driver	String	
Transport 	ErrCode	Long	
Transport 	ErrText	String	
Transport 	Location	String	
Transport 	Options	String	
Transport 	TimeOut	Long	
Transport 	Trace	String	
TreeViewItem	Bold	Boolean 	
TreeViewItem	Children	Boolean 	
TreeViewItem	CutHighLighted	Boolean 	
TreeViewItem	Data	Any	
TreeViewItem	DropHighLighted	Boolean 	
TreeViewItem	Expanded	Boolean 
TreeViewItem	ExpandedOnce	Boolean 
TreeViewItem	HasFocus	Boolean 
TreeViewItem	ItemHandle	Long
TreeViewItem	Label	Label
TreeViewItem	Level	Integer
TreeViewItem	OverlayPictureIndex	Integer
TreeViewItem	PictureIndex	Integer
TreeViewItem	SelectedPictureIndex	Integer
TreeViewItem	Selected	Boolean 
TreeViewItem	StatePictureIndex	Integer
TypeDefinition 	Category 	TypeCategory
TypeDefinition 	ClassDefinition	PowerObject
TypeDefinition 	DataTypeOf	String
TypeDefinition 	IsStructure	Boolean
TypeDefinition 	IsSystemType	Boolean	
TypeDefinition 	IsVariableLength	Boolean	
TypeDefinition 	IsVisualType	Boolean	
TypeDefinition 	LibraryName	String	
TypeDefinition 	Name	String	
UserObject	BackColor	Long	
UserObject	Border	Boolean	
UserObject	BorderStyle	BorderStyle (enumerated)	
UserObject	BringToTop	Boolean	
UserObject	ClassName	String	
UserObject	ColumnsPerPage	Integer	
UserObject	Control[ ]	WindowObject	
UserObject	DragAuto	Boolean	
UserObject	DragIcon	String	
UserObject	Enabled	Boolean	
UserObject	Height	Integer	
UserObject	HScrollBar	Boolean	
UserObject	LibraryName	String	
UserObject	LinesPerPage	Integer	
UserObject	ObjectType	UserObjects (enumerated)	
UserObject	PictureMaskColor	Long	
UserObject	PictureName	String	
UserObject	Pointer	String	
UserObject	PowerTipText	String	
UserObject	Style	Long	
UserObject	TabBackColor	Long	
UserObject	TabTextColor	Long	
UserObject	TabOrder	Integer	
UserObject	Tag	String	
UserObject	Text	String	
UserObject	UnitsPerColumn	Integer	
UserObject	UnitsPerLine	Integer	
UserObject	Visible	Boolean	
UserObject	VScrollBar	Boolean	
UserObject	Width	Integer	
UserObject	X	Integer	
UserObject	Y	Integer	
VariableCardinality 	ArrayDefinition[ ]	ArrayBounds	
VariableCardinality 	Cardinality	VariableCardinalityType	
VariableCardinality 	ClassDefinition	PowerObject	
VariableDefinition 	CallingConvention	ArgCallingConvention	
VariableDefinition 	Cardinality	VariableCardinalityDefinition	
VariableDefinition 	ClassDefinition	PowerObject	
VariableDefinition 	InitialValue	Any	
VariableDefinition 	IsConstant	Boolean	
VariableDefinition 	IsControl	Boolean	
VariableDefinition 	IsUserDefined	Boolean	
VariableDefinition 	Kind	VariableKind	
VariableDefinition 	Name	String	
VariableDefinition 	OverridesAncestorValue	Boolean	
VariableDefinition 	ReadAccess	VarAccess	
VariableDefinition 	TypeInfo	TypeDefinition	
VariableDefinition 	WriteAccess	VarAccess	
Window	BackColor	Long	
Window	Border	Boolean	
Window	BringToTop	Boolean	
Window	ColumnsPerPage	Integer	
Window	Control[ ]	WindowObject	
Window	ControlMenu	Boolean	
Window	Enabled	Boolean	
Window	Height	Integer	
Window	HScrollBar	Boolean	
Window	Icon	String	
Window	KeyboardIcon	Boolean	
Window	LinesPerPage	Integer	
Window	MaxBox	Boolean	
Window	MenuID	Menu	
Window	MenuName	String	
Window	MinBox	Boolean	
Window	Pointer	String	
Window	Resizable	Boolean	
Window	RightToLeft	Boolean	
Window	Tag	String	
Window	Title	String	
Window	TitleBar	Boolean	
Window	ToolbarAlignment	ToolbarAlignment (enumerated) 	
Window	ToolbarHeight	Integer	
Window	ToolbarVisible	Boolean	
Window	ToolbarWidth	Integer	
Window	ToolbarX	Integer	
Window	ToolbarY	Integer	
Window	UnitsPerColumn	Integer	
Window	UnitsPerLine	Integer	
Window	Visible	Boolean	
Window	VScrollBar	Boolean	
Window	Width	Integer	
Window	WindowState	WindowState (enumerated)	
Window	WindowType	WindowType (enumerated)	
Window	X	Integer	
Window	Y	Integer	
----------------------------------------------------------------*/
/*----------------------------------------------------------------
PowerBuilder Object Events
------------------------------------------------------------------
CheckBox	Clicked	  
CheckBox	Constructor	  
CheckBox	Destructor	  
CheckBox	DragDrop	  
CheckBox	DragEnter	  
CheckBox	DragLeave	  
CheckBox	DragWithin	  
CheckBox	GetFocus	  
CheckBox	LoseFocus	  
CheckBox	Other	  
CheckBox	RButtonDown	  
CommandButton	Clicked	  
CommandButton	Constructor	  
CommandButton	Destructor	  
CommandButton	DragDrop	  
CommandButton	DragEnter	  
CommandButton	DragLeave	  
CommandButton	DragWithin	  
CommandButton	GetFocus	  
CommandButton	LoseFocus	  
CommandButton	Other	  
CommandButton	RButtonDown	  
DataWindow 	Clicked	  
DataWindow 	Constructor	  
DataWindow 	DBError	  
DataWindow 	Destructor	  
DataWindow 	DoubleClicked	  
DataWindow 	DragDrop	  
DataWindow 	DragEnter	  
DataWindow 	DragLeave	  
DataWindow 	DragWithin	  
DataWindow 	EditChanged	  
DataWindow 	Error	  
DataWindow 	GetFocus	  
DataWindow 	ItemChanged	  
DataWindow 	ItemError	  
DataWindow 	ItemFocusChanged	  
DataWindow 	LoseFocus	  
DataWindow 	Other	  
DataWindow 	PrintEnd	  
DataWindow 	PrintPage	  
DataWindow 	PrintStart	  
DataWindow 	RButtonDown	  
DataWindow 	Resize	  
DataWindow 	RetrieveEnd	  
DataWindow 	RetrieveRow	  
DataWindow 	RetrieveStart	  
DataWindow 	RowFocusChanged	  
DataWindow 	ScrollHorizontal	  
DataWindow 	ScrollVertical	  
DataWindow 	SQLPreview	  
DataWindow 	UpdateEnd	  
DataWindow 	UpdateStart	  
DropDownListBox	Constructor	  
DropDownListBox	Destructor	  
DropDownListBox	DoubleClicked	  
DropDownListBox	DragDrop	  
DropDownListBox	DragEnter	  
DropDownListBox	DragLeave	  
DropDownListBox	DragWithin	  
DropDownListBox	GetFocus	  
DropDownListBox	LoseFocus	  
DropDownListBox	Modified	  
DropDownListBox	Other	  
DropDownListBox	RButtonDown	  
DropDownListBox	SelectionChanged	  
DropDownPicture	Constructor	  
DropDownPicture	Destructor	  
DropDownPicture	DoubleClicked	  
DropDownPicture	DragDrop	  
DropDownPicture	DragEnter	  
DropDownPicture	DragLeave	  
DropDownPicture	DragWithin	  
DropDownPicture	GetFocus	  
DropDownPicture	LoseFocus	  
DropDownPicture	Modified	  
DropDownPicture	Other	  
DropDownPicture	RButtonDown	  
DropDownPicture	SelectionChanged	  
EditMask	Constructor	  
EditMask	Destructor	  
EditMask	DragDrop	  
EditMask	DragEnter	  
EditMask	DragLeave	  
EditMask	DragWithin	  
EditMask	GetFocus	  
EditMask	LoseFocus	  
EditMask	Modified	  
EditMask	Other	  
EditMask	RButtonDown	  
Graph	Clicked	  
Graph	Constructor	  
Graph	Destructor	  
Graph	DoubleClicked	  
Graph	DragDrop	  
Graph	DragEnter	  
Graph	DragLeave	  
Graph	DragWithin	  
Graph	GetFocus	  
Graph	LoseFocus	  
Graph	Other	  
Graph	RButtonDown	  
HScrollBar	Constructor	  
HScrollBar	Destructor	  
HScrollBar	DragDrop	  
HScrollBar	DragEnter	  
HScrollBar	DragLeave	  
HScrollBar	DragWithin	  
HScrollBar	GetFocus	  
HScrollBar	LineLeft	  
HScrollBar	LineRight	  
HScrollBar	LoseFocus	  
HScrollBar	Moved	  
HScrollBar	Other	  
HScrollBar	PageLeft	  
HScrollBar	PageRight	  
HScrollBar	RButtonDown	  
ListBox 	Constructor	  
ListBox 	Destructor	  
ListBox 	DoubleClicked	  
ListBox 	DragDrop	  
ListBox 	DragEnter	  
ListBox 	DragLeave	  
ListBox 	DragWithin	  
ListBox 	GetFocus	  
ListBox 	LoseFocus	  
ListBox 	Other	  
ListBox 	RButtonDown	  
ListBox 	SelectionChanged	  
ListView	BeginDrag	  
ListView	BeginLabelEdit	  
ListView	BeginRightDrag	  
ListView	Clicked	  
ListView	ColumnClick	  
ListView	Constructor	  
ListView	DeleteAllItems	  
ListView	DeleteItem	  
ListView	Destructor	  
ListView	DoubleClicked	  
ListView	DragDrop	  
ListView	DragEnter	  
ListView	DragLeave	  
ListView	DragWithin	  
ListView	EndLabelEdit	  
ListView	GetFocus	  
ListView	InsertItem	  
ListView	ItemChanged	  
ListView	ItemChanging	  
ListView	Key	  
ListView	LoseFocus	  
ListView	Other	  
ListView	RightClicked	  
ListView	RightDoubleClicked	  
ListView	Sort	  
MultiLineEdit 	Constructor	  
MultiLineEdit 	Destructor	  
MultiLineEdit 	DragDrop	  
MultiLineEdit 	DragEnter	  
MultiLineEdit 	DragLeave	  
MultiLineEdit 	DragWithin	  
MultiLineEdit 	GetFocus	  
MultiLineEdit 	LoseFocus	  
MultiLineEdit 	Modified	  
MultiLineEdit 	Other	  
MultiLineEdit 	RButtonDown	  
OLEControl 	Clicked	  
OLEControl 	Close	  
OLEControl 	Constructor	  
OLEControl 	DataChange	  
OLEControl 	Destructor	  
OLEControl 	DoubleClicked	  
OLEControl 	DragDrop	  
OLEControl 	DragEnter	  
OLEControl 	DragLeave	  
OLEControl 	DragWithin	  
OLEControl 	Error	  
OLEControl 	ExternalException	  
OLEControl 	GetFocus	  
OLEControl 	LoseFocus	  
OLEControl 	Other	  
OLEControl 	PropertyChanged	  
OLEControl 	PropertyRequestEdit	  
OLEControl 	RButtonDown	  
OLEControl 	Rename	  
OLEControl 	Save	  
OLEControl 	ViewChange	  
OLECustomControl 	Clicked	  
OLECustomControl 	Constructor	  
OLECustomControl 	DataChange	  
OLECustomControl 	Destructor	  
OLECustomControl 	DoubleClicked	  
OLECustomControl 	DragDrop	  
OLECustomControl 	DragEnter	  
OLECustomControl 	DragLeave	  
OLECustomControl 	DragWithin	  
OLECustomControl 	Error	  
OLECustomControl 	ExternalException	  
OLECustomControl 	GetFocus	  
OLECustomControl 	LoseFocus	  
OLECustomControl 	Other	  
OLECustomControl 	PropertyChanged	  
OLECustomControl 	PropertyRequestEdit	  
OLECustomControl 	RButtonDown	  
Picture 	Clicked	  
Picture 	Constructor	  
Picture 	Destructor	  
Picture 	DoubleClicked	  
Picture 	DragDrop	  
Picture 	DragEnter	  
Picture 	DragLeave	  
Picture 	DragWithin	  
Picture 	GetFocus	  
Picture 	LoseFocus	  
Picture 	Other	  
Picture 	RButtonDown	  
PictureButton 	Clicked	  
PictureButton 	Constructor	  
PictureButton 	Destructor	  
PictureButton 	DragDrop	  
PictureButton 	DragEnter	  
PictureButton 	DragLeave	  
PictureButton 	DragWithin	  
PictureButton 	GetFocus	  
PictureButton 	LoseFocus	  
PictureButton 	Other	  
PictureButton 	RButtonDown	  
PictureListBox	Constructor	  
PictureListBox	Destructor	  
PictureListBox	DoubleClicked	  
PictureListBox	DragDrop	  
PictureListBox	DragEnter	  
PictureListBox	DragLeave	  
PictureListBox	DragWithin	  
PictureListBox	GetFocus	  
PictureListBox	LoseFocus	  
PictureListBox	Other	  
PictureListBox	RButtonDown	  
PictureListBox	SelectionChanged	  
RadioButton	Clicked	  
RadioButton	Constructor	  
RadioButton	Destructor	  
RadioButton	DragDrop	  
RadioButton	DragEnter	  
RadioButton	DragLeave	  
RadioButton	DragWithin	  
RadioButton	GetFocus	  
RadioButton	LoseFocus	  
RadioButton	Other	  
RadioButton	RButtonDown	  
RichTextEdit 	Constructor	  
RichTextEdit 	Destructor	  
RichTextEdit 	DoubleClicked	  
RichTextEdit 	DragDrop	  
RichTextEdit 	DragEnter	  
RichTextEdit 	DragLeave	  
RichTextEdit 	DragWithin	  
RichTextEdit 	FileExists	  
RichTextEdit 	GetFocus	  
RichTextEdit 	InputFieldSelected	  
RichTextEdit 	Key	  
RichTextEdit 	LoseFocus	  
RichTextEdit 	Modified	  
RichTextEdit 	MouseDown	  
RichTextEdit 	MouseMove	  
RichTextEdit 	MouseUp	  
RichTextEdit 	Other	  
RichTextEdit 	PictureSelected	  
RichTextEdit 	PrintFooter	  
RichTextEdit 	PrintHeader	  
RichTextEdit 	RButtonDown	  
RichTextEdit 	RButtonUp	  
SingleLineEdit	Constructor	  
SingleLineEdit	Destructor	  
SingleLineEdit	DragDrop	  
SingleLineEdit	DragEnter	  
SingleLineEdit	DragLeave	  
SingleLineEdit	DragWithin	  
SingleLineEdit	GetFocus	  
SingleLineEdit	LoseFocus	  
SingleLineEdit	Modified	  
SingleLineEdit	Other	  
SingleLineEdit	RButtonDown	  
StaticText 	Clicked	  
StaticText 	Constructor	  
StaticText 	Destructor	  
StaticText 	DoubleClicked	  
StaticText 	DragDrop	  
StaticText 	DragEnter	  
StaticText 	DragLeave	  
StaticText 	DragWithin	  
StaticText 	GetFocus	  
StaticText 	LoseFocus	  
StaticText 	Other	  
StaticText 	RButtonDown	  
Tab	Clicked	  
Tab	Constructor	  
Tab	Destructor	  
Tab	DoubleClicked	  
Tab	DragDrop	  
Tab	DragEnter	  
Tab	DragLeave	  
Tab	DragWithin	  
Tab	GetFocus	  
Tab	Key	  
Tab	LoseFocus	  
Tab	Other	  
Tab	RightClicked	  
Tab	RightDoubleClicked	  
Tab	SelectionChanged	  
Tab	SelectionChanging	  
TreeView	BeginDrag	  
TreeView	BeginLabelEdit	  
TreeView	BeginRightDrag	  
TreeView	Clicked	  
TreeView	Constructor	  
TreeView	DeleteItem	  
TreeView	Destructor	  
TreeView	DoubleClicked	  
TreeView	DragDrop	  
TreeView	DragEnter	  
TreeView	DragLeave	  
TreeView	DragWithin	  
TreeView	EndLabelEdit	  
TreeView	GetFocus	  
TreeView	ItemCollapsed	  
TreeView	ItemCollapsing	  
TreeView	ItemExpanded	  
TreeView	ItemExpanding	  
TreeView	ItemPopulate	  
TreeView	Key	  
TreeView	LoseFocus	  
TreeView	Other	  
TreeView	RightClicked	  
TreeView	RightDoubleClicked	  
TreeView	SelectionChanged	  
TreeView	SelectionChanging	  
TreeView	Sort	  
UserObject 	Constructor	  
UserObject 	Destructor	  
UserObject 	DragDrop	  
UserObject 	DragEnter	  
UserObject 	DragLeave	  
UserObject 	DragWithin	  
UserObject 	Other	  
UserObject 	RButtonDown	  
VScrollBar 	Constructor	  
VScrollBar 	Destructor	  
VScrollBar 	DragDrop	  
VScrollBar 	DragEnter	  
VScrollBar 	DragLeave	  
VScrollBar 	DragWithin	  
VScrollBar 	GetFocus	  
VScrollBar 	LineDown	  
VScrollBar 	LineUp	  
VScrollBar 	LoseFocus	  
VScrollBar 	Moved	  
VScrollBar 	Other	  
VScrollBar 	PageDown	  
VScrollBar 	PageUp	  
VScrollBar 	RButtonDown	  
Application	Close	  
Application	ConnectionBegin	  
Application	ConnectionEnd	  
Application	Idle	  
Application	Open	  
Application	SystemError	  
Connection	Constructor	  
Connection	Destructor	  
Connection	Error	  
ContextInformation	Constructor	  
ContextInformation	Destructor	  
ContextKeyword	Constructor	  
ContextKeyword	Destructor	  
CPlusPlus 	Constructor	  
CPlusPlus 	Destructor	  
DataStore 	Constructor	  
DataStore 	DBError	  
DataStore 	Destructor	  
DataStore 	Error	  
DataStore 	ItemChanged	  
DataStore 	ItemError	  
DataStore 	PrintEnd	  
DataStore 	PrintPage	  
DataStore 	PrintStart	  
DataStore 	RetrieveEnd	  
DataStore 	RetrieveRow	  
DataStore 	RetrieveStart	  
DataStore 	SQLPreview	  
DataStore 	UpdateEnd	  
DataStore 	UpdateStart	  
DynamicDescriptionArea 	Constructor	  
DynamicDescriptionArea 	Destructor	  
Error	Constructor	  
Error	Destructor	  
Inet	Constructor	  
Inet	Destructor	  
InternetResult 	Constructor	  
InternetResult 	Destructor	  
mailSession 	Constructor	  
mailSession 	Destructor	  
Menu	Clicked	  
Menu	Selected	  
MenuCascade 	Clicked	  
MenuCascade 	Selected	  
Message 	Constructor	  
Message 	Destructor	  
OLEObject 	Constructor	  
OLEObject 	Destructor	  
OLEObject 	Error	  
OLEObject 	ExternalException	  
OLEStorage 	Constructor	  
OLEStorage 	Destructor	  
OLEStream 	Constructor	  
OLEStream 	Destructor	  
Pipeline 	Constructor	  
Pipeline 	Destructor	  
Pipeline 	PipeEnd	  
Pipeline 	PipeMeter	  
Pipeline 	PipeStart	  
Timing 	Constructor	  
Timing 	Destructor	  
Timing 	Timer	  
Transaction 	Constructor	  
Transaction 	Destructor	  
UserObject	Constructor	  
UserObject	Destructor	  
UserObject	DragDrop	  
UserObject	DragEnter	  
UserObject	DragLeave	  
UserObject	DragWithin	  
UserObject	Other	  
UserObject	RButtonDown	  
Window	Activate	  
Window	Clicked	  
Window	Close 	  
Window	CloseQuery	  
Window	Deactivate	  
Window	DoubleClicked	  
Window	DragDrop	  
Window	DragEnter	  
Window	DragLeave	  
Window	DragWithin	  
Window	Hide 	  
Window	HotLinkAlarm	  
Window	Key	  
Window	MouseDown	  
Window	MouseMove	  
Window	MouseUp	  
Window	Open 	  
Window	Other	  
Window	RButtonDown	  
Window	RemoteExec	  
Window	RemoteHotLinkStart	  
Window	RemoteHotLinkStop	  
Window	RemoteRequest	  
Window	RemoteSend	  
Window	Resize	  
Window	Show	  
Window	SystemKey	  
Window	Timer	  
Window	ToolbarMoved	  
SystemEvent	HotLinkAlarm	  
SystemEvent	RemoteExec	  
SystemEvent	RemoteHotLinkStart	  
SystemEvent	RemoteHotLinkStop	  
SystemEvent	RemoteRequest	  
SystemEvent	RemoteSend	  
----------------------------------------------------------------*/


DataWindow 	DeletedCount	Long	
DataWindow 	DeleteRow	Integer	
DataWindow 	Describe	String	
DataWindow 	Drag	Integer	
DataWindow 	Filter	Integer	
DataWindow 	FilteredCount	Integer	
DataWindow 	Find	Long	
DataWindow 	FindCategory	Integer	
DataWindow 	FindGroupChange	Long	
DataWindow 	FindNext	Integer	
DataWindow 	FindRequired	Integer
DataWindow 	FindSeries	Integer
DataWindow 	GenerateHTMLForm	Integer
DataWindow 	GetBandAtPointer	String
DataWindow 	GetBorderStyle	Border (enumerated)
DataWindow 	GetChanges	Long
DataWindow 	GetChild	Integer
DataWindow 	GetClickedColumn	Integer
DataWindow 	GetClickedRow	Long
DataWindow 	GetColumn	Integer
DataWindow 	GetColumnName	String
DataWindow 	GetContextService	Integer
DataWindow 	GetData	Double
DataWindow 	GetDataPieExplode	Integer
DataWindow 	GetDataStyle	Integer
DataWindow 	GetDataValue	Integer
DataWindow 	GetFormat	String
DataWindow 	GetFullState	Long
DataWindow 	GetItemDate	Date
DataWindow 	GetItemDateTime	DateTime
DataWindow 	GetItemDecimal	Decimal
DataWindow 	GetItemNumber	Double
DataWindow 	GetItemStatus	dwItemStatus (enumerated)
DataWindow 	GetItemString	String
DataWindow 	GetItemTime	Time
DataWindow 	GetMessageText	String
DataWindow 	GetNextModified	Long
DataWindow 	GetObjectAtPointer	String
DataWindow 	GetParent	PowerObject
DataWindow 	GetRow	Long
DataWindow 	GetSelectedRow	Integer
DataWindow 	GetSeriesStyle	Integer
DataWindow 	GetSQLPreview	String	
DataWindow 	GetSQLSelect	String	
DataWindow 	GetStateStatus	Long	
DataWindow 	GetText	String	
DataWindow 	GetTrans	Integer	
DataWindow 	GetUpdateStatus	Integer	
DataWindow 	GetValidate	String	
DataWindow 	GetValue	String	
DataWindow 	GroupCalc	Integer	
DataWindow 	Hide	Integer	
DataWindow 	ImportClipboard 	Long	
DataWindow 	ImportFile 	Long	
DataWindow 	ImportString	Long	
DataWindow 	InsertDocument	Integer	
DataWindow 	InsertRow	Long	
DataWindow 	IsSelected	Boolean	
DataWindow 	LineCount	Integer	
DataWindow 	ModifiedCount	Long	
DataWindow 	Modify	String	
DataWindow 	Move	Integer	
DataWindow 	ObjectAtPointer	grObjectType	
DataWindow 	OLEActivate	Integer	
DataWindow 	Paste	Integer	
DataWindow 	PasteRTF	Long	
DataWindow 	PointerX	Integer	
DataWindow 	PointerY	Integer	
DataWindow 	Position	Integer	
DataWindow 	PostEvent	Boolean	
DataWindow 	Print	Integer	
DataWindow 	PrintCancel	Integer	
DataWindow 	ReplaceText	Integer	
DataWindow 	ReselectRow	Integer	
DataWindow 	Reset	Integer	
DataWindow 	ResetDataColors	Integer	
DataWindow 	ResetTransObject	Integer	
DataWindow 	ResetUpdate	Integer	
DataWindow 	Resize	Integer	
DataWindow 	Retrieve	Long	
DataWindow 	RowCount	Long	
DataWindow 	RowsCopy	Integer	
DataWindow 	RowsDiscard	Integer	
DataWindow 	RowsMove	Integer	
DataWindow 	SaveAs	Integer	
DataWindow 	SaveAsAscii	Long	
DataWindow 	Scroll	Integer	
DataWindow 	ScrollNextPage	Long	
DataWindow 	ScrollNextRow	Long	
DataWindow 	ScrollPriorPage	Long	
DataWindow 	ScrollPriorRow	Long	
DataWindow 	ScrollToRow	Integer	
DataWindow 	SelectedLength	Integer	
DataWindow 	SelectedLine	Integer	
DataWindow 	SelectedStart	Integer	
DataWindow 	SelectedText	String	
DataWindow 	SelectRow	Integer	
DataWindow 	SelectText	Integer	
DataWindow 	SelectTextAll	Integer	
DataWindow 	SelectTextLine	Integer	
DataWindow 	SelectTextWord	Integer	
DataWindow 	SeriesCount	Integer	
DataWindow 	SeriesName	String	
DataWindow 	SetActionCode	Integer	
DataWindow 	SetBorderStyle	Integer	
DataWindow 	SetChanges	Long	
DataWindow 	SetColumn	Integer	
DataWindow 	SetDataPieExplode	Integer	
DataWindow 	SetDataStyle	Integer	
DataWindow 	SetDetailHeight	Integer	
DataWindow 	SetFilter	Integer	
DataWindow 	SetFocus	Integer	
DataWindow 	SetFormat	Integer	
DataWindow 	SetFullState	Long	
DataWindow 	SetItem	Integer	
DataWindow 	SetItemStatus	Integer	
DataWindow 	SetPosition	Integer	
DataWindow 	SetRedraw	Integer	
DataWindow 	SetRow	Integer	
DataWindow 	SetRowFocusIndicator	Integer	
DataWindow 	SetSeriesStyle	Integer	
DataWindow 	SetSort	Integer	
DataWindow 	SetSQLPreview	Integer
DataWindow 	SetSQLSelect	Integer
DataWindow 	SetTabOrder	Integer
DataWindow 	SetText	Integer
DataWindow 	SetTrans	Integer
DataWindow 	SetTransObject	Integer
DataWindow 	SetValidate	Integer
DataWindow 	SetValue	Integer
DataWindow 	ShareData	Integer
DataWindow 	ShareDataOff	Integer
DataWindow 	Show	Integer
DataWindow 	ShowHeadFoot	Integer
DataWindow 	Sort	Integer
DataWindow 	TextLine	String
DataWindow 	TriggerEvent	Integer
DataWindow 	TypeOf	Object
DataWindow 	Undo	Integer
DataWindow 	Update	Integer
DropDownListBox	AddItem	Integer
DropDownListBox	ClassName	String
DropDownListBox	Clear	Integer
DropDownListBox	Copy	Integer
DropDownListBox	Cut	Integer
DropDownListBox	DeleteItem	Integer
DropDownListBox	DirList	Boolean
DropDownListBox	DirSelect	Boolean
DropDownListBox	Drag	Integer
DropDownListBox	FindItem	Integer
DropDownListBox	GetContextService	Integer
DropDownListBox	GetParent	PowerObject
DropDownListBox	Hide	Integer
DropDownListBox	InsertItem	Integer
DropDownListBox	Move	Integer
DropDownListBox	Paste	Integer
DropDownListBox	PointerX	Integer
DropDownListBox	PointerY	Integer
DropDownListBox	Position	Integer
DropDownListBox	PostEvent	Boolean
DropDownListBox	Print	Integer
DropDownListBox	ReplaceText	Integer
DropDownListBox	Reset	Integer
DropDownListBox	Resize	Integer
DropDownListBox	SelectedLength	Integer
DropDownListBox	SelectedStart	Integer
DropDownListBox	SelectedText	String
DropDownListBox	SelectItem	Integer
DropDownListBox	SelectText	Integer
DropDownListBox	SetFocus	Integer
DropDownListBox	SetPosition	Integer
DropDownListBox	SetRedraw	Integer
DropDownListBox	Show	Integer
DropDownListBox	Text	String
DropDownListBox	TotalItems	Integer
DropDownListBox	TriggerEvent	Integer
DropDownListBox	TypeOf	Control
DropDownPicture	AddItem	Integer
DropDownPicture	AddPicture	Integer
DropDownPicture	ClassName	String
DropDownPicture	Clear	Integer
DropDownPicture	Copy	Integer
DropDownPicture	Cut	Integer
DropDownPicture	DeleteItem	Integer
DropDownPicture	DeletePicture	Integer
DropDownPicture	DeletePictures	Integer
DropDownPicture	DirList	Boolean
DropDownPicture	DirSelect	Boolean
DropDownPicture	Drag	Integer
DropDownPicture	FindItem	Integer
DropDownPicture	GetContextService	Integer
DropDownPicture	GetParent	PowerObject
DropDownPicture	Hide	Integer
DropDownPicture	InsertItem	Integer
DropDownPicture	Move	Integer
DropDownPicture	Paste	Integer
DropDownPicture	PointerX	Integer
DropDownPicture	PointerY	Integer
DropDownPicture	Position	Integer
DropDownPicture	PostEvent	Boolean
DropDownPicture	Print	Integer
DropDownPicture	ReplaceText	Integer
DropDownPicture	Reset	Integer
DropDownPicture	Resize	Integer
DropDownPicture	SelectedLength	Integer
DropDownPicture	SelectedStart	Integer
DropDownPicture	SelectedText	String
DropDownPicture	SelectItem	Integer
DropDownPicture	SelectText	Integer
DropDownPicture	SetFocus	Integer
DropDownPicture	SetPosition	Integer
DropDownPicture	SetRedraw	Integer
DropDownPicture	Show	Integer
DropDownPicture	Text	String
DropDownPicture	TotalItems	Integer
DropDownPicture	TriggerEvent	Integer
DropDownPicture	TypeOf	Control
EditMask	ClassName	String
EditMask	Clear	Integer
EditMask	Copy	Integer
EditMask	Cut	Integer
EditMask	Drag	Integer
EditMask	GetContextService	Integer
EditMask	GetData	Integer
EditMask	GetParent	PowerObject
EditMask	Hide	Integer
EditMask	LineCount	Integer
EditMask	LineLength	Integer
EditMask	Move	Integer
EditMask	Paste	Integer
EditMask	PointerX	Integer
EditMask	PointerY	Integer
EditMask	Position	Integer
EditMask	PostEvent	Boolean
EditMask	Print	Integer
EditMask	ReplaceText	Integer
EditMask	Resize	Integer
EditMask	Scroll	Integer
EditMask	SelectedLength	Integer
EditMask	SelectedLine	Integer
EditMask	SelectedStart	Integer
EditMask	SelectedText	String
EditMask	SelectText	Integer
EditMask	SetFocus	Integer
EditMask	SetMask	Integer
EditMask	SetPosition	Integer
EditMask	SetRedraw	Integer
EditMask	Show	Integer
EditMask	TextLine	String
EditMask	TriggerEvent	Integer
EditMask	TypeOf	Object
Graph	AddCategory	Integer
Graph	AddData	Long
Graph	AddSeries	Integer
Graph	CategoryCount	Integer
Graph	CategoryName	String
Graph	ClassName	String
Graph	Clipboard	Integer
Graph	DataCount	Long
Graph	DeleteCategory	Integer
Graph	DeleteData	Integer
Graph	DeleteSeries	Integer
Graph	Drag	Integer	
Graph	FindCategory	Integer	
Graph	FindSeries	Integer	
Graph	GetContextService	Integer	
Graph	GetData	Double	
Graph	GetDataPieExplode	Integer	
Graph	GetDataStyle	Integer	
Graph	GetDataValue	Integer	
Graph	GetSeriesStyle	Integer	
Graph	GetParent	PowerObject	
Graph	Hide	Integer	
Graph	ImportClipboard	Long	
Graph	ImportFile	Long	
Graph	ImportString	Long	
Graph	InsertCategory	Integer	
Graph	InsertData	Long	
Graph	InsertSeries	Integer
Graph	ModifyData	Integer
Graph	Move	Integer
Graph	ObjectAtPointer	GrObjectType
Graph	PointerX	Integer
Graph	PointerY	Integer
Graph	PostEvent	Boolean
Graph	Print	Integer
Graph	Reset	Integer
Graph	ResetDataColors	Integer
Graph	Resize	Integer
Graph	SaveAs	Integer
Graph	SeriesCount	Integer
Graph	SeriesName	String
Graph	SetDataPieExplode	Integer
Graph	SetDataStyle	Integer
Graph	SetFocus	Integer
Graph	SetPosition	Integer
Graph	SetRedraw	Integer
Graph	SetSeriesStyle	Integer
Graph	Show	Integer
Graph	TriggerEvent	Integer
Graph	TypeOf	Object
GroupBox 	ClassName	String
GroupBox 	Drag	Integer
GroupBox 	GetContextService	Integer
GroupBox 	GetParent	PowerObject
GroupBox 	Hide	Integer
GroupBox 	Move	Integer
GroupBox 	PointerX	Integer
GroupBox 	PointerY	Integer
GroupBox 	Print	Integer
GroupBox 	Resize	Integer
GroupBox 	SetFocus	Integer
GroupBox 	SetPosition	Integer
GroupBox 	SetRedraw	Integer
GroupBox 	Show	Integer
GroupBox 	TypeOf	Object
HScrollBar	ClassName	String
HScrollBar	Drag	Integer
HScrollBar	GetContextService	Integer
HScrollBar	GetParent	PowerObject
HScrollBar	Hide	Integer
HScrollBar	Move	Integer
HScrollBar	PointerX	Integer
HScrollBar	PointerY	Integer
HScrollBar	PostEvent	Boolean
HScrollBar	Print	Integer
HScrollBar	Resize	Integer
HScrollBar	SetFocus	Integer
HScrollBar	SetPosition	Integer
HScrollBar	SetRedraw	Integer
HScrollBar	Show	Integer
HScrollBar	TriggerEvent	Integer
HScrollBar	TypeOf	Object
Line	ClassName	String
Line	GetContextService	Integer
Line	GetParent	PowerObject
Line	Hide	Integer
Line	Move	Integer
Line	Resize	Integer
Line	Show	Integer
Line	TypeOf	Object
ListBox 	AddItem	Integer
ListBox 	ClassName	String
ListBox 	DeleteItem	Integer
ListBox 	DirList	Boolean
ListBox 	DirSelect	Boolean
ListBox 	Drag	Integer
ListBox 	FindItem	Integer
ListBox 	GetContextService	Integer
ListBox 	GetParent	PowerObject
ListBox 	Hide	Integer
ListBox 	InsertItem	Integer
ListBox 	Move	Integer
ListBox 	PointerX	Integer
ListBox 	PointerY	Integer	
ListBox 	PostEvent	Boolean	
ListBox 	Print	Integer	
ListBox 	Reset	Integer	
ListBox 	Resize	Integer	
ListBox 	SelectedIndex	Integer	
ListBox 	SelectedItem	String	
ListBox 	SelectItem	Integer	
ListBox 	SetFocus	Integer	
ListBox 	SetPosition	Integer	
ListBox 	SetRedraw	Integer	
ListBox 	SetState	Integer	
ListBox 	SetTop	Integer	
ListBox 	Show	Integer	
ListBox 	State	Integer	
ListBox 	Text	String	
ListBox 	Top	Integer
ListBox 	TotalItems	Integer
ListBox 	TotalSelected	Integer
ListBox 	TriggerEvent	Integer
ListBox 	TypeOf	Object
ListView	AddColumn	Integer
ListView	AddItem	Integer
ListView	AddLargePicture	Integer 
ListView	AddSmallPicture	Integer 
ListView	AddstatePicture	Integer 
ListView	Arrange	Integer 
ListView	ClassName	String
ListView	DeleteColumn	Integer 
ListView	DeleteColumns	Integer 
ListView	DeleteItem	Integer 
ListView	DeleteItems	Integer 
ListView	DeleteLargePicture	Integer 
ListView	DeleteLargePictures	Integer 
ListView	DeleteSmallPicture	Integer 
ListView	DeleteSmallPictures	Integer 
ListView	DeleteStatePicture	Integer 
ListView	DeleteStatePictures	Integer 
ListView	Drag	Integer 
ListView	EditLabel	Integer 
ListView	FindItem	Integer 
ListView	GetColumn	Integer 
ListView	GetContextService	Integer
ListView	GetItem	Integer 
ListView	GetOrigin	Integer 
ListView	GetParent	PowerObject 
ListView	Hide	Integer 
ListView	InsertColumn	Integer 
ListView	InsertItem	Integer 
ListView	Move	Integer 
ListView	PointerX	Integer 
ListView	PointerY	Integer 
ListView	PostEvent	Boolean
ListView	Print	Integer 
ListView	Resize	Integer 
ListView	SelectedIndex	Integer 
ListView	SetColumn	Integer 
ListView	SetFocus	Integer 
ListView	SetItem	Integer 
ListView	SetOverlayPicture	Integer 
ListView	SetPosition	Integer 
ListView	SetRedraw	Integer 
ListView	Show	Integer 
ListView	Sort	Integer 
ListView	TotalColumns	Integer 
ListView	TotalItems	Integer 
ListView	TotalSelected	Integer 
ListView	TriggerEvent	Integer
ListView	TypeOf	Object
MultiLineEdit 	CanUndo	Boolean
MultiLineEdit 	ClassName	String
MultiLineEdit 	Clear	Integer
MultiLineEdit 	Copy	Integer
MultiLineEdit 	Cut	Integer
MultiLineEdit 	Drag	Integer
MultiLineEdit 	GetContextService	Integer
MultiLineEdit 	GetParent	PowerObject
MultiLineEdit 	Hide	Integer
MultiLineEdit 	LineCount	Integer
MultiLineEdit 	LineLength	Integer
MultiLineEdit 	Move	Integer
MultiLineEdit 	Paste	Integer
MultiLineEdit 	PointerX	Integer
MultiLineEdit 	PointerY	Integer
MultiLineEdit 	Position	Integer
MultiLineEdit 	PostEvent	Boolean
MultiLineEdit 	Print	Integer
MultiLineEdit 	ReplaceText	Integer
MultiLineEdit 	Resize	Integer
MultiLineEdit 	Scroll	Integer
MultiLineEdit 	SelectedLength	Integer
MultiLineEdit 	SelectedLine	Integer
MultiLineEdit 	SelectedStart	Integer
MultiLineEdit 	SelectedText	String
MultiLineEdit 	SelectText	Integer
MultiLineEdit 	SetFocus	Integer
MultiLineEdit 	SetPosition	Integer
MultiLineEdit 	SetRedraw	Integer
MultiLineEdit 	Show	Integer
MultiLineEdit 	TextLine	String
MultiLineEdit 	TriggerEvent	Integer
MultiLineEdit 	TypeOf	Object
MultiLineEdit 	Undo	Integer
OLEControl 	Activate	Integer
OLEControl 	ClassName	String
OLEControl 	Clear	Integer
OLEControl 	Copy	Integer
OLEControl 	Cut	Integer
OLEControl 	DoVerb	Integer
OLEControl 	Drag	Integer
OLEControl 	GetContextService	Integer
OLEControl 	GetData	Integer
OLEControl 	GetNativePointer	Integer
OLEControl 	GetParent	PowerObject
OLEControl 	Hide	Integer
OLEControl 	InsertClass	Integer
OLEControl 	InsertFile	Integer
OLEControl 	InsertObject	Integer
OLEControl 	LinkTo	Integer
OLEControl 	Move	Integer
OLEControl 	Open	Integer
OLEControl 	Paste	Integer
OLEControl 	PasteLink	Integer
OLEControl 	PasteSpecial	Integer
OLEControl 	PointerX	Integer
OLEControl 	PointerY	Integer
OLEControl 	PostEvent	Boolean
OLEControl 	Print	Integer
OLEControl 	ReleaseNativePointer	Integer
OLEControl 	Resize	Integer
OLEControl 	Save	Integer
OLEControl 	SaveAs	Integer
OLEControl 	SelectObject	Integer
OLEControl 	SetData	Integer
OLEControl 	SetFocus	Integer
OLEControl 	SetPosition	Integer
OLEControl 	SetRedraw	Integer
OLEControl 	Show	Integer
OLEControl 	TriggerEvent	Integer
OLEControl 	TypeOf	Object
OLEControl 	UpdateLinksDialog	Integer
OLECustomControl 	ClassName	String
OLECustomControl 	Drag	Integer
OLECustomControl 	GetContextService	Integer
OLECustomControl 	GetData	Integer
OLECustomControl 	GetNativePointer	Integer
OLECustomControl 	GetParent	PowerObject 
OLECustomControl 	Hide	Integer
OLECustomControl 	Move	Integer
OLECustomControl 	PointerX	Integer
OLECustomControl 	PointerY	Integer
OLECustomControl 	PostEvent	Boolean
OLECustomControl 	Print	Integer
OLECustomControl 	ReleaseNativePointer	Integer
OLECustomControl 	Resize	Integer
OLECustomControl 	SetAutomationLocale	Integer
OLECustomControl 	SetData	Integer
OLECustomControl 	SetFocus	Integer
OLECustomControl 	SetPosition	Integer
OLECustomControl 	SetRedraw	Integer
OLECustomControl 	Show	Integer
OLECustomControl 	TriggerEvent	Integer
OLECustomControl 	TypeOf	Object
Oval 	ClassName	String
Oval 	GetContextService	Integer
Oval 	GetParent	PowerObject
Oval 	Hide	Integer
Oval 	Move	Integer
Oval 	Resize	Integer
Oval 	Show	Integer
Oval 	TypeOf	Object
Picture 	ClassName	String
Picture 	Drag	Integer
Picture 	Draw	Integer
Picture 	GetContextService	Integer
Picture 	GetParent	PowerObject
Picture 	Hide	Integer
Picture 	Move	Integer
Picture 	PointerX	Integer
Picture 	PointerY	Integer
Picture 	PostEvent	Boolean
Picture 	Print	Integer
Picture 	Resize	Integer
Picture 	SetFocus	Integer
Picture 	SetPicture	Integer
Picture 	SetPosition	Integer
Picture 	SetRedraw	Integer
Picture 	Show	Integer
Picture 	TriggerEvent	Integer
Picture 	TypeOf	Object
PictureButton 	ClassName	String
PictureButton 	Drag	Integer
PictureButton 	GetContextService	Integer
PictureButton 	GetParent	PowerObject
PictureButton 	Hide	Integer
PictureButton 	Move	Integer
PictureButton 	PointerX	Integer
PictureButton 	PointerY	Integer
PictureButton 	PostEvent	Boolean
PictureButton 	Print	Integer
PictureButton 	Resize	Integer
PictureButton 	SetFocus	Integer
PictureButton 	SetPosition	Integer
PictureButton 	SetRedraw	Integer
PictureButton 	Show	Integer
PictureButton 	TriggerEvent	Integer
PictureButton 	TypeOf	Object
PictureListBox	AddItem	Integer
PictureListBox	AddPicture	Integer
PictureListBox	ClassName	String
PictureListBox	DeleteItem	Integer
PictureListBox	DeletePicture	Integer
PictureListBox	DeletePictures	Integer
PictureListBox	DirList	Boolean
PictureListBox	DirSelect	Boolean
PictureListBox	Drag	Integer
PictureListBox	FindItem	Integer	
PictureListBox	GetContextService	Integer	
PictureListBox	GetParent	PowerObject	
PictureListBox	Hide	Integer	
PictureListBox	InsertItem	Integer	
PictureListBox	Move	Integer	
PictureListBox	PointerX	Integer	
PictureListBox	PointerY	Integer	
PictureListBox	PostEvent	Boolean	
PictureListBox	Print	Integer	
PictureListBox	Reset	Integer	
PictureListBox	Resize	Integer	
PictureListBox	SelectedIndex	Integer	
PictureListBox	SelectedItem	String	
PictureListBox	SelectItem	Integer	
PictureListBox	SetFocus	Integer	
PictureListBox	SetPosition	Integer
PictureListBox	SetRedraw	Integer
PictureListBox	SetState	Integer
PictureListBox	SetTop	Integer
PictureListBox	Show	Integer
PictureListBox	State	Integer
PictureListBox	Text	String
PictureListBox	Top	Integer
PictureListBox	TotalItems	Integer
PictureListBox	TotalSelected	Integer
PictureListBox	TriggerEvent	Integer
PictureListBox	TypeOf	Object
RadioButton	ClassName	String
RadioButton	Drag	Integer
RadioButton	GetContextService	Integer
RadioButton	GetParent	PowerObject
RadioButton	Hide	Integer
RadioButton	Move	Integer
RadioButton	PointerX	Integer
RadioButton	PointerY	Integer
RadioButton	PostEvent	Boolean
RadioButton	Print	Integer
RadioButton	Resize	Integer
RadioButton	SetFocus	Integer
RadioButton	SetPosition	Integer
RadioButton	SetRedraw	Integer
RadioButton	Show	Integer
RadioButton	TriggerEvent	Integer
RadioButton	TypeOf	Object
Rectangle 	ClassName	String
Rectangle 	GetContextService	Integer
Rectangle 	GetParent	PowerObject
Rectangle 	Hide	Integer
Rectangle 	Move	Integer
Rectangle 	Resize	Integer
Rectangle 	Show	Integer
Rectangle 	TypeOf	Object
RichTextEdit 	CanUndo	Boolean
RichTextEdit 	ClassName	String
RichTextEdit 	Clear	Long
RichTextEdit 	Copy	Long
RichTextEdit 	CopyRTF	String
RichTextEdit 	Cut	Long
RichTextEdit 	DataSource	Integer
RichTextEdit 	Drag	Integer
RichTextEdit 	Find	Integer
RichTextEdit 	FindNext	Integer
RichTextEdit 	GetAlignment	Alignment
RichTextEdit 	GetContextService	Integer
RichTextEdit 	GetParagraphSetting	Long
RichTextEdit 	GetParent	PowerObject
RichTextEdit 	GetSpacing	Spacing
RichTextEdit 	GetTextColor	Long
RichTextEdit 	GetTextStyle	Boolean
RichTextEdit 	Hide	Integer
RichTextEdit 	InputFieldChangeData	Integer
RichTextEdit 	InputFieldCurrentName	String
RichTextEdit 	InputFieldDeleteCurrent	Integer
RichTextEdit 	InputFieldGetData	String
RichTextEdit 	InputFieldInsert	Integer
RichTextEdit 	InputFieldLocate	String
RichTextEdit 	InsertDocument	Integer
RichTextEdit 	InsertPicture	Integer
RichTextEdit 	IsPreview	Boolean
RichTextEdit 	LineCount	Integer
RichTextEdit 	LineLength	Integer
RichTextEdit 	Move	Integer
RichTextEdit 	PageCount	Integer
RichTextEdit 	Paste	Integer
RichTextEdit 	PasteRTF	Long
RichTextEdit 	PointerX	Integer
RichTextEdit 	PointerY	Integer
RichTextEdit 	Position	Integer
RichTextEdit 	PostEvent	Integer
RichTextEdit 	Preview	Integer
RichTextEdit 	Print	Integer
RichTextEdit 	ReplaceText	Integer
RichTextEdit 	Resize	Integer
RichTextEdit 	SaveDocument	Integer
RichTextEdit 	Scroll	Integer
RichTextEdit 	ScrollNextPage	Integer
RichTextEdit 	ScrollNextRow	Long
RichTextEdit 	ScrollPriorPage	Long
RichTextEdit 	ScrollPriorRow	Long
RichTextEdit 	ScrollToRow	Long
RichTextEdit 	SelectedColumn	Integer
RichTextEdit 	SelectedLength	Long
RichTextEdit 	SelectedLine	Long
RichTextEdit 	SelectedPage	Long
RichTextEdit 	SelectedStart	Integer
RichTextEdit 	SelectedText	String
RichTextEdit 	SelectText	Long
RichTextEdit 	SelectTextAll	Integer
RichTextEdit 	SelectTextLine	Integer
RichTextEdit 	SelectTextWord	Integer
RichTextEdit 	SetAlignment	Integer`
RichTextEdit 	SetFocus	Integer
RichTextEdit 	SetParagraphSetting	Integer
RichTextEdit 	SetPosition	Integer
RichTextEdit 	SetRedraw	Integer
RichTextEdit 	SetSpacing	Integer
RichTextEdit 	SetTextColor	Integer
RichTextEdit 	SetTextStyle	Integer
RichTextEdit 	Show	Integer
RichTextEdit 	ShowHeadFoot	Integer
RichTextEdit 	TextLine	String
RichTextEdit 	TriggerEvent	Integer
RichTextEdit 	TypeOf	Object
RichTextEdit 	Undo	Integer
RoundRectangle 	ClassName	String
RoundRectangle 	GetContextService	Integer
RoundRectangle 	GetParent	PowerObject
RoundRectangle 	Hide	Integer
RoundRectangle 	Move	Integer
RoundRectangle 	Resize	Integer
RoundRectangle 	Show	Integer
RoundRectangle 	TypeOf	Object
SingleLineEdit	CanUndo	Boolean
SingleLineEdit	ClassName	String
SingleLineEdit	Clear	Integer
SingleLineEdit	Copy	Integer
SingleLineEdit	Cut	Integer
SingleLineEdit	Drag	Integer
SingleLineEdit	GetContextService	Integer
SingleLineEdit	GetParent	PowerObject
SingleLineEdit	Hide	Integer
SingleLineEdit	Move	Integer
SingleLineEdit	Paste	Integer
SingleLineEdit	PointerX	Integer
SingleLineEdit	PointerY	Integer
SingleLineEdit	Position	Integer
SingleLineEdit	PostEvent	Boolean
SingleLineEdit	Print	Integer
SingleLineEdit	ReplaceText	Integer
SingleLineEdit	Resize	Integer
SingleLineEdit	SelectedLength	Integer
SingleLineEdit	SelectedStart	Integer
SingleLineEdit	SelectedText	String
SingleLineEdit	SelectText	Integer
SingleLineEdit	SetFocus	Integer
SingleLineEdit	SetPosition	Integer
SingleLineEdit	SetRedraw	Integer
SingleLineEdit	Show	Integer
SingleLineEdit	TriggerEvent	Integer
SingleLineEdit	TypeOf	Object
SingleLineEdit	Undo	Integer
StaticText 	ClassName	String
StaticText 	Drag	Integer
StaticText 	GetContextService	Integer
StaticText 	GetParent	PowerObject
StaticText 	Hide	Integer
StaticText 	Move	Integer
StaticText 	PointerX	Integer
StaticText 	PointerY	Integer
StaticText 	PostEvent	Boolean
StaticText 	Print	Integer
StaticText 	Resize	Integer
StaticText 	SetFocus	Integer
StaticText 	SetPosition	Integer
StaticText 	SetRedraw	Integer
StaticText 	Show	Integer
StaticText 	TriggerEvent	Integer
StaticText 	TypeOf	Object
Tab	ClassName	String
Tab	CloseTab	Integer
Tab	Drag	Integer
Tab	GetContextService	Integer
Tab	GetParent	PowerObject
Tab	Hide	Integer
Tab	Move	Integer
Tab	MoveTab	Integer
Tab	OpenTab	Integer
Tab	OpenTabWithParm	Integer
Tab	PointerX	Integer
Tab	PointerY	Integer
Tab	PostEvent	Integer
Tab	Print	Integer
Tab	Resize	Integer
Tab	SelectTab	Integer
Tab	SetFocus	Integer
Tab	SetPosition	Integer
Tab	SetRedraw	Integer
Tab	Show	Integer
Tab	TabPostEvent	Integer
Tab	TabTriggerEvent	Integer
Tab	TriggerEvent	Integer
Tab	TypeOf	Object
TreeView	AddPicture	Integer
TreeView	AddStatePicture	Integer
TreeView	ClassName	String
TreeView	CollapseItem	Integer
TreeView	DeleteItem	Integer
TreeView	DeletePicture 	Integer
TreeView	DeletePictures	Integer
TreeView	DeleteStatePicture	Integer
TreeView	DeleteStatePictures	Integer
TreeView	Drag	Integer 
TreeView	EditLabel	Integer 
TreeView	ExpandAll	Integer
TreeView	ExpandItem	Integer
TreeView	FindItem	Long
TreeView	GetContextService	Integer
TreeView	GetItem	Integer
TreeView	GetParent	PowerObject
TreeView	Hide	Integer
TreeView	InsertItem	Long
TreeView	InsertItemFirst	Long
TreeView	InsertItemLast	Long
TreeView	InsertItemSort	Long
TreeView	Move	Integer 
TreeView	PointerX	Integer 
TreeView	PointerY	Integer 
TreeView	PostEvent	Boolean
TreeView	Print	Integer 
TreeView	Resize	Integer 
TreeView	SelectItem	Integer
TreeView	SetDropHighlight	Integer
TreeView	SetFirstVisible	Integer
TreeView	SetFocus	Integer 
TreeView	SetItem	Integer
TreeView	SetLevelPictures	Integer
TreeView	SetOverlayPicture	Integer
TreeView	SetPosition	Integer
TreeView	SetRedraw	Integer
TreeView	Show	Integer
TreeView	Sort	Integer
TreeView	SortAll	Integer
TreeView	TriggerEvent	Integer
TreeView	TypeOf	Object
UserObject 	AddItem	Integer
UserObject 	ClassName	String
UserObject 	DeleteItem	Integer
UserObject 	Drag	Integer
UserObject 	EventParmDouble	Integer
UserObject 	EventParmString	Integer
UserObject 	GetContextService	Integer
UserObject 	GetParent	PowerObject
UserObject 	Hide	Integer
UserObject 	InsertItem	Integer
UserObject 	Move	Integer
UserObject 	PointerX	Integer
UserObject 	PointerY	Integer
UserObject 	PostEvent	Boolean
UserObject 	Print	Integer
UserObject 	Resize	Integer
UserObject 	SetFocus	Integer
UserObject 	SetPosition	Integer
UserObject 	SetRedraw	Integer
UserObject 	Show	Integer
UserObject 	TriggerEvent	Integer
UserObject 	TypeOf	Object
VScrollBar 	ClassName	String
VScrollBar 	Drag	Integer
VScrollBar 	GetContextService	Integer
VScrollBar 	GetParent	PowerObject
VScrollBar 	Hide	Integer
VScrollBar 	Move	Integer
VScrollBar 	PointerX	Integer
VScrollBar 	PointerY	Integer
VScrollBar 	PostEvent	Boolean
VScrollBar 	Print	Integer
VScrollBar 	Resize	Integer
VScrollBar 	SetFocus	Integer
VScrollBar 	SetPosition	Integer
VScrollBar 	SetRedraw	Integer
VScrollBar 	Show	Integer
VScrollBar 	TriggerEvent	Integer
VScrollBar 	TypeOf	Object
Application	ClassName	String
Application	GetContextService	Integer
Application	GetParent	PowerObject
Application	PostEvent	Boolean
Application	SetLibraryList	Integer
Application	SetTransPool	Integer
Application	TriggerEvent	Integer
Application	TypeOf	Object
ArrayBounds 	ClassName	String
ArrayBounds 	GetContextService	Integer
ArrayBounds 	GetParent	PowerObject
ArrayBounds 	TypeOf	Object
ClassDefinition	ClassName	String
ClassDefinition	FindMatchingFunction	ScriptDefinition
ClassDefinition	GetContextService	Integer
ClassDefinition	GetParent	PowerObject
ClassDefinition	TypeOf	Object
Connection	ClassName	String
Connection	ConnectToServer	Long
Connection	CreateInstance	Long
Connection	DisconnectServer	Long
Connection	GetContextService	Integer
Connection	GetParent	PowerObject
Connection	GetServerInfo	Long
Connection	PostEvent	Boolean
Connection	RemoteStopConnection	Long
Connection	RemoteStopListening	Long
Connection	TriggerEvent	Integer
Connection	TypeOf	Object
ConnectionInfo 	ClassName	String
ConnectionInfo 	GetContextService	Integer
ConnectionInfo 	GetParent	PowerObject
ConnectionInfo 	TypeOf	Object
ContextInformation	ClassName	String
ContextInformation	GetCompanyName	Integer
ContextInformation	GetContextService	Integer
ContextInformation	GetFixesVersion	Integer
ContextInformation	GetHostObject	Integer
ContextInformation	GetMajorVersion	Integer
ContextInformation	GetMinorVersion	Integer
ContextInformation	GetName	Integer
ContextInformation	GetParent	PowerObject
ContextInformation	GetShortName	Integer
ContextInformation	GetVersionName	Integer
ContextInformation	PostEvent	Boolean
ContextInformation	TriggerEvent	Integer
ContextInformation	TypeOf	Object
ContextKeyword	ClassName	String
ContextKeyword	GetContextKeywords	Integer
ContextKeyword	GetContextService	Integer
ContextKeyword	GetName	Integer
ContextKeyword	GetParent	PowerObject
ContextKeyword	PostEvent	Boolean
ContextKeyword	TriggerEvent	Integer
ContextKeyword	TypeOf	Object
CPlusPlus 	ClassName	String
CPlusPlus 	GetContextService	Integer
CPlusPlus 	GetParent	PowerObject
CPlusPlus 	PostEvent	Boolean
CPlusPlus 	TriggerEvent	Integer
CPlusPlus 	TypeOf	Object
DataStore 	AcceptText	Integer
DataStore 	CategoryCount	Integer
DataStore 	CategoryName	String
DataStore 	ClassName	String
DataStore 	ClearValues	Integer
DataStore 	Clipboard	Integer
DataStore 	CopyRTF	String
DataStore 	Create	Integer
DataStore 	DataCount	Long
DataStore 	DBCancel	Integer
DataStore 	DeletedCount	Long
DataStore 	DeleteRow	Integer
DataStore 	Describe	String
DataStore 	Filter	Integer
DataStore 	FilteredCount	Integer
DataStore 	Find	Long
DataStore 	FindCategory	Integer
DataStore 	FindGroupChange	Long
DataStore 	FindRequired	Integer
DataStore 	FindSeries	Integer
DataStore 	GenerateHTMLForm	Integer
DataStore 	GetBorderStyle	Border (enumerated)
DataStore 	GetChanges	Long
DataStore 	GetChild	Integer
DataStore 	GetColumn	Integer
DataStore 	GetColumnName	String
DataStore 	GetContextService	Integer
DataStore 	GetData	Double
DataStore 	GetDataPieExplode	Integer
DataStore 	GetDataStyle	Integer
DataStore 	GetDataValue	Integer
DataStore 	GetFormat	String
DataStore 	GetFullState	Long
DataStore 	GetItemDate	Date
DataStore 	GetItemDateTime	DateTime
DataStore 	GetItemDecimal	Decimal
DataStore 	GetItemNumber	Double
DataStore 	GetItemStatus	dwItemStatus (enumerated)
DataStore 	GetItemString	String
DataStore 	GetItemTime	Time
DataStore 	GetNextModified	Long
DataStore 	GetParent	PowerObject
DataStore 	GetRow	Long
DataStore 	GetSelectedRow	Integer
DataStore 	GetSeriesStyle	Integer
DataStore 	GetSQLSelect	String
DataStore 	GetStateStatus	Long
DataStore 	GetText	String
DataStore 	GetTrans	Integer
DataStore 	GetValidate	String
DataStore 	GetValue	String
DataStore 	GroupCalc	Integer
DataStore 	ImportClipboard 	Long	
DataStore 	ImportFile 	Long	
DataStore 	ImportString	Long	
DataStore 	InsertDocument	Integer	
DataStore 	InsertRow	Long	
DataStore 	IsSelected	Boolean	
DataStore 	ModifiedCount	Long	
DataStore 	Modify	String	
DataStore 	PasteRTF	Long	
DataStore 	PostEvent	Boolean	
DataStore 	Print	Integer	
DataStore 	PrintCancel	Integer	
DataStore 	ReselectRow	Integer	
DataStore 	Reset	Integer	
DataStore 	ResetDataColors	Integer	
DataStore 	ResetTransObject	Integer	
DataStore 	ResetUpdate	Integer	
DataStore 	Retrieve	Long	
DataStore 	RowCount	Long	
DataStore 	RowsCopy	Integer	
DataStore 	RowsDiscard	Integer	
DataStore 	RowsMove	Integer	
DataStore 	SaveAs	Integer	
DataStore 	SaveAs	Integer	
DataStore 	SaveAsAscii	Long	
DataStore 	SelectRow	Integer	
DataStore 	SeriesCount	Integer	
DataStore 	SeriesName	String	
DataStore 	SetBorderStyle	Integer	
DataStore 	SetChanges	Long	
DataStore 	SetColumn	Integer	
DataStore 	SetDataPieExplode	Integer	
DataStore 	SetDataStyle	Integer	
DataStore 	SetDetailHeight	Integer	
DataStore 	SetFilter	Integer	
DataStore 	SetFormat	Integer	
DataStore 	SetFullState	Long	
DataStore 	SetItem	Integer	
DataStore 	SetItemStatus	Integer	
DataStore 	SetPosition	Integer	
DataStore 	SetRow	Integer	
DataStore 	SetSeriesStyle	Integer	
DataStore 	SetSort	Integer	
DataStore 	SetSQLPreview	Integer	
DataStore 	SetSQLSelect	Integer	
DataStore 	SetText	Integer	
DataStore 	SetTrans	Integer	
DataStore 	SetTransObject	Integer	
DataStore 	SetValidate	Integer
DataStore 	SetValue	Integer
DataStore 	ShareData	Integer
DataStore 	ShareDataOff	Integer
DataStore 	Sort	Integer
DataStore 	TriggerEvent	Integer
DataStore 	TypeOf	Object
DataStore 	Update	Integer
DataWindowChild	AcceptText	Integer
DataWindowChild	ClassName	String
DataWindowChild	ClearValues	Integer
DataWindowChild	CrosstabDialog	Integer
DataWindowChild	DBCancel	Integer
DataWindowChild	DBErrorCode	Long
DataWindowChild	DBErrorMessage	String
DataWindowChild	DeletedCount	Long
DataWindowChild	DeleteRow	Integer
DataWindowChild	Describe	String
DataWindowChild	Filter	Integer
DataWindowChild	FilteredCount	Integer
DataWindowChild	Find	Long
DataWindowChild	FindGroupChange	Long
DataWindowChild	FindRequired	Integer
DataWindowChild	GetBandAtPointer	String
DataWindowChild	GetBorderStyle	Border (enumerated)
DataWindowChild	GetClickedColumn	Integer
DataWindowChild	GetClickedRow	Long
DataWindowChild	GetColumn	Integer
DataWindowChild	GetColumnName	String
DataWindowChild	GetContextService	Integer
DataWindowChild	GetFormat	String
DataWindowChild	GetItemDate	Date
DataWindowChild	GetItemDateTime	DateTime
DataWindowChild	GetItemDecimal	Decimal
DataWindowChild	GetItemNumber	Double
DataWindowChild	GetItemStatus	dwItemStatus (enumerated)
DataWindowChild	GetItemString	String
DataWindowChild	GetItemTime	Time
DataWindowChild	GetNextModified	Long
DataWindowChild	GetObjectAtPointer	String
DataWindowChild	GetParent	PowerObject
DataWindowChild	GetRow	Long
DataWindowChild	GetSelectedRow	Integer
DataWindowChild	GetSQLPreview	String
DataWindowChild	GetSQLSelect	String
DataWindowChild	GetText	String
DataWindowChild	GetTrans	Integer
DataWindowChild	GetUpdateStatus	Integer
DataWindowChild	GetValidate	String
DataWindowChild	GetValue	String
DataWindowChild	GroupCalc	Integer
DataWindowChild	ImportClipboard 	Long
DataWindowChild	ImportFile 	Long
DataWindowChild	ImportString	Long
DataWindowChild	InsertRow	Long
DataWindowChild	IsSelected	Boolean
DataWindowChild	ModifiedCount	Long
DataWindowChild	Modify	String
DataWindowChild	OLEActivate	Integer
DataWindowChild	ReselectRow	Integer
DataWindowChild	Reset	Integer
DataWindowChild	ResetTransObject	Integer
DataWindowChild	ResetUpdate	Integer
DataWindowChild	Resize	Integer	
DataWindowChild	Retrieve	Long	
DataWindowChild	RowCount	Long	
DataWindowChild	RowsCopy	Integer	
DataWindowChild	RowsDiscard	Integer	
DataWindowChild	RowsMove	Integer	
DataWindowChild	SaveAs	Integer	
DataWindowChild	ScrollNextPage	Long	
DataWindowChild	ScrollNextRow	Long	
DataWindowChild	ScrollPriorPage	Long	
DataWindowChild	ScrollPriorRow	Long	
DataWindowChild	ScrollToRow	Integer	
DataWindowChild	SelectRow	Integer	
DataWindowChild	SetActionCode	Integer	
DataWindowChild	SetBorderStyle	Integer	
DataWindowChild	SetColumn	Integer	
DataWindowChild	SetDetailHeight	Integer
DataWindowChild	SetFilter	Integer
DataWindowChild	SetFormat	Integer
DataWindowChild	SetItem	Integer
DataWindowChild	SetItemStatus	Integer
DataWindowChild	SetPosition	Integer
DataWindowChild	SetRedraw	Integer
DataWindowChild	SetRow	Integer
DataWindowChild	SetRowFocusIndicator	Integer
DataWindowChild	SetSort	Integer
DataWindowChild	SetSQLPreview	Integer
DataWindowChild	SetSQLSelect	Integer
DataWindowChild	SetTabOrder	Integer
DataWindowChild	SetText	Integer
DataWindowChild	SetTrans	Integer
DataWindowChild	SetTransObject	Integer
DataWindowChild	SetValidate	Integer	
DataWindowChild	SetValue	Integer	
DataWindowChild	ShareData	Integer	
DataWindowChild	ShareDataOff	Integer	
DataWindowChild	Sort	Integer	
DataWindowChild	TypeOf	Object	
DataWindowChild	Update	Integer	
DynamicDescriptionArea 	ClassName	String	
DynamicDescriptionArea 	GetContextService	Integer	
DynamicDescriptionArea 	GetDynamicDate	Date	
DynamicDescriptionArea 	GetDynamicDateTime	DateTime	
DynamicDescriptionArea 	GetDynamicNumber	Double	
DynamicDescriptionArea 	GetDynamicString	String	
DynamicDescriptionArea 	GetDynamicTime	Time	
DynamicDescriptionArea 	GetParent	PowerObject	
DynamicDescriptionArea 	PostEvent	Boolean
DynamicDescriptionArea 	SetDynamicParm	Integer
DynamicDescriptionArea 	TriggerEvent	Integer
DynamicDescriptionArea 	TypeOf	Object
EnumerationDefinition	ClassName	String
EnumerationDefinition	GetContextService	Integer
EnumerationDefinition	GetParent	PowerObject
EnumerationDefinition	TypeOf	Object
EnumerationItemDefinition	ClassName	String
EnumerationItemDefinition	GetContextService	Integer
EnumerationItemDefinition	GetParent	PowerObject
EnumerationItemDefinition	TypeOf	Object
Environment	ClassName	String
Environment	GetContextService	Integer
Environment	GetParent	PowerObject
Environment	TypeOf	Object
Error	ClassName	String
Error	GetContextService	Integer
Error	GetParent	PowerObject
Error	PostEvent	Boolean
Error	TriggerEvent	Integer
Error	TypeOf	Object
grAxis	ClassName	String
grAxis	GetContextService	Integer
grAxis	GetParent	PowerObject
grAxis	TypeOf	Object
grDispAttr	ClassName	String
grDispAttr	GetContextService	Integer
grDispAttr	GetParent	PowerObject
grDispAttr	TypeOf	Object
Inet	ClassName	String
Inet	GetContextService	Integer
Inet	GetParent	PowerObject
Inet	GetURL	Integer
Inet	HyperLinkToURL	Integer
Inet	PostEvent	Boolean
Inet	PostURL	Integer
Inet	TriggerEvent	Integer
Inet	TypeOf	Object
InternetResult 	ClassName	String
InternetResult 	GetContextService	Integer
InternetResult 	GetParent	PowerObject
InternetResult 	InternetData	Integer
InternetResult 	PostEvent	Boolean
InternetResult 	TriggerEvent	Integer
InternetResult 	TypeOf	Object
ListViewItem 	ClassName	String
ListViewItem 	GetContextService	Integer
ListViewItem 	GetParent	PowerObject
ListViewItem 	TypeOf	Object
mailFileDescription	Classname	String
mailFileDescription	GetContextService	Integer
mailFileDescription	GetParent	PowerObject
mailFileDescription	TypeOf	Object
mailMessage 	Classname	String
mailMessage 	GetContextService	Integer
mailMessage 	GetParent	PowerObject
mailMessage 	TypeOf	Object
mailRecipient 	Classname	String
mailRecipient 	GetContextService	Integer
mailRecipient 	GetParent	PowerObject
mailRecipient 	TypeOf	Object
mailSession 	Classname	String
mailSession 	GetContextService	Integer
mailSession 	GetParent	PowerObject
mailSession 	mailAddress	mailReturnCode 
mailSession 	mailDeleteMessage	mailReturnCode 
mailSession 	mailGetMessages	mailReturnCode 
mailSession 	mailHandle	UnsignedLong
mailSession 	mailLogoff	mailReturnCode 
mailSession 	mailLogon	mailReturnCode
mailSession 	mailReadMessage	mailReturnCode
mailSession 	mailRecipientDetails	mailReturnCode
mailSession 	mailResolveRecipient	mailReturnCode
mailSession 	mailSaveMessage	mailReturnCode
mailSession 	mailSend	mailReturnCode 
mailSession 	PostEvent	Boolean
mailSession 	TriggerEvent	Integer
mailSession 	TypeOf	Object
MDIClient 	ClassName	String
MDIClient 	GetContextService	Integer
MDIClient 	GetParent	PowerObject
MDIClient 	Hide	Integer
MDIClient 	Move	Integer
MDIClient 	Resize	Integer
MDIClient 	SetRedraw	Integer
MDIClient 	Show	Integer
MDIClient 	TypeOf	Object
Menu	Check	Integer
Menu	ClassName	String
Menu	Disable	Integer
Menu	Enable	Integer
Menu	GetContextService	Integer
Menu	GetParent	PowerObject
Menu	Hide	Integer
Menu	PopMenu	Integer
Menu	PostEvent	Integer
Menu	Show	Integer
Menu	TriggerEvent	Integer
Menu	TypeOf	Object
Menu	Uncheck	Integer
MenuCascade 	Check	Integer
MenuCascade 	ClassName	String
MenuCascade 	Disable	Integer
MenuCascade 	Enable	Integer
MenuCascade 	GetContextService	Integer
MenuCascade 	GetParent	PowerObject
MenuCascade 	Hide	Integer
MenuCascade 	PopMenu	Integer
MenuCascade 	PostEvent	Integer
MenuCascade 	Show	Integer
MenuCascade 	TriggerEvent	Integer
MenuCascade 	TypeOf	Object
MenuCascade 	Uncheck	Integer
Message 	ClassName	String
Message 	GetContextService	Integer
Message 	GetParent	PowerObject
Message 	PostEvent	Boolean
Message 	TriggerEvent	Integer
Message 	TypeOf	Object
OLEObject 	ClassName	String
OLEObject 	ConnectToNewObject	Integer
OLEObject 	ConnectToNewRemoteObject	Integer
OLEObject 	ConnectToObject	Integer
OLEObject 	ConnectToRemoteObject	Integer
OLEObject 	DisconnectObject	Integer
OLEObject 	GetAutomationNative- 	
OLEObject 	Pointer	Integer
OLEObject 	GetContextService	Integer
OLEObject 	GetParent	PowerObject
OLEObject 	PostEvent	Boolean
OLEObject 	ReleaseAutomation- 	
OLEObject 	NativePointer 	Integer
OLEObject 	SetAutomationLocale	Integer
OLEObject 	SetAutomationPointer	Integer
OLEObject 	SetAutomationTimeout	Integer
OLEObject 	TriggerEvent	Integer
OLEObject 	TypeOf	Object
OLEStorage 	ClassName	String
OLEStorage 	Clear	Integer
OLEStorage 	Close	Integer
OLEStorage 	GetContextService	Integer
OLEStorage 	GetParent	PowerObject
OLEStorage 	MemberDelete	Integer
OLEStorage 	MemberExists	Integer
OLEStorage 	MemberRename	Integer
OLEStorage 	Open	Integer
OLEStorage 	PostEvent	Boolean
OLEStorage 	Save	Integer
OLEStorage 	SaveAs	Integer
OLEStorage 	TriggerEvent	Integer
OLEStorage 	TypeOf	Object
OLEStream 	ClassName	String
OLEStream 	Close	Integer
OLEStream 	GetContextService	Integer
OLEStream 	GetParent	PowerObject
OLEStream 	Length	Integer
OLEStream 	Open	Integer
OLEStream 	PostEvent	Boolean
OLEStream 	Read	Integer
OLEStream 	Seek	Integer
OLEStream 	TriggerEvent	Integer
OLEStream 	TypeOf	Object
OLEStream 	Write	Long
Pipeline 	Cancel	Integer
Pipeline 	ClassName	String
Pipeline 	GetContextService	Integer
Pipeline 	GetParent	PowerObject
Pipeline 	PostEvent	Boolean
Pipeline 	Repair	Integer
Pipeline 	Start	Integer
Pipeline 	TriggerEvent	Integer
Pipeline 	TypeOf	Object
ProfileCall	ClassName	String
ProfileCall	GetContextService	Integer
ProfileCall	GetParent	PowerObject
ProfileCall	TypeOf	Object
ProfileClass 	ClassName	String
ProfileClass 	GetContextService	Integer
ProfileClass 	GetParent	PowerObject
ProfileClass 	RoutineList	ErrorReturn (enumerated)
ProfileClass 	TypeOf	Object
ProfileLine	ClassName	String
ProfileLine	GetContextService	Integer
ProfileLine	GetParent	PowerObject
ProfileLine	OutGoingCallList	ErrorReturn (enumerated)
ProfileLine	RoutineList	ErrorReturn (enumerated)
ProfileLine	TypeOf	Object
ProfileRoutine 	ClassName	String
ProfileRoutine 	GetContextService	Integer
ProfileRoutine 	GetParent	PowerObject
ProfileRoutine 	IncomingCallList	ErrorReturn (enumerated)
ProfileRoutine 	LineList	ErrorReturn (enumerated)
ProfileRoutine 	OutgoingCallList	ErrorReturn (enumerated)
ProfileRoutine 	TypeOf	Object
Profiling	BuildModel	ErrorReturn (enumerated)
Profiling	ClassList	ErrorReturn (enumerated)
Profiling	ClassName	String
Profiling	DestroyModel	ErrorReturn (enumerated)
Profiling	GetContextService	Integer
Profiling	GetParent	PowerObject
Profiling	RoutineList	ErrorReturn (enumerated)
Profiling	SetTraceFileName	ErrorReturn
Profiling	SystemRoutine	ProfileRoutine
Profiling	TypeOf	Object
ScriptDefinition 	ClassName	String
ScriptDefinition 	GetContextService	Integer
ScriptDefinition 	GetParent	PowerObject
ScriptDefinition 	TypeOf	Object
TraceActivityNode	ClassName	String
TraceActivityNode	GetContextService	Integer
TraceActivityNode	GetParent	PowerObject
TraceActivityNode	TypeOf	Object
TraceBeginEnd	ClassName	String
TraceBeginEnd	GetContextService	Integer
TraceBeginEnd	GetParent	PowerObject
TraceBeginEnd	TypeOf	Object
TraceError	ClassName	String
TraceError	GetContextService	Integer
TraceError	GetParent	PowerObject
TraceError	TypeOf	Object
TraceESQL 	ClassName	String
TraceESQL 	GetContextService	Integer
TraceESQL 	GetParent	PowerObject
TraceESQL 	TypeOf	Object
TraceFile	ClassName	String
TraceFile	Close	ErrorReturn (enumerated)
TraceFile	GetContextService	Integer
TraceFile	GetParent	PowerObject
TraceFile	NextActivity	TraceActivityNode
TraceFile	Open	ErrorReturn (enumerated)
TraceFile	Reset	ErrorReturn (enumerated)
TraceFile	TypeOf	Object
TraceGarbageCollect	ClassName	String
TraceGarbageCollect	GetContextService	Integer
TraceGarbageCollect	GetParent	PowerObject
TraceGarbageCollect	TypeOf	Object
TraceLine	ClassName	String
TraceLine	GetContextService	Integer
TraceLine	GetParent	PowerObject
TraceLine	TypeOf	Object
TraceObject	ClassName	String
TraceObject	GetContextService	Integer
TraceObject	GetParent	PowerObject
TraceObject	TypeOf	Object
TraceRoutine	ClassName	String
TraceRoutine	GetContextService	Integer
TraceRoutine	GetParent	PowerObject
TraceRoutine	TypeOf	Object
TraceTree	BuildModel	ErrorReturn(enumerated)
TraceTree	ClassName	String
TraceTree	DestroyModel	ErrorReturn(enumerated)
TraceTree	EntryList	ErrorReturn(enumerated)
TraceTree	GetContextService	Integer
TraceTree	GetParent	PowerObject
TraceTree	SetTraceFileName	ErorReturn
TraceTree	TypeOf	Object
TraceTreeError	ClassName	String
TraceTreeError	GetContextService	Integer
TraceTreeError	GetParent	PowerObject
TraceTreeError	TypeOf	Object
TraceTreeESQL 	ClassName	String
TraceTreeESQL 	GetContextService	Integer
TraceTreeESQL 	GetParent	PowerObject
TraceTreeESQL 	TypeOf	Object
TraceTreeGarbageCollect 	ClassName	String
TraceTreeGarbageCollect 	GetChildrenList	ErrorReturn (enumerated)
TraceTreeGarbageCollect 	GetContextService	Integer
TraceTreeGarbageCollect 	GetParent	PowerObject
TraceTreeGarbageCollect 	TypeOf	Object
TraceTreeLine 	ClassName	String
TraceTreeLine 	GetContextService	Integer
TraceTreeLine 	GetParent	PowerObject
TraceTreeLine 	TypeOf	Object
TraceTreeNode 	ClassName	String
TraceTreeNode 	GetContextService	Integer
TraceTreeNode 	GetParent	PowerObject
TraceTreeNode 	TypeOf	Object
TraceTreeObject 	ClassName	String
TraceTreeObject 	GetChildrenList	
TraceTreeObject 	GetContextService	Integer
TraceTreeObject 	GetParent	PowerObject
TraceTreeObject 	TypeOf	Object
TraceTreeRoutine	ClassName	String
TraceTreeRoutine	GetChildrenList	ErrorReturn(enumerated)
TraceTreeRoutine	GetContextService	Integer
TraceTreeRoutine	GetParent	PowerObject
TraceTreeRoutine	TypeOf	Object
TraceTreeUser 	ClassName	String
TraceTreeUser 	GetContextService	Integer
TraceTreeUser 	GetParent	PowerObject
TraceTreeUser 	TypeOf	Object
TraceUser	ClassName	String
TraceUser	GetContextService	Integer
TraceUser	GetParent	PowerObject
TraceUser	TypeOf	Object
Timing 	ClassName	String
Timing 	GetContextService	Integer
Timing 	GetParent	PowerObject
Timing 	PostEvent	Boolean
Timing 	Start	Integer
Timing 	Stop	Integer
Timing 	TriggerEvent	Integer
Timing 	TypeOf	Object
Transaction 	ClassName	String
Transaction 	DBHandle	Long
Transaction 	GetContextService	Integer
Transaction 	GetParent	PowerObject
Transaction 	PostEvent	Boolean
Transaction 	SyntaxFromSQL	String
Transaction 	TriggerEvent	Integer
Transaction 	TypeOf	Object
Transport 	ClassName	String
Transport 	GetContextService	Integer
Transport 	GetParent	PowerObject
Transport 	Listen	Long
Transport 	StopListening	Long
Transport 	TypeOf	Object
TreeViewItem	ClassName	String
TreeViewItem	GetContextService	Integer
TreeViewItem	GetParent	PowerObject
TreeViewItem	TypeOf	Object
TypeDefinition 	ClassName	String
TypeDefinition 	GetContextService	Integer
TypeDefinition 	GetParent	PowerObject
TypeDefinition 	TypeOf	Object
UserObject	AddItem	Integer
UserObject	ClassName	String
UserObject	DeleteItem	Integer
UserObject	Drag	Integer
UserObject	EventParmDouble	Integer
UserObject	EventParmString	Integer
UserObject	GetContextService	Integer
UserObject	GetParent	PowerObject
UserObject	Hide	Integer
UserObject	InsertItem	Integer
UserObject	Move	Integer
UserObject	PointerX	Integer
UserObject	PointerY	Integer
UserObject	PostEvent	Boolean
UserObject	Print	Integer
UserObject	Resize	Integer
UserObject	SetFocus	Integer
UserObject	SetPosition	Integer
UserObject	SetRedraw	Integer
UserObject	Show	Integer
UserObject	TriggerEvent	Integer
UserObject	TypeOf	Object
VariableCardinality 	ClassName	String
VariableCardinality 	GetContextService	Integer
VariableCardinality 	GetParent	PowerObject
VariableCardinality 	TypeOf	Object
VariableDefinition 	ClassName	String
VariableDefinition 	GetContextService	Integer
VariableDefinition 	GetParent	PowerObject
VariableDefinition 	TypeOf	Object
Window	ArrangeSheets	Integer
Window	ChangeMenu	Integer
Window	ClassName	String
Window	CloseUserObject	Integer
Window	GetActiveSheet	Window
Window	GetContextService	Integer
Window	GetFirstSheet	Window
Window	GetNextSheet	Window
Window	GetParent	PowerObject
Window	GetToolbar	Integer
Window	GetToolbarPos	Integer
Window	Hide	Integer
Window	Move	Integer
Window	OpenUserObject	Integer
Window	OpenUserObjectWithParm	Integer
Window	ParentWindow	Window
Window	PointerX	Integer
Window	PointerY	Integer
Window	PostEvent	Boolean
Window	Print	Integer
Window	Resize	Integer
Window	SetFocus	Integer	
Window	SetMicroHelp	Integer	
Window	SetPosition	Integer	
Window	SetRedraw	Integer	
Window	SetToolbar	Integer	
Window	SetToolbarPosition	Integer	
Window	Show	Integer	
Window	TriggerEvent	Integer	
Window	TypeOf	Object	
Window	WorkSpaceHeight	Integer	
Window	WorkSpaceWidth	Integer	
Window	WorkSpaceX	Integer	
Window	WorkSpaceY	Integer	
SystemFunction	LowerBound	  	
SystemFunction	UpperBound	  	
SystemFunction	Blob	  
SystemFunction	BlobEdit	  
SystemFunction	BlobMid	  
SystemFunction	Len	  
SystemFunction	String	  
SystemFunction	Asc	  
SystemFunction	Char	  
SystemFunction	Dec	  
SystemFunction	Double	  
SystemFunction	Integer	  
SystemFunction	Long	  
SystemFunction	Real	  
SystemFunction	Date	  
SystemFunction	DateTime	  
SystemFunction	IsDate	  
SystemFunction	IsNull	  
SystemFunction	IsNumber	  
SystemFunction	IsTime	  
SystemFunction	String	  
SystemFunction	Time	  
SystemFunction	Day	  
SystemFunction	DayName	  
SystemFunction	DayNumber	  
SystemFunction	DaysAfter	  
SystemFunction	Hour	  
SystemFunction	Minute	  
SystemFunction	Month	  
SystemFunction	Now	  
SystemFunction	RelativeDate	  
SystemFunction	RelativeTime	  
SystemFunction	Second	  
SystemFunction	Today	  
SystemFunction	Year	  
SystemFunction	CloseChannel	  
SystemFunction	ExecRemote 	  
SystemFunction	GetDataDDE	  
SystemFunction	GetDataDDEOrigin	  
SystemFunction	GetRemote 	  
SystemFunction	OpenChannel	  
SystemFunction	RespondRemote	  
SystemFunction	SetRemote 	  
SystemFunction	StartHotLink	  
SystemFunction	StopHotLink	  
SystemFunction	GetCommandDDE	  
SystemFunction	GetCommandDDEOrigin	  
SystemFunction	GetDataDDE	  
SystemFunction	GetDataDDEOrigin	  
SystemFunction	RespondRemote	  
SystemFunction	SetDataDDE	  
SystemFunction	StartServerDDE	  
SystemFunction	StopServerDDE	  
SystemFunction	FileClose	  
SystemFunction	FileDelete	  
SystemFunction	FileExists	  
SystemFunction	FileLength	  
SystemFunction	FileOpen	  
SystemFunction	FileRead	  
SystemFunction	FileSeek	  
SystemFunction	FileWrite	  
SystemFunction	GetFileOpenName	  
SystemFunction	GetFileSaveName	  
SystemFunction	IsAllArabic	  
SystemFunction	IsAllHebrew	  
SystemFunction	IsAnyArabic	  
SystemFunction	IsAnyHebrew	  
SystemFunction	IsArabic	  
SystemFunction	IsArabicAndNumbers	  
SystemFunction	IsHebrew	  
SystemFunction	IsHebrewAndNumbers	  
SystemFunction	Reverse	  
SystemFunction	ToAnsi	  
SystemFunction	ToUnicode	  
SystemFunction	LibraryCreate	  
SystemFunction	LibraryDelete	  
SystemFunction	LibraryDirectory	  
SystemFunction	LibraryExport	  
SystemFunction	LibraryImport	  
SystemFunction	mailAddress	  
SystemFunction	mailDeleteMessage	  
SystemFunction	mailGetMessages	  
SystemFunction	mailHandle	  
SystemFunction	mailLogoff	  
SystemFunction	mailLogon	  
SystemFunction	mailReadMessage	  
SystemFunction	mailRecipientDetails	  
SystemFunction	mailResolveRecipient	  
SystemFunction	mailSaveMessage	  
SystemFunction	mailSend	  
SystemFunction	Beep	  
SystemFunction	ClassName	  
SystemFunction	DebugBreak	  
SystemFunction	DraggedObject	  
SystemFunction	IntHigh	  
SystemFunction	IntLow	  
SystemFunction	IsValid	  
SystemFunction	KeyDown	  
SystemFunction	MessageBox	  
SystemFunction	PixelsToUnits	  
SystemFunction	PopulateError	  
SystemFunction	RGB	  
SystemFunction	SetNull	  
SystemFunction	SetPointer	  
SystemFunction	SignalError	  
SystemFunction	UnitsToPixels	  
SystemFunction	Abs	  
SystemFunction	Ceiling	  
SystemFunction	Cos	  
SystemFunction	Exp	  
SystemFunction	Fact	  
SystemFunction	Int	  
SystemFunction	Log	  
SystemFunction	LogTen	  
SystemFunction	Max	  
SystemFunction	Min	  
SystemFunction	Mod	  
SystemFunction	Pi	  
SystemFunction	Rand	  
SystemFunction	Randomize	  
SystemFunction	Round	  
SystemFunction	Sign	  
SystemFunction	Sin	  
SystemFunction	Sqrt	  
SystemFunction	Tan	  
SystemFunction	Truncate	  
SystemFunction	Print	  
SystemFunction	PrintBitmap	  
SystemFunction	PrintCancel	  
SystemFunction	PrintClose	  
SystemFunction	PrintDataWindow	  
SystemFunction	PrintDefineFont	  
SystemFunction	PrintLine	  
SystemFunction	PrintOpen	  
SystemFunction	PrintOval	  
SystemFunction	PrintPage	  
SystemFunction	PrintRect	  
SystemFunction	PrintRoundRect	  
SystemFunction	PrintScreen	  
SystemFunction	PrintSend	  
SystemFunction	PrintSetFont	  
SystemFunction	PrintSetSpacing	  
SystemFunction	PrintSetup	  
SystemFunction	PrintText	  
SystemFunction	PrintWidth	  
SystemFunction	PrintX	  
SystemFunction	PrintY	  
SystemFunction	RegistryDelete	  
SystemFunction	RegistryGet	  
SystemFunction	RegistryKeys	  
SystemFunction	RegistrySet	  
SystemFunction	RegistryValues	  
SystemFunction	Asc	  
SystemFunction	Char	  
SystemFunction	Fill	  
SystemFunction	Left	  
SystemFunction	LeftTrim	  
SystemFunction	Len	  
SystemFunction	Lower	  
SystemFunction	Match	  
SystemFunction	Mid	  
SystemFunction	Pos	  
SystemFunction	Replace	  
SystemFunction	Reverse	  
SystemFunction	Right	  
SystemFunction	RightTrim	  
SystemFunction	Space	  
SystemFunction	Trim	  
SystemFunction	Upper	  
SystemFunction	Clipboard	  
SystemFunction	CommandParm	  
SystemFunction	DoScript	  
SystemFunction	GetApplication	  
SystemFunction	GetEnvironment	  
SystemFunction	GetFocus	  
SystemFunction	Post	  
SystemFunction	ProfileInt	  
SystemFunction	ProfileString	  
SystemFunction	Restart	  
SystemFunction	Run	  
SystemFunction	Send	  
SystemFunction	SetProfileString	  
SystemFunction	ShowHelp	  
SystemFunction	SignalError	  
SystemFunction	Yield	  
SystemFunction	CPU	  
SystemFunction	Idle	  
SystemFunction	Timer	  
SystemFunction	Close	  
SystemFunction	CloseWithReturn	  
SystemFunction	Open	  
SystemFunction	OpenSheet	  
SystemFunction	OpenSheetWithParm	  
SystemFunction	OpenWithParm	  
----------------------------------------------------------------*/
/*----------------------------------------------------------------
PowerBuilder Object Properties
------------------------------------------------------------------
CheckBox	Automatic	Boolean	
CheckBox	BackColor	Long	
CheckBox	BorderStyle	BorderStyle (enumerated)	
CheckBox	BringToTop	Boolean	
CheckBox	Checked	Boolean	
CheckBox	DragAuto	Boolean	
CheckBox	DragIcon	String	
CheckBox	Enabled	Boolean	
CheckBox	FaceName	String	
CheckBox	FontCharSet	FontCharSet (enumerated)	
CheckBox	FontFamily	FontFamily (enumerated)	
CheckBox	FontPitch	FontPitch (enumerated)	
CheckBox	Height	Integer	
CheckBox	Italic	Boolean	
CheckBox	LeftText	Boolean	
CheckBox	Pointer	String	
CheckBox	RightToLeft	Boolean	
CheckBox	TabOrder	Integer	
CheckBox	Tag	String	
CheckBox	Text	String	
CheckBox	TextColor	Long	
CheckBox	TextSize	Integer	
CheckBox	ThirdState	Boolean	
CheckBox	ThreeState	Boolean	
CheckBox	Underline	Boolean	
CheckBox	Visible	Boolean	
CheckBox	Weight	Integer	
CheckBox	Width	Integer	
CheckBox	X	Integer	
CheckBox	Y	Integer	
CommandButton	BringToTop	Boolean	
CommandButton	Cancel	Boolean	
CommandButton	Default	Boolean	
CommandButton	DragAuto	Boolean	
CommandButton	DragIcon	String	
CommandButton	Enabled	Boolean	
CommandButton	FaceName	String	
CommandButton	FontCharSet	FontCharSet (enumerated)	
CommandButton	FontFamily	FontFamily (enumerated)	
CommandButton	FontPitch	FontPitch (enumerated)	
CommandButton	Height	Integer	
CommandButton	Italic	Boolean	
CommandButton	Pointer	String	
CommandButton	TabOrder	Integer	
CommandButton	Tag	String	
CommandButton	Text	String	
CommandButton	TextSize	Integer	
CommandButton	Underline	Boolean	
CommandButton	Visible	Boolean	
CommandButton	Weight	Integer	
CommandButton	Width	Integer	
CommandButton	X	Integer	
CommandButton	Y	Integer	
DataWindow 	Border	Boolean	
DataWindow 	BorderStyle	BorderStyle (enumerated)	
DataWindow 	BringToTop	Boolean	
DataWindow 	ControlMenu	Boolean	
DataWindow 	DataObject	String	
DataWindow 	DragAuto	Boolean	
DataWindow 	DragIcon	String	
DataWindow 	Enabled	Boolean	
DataWindow 	Height	Integer	
DataWindow 	HScrollBar	Boolean	
DataWindow 	HSplitScroll	Boolean	
DataWindow 	Icon	String	
DataWindow 	LiveScroll	Boolean	
DataWindow 	MaxBox	Boolean	
DataWindow 	MinBox	Boolean	
DataWindow 	Object	DWObject	
DataWindow 	Resizable	Boolean	
DataWindow 	RightToLeft	Boolean	
DataWindow 	TabOrder	Integer	
DataWindow 	Tag	String	
DataWindow 	Title	String	
DataWindow 	TitleBar	Boolean	
DataWindow 	Visible	Boolean	
DataWindow 	VScrollBar	Boolean	
DataWindow 	Width	Integer	
DataWindow 	X	Integer	
DataWindow 	Y	Integer	
DropDownListBox	Accelerator	Integer	
DropDownListBox	AllowEdit	Boolean	
DropDownListBox	AutoHScroll	Boolean	
DropDownListBox	BackColor	Long	
DropDownListBox	Border	Boolean	
DropDownListBox	BorderStyle	BorderStyle (enumerated)	
DropDownListBox	BringToTop	Boolean	
DropDownListBox	DragAuto	Boolean	
DropDownListBox	DragIcon	String	
DropDownListBox	Enabled	Boolean	
DropDownListBox	FaceName	String	
DropDownListBox	FontCharSet	FontCharSet (enumerated)	
DropDownListBox	FontFamily	FontFamily (enumerated)	
DropDownListBox	FontPitch	FontPitch (enumerated)	
DropDownListBox	Height	Integer	
DropDownListBox	HScrollBar	Boolean	
DropDownListBox	Italic	Boolean	
DropDownListBox	Item[ ]	String array	
DropDownListBox	Limit	Integer	
DropDownListBox	Pointer	String	
DropDownListBox	RightToLeft	Boolean	
DropDownListBox	ShowList	Boolean	
DropDownListBox	Sorted	Boolean	
DropDownListBox	TabOrder	Integer	
DropDownListBox	Tag	String	
DropDownListBox	Text	String	
DropDownListBox	TextColor	Long	
DropDownListBox	TextSize	Integer	
DropDownListBox	Underline	Boolean	
DropDownListBox	Visible	Boolean	
DropDownListBox	VScrollBar	Boolean	
DropDownListBox	Weight	Integer	
DropDownListBox	Width	Integer	
DropDownListBox	X	Integer	
DropDownListBox	Y	Integer	
DropDownPicture	 Accelerator	Integer	
DropDownPicture	AllowEdit	Boolean	
DropDownPicture	AutoHScroll	Boolean	
DropDownPicture	BackColor	Long	
DropDownPicture	Border	Boolean	
DropDownPicture	BorderStyle	BorderStyle (enumerated)	
DropDownPicture	BringToTop	Boolean	
DropDownPicture	DragAuto	Boolean	
DropDownPicture	DragIcon	String	
DropDownPicture	Enabled	Boolean	
DropDownPicture	FaceName	String	
DropDownPicture	FontCharSet	FontCharSet (enumerated)	
DropDownPicture	FontFamily	FontFamily (enumerated)	
DropDownPicture	FontPitch	FontPitch (enumerated)	
DropDownPicture	Height	Integer	
DropDownPicture	HScrollBar	Boolean	
DropDownPicture	Italic	Boolean	
DropDownPicture	Item[ ]	String array	
DropDownPicture	ItemPictureIndex[ ]	Integer	
DropDownPicture	Limit	Integer	
DropDownPicture	PictureHeight	Integer	
DropDownPicture	PictureWidth	Integer	
DropDownPicture	PictureMaskColor	Long	
DropDownPicture	PictureName[ ]	String	
DropDownPicture	Pointer	String	
DropDownPicture	RightToLeft	Boolean	
DropDownPicture	ShowList	Boolean	
DropDownPicture	Sorted	Boolean	
DropDownPicture	TabOrder	Integer	
DropDownPicture	Tag	String	
DropDownPicture	Text	String	
DropDownPicture	TextColor	Long	
DropDownPicture	TextSize	Integer	
DropDownPicture	Underline	Boolean	
DropDownPicture	Visible	Boolean	
DropDownPicture	VScrollBar	Boolean	
DropDownPicture	Weight	Integer	
DropDownPicture	Width	Integer	
DropDownPicture	X	Integer	
DropDownPicture	Y	Integer	
EditMask	Accelerator	Integer	
EditMask	Alignment	Alignment 	
EditMask	(enumerated)	Specifies the alignment of text in the control. Values are:Center!Justify!Left!Right!	
EditMask	AutoHScroll	Boolean	
EditMask	AutoSkip	Boolean	
EditMask	AutoVScroll	Boolean	
EditMask	BackColor	Long	
EditMask	Border	Boolean	
EditMask	BorderStyle	BorderStyle (enumerated)	
EditMask	BringToTop	Boolean	
EditMask	DisplayData	String	
EditMask	DisplayOnly	Boolean	
EditMask	DragAuto	Boolean	
EditMask	DragIcon	String	
EditMask	Enabled	Boolean	
EditMask	FaceName	String	
EditMask	FontCharSet	FontCharSet (enumerated)	
EditMask	FontFamily	FontFamily (enumerated)	
EditMask	FontPitch	FontPitch (enumerated)	
EditMask	Height	Integer	
EditMask	HScrollBar	Boolean	
EditMask	HideSelection	Boolean	
EditMask	IgnoreDefaultButton	Boolean	
EditMask	Increment	Double	
EditMask	Italic	Boolean	
EditMask	Limit	Integer	
EditMask	Mask	String	
EditMask	MaskDataType	MaskDataType (enumerated)	
EditMask	MinMax	String	
EditMask	Pointer	String	
EditMask	RightToLeft	Boolean	
EditMask	Spin	Boolean	
EditMask	TabOrder	Integer	
EditMask	TabStop[ ]	Integer	
EditMask	Tag	String	
EditMask	Text	String	
EditMask	TextColor	Long	
EditMask	TextCase	TextCase (enumerated)	
EditMask	TextSize	Integer	
EditMask	UnderLine	Boolean	
EditMask	UseCodeTable	Boolean	
EditMask	Visible	Boolean	
EditMask	VScrollBar	Boolean	
EditMask	Weight	Integer	
EditMask	Width	Integer	
EditMask	X	Integer	
EditMask	Y	Integer	
Graph	BackColor	Long	
Graph	Border	Boolean	
Graph	BorderStyle	BorderStyle (enumerated)	
Graph	BringToTop	Boolean	
Graph	Category	grAxis	
Graph	CategorySort	grSortType	
Graph	Depth	Integer	
Graph	DragAuto	Boolean	
Graph	DragIcon	String	
Graph	Elevation	Integer	
Graph	Enabled	Boolean	
Graph	FocusRectangle	Boolean	
Graph	GraphType	grGraphType (enumerated)	
Graph	Height	Integer	
Graph	Legend	grLegendType (enumerated)	
Graph	LegendDispAttr	grDispAttr
Graph	OverlapPercent	Integer
Graph	Perspective	Integer
Graph	PieDispAttr	grDispAttr
Graph	Pointer	String
Graph	Rotation	Integer
Graph	Series	grAxis
Graph	SeriesSort	grSortType
Graph	ShadeColor	Long
Graph	Spacing	Integer
Graph	TabOrder	Integer
Graph	Tag	String
Graph	TextColor	Long
Graph	Title	String
Graph	TitleDispAttr	grDispAttr
Graph	Values	grAxis
Graph	Visible	Boolean	
Graph	Width	Integer	
Graph	X	Integer	
Graph	Y	Integer	
GroupBox 	BackColor	Long	
GroupBox 	BorderStyle	BorderStyle (enumerated)	
GroupBox 	BringToTop	Boolean	
GroupBox 	DragAuto	Boolean	
GroupBox 	DragIcon	String	
GroupBox 	Enabled	Boolean	
GroupBox 	FaceName	String	
GroupBox 	FontCharSet	FontCharSet (enumerated)	
GroupBox 	FontFamily	FontFamily (enumerated)	
GroupBox 	FontPitch	FontPitch (enumerated)	
GroupBox 	Height	Integer	
GroupBox 	Italic	Boolean	
GroupBox 	Pointer	String	
GroupBox 	RightToLeft 	Boolean	
GroupBox 	TabOrder	Integer	
GroupBox 	Tag	String	
GroupBox 	Text	String	
GroupBox 	TextColor	Long	
GroupBox 	TextSize	Integer	
GroupBox 	Underline	Boolean	
GroupBox 	Visible	Boolean	
GroupBox 	Weight	Integer	
GroupBox 	Width	Integer	
GroupBox 	X	Integer	
GroupBox 	Y	Integer	
HScrollBar	BringToTop	Boolean	
HScrollBar	DragAuto	Boolean	
HScrollBar	DragIcon	String	
HScrollBar	Height	Integer	
HScrollBar	MaxPosition	Integer	
HScrollBar	MinPosition	Integer	
HScrollBar	Pointer	String	
HScrollBar	Position	Integer	
HScrollBar	StdHeight	Boolean	
HScrollBar	TabOrder	Integer	
HScrollBar	Tag	String	
HScrollBar	Visible	Boolean	
Line	BeginX	Integer	
Line	BeginY	Integer	
Line	EndX	Integer	
Line	EndY	Integer	
Line	LineColor	Long	
Line	LineStyle	LineStyle (enumerated)	
Line	LineThickness	Integer	
Line	Tag	String	
Line	Visible	Boolean	
ListBox 	Accelerator	Integer	
ListBox 	BackColor	Long	
ListBox 	Border	Boolean	
ListBox 	BorderStyle	BorderStyle (enumerated)	
ListBox 	BringToTop	Boolean	
ListBox 	DisableNoScroll	Boolean	
ListBox 	DragAuto	Boolean	
ListBox 	DragIcon	String	
ListBox 	Enabled	Boolean	
ListBox 	ExtendedSelect	Boolean	
ListBox 	FaceName	String	
ListBox 	FontCharSet	FontCharSet (enumerated)	
ListBox 	FontFamily	FontFamily (enumerated)	
ListBox 	FontPitch	FontPitch (enumerated)	
ListBox 	Height	Integer	
ListBox 	HScrollBar	Boolean	
ListBox 	Italic	Boolean	
ListBox 	Item[ ]	String	
ListBox 	MultiSelect	Boolean	
ListBox 	Pointer	String	
ListBox 	RightToLeft	Boolean	
ListBox 	Sorted	Boolean	
ListBox 	TabOrder	Integer	
ListBox 	TabStop[ ]	Integer array	
ListBox 	Tag	String	
ListBox 	TextColor	Long	
ListBox 	TextSize	Integer
ListBox 	Underline	Boolean
ListBox 	Visible	Boolean
ListBox 	VScrollBar	Boolean
ListBox 	Weight	Integer
ListBox 	Width	Integer
ListBox 	X	Integer
ListBox 	Y	Integer
ListView	Accelerator	Integer
ListView	AutoArrange	Boolean
ListView	BackColor	Long
ListView	Border	Boolean 
ListView	BorderStyle	BorderStyle (enumerated)
ListView	BringToTop	Boolean 
ListView	ButtonHeader	Boolean 
ListView	DeleteItems	Boolean 	
ListView	DragAuto 	Boolean 	
ListView	DragIcon	String	
ListView	EditLabels	Boolean 	
ListView	Enabled	Boolean	
ListView	ExtendedSelect	Boolean	
ListView	FaceName	String	
ListView	FixedLocations 	Boolean 	
ListView	FontCharSet	FontCharSet (enumerated) 	
ListView	FontFamily	FontFamily (enumerated) 	
ListView	FontPitch	FontPitch (enumerated) 	
ListView	Height	Integer	
ListView	HideSelection	Boolean	
ListView	Italic	Boolean	
ListView	Item[ ]	String	
ListView	ItemPictureIndex[ ]	Integer	
ListView	LabelWrap	Boolean 	
ListView	LargePictureHeight 	Integer	
ListView	LargePictureMaskColor	Long	
ListView	LargePictureName[ ]	String	
ListView	LargePictureWidth	Integer	
ListView	Pointer	String	
ListView	Scrolling	Boolean 	
ListView	ShowHeader 	Boolean 	
ListView	SmallPictureHeight 	Integer	
ListView	SmallPictureMaskColor	Long	
ListView	SmallPictureName[ ]	String	
ListView	SmallPictureWidth	Integer	
ListView	SortType	grSortType	
ListView	StatePictureHeight	Integer	
ListView	StatePictureMaskColor	Long	
ListView	StatePictureName[ ]	String	
ListView	StatePictureWidth	Integer	
ListView	TabOrder	Integer	
ListView	Tag	String	
ListView	TextColor	Long	
ListView	TextSize	Integer	
ListView	Underline	Boolean	
ListView	View	ListViewView 	
ListView	Visible	Boolean	
ListView	Weight	Integer	
ListView	Width	Integer	
ListView	X	Integer	
ListView	Y	Integer	
MultiLineEdit 	Accelerator	Integer	
MultiLineEdit 	Alignment	Alignment (enumerated)	
MultiLineEdit 	AutoHScroll	Boolean	
MultiLineEdit 	AutoVScroll	Boolean	
MultiLineEdit 	BackColor	Long	
MultiLineEdit 	Border	Boolean	
MultiLineEdit 	BorderStyle	BorderStyle (enumerated)	
MultiLineEdit 	BringToTop	Boolean	
MultiLineEdit 	DisplayOnly	Boolean	
MultiLineEdit 	DragAuto	Boolean	
MultiLineEdit 	DragIcon	String	
MultiLineEdit 	Enabled	Boolean	
MultiLineEdit 	FaceName	String	
MultiLineEdit 	FontCharSet	FontCharSet (enumerated)	
MultiLineEdit 	FontFamily	FontFamily (enumerated)	
MultiLineEdit 	FontPitch	FontPitch (enumerated)	
MultiLineEdit 	Height	Integer	
MultiLineEdit 	HideSelection	Boolean	
MultiLineEdit 	HScrollBar	Boolean	
MultiLineEdit 	IgnoreDefaultButton	Boolean	
MultiLineEdit 	Italic	Boolean	
MultiLineEdit 	Limit	Integer	
MultiLineEdit 	Pointer	String	
MultiLineEdit 	RightToLeft	Boolean	
MultiLineEdit 	TabOrder	Integer	
MultiLineEdit 	TabStop[ ]	Integer	
MultiLineEdit 	Tag	String	
MultiLineEdit 	Text	String	
MultiLineEdit 	TextCase	TextCase (enumerated)	
MultiLineEdit 	TextColor	Long	
MultiLineEdit 	TextSize	Integer	
MultiLineEdit 	Underline	Boolean	
MultiLineEdit 	Visible	Boolean	
MultiLineEdit 	VScrollBar	Boolean	
MultiLineEdit 	Weight	Integer	
MultiLineEdit 	Width	Integer	
MultiLineEdit 	X	Integer	
MultiLineEdit 	Y	Integer	
OLEControl 	Activation	omActivation	
OLEControl 	BackColor	Long	
OLEControl 	Border	Boolean	
OLEControl 	BorderStyle	BorderStyle (enumerated)	
OLEControl 	BringToTop	Boolean	
OLEControl 	ClassLongName	String	
OLEControl 	ClassShortName	String	
OLEControl 	ContentsAllowed	omContents	
OLEControl 	Allowed	Specifies whether the OLE object in the control must be embedded or linked or whether either method is allowed when Insert is called at runtime.	
OLEControl 	DisplayName	String	
OLEControl 	DisplayType	omDisplayType	
OLEControl 	DocFileName	String	
OLEControl 	DragAuto	Boolean	
OLEControl 	DragIcon	String	
OLEControl 	Enabled	Boolean	
OLEControl 	FocusRectangle	Boolean	
OLEControl 	Height	Integer	
OLEControl 	IsDragTarget	Boolean	
OLEControl 	LinkItem	String	
OLEControl 	LinkUpdateOptions	omLinkUpdateOptions	
OLEControl 	Object	omObject	
OLEControl 	ObjectData	Blob	
OLEControl 	ParentStorage	omStorage	
OLEControl 	Pointer	String	
OLEControl 	Resizable	Boolean	
OLEControl 	TabOrder	Integer	
OLEControl 	Tag	String	
OLEControl 	Visible	Boolean	
OLEControl 	Width	Integer	
OLEControl 	X	Integer	
OLEControl 	Y	Integer	
OLECustomControl 	Alignment	Alignment (enumerated)	
OLECustomControl 	BackColor	Long	
OLECustomControl 	Border	Boolean	
OLECustomControl 	BorderStyle	BorderStyle (enumerated)	
OLECustomControl 	BringToTop	Boolean	
OLECustomControl 	Cancel	Boolean	
OLECustomControl 	ClassLongName	String	
OLECustomControl 	ClassShortName	String	
OLECustomControl 	DisplayName	String	
OLECustomControl 	Default	Boolean	
OLECustomControl 	DragAuto	Boolean	
OLECustomControl 	DragIcon	String	
OLECustomControl 	Enabled	Boolean
OLECustomControl 	FaceName	String
OLECustomControl 	FocusRectangle	Boolean
OLECustomControl 	FontCharSet	FontCharSet (enumerated)
OLECustomControl 	FontFamily	FontFamily (enumerated)
OLECustomControl 	FontPitch	FontPitch (enumerated)
OLECustomControl 	Height	Integer
OLECustomControl 	IsDragTarget	Boolean
OLECustomControl 	Italic	Boolean
OLECustomControl 	Object	omObject
OLECustomControl 	Pointer	String
OLECustomControl 	TabOrder	Integer
OLECustomControl 	Tag	String
OLECustomControl 	TextColor	Long
OLECustomControl 	TextSize	Integer
OLECustomControl 	Underline	Boolean
OLECustomControl 	Visible	Boolean	
OLECustomControl 	Weight	Integer	
OLECustomControl 	Width	Integer	
OLECustomControl 	X	Integer	
OLECustomControl 	Y	Integer	
Oval 	FillColor	Long	
Oval 	FillPattern	FillPattern (enumerated)	
Oval 	Height	Integer	
Oval 	LineColor	Long	
Oval 	LineStyle	LineStyle (enumerated)	
Oval 	LineThickness	Integer	
Oval 	Tag	String	
Oval 	Visible	Boolean	
Oval 	Width	Integer	
Oval 	X	Integer	
Oval 	Y	Integer	
Picture 	Border	Boolean	
Picture 	BorderStyle	BorderStyle (enumerated)	
Picture 	BringToTop	Boolean	
Picture 	DragAuto	Boolean	
Picture 	DragIcon	String	
Picture 	Enabled	Boolean	
Picture 	FocusRectangle	Boolean	
Picture 	Height	Integer	
Picture 	Invert	Boolean	
Picture 	OriginalSize	Boolean	
Picture 	PictureName	String	
Picture 	Pointer	String	
Picture 	TabOrder	Integer	
Picture 	Tag	String	
Picture 	Visible	Boolean	
Picture 	Width	Integer	
Picture 	X	Integer	
Picture 	Y	Integer	
PictureButton 	HTextAlign	Alignment (enumerated)	
PictureButton 	BringToTop	Boolean	
PictureButton 	Cancel	Boolean	
PictureButton 	Default	Boolean	
PictureButton 	DisabledName	String	
PictureButton 	DragAuto	Boolean	
PictureButton 	DragIcon	String	
PictureButton 	Enabled	Boolean	
PictureButton 	FaceName	String	
PictureButton 	FontCharSet	FontCharSet (enumerated)	
PictureButton 	FontFamily	FontFamily (enumerated)	
PictureButton 	FontPitch	FontPitch (enumerated)	
PictureButton 	Height	Integer	
PictureButton 	Italic	Boolean	
PictureButton 	OriginalSize	Boolean	
PictureButton 	PictureName	String	
PictureButton 	Pointer	String	
PictureButton 	TabOrder	Integer	
PictureButton 	Tag	String	
PictureButton 	Text	String	
PictureButton 	TextSize	Integer	
PictureButton 	Underline	Boolean	
PictureButton 	Visible	Boolean	
PictureButton 	VTextAlign	VTextAlign (enumerated)	
PictureButton 	Weight	Integer	
PictureButton 	Width	Integer	
PictureButton 	X	Integer	
PictureButton 	Y	Integer	
PictureListBox	Accelerator	Integer	
PictureListBox	BackColor	Long	
PictureListBox	Border	Boolean	
PictureListBox	BorderStyle	BorderStyle (enumerated)	
PictureListBox	BringToTop	Boolean	
PictureListBox	DisableNoScroll	Boolean	
PictureListBox	DragAuto	Boolean	
PictureListBox	DragIcon	String	
PictureListBox	Enabled	Boolean	
PictureListBox	ExtendedSelect	Boolean	
PictureListBox	FaceName	String	
PictureListBox	FontCharSet	FontCharSet (enumerated)	
PictureListBox	FontFamily	FontFamily (enumerated)	
PictureListBox	FontPitch	FontPitch (enumerated)	
PictureListBox	Height	Integer	
PictureListBox	HScrollBar	Boolean	
PictureListBox	Italic	Boolean	
PictureListBox	Item[ ]	String	
PictureListBox	ItemPictureIndex[ ]	Integer	
PictureListBox	MultiSelect	Boolean	
PictureListBox	PictureHeight	Integer	
PictureListBox	PictureWidth	Integer	
PictureListBox	PictureMaskColor	Long	
PictureListBox	PictureName[ ]	String	
PictureListBox	Pointer	String	
PictureListBox	RightToLeft	Boolean	
PictureListBox	Sorted	Boolean	
PictureListBox	TabOrder	Integer	
PictureListBox	TabStop[ ]	Integer array	
PictureListBox	Tag	String	
PictureListBox	TextColor	Long	
RadioButton	Automatic	Boolean	
RadioButton	BackColor	Long	
RadioButton	BorderStyle	BorderStyle (enumerated)	
RadioButton	BringToTop	Boolean	
RadioButton	Checked	Boolean	
RadioButton	DragAuto	Boolean	
RadioButton	DragIcon	String	
RadioButton	Enabled	Boolean	
RadioButton	FaceName	String	
RadioButton	FontCharSet	FontCharSet (enumerated)	
RadioButton	FontFamily	FontFamily (enumerated)	
RadioButton	FontPitch	FontPitch (enumerated)	
RadioButton	Height	Integer	
RadioButton	Italic	Boolean	
RadioButton	LeftText	Boolean	
RadioButton	Pointer	String	
RadioButton	RightToLeft	Boolean	
RadioButton	TabOrder	Integer	
RadioButton	Tag	String	
RadioButton	Text	String	
RadioButton	TextColor	Long	
RadioButton	TextSize	Integer	
RadioButton	Underline	Boolean	
RadioButton	Visible	Boolean	
RadioButton	Weight	Integer	
RadioButton	Width	Integer	
RadioButton	X	Integer	
RadioButton	Y	Integer	
Rectangle 	FillColor	Long	
Rectangle 	FillPattern	FillPattern (enumerated)	
Rectangle 	Height	Integer	
Rectangle 	LineColor	Long	
Rectangle 	LineStyle	LineStyle (enumerated)	
Rectangle 	LineThickness	Integer	
Rectangle 	Tag	String	
Rectangle 	Visible	Boolean	
Rectangle 	Width	Integer	
Rectangle 	X	Integer	
Rectangle 	Y	Integer	
RichTextEdit 	Accelerator	Integer	
RichTextEdit 	BackColor	Long	
RichTextEdit 	Border	Boolean	
RichTextEdit 	BorderStyle	BorderStyle (enumerated)	
RichTextEdit 	BottomMargin	Long	
RichTextEdit 	BringToTop	Boolean	
RichTextEdit 	DisplayOnly	Boolean	
RichTextEdit 	DocumentName	String	
RichTextEdit 	DragAuto	Boolean	
RichTextEdit 	DragIcon	String	
RichTextEdit 	Enabled	Boolean	
RichTextEdit 	HeaderFooter	Boolean	
RichTextEdit 	Height	Integer	
RichTextEdit 	HScrollBar	Boolean	
RichTextEdit 	InputFieldBackColor	Long	
RichTextEdit 	InputFieldNamesVisible	Boolean	
RichTextEdit 	InputFieldsVisible	Boolean	
RichTextEdit 	LeftMargin	Long	
RichTextEdit 	Modified	Boolean	
RichTextEdit 	PicturesAsFrame	Boolean	
RichTextEdit 	Pointer	String	
RichTextEdit 	PopMenu	Boolean	
RichTextEdit 	Resizable	Boolean	
RichTextEdit 	ReturnsVisible	Boolean	
RichTextEdit 	RightMargin	Long	
RichTextEdit 	RulerBar	Boolean	
RichTextEdit 	SpacesVisible	Boolean	
RichTextEdit 	TabBar	Boolean	
RichTextEdit 	TabOrder	Integer	
RichTextEdit 	TabsVisible	Boolean	
RichTextEdit 	Tag	String	
RichTextEdit 	ToolBar	Boolean	
RichTextEdit 	TopMargin	Long	
RichTextEdit 	UndoDepth	Integer	
RichTextEdit 	Visible	Boolean	
RichTextEdit 	VScrollBar	Boolean	
RichTextEdit 	Width	Integer	
RichTextEdit 	WordWrap	Boolean	
RichTextEdit 	X	Integer	
RichTextEdit 	Y	Integer	
RoundRectangle 	CornerHeight	Integer	
RoundRectangle 	CornerWidth	Integer	
RoundRectangle 	FillColor	Long	
RoundRectangle 	FillPattern	FillPattern (enumerated)	
RoundRectangle 	Height	Integer	
RoundRectangle 	LineColor	Long	
RoundRectangle 	LineStyle	LineStyle (enumerated)	
RoundRectangle 	LineThickness	Integer	
RoundRectangle 	Tag	String	
RoundRectangle 	Visible	Boolean	
RoundRectangle 	Width	Integer	
RoundRectangle 	X	Integer	
RoundRectangle 	Y	Integer	
SingleLineEdit	Accelerator	Integer	
SingleLineEdit	AutoHScroll	Boolean	
SingleLineEdit	BackColor	Long	
SingleLineEdit	Border	Boolean	
SingleLineEdit	BorderStyle	BorderStyle (enumerated)	
SingleLineEdit	BringToTop	Boolean	
SingleLineEdit	DisplayOnly	Boolean	
SingleLineEdit	DragAuto	Boolean	
SingleLineEdit	DragIcon	String	
SingleLineEdit	Enabled	Boolean	
SingleLineEdit	FaceName	String	
SingleLineEdit	FontCharSet	FontCharSet (enumerated)	
SingleLineEdit	FontFamily	FontFamily (enumerated)	
SingleLineEdit	FontPitch	FontPitch (enumerated)	
SingleLineEdit	Height	Integer	
SingleLineEdit	HideSelection	Boolean	
SingleLineEdit	Italic	Boolean	
SingleLineEdit	Limit	Integer	
SingleLineEdit	Password	Boolean	
SingleLineEdit	Pointer	String	
SingleLineEdit	RightToLeft	Boolean	
SingleLineEdit	TabOrder	Integer	
SingleLineEdit	Tag	String	
SingleLineEdit	Text	String	
SingleLineEdit	TextCase	TextCase (enumerated)	
SingleLineEdit	TextColor	Long	
SingleLineEdit	TextSize	Integer	
SingleLineEdit	Underline	Boolean	
SingleLineEdit	Visible	Boolean	
SingleLineEdit	Weight	Integer	
SingleLineEdit	Width	Integer	
SingleLineEdit	X	Integer	
SingleLineEdit	Y	Integer	
StaticText 	Alignment	Alignment (enumerated)	
StaticText 	BackColor	Long	
StaticText 	Border	Boolean	
StaticText 	BorderColor	Long	
StaticText 	BorderStyle	BorderStyle (enumerated)	
StaticText 	BringToTop	Boolean	
StaticText 	DragAuto	Boolean	
StaticText 	DragIcon	String	
StaticText 	Enabled	Boolean	
StaticText 	FaceName	String	
StaticText 	FillPattern	FillPattern (enumerated)	
StaticText 	FocusRectangle	Boolean	
StaticText 	FontCharSet	FontCharSet (enumerated)	
StaticText 	FontFamily	FontFamily (enumerated)	
StaticText 	FontPitch	FontPitch (enumerated)	
StaticText 	Height	Integer	
StaticText 	Italic	Boolean	
StaticText 	Pointer	String	
StaticText 	RightToLeft	Boolean	
StaticText 	TabOrder	Integer	
StaticText 	Tag	String	
StaticText 	Text	String	
StaticText 	TextColor	Long	
StaticText 	TextSize	Integer	
StaticText 	Underline	Boolean	
StaticText 	Visible	Boolean	
StaticText 	Weight	Integer	
StaticText 	Width	Integer	
StaticText 	X	Integer	
StaticText 	Y	Integer	
Tab	Alignment	Alignment (enumerated)	
Tab	BackColor	Long	
Tab	BoldSelectedText	Boolean	
Tab	BringToTop	Boolean	
Tab	CreateOnDemand	Boolean	
Tab	Control[ ]	UserObject	
Tab	DragAuto	Boolean	
Tab	DragIcon	String	
Tab	Enabled	Boolean	
Tab	FaceName	String	
Tab	FixedWidth	Boolean	
Tab	FocusOnButtonDown	Boolean	
Tab	FontCharSet	FontCharSet (enumerated)	
Tab	FontFamily	FontFamily (enumerated)	
Tab	FontPitch	FontPitch (enumerated)	
Tab	Height	Integer	
Tab	Italic	Boolean	
Tab	Multiline	Boolean	
Tab	PerpendicularText	Boolean	
Tab	PictureOnRight	Boolean	
Tab	Pointer	String	
Tab	PowerTips	Boolean	
Tab	RaggedRight	Boolean	
Tab	SelectedTab	Integer	
Tab	ShowPicture	Boolean	
Tab	ShowText	Boolean	
Tab	TabOrder	Integer	
Tab	TabPosition	TabPosition (enumerated)	
Tab	Tag	String	
Tab	TextSize	Integer	
Tab	Underline	Boolean	
Tab	Visible	Boolean	
Tab	Weight	Integer	
Tab	Width	Integer	
Tab	X	Integer	
Tab	Y	Integer	
TreeView	Accelerator	Integer	
TreeView	BackColor	Long	
TreeView	Border	Boolean 	
TreeView	BorderStyle	BorderStyle (enumerated)	
TreeView	BringToTop	Boolean 	
TreeView	DeleteItems	Boolean 	
TreeView	DisableDragDrop	Boolean 	
TreeView	DragAuto 	Boolean 	
TreeView	DragIcon	String	
TreeView	EditLabels	Boolean 	
TreeView	Enabled	Boolean	
TreeView	FaceName	String	
TreeView	FontCharSet	FontCharSet (enumerated)	
TreeView	FontFamily	FontFamily (enumerated)	
TreeView	FontPitch	FontPitch (enumerated)	
TreeView	HasButtons	Boolean 	
TreeView	HasLines	Boolean 	
TreeView	Height	Integer	
TreeView	HideSelection	Boolean	
TreeView	Indent	Integer	
TreeView	Italic	Boolean	
TreeView	LinesAtRoot	Boolean 	
TreeView	PictureHeight	Integer	
TreeView	PictureMaskColor	Long	
TreeView	PictureName	String	
TreeView	PictureWidth	Integer	
TreeView	Pointer	String	
TreeView	SortType	grSortType	
TreeView	StatePictureHeight	Integer	
TreeView	StatePictureMask- 		
TreeView	Color	Long	
TreeView	StatePictureName	String	
TreeView	StatePictureWidth	Integer	
TreeView	TabOrder	Integer	
TreeView	Tag	String	
TreeView	TextColor	Long	
TreeView	TextSize	Integer	
TreeView	Underline	Boolean	
TreeView	Visible	Boolean	
TreeView	Weight	Integer	
TreeView	Width	Integer	
TreeView	X	Integer	
TreeView	Y	Integer	
UserObject 	BackColor	Long	
UserObject 	Border	Boolean	
UserObject 	BorderStyle	BorderStyle (enumerated)	
UserObject 	BringToTop	Boolean	
UserObject 	ClassName	String	
UserObject 	ColumnsPerPage	Integer	
UserObject 	Control[ ]	WindowObject	
UserObject 	DragAuto	Boolean	
UserObject 	DragIcon	String	
UserObject 	Enabled	Boolean	
UserObject 	Height	Integer	
UserObject 	HScrollBar	Boolean	
UserObject 	LibraryName	String	
UserObject 	LinesPerPage	Integer	
UserObject 	ObjectType	UserObjects (enumerated)	
UserObject 	PictureMaskColor	Long	
UserObject 	PictureName	String	
UserObject 	Pointer	String	
UserObject 	PowerTipText	String	
UserObject 	Style	Long	
UserObject 	TabBackColor	Long	
UserObject 	TabTextColor	Long	
UserObject 	TabOrder	Integer	
UserObject 	Tag	String	
UserObject 	Text	String	
UserObject 	UnitsPerColumn	Integer	
UserObject 	UnitsPerLine	Integer	
UserObject 	Visible	Boolean	
UserObject 	VScrollBar	Boolean	
UserObject 	Width	Integer	
UserObject 	X	Integer	
UserObject 	Y	Integer	
VScrollBar 	BringToTop	Boolean	
VScrollBar 	DragAuto	Boolean	
VScrollBar 	DragIcon	String	
VScrollBar 	Height	Integer	
VScrollBar 	MaxPosition	Integer	
VScrollBar 	MinPosition	Integer	
VScrollBar 	Pointer	String	
VScrollBar 	Position	Integer	
VScrollBar 	StdWidth	Boolean	
VScrollBar 	TabOrder	Integer	
VScrollBar 	Tag	String	
VScrollBar 	Visible	Boolean	
VScrollBar 	Width	Integer	
VScrollBar 	X	Integer	
VScrollBar 	Y	Integer	
Application	AppName	String	
Application	DDETimeOut	Integer	
Application	DisplayName	String	
Application	DWMessageTitle	String	
Application	MicroHelpDefault	String	
Application	RightToLeft	Boolean	
Application	ToolbarFrameTitle	String	
Application	ToolbarPopMenuText	String	
Application	ToolbarSheetTitle	String	
Application	ToolbarText	Boolean	
Application	ToolbarTips	Boolean	
Application	ToolbarUserControl	Boolean	
ArrayBounds 	ClassDefinition	PowerObject	
ArrayBounds 	LowerBound	Long	
ArrayBounds 	UpperBound	Long	
ClassDefinition	Ancestor	ClassDefinition	
ClassDefinition	Category	TypeCategory	
ClassDefinition	ClassDefinition	PowerObject	
ClassDefinition	DataTypeOf	String	
ClassDefinition	IsAutoinstantiate	Boolean	
ClassDefinition	IsStructure	Boolean	
ClassDefinition	IsSystemType	Boolean	
ClassDefinition	IsVariableLength	Boolean	
ClassDefinition	IsVisualType	Boolean	
ClassDefinition	LibraryName	String	
ClassDefinition	Name	String	
ClassDefinition	NestedClassList[ ]	ClassDefinition	
ClassDefinition	ParentClass	ClassDefinition	
ClassDefinition	ScriptList[ ]	ScriptDefinition	
ClassDefinition	VariableList[ ]	VariableDefinition	
Connection	Application	String	
Connection	ConnectString	String	
Connection	Driver	String	
Connection	ErrCode	Long	
Connection	ErrText	String	
Connection	Location	String	
Connection	Options	String	
Connection	Password	String	
Connection	Trace	String	
Connection	UserID	String	
ConnectionInfo 	Busy	Boolean
ConnectionInfo 	CallCount	Long
ConnectionInfo 	ClientID	String
ConnectionInfo 	ConnectTime	DateTime
ConnectionInfo 	ConnectUserID	String
ConnectionInfo 	LastCallTime	DateTime
ConnectionInfo 	Location	String
ConnectionInfo 	UserID	String
ContextInformation	ClassDefinition	PowerObject
ContextKeyword	ClassDefinition	PowerObject
CPlusPlus 	LibraryName	String
DataStore 	DataObject	String	
DataStore 	Object	DWObject	
DynamicDescriptionArea 	NumInputs	Integer	
DynamicDescriptionArea 	NumOutputs	Integer	
DynamicDescriptionArea 	InParmType[ ]	ParmType (enumerated)	
DynamicDescriptionArea 	OutParmType[ ]	ParmType (enumerated)	
EnumerationDefinition	Category 	TypeCategory	
EnumerationDefinition	ClassDefinition	PowerObject	
EnumerationDefinition	DataTypeOf	String	
EnumerationDefinition	Enumeration[ ]	Enumeration-	
EnumerationDefinition	ItemDefinition	An array of the name-value pairs for all the items in the enumeration.	
EnumerationDefinition	IsStructure	Boolean	
EnumerationDefinition	IsSystemType 	Boolean	
EnumerationDefinition	 IsVariableLength	Boolean	
EnumerationDefinition	IsVisualType	Boolean	
EnumerationDefinition	LibraryName	String	
EnumerationDefinition	Name	String	
EnumerationItemDefinition	ClassDefinition	PowerObject	
EnumerationItemDefinition	Name	String	
EnumerationItemDefinition	Value	Long	
Environment	CPUType	CPUTypes (enumerated)	
Environment	MachineCode	Boolean	
Environment	OSFixesRevision	Integer	
Environment	OSMajorRevision	Integer	
Environment	OSMinorRevision	Integer	
Environment	PBFixesRevision	Integer	
Environment	PBMajorRevision	Integer	
Environment	PBMinorRevision	Integer	
Environment	NumberOfColors	Long
Environment	ScreenHeight	Long
Environment	ScreenWidth	Long
Environment	OSType	OSTypes (enumerated)
Environment	PBType	PBTypes (enumerated)
Environment	Win16	Boolean
Error	Line	Integer
Error	Number	Integer
Error	Object	String
Error	ObjectEvent	String
Error	Text	String
Error	WindowMenu	String
grAxis	AutoScale	Boolean
grAxis	DataType	grAxisDataType(enumerated)
grAxis	DisplayAttr	grDispAttr (object)
grAxis	DisplayEveryNLabels	Integer
grAxis	DropLines	LineStyle (enumerated)
grAxis	Frame	LineStyle (enumerated)
grAxis	Label	String
grAxis	LabelDispAttr	grDispAttr (object)
grAxis	MajorDivisions	Integer
grAxis	MajorGridLine	LineStyle (enumerated)
grAxis	MajorTic	grTicType (enumerated)
grAxis	MaximumValue	Double
grAxis	MaxValDateTime	DateTime
grAxis	MinimumValue	Double
grAxis	MinorDivisions	Integer
grAxis	MinorGridLine	LineStyle (enumerated)
grAxis	MinorTic	grTicType (enumerated)
grAxis	MinValDateTime	DateTime
grAxis	OriginLine	LineStyle (enumerated)	
grAxis	PrimaryLine	LineStyle (enumerated)	
grAxis	RoundTo	Double	
grAxis	RoundToUnitTo	grRoundToType (enumerated)	
grAxis	ScaleType	grScaleType (enumerated)	
grAxis	ScaleValue	grScaleValue (enumerated)	
grAxis	SecondaryLine	LineStyle (enumerated)	
grAxis	ShadeBackEdge	Boolean	
grDispAttr	Alignment	Alignment (enumerated)	
grDispAttr	AutoSize	Boolean	
grDispAttr	BackColor	Long	
grDispAttr	DisplayExpression	String	
grDispAttr	Escapement	Integer	
grDispAttr	FaceName	String	
grDispAttr	FillPattern	FillPattern (enumerated)	
grDispAttr	FontCharSet	FontCharSet (enumerated)
grDispAttr	FontFamily	FontFamily (enumerated)
grDispAttr	FontPitch	FontPitch (enumerated)
grDispAttr	Format	String
grDispAttr	Italic	Boolean
grDispAttr	TextColor	Long
grDispAttr	TextSize	Integer
grDispAttr	Underline	Boolean
grDispAttr	Weight	Integer
Inet	ClassDefinition	PowerObject
InternetResult 	lassDefinition	PowerObject
ListViewItem 	CutHighlighted	Boolean 
ListViewItem 	Data	Any
ListViewItem 	DropHighlighted	Boolean 
ListViewItem 	HasFocus	Boolean 
ListViewItem 	ItemX	Integer
ListViewItem 	ItemY	Integer
ListViewItem 	Label	String
ListViewItem 	OverlayPictureIndex	Integer
ListViewItem 	PictureIndex	Integer
ListViewItem 	Selected	Boolean 
ListViewItem 	StatePictureIndex	Integer
mailFileDescription	FileType	mailFileType(enumerated) 
mailFileDescription	Filename	String
mailFileDescription	Pathname	String
mailFileDescription	Position	Unsignedlong
mailMessage 	AttachmentFile[ ]	mailFileDescription
mailMessage 	ConversationID	String
mailMessage 	DateReceived	String
mailMessage 	MessageSent	Boolean
mailMessage 	MessageType	String
mailMessage 	NoteText	String
mailMessage 	ReceiptRequested	Boolean
mailMessage 	Recipient[ ]	mailRecipient
mailMessage 	Subject	String
mailMessage 	Unread	Boolean
mailRecipient 	Address	String
mailRecipient 	EntryID	Blob
mailRecipient 	Name	String
mailRecipient 	RecipientType	mailRecipientType (enumerated)
mailSession 	MessageID[ ]	String
mailSession 	SessionID	Long
MDIClient 	BackColor	Long
MDIClient 	BringToTop	Boolean
MDIClient 	Height	Integer
MDIClient 	MicroHelpHeight	Integer
MDIClient 	Tag	String
MDIClient 	Visible	Boolean
MDIClient 	Width	Integer
MDIClient 	X	Integer
MDIClient 	Y	Integer
Menu	Checked	Boolean
Menu	Enabled	Boolean
Menu	Item[ ]	Menu
Menu	MenuItemType	MenuItemType (enumerated)
Menu	MergeOption	MenuMerge Option (enumerated)	
Menu	MicroHelp	String	
Menu	ParentWindow	Window	
Menu	ShiftToRight	Boolean	
Menu	Shortcut	Integer	
Menu	Tag	String	
Menu	Text	String	
Menu	ToolbarItemDown	Boolean	
Menu	ToolbarItemDownName	String	
Menu	ToolbarItemBarIndex	Integer	
Menu	ToolbarItemName	String	
Menu	ToolbarItemOrder	Integer	
Menu	ToolbarItemSpace	Integer	
Menu	ToolbarItemText	String	
Menu	ToolbarItemVisible	Boolean	
Menu	Visible	Boolean	
MenuCascade 	Checked	Boolean	
MenuCascade 	Columns	Integer	
MenuCascade 	CurrentItem	Menu	
MenuCascade 	DropDown	Boolean	
MenuCascade 	Enabled	Boolean	
MenuCascade 	Item[ ]	Menu	
MenuCascade 	MenuItemType	MenuItemType (enumerated)	
MenuCascade 	MergeOption	MenuMergeOption (enumerated) 	
MenuCascade 	"This and other OLE functions are only available on the Windows platform.? For more information about MergeOption, see the chapter on using OLE in Application Techniques."		
MenuCascade 	MicroHelp	String	
MenuCascade 	ParentWindow	Window	
MenuCascade 	ShiftToRight	Boolean	
MenuCascade 	Shortcut	Integer	
MenuCascade 	Tag	String	
MenuCascade 	Text	String	
MenuCascade 	ToolbarItemDown	Boolean	
MenuCascade 	ToolbarItemDownName	String	
MenuCascade 	ToolbarItemBarIndex	Integer	
MenuCascade 	ToolbarItemName	String	
MenuCascade 	ToolbarItemOrder	Integer	
MenuCascade 	ToolbarItemSpace	Integer	
MenuCascade 	ToolbarItemText	String	
MenuCascade 	ToolbarItemVisible	Boolean	
MenuCascade 	Visible	Boolean	
Message 	Handle	Long	
Message 	Number	UnsignedInt	
Message 	WordParm	Long	
Message 	LongParm	Long	
Message 	DoubleParm	Double	
Message 	StringParm	String	
Message 	PowerObjectParm	PowerObject	
Message 	Processed	Boolean	
Message 	ReturnValue	Long	
OLEStorage 	DocumentName	String	
OLEStream 	Name	String	
OLEStream 	Storage	OMStorage	
Pipeline 	DataObject	String	
Pipeline 	RowsInError	Long	
Pipeline 	RowsRead	Long	
Pipeline 	RowsWritten	Long	
Pipeline 	Syntax	String	
ProfileCall	AbsoluteSelfTime	Decimal	
ProfileCall	AbsoluteTotalTime	Decimal
ProfileCall	CalledRoutine	ProfileRoutine
ProfileCall	CallingLine	ProfileLine
ProfileCall	CallingRoutine	ProfileRoutine
ProfileCall	HitCount	Long 
ProfileCall	PercentCalleeSelfTime	Double 
ProfileCall	PercentCalleeTotalTime	Double
ProfileCall	PercentCallerTotalTime	Double 
ProfileClass 	LibraryName	String
ProfileClass 	Name	String
ProfileLine	AbsoluteSelfTime	Decimal
ProfileLine	AbsoluteTotalTime	Decimal
ProfileLine	HitCount	Long
ProfileLine	LineNumber	Long
ProfileLine	MaxSelfTime	Decimal	
ProfileLine	MaxTotalTime	Decimal	
ProfileLine	MinSelfTime	Decimal	
ProfileLine	MinTotalTime	Decimal	
ProfileLine	PercentSelfTime	Double	
ProfileLine	PercentTotalTime	Double	
ProfileLine	Routine	ProfileRoutine	
ProfileRoutine 	AbsoluteSelfTime	Decimal	
ProfileRoutine 	AbsoluteTotalTime	Decimal	
ProfileRoutine 	Class	ProfileClass	
ProfileRoutine 	HitCount	Long	
ProfileRoutine 	Kind	ProfileRoutineKind (enumerated) 	
ProfileRoutine 	MaxSelfTime	Decimal	
ProfileRoutine 	MaxTotalTime	Decimal	
ProfileRoutine 	MinSelfTime	Decimal	
ProfileRoutine 	MinTotalTime	Decimal	
ProfileRoutine 	Name	String 	
ProfileRoutine 	PercentSelfTime	Double	
ProfileRoutine 	PercentTotalTime	Double	
Profiling	ApplicationName	String	
Profiling	CollectionTime	Decimal	
Profiling	NumberOfActivities	Long	
Profiling	TraceFileName	String	
ScriptDefinition 	Access	VarAccess	
ScriptDefinition 	AliasName	String	
ScriptDefinition 	ArgumentList	VariableDefinition	
ScriptDefinition 	ClassDefinition	PowerObject	
ScriptDefinition 	EventId	Long	
ScriptDefinition 	EventIdName	String	
ScriptDefinition 	ExternalUserFunction	String	
ScriptDefinition 	IsExternalEvent	Boolean	
ScriptDefinition 	IsLocallyDefined	Boolean	
ScriptDefinition 	IsLocallyScripted	Boolean	
ScriptDefinition 	IsRPCFunction	Boolean	
ScriptDefinition 	IsScripted	Boolean	
ScriptDefinition 	Kind	ScriptKind 	
ScriptDefinition 	LocalVariableList	VariableDefinition	
ScriptDefinition 	Name	String	
ScriptDefinition 	ReturnType	TypeDefinition	
ScriptDefinition 	Source	String	
ScriptDefinition 	SystemFunction	String	
TraceActivityNode	ActivityType	TraceActivity (enumerated)	
TraceActivityNode	Category	TraceCategory (enumerated)	
TraceActivityNode	TimerValue	Decimal	
TraceBeginEnd	ActivityType	TraceActivity (enumerated)
TraceBeginEnd	Category	TraceCategory (enumerated)
TraceBeginEnd	Message	String
TraceBeginEnd	TimerValue	Decimal
TraceError	ActivityType	TraceActivity (enumerated)
TraceError	Category	TraceCategory (enumerated)
TraceError	Message	String
TraceError	Severity	Long
TraceError	TimerValue	Decimal
TraceESQL 	ActivityNode	TraceActivity
TraceESQL 	Category	TraceCategory
TraceESQL 	Name	String
TraceESQL 	TimerValue	Decimal
TraceFile	ApplicationName	String	
TraceFile	CollectionTime	Decimal	
TraceFile	LastError	ErrorReturn (enumerated)	
TraceFile	NumberOfActivities	Long	
TraceFile	FileName	String	
TraceGarbageCollect	ActivityType	TraceActivity (enumerated)	
TraceGarbageCollect	Category	TraceCategory (enumerated)	
TraceGarbageCollect	TimerValue	Decimal	
TraceLine	ActivityType	TraceActivity (enumerated)	
TraceLine	Category	TraceCategory (enumerated)	
TraceLine	LineNumber	UnsignedLong	
TraceLine	TimerValue	Decimal	
TraceObject	ActivityType	TraceActivity (enumerated)
TraceObject	Category	TraceCategory (enumerated)
TraceObject	ClassName	String
TraceObject	IsCreate	Boolean
TraceObject	LibraryName	String
TraceObject	ObjectID	UnsignedLong
TraceObject	TimerValue	Decimal
TraceRoutine	ActivityType	TraceActivity (enumerated)
TraceRoutine	Category	TraceCategory (enumerated)
TraceRoutine	ClassName	String
TraceRoutine	IsEvent	Boolean
TraceRoutine	LibraryName	String
TraceRoutine	Name	String
TraceRoutine	ObjectID	UnsignedLong
TraceRoutine	TimerValue	Decimal
TraceTree	ApplicationName	String	
TraceTree	CollectionTime	Decimal	
TraceTree	NumberOfActivities	Long	
TraceTree	TraceFileName	String	
TraceTreeError	ActivityType	TraceActivity (enumerated)	
TraceTreeError	Message	String	
TraceTreeError	ParentNode	TraceTreeNode	
TraceTreeError	Severity	Long	
TraceTreeError	TimerValue	Decimal	
TraceTreeESQL 	ActivityNode	TraceActivity (enumerated)	
TraceTreeESQL 	EnterTimerValue	Decimal	
TraceTreeESQL 	ExitTimerValue	Decimal	
TraceTreeESQL 	Name	String	
TraceTreeESQL 	ParentNode	TraceTreeNode	
TraceTreeGarbageCollect 	ActivityType	TraceActivity (enumerated)	
TraceTreeGarbageCollect 	EnterTimerValue	Decimal	
TraceTreeGarbageCollect 	ExitTimerValue	Decimal	
TraceTreeGarbageCollect 	ParentNode	TraceTreeNode	
TraceTreeLine 	ActivityType	TraceActivity (enumerated)	
TraceTreeLine 	LineNumber	UnsignedLong	
TraceTreeLine 	ParentNode	TraceTreeNode	
TraceTreeLine 	TimerValue	Decimal	
TraceTreeNode 	ActivityType	TraceActivity (enumerated)	
TraceTreeNode 	ParentNode	TraceTreeNode	
TraceTreeObject 	ActivityType	TraceActivity (enumerated)	
TraceTreeObject 	ClassName	String
TraceTreeObject 	Create	Boolean
TraceTreeObject 	EnterTimerValue	Decimal
TraceTreeObject 	ExitTimerValue	Decimal 
TraceTreeObject 	LibraryName	String
TraceTreeObject 	ObjectID	UnsignedLong
TraceTreeObject 	ParentNode	TraceTreeNode
TraceTreeRoutine	ActivityType	TraceActivity (enumerated)
TraceTreeRoutine	ClassName	String
TraceTreeRoutine	EnterTimerValue	Decimal
TraceTreeRoutine	ExitTimerValue	Decimal
TraceTreeRoutine	IsEvent	Boolean
TraceTreeRoutine	LibraryName	String
TraceTreeRoutine	Name	String
TraceTreeRoutine	ObjectID	UnsignedLong
TraceTreeRoutine	ParentNode	TraceTreeNode
TraceTreeUser 	ActivityType	TraceActivity (enumerated)
TraceTreeUser 	Argument	Long
TraceTreeUser 	Message	String
TraceTreeUser 	ParentNode	TraceTreeNode
TraceTreeUser 	TimerValue	Decimal
TraceUser	ActivityType	TraceActivity (enumerated)
TraceUser	Argument	Long
TraceUser	Category	TraceCategory (enumerated)
TraceUser	Message	String
TraceUser	TimerValue	Decimal
Timing 	ClassDefinition	PowerObject
Timing 	Interval	Double
Timing 	Running	Boolean
Transaction 	AutoCommit	Boolean
Transaction 	Database	String
Transaction 	DBMS	String
Transaction 	DBParm	String
Transaction 	DBPass	String
Transaction 	Lock	String
Transaction 	LogID	String
Transaction 	LogPass	String
Transaction 	ServerName	String
Transaction 	SQLCode	Long
Transaction 	SQLDBCode	Long
Transaction 	SQLErrText	String
Transaction 	SQLNRows	Long
Transaction 	SQLReturnData	String
Transaction 	UserID	String	
Transport 	Application	String	
Transport 	Driver	String	
Transport 	ErrCode	Long	
Transport 	ErrText	String	
Transport 	Location	String	
Transport 	Options	String	
Transport 	TimeOut	Long	
Transport 	Trace	String	
TreeViewItem	Bold	Boolean 	
TreeViewItem	Children	Boolean 	
TreeViewItem	CutHighLighted	Boolean 	
TreeViewItem	Data	Any	
TreeViewItem	DropHighLighted	Boolean 	
TreeViewItem	Expanded	Boolean 
TreeViewItem	ExpandedOnce	Boolean 
TreeViewItem	HasFocus	Boolean 
TreeViewItem	ItemHandle	Long
TreeViewItem	Label	Label
TreeViewItem	Level	Integer
TreeViewItem	OverlayPictureIndex	Integer
TreeViewItem	PictureIndex	Integer
TreeViewItem	SelectedPictureIndex	Integer
TreeViewItem	Selected	Boolean 
TreeViewItem	StatePictureIndex	Integer
TypeDefinition 	Category 	TypeCategory
TypeDefinition 	ClassDefinition	PowerObject
TypeDefinition 	DataTypeOf	String
TypeDefinition 	IsStructure	Boolean
TypeDefinition 	IsSystemType	Boolean	
TypeDefinition 	IsVariableLength	Boolean	
TypeDefinition 	IsVisualType	Boolean	
TypeDefinition 	LibraryName	String	
TypeDefinition 	Name	String	
UserObject	BackColor	Long	
UserObject	Border	Boolean	
UserObject	BorderStyle	BorderStyle (enumerated)	
UserObject	BringToTop	Boolean	
UserObject	ClassName	String	
UserObject	ColumnsPerPage	Integer	
UserObject	Control[ ]	WindowObject	
UserObject	DragAuto	Boolean	
UserObject	DragIcon	String	
UserObject	Enabled	Boolean	
UserObject	Height	Integer	
UserObject	HScrollBar	Boolean	
UserObject	LibraryName	String	
UserObject	LinesPerPage	Integer	
UserObject	ObjectType	UserObjects (enumerated)	
UserObject	PictureMaskColor	Long	
UserObject	PictureName	String	
UserObject	Pointer	String	
UserObject	PowerTipText	String	
UserObject	Style	Long	
UserObject	TabBackColor	Long	
UserObject	TabTextColor	Long	
UserObject	TabOrder	Integer	
UserObject	Tag	String	
UserObject	Text	String	
UserObject	UnitsPerColumn	Integer	
UserObject	UnitsPerLine	Integer	
UserObject	Visible	Boolean	
UserObject	VScrollBar	Boolean	
UserObject	Width	Integer	
UserObject	X	Integer	
UserObject	Y	Integer	
VariableCardinality 	ArrayDefinition[ ]	ArrayBounds	
VariableCardinality 	Cardinality	VariableCardinalityType	
VariableCardinality 	ClassDefinition	PowerObject	
VariableDefinition 	CallingConvention	ArgCallingConvention	
VariableDefinition 	Cardinality	VariableCardinalityDefinition	
VariableDefinition 	ClassDefinition	PowerObject	
VariableDefinition 	InitialValue	Any	
VariableDefinition 	IsConstant	Boolean	
VariableDefinition 	IsControl	Boolean	
VariableDefinition 	IsUserDefined	Boolean	
VariableDefinition 	Kind	VariableKind	
VariableDefinition 	Name	String	
VariableDefinition 	OverridesAncestorValue	Boolean	
VariableDefinition 	ReadAccess	VarAccess	
VariableDefinition 	TypeInfo	TypeDefinition	
VariableDefinition 	WriteAccess	VarAccess	
Window	BackColor	Long	
Window	Border	Boolean	
Window	BringToTop	Boolean	
Window	ColumnsPerPage	Integer	
Window	Control[ ]	WindowObject	
Window	ControlMenu	Boolean	
Window	Enabled	Boolean	
Window	Height	Integer	
Window	HScrollBar	Boolean	
Window	Icon	String	
Window	KeyboardIcon	Boolean	
Window	LinesPerPage	Integer	
Window	MaxBox	Boolean	
Window	MenuID	Menu	
Window	MenuName	String	
Window	MinBox	Boolean	
Window	Pointer	String	
Window	Resizable	Boolean	
Window	RightToLeft	Boolean	
Window	Tag	String	
Window	Title	String	
Window	TitleBar	Boolean	
Window	ToolbarAlignment	ToolbarAlignment (enumerated) 	
Window	ToolbarHeight	Integer	
Window	ToolbarVisible	Boolean	
Window	ToolbarWidth	Integer	
Window	ToolbarX	Integer	
Window	ToolbarY	Integer	
Window	UnitsPerColumn	Integer	
Window	UnitsPerLine	Integer	
Window	Visible	Boolean	
Window	VScrollBar	Boolean	
Window	Width	Integer	
Window	WindowState	WindowState (enumerated)	
Window	WindowType	WindowType (enumerated)	
Window	X	Integer	
Window	Y	Integer	
----------------------------------------------------------------*/
/*----------------------------------------------------------------
PowerBuilder Object Events
------------------------------------------------------------------
CheckBox	Clicked	  
CheckBox	Constructor	  
CheckBox	Destructor	  
CheckBox	DragDrop	  
CheckBox	DragEnter	  
CheckBox	DragLeave	  
CheckBox	DragWithin	  
CheckBox	GetFocus	  
CheckBox	LoseFocus	  
CheckBox	Other	  
CheckBox	RButtonDown	  
CommandButton	Clicked	  
CommandButton	Constructor	  
CommandButton	Destructor	  
CommandButton	DragDrop	  
CommandButton	DragEnter	  
CommandButton	DragLeave	  
CommandButton	DragWithin	  
CommandButton	GetFocus	  
CommandButton	LoseFocus	  
CommandButton	Other	  
CommandButton	RButtonDown	  
DataWindow 	Clicked	  
DataWindow 	Constructor	  
DataWindow 	DBError	  
DataWindow 	Destructor	  
DataWindow 	DoubleClicked	  
DataWindow 	DragDrop	  
DataWindow 	DragEnter	  
DataWindow 	DragLeave	  
DataWindow 	DragWithin	  
DataWindow 	EditChanged	  
DataWindow 	Error	  
DataWindow 	GetFocus	  
DataWindow 	ItemChanged	  
DataWindow 	ItemError	  
DataWindow 	ItemFocusChanged	  
DataWindow 	LoseFocus	  
DataWindow 	Other	  
DataWindow 	PrintEnd	  
DataWindow 	PrintPage	  
DataWindow 	PrintStart	  
DataWindow 	RButtonDown	  
DataWindow 	Resize	  
DataWindow 	RetrieveEnd	  
DataWindow 	RetrieveRow	  
DataWindow 	RetrieveStart	  
DataWindow 	RowFocusChanged	  
DataWindow 	ScrollHorizontal	  
DataWindow 	ScrollVertical	  
DataWindow 	SQLPreview	  
DataWindow 	UpdateEnd	  
DataWindow 	UpdateStart	  
DropDownListBox	Constructor	  
DropDownListBox	Destructor	  
DropDownListBox	DoubleClicked	  
DropDownListBox	DragDrop	  
DropDownListBox	DragEnter	  
DropDownListBox	DragLeave	  
DropDownListBox	DragWithin	  
DropDownListBox	GetFocus	  
DropDownListBox	LoseFocus	  
DropDownListBox	Modified	  
DropDownListBox	Other	  
DropDownListBox	RButtonDown	  
DropDownListBox	SelectionChanged	  
DropDownPicture	Constructor	  
DropDownPicture	Destructor	  
DropDownPicture	DoubleClicked	  
DropDownPicture	DragDrop	  
DropDownPicture	DragEnter	  
DropDownPicture	DragLeave	  
DropDownPicture	DragWithin	  
DropDownPicture	GetFocus	  
DropDownPicture	LoseFocus	  
DropDownPicture	Modified	  
DropDownPicture	Other	  
DropDownPicture	RButtonDown	  
DropDownPicture	SelectionChanged	  
EditMask	Constructor	  
EditMask	Destructor	  
EditMask	DragDrop	  
EditMask	DragEnter	  
EditMask	DragLeave	  
EditMask	DragWithin	  
EditMask	GetFocus	  
EditMask	LoseFocus	  
EditMask	Modified	  
EditMask	Other	  
EditMask	RButtonDown	  
Graph	Clicked	  
Graph	Constructor	  
Graph	Destructor	  
Graph	DoubleClicked	  
Graph	DragDrop	  
Graph	DragEnter	  
Graph	DragLeave	  
Graph	DragWithin	  
Graph	GetFocus	  
Graph	LoseFocus	  
Graph	Other	  
Graph	RButtonDown	  
HScrollBar	Constructor	  
HScrollBar	Destructor	  
HScrollBar	DragDrop	  
HScrollBar	DragEnter	  
HScrollBar	DragLeave	  
HScrollBar	DragWithin	  
HScrollBar	GetFocus	  
HScrollBar	LineLeft	  
HScrollBar	LineRight	  
HScrollBar	LoseFocus	  
HScrollBar	Moved	  
HScrollBar	Other	  
HScrollBar	PageLeft	  
HScrollBar	PageRight	  
HScrollBar	RButtonDown	  
ListBox 	Constructor	  
ListBox 	Destructor	  
ListBox 	DoubleClicked	  
ListBox 	DragDrop	  
ListBox 	DragEnter	  
ListBox 	DragLeave	  
ListBox 	DragWithin	  
ListBox 	GetFocus	  
ListBox 	LoseFocus	  
ListBox 	Other	  
ListBox 	RButtonDown	  
ListBox 	SelectionChanged	  
ListView	BeginDrag	  
ListView	BeginLabelEdit	  
ListView	BeginRightDrag	  
ListView	Clicked	  
ListView	ColumnClick	  
ListView	Constructor	  
ListView	DeleteAllItems	  
ListView	DeleteItem	  
ListView	Destructor	  
ListView	DoubleClicked	  
ListView	DragDrop	  
ListView	DragEnter	  
ListView	DragLeave	  
ListView	DragWithin	  
ListView	EndLabelEdit	  
ListView	GetFocus	  
ListView	InsertItem	  
ListView	ItemChanged	  
ListView	ItemChanging	  
ListView	Key	  
ListView	LoseFocus	  
ListView	Other	  
ListView	RightClicked	  
ListView	RightDoubleClicked	  
ListView	Sort	  
MultiLineEdit 	Constructor	  
MultiLineEdit 	Destructor	  
MultiLineEdit 	DragDrop	  
MultiLineEdit 	DragEnter	  
MultiLineEdit 	DragLeave	  
MultiLineEdit 	DragWithin	  
MultiLineEdit 	GetFocus	  
MultiLineEdit 	LoseFocus	  
MultiLineEdit 	Modified	  
MultiLineEdit 	Other	  
MultiLineEdit 	RButtonDown	  
OLEControl 	Clicked	  
OLEControl 	Close	  
OLEControl 	Constructor	  
OLEControl 	DataChange	  
OLEControl 	Destructor	  
OLEControl 	DoubleClicked	  
OLEControl 	DragDrop	  
OLEControl 	DragEnter	  
OLEControl 	DragLeave	  
OLEControl 	DragWithin	  
OLEControl 	Error	  
OLEControl 	ExternalException	  
OLEControl 	GetFocus	  
OLEControl 	LoseFocus	  
OLEControl 	Other	  
OLEControl 	PropertyChanged	  
OLEControl 	PropertyRequestEdit	  
OLEControl 	RButtonDown	  
OLEControl 	Rename	  
OLEControl 	Save	  
OLEControl 	ViewChange	  
OLECustomControl 	Clicked	  
OLECustomControl 	Constructor	  
OLECustomControl 	DataChange	  
OLECustomControl 	Destructor	  
OLECustomControl 	DoubleClicked	  
OLECustomControl 	DragDrop	  
OLECustomControl 	DragEnter	  
OLECustomControl 	DragLeave	  
OLECustomControl 	DragWithin	  
OLECustomControl 	Error	  
OLECustomControl 	ExternalException	  
OLECustomControl 	GetFocus	  
OLECustomControl 	LoseFocus	  
OLECustomControl 	Other	  
OLECustomControl 	PropertyChanged	  
OLECustomControl 	PropertyRequestEdit	  
OLECustomControl 	RButtonDown	  
Picture 	Clicked	  
Picture 	Constructor	  
Picture 	Destructor	  
Picture 	DoubleClicked	  
Picture 	DragDrop	  
Picture 	DragEnter	  
Picture 	DragLeave	  
Picture 	DragWithin	  
Picture 	GetFocus	  
Picture 	LoseFocus	  
Picture 	Other	  
Picture 	RButtonDown	  
PictureButton 	Clicked	  
PictureButton 	Constructor	  
PictureButton 	Destructor	  
PictureButton 	DragDrop	  
PictureButton 	DragEnter	  
PictureButton 	DragLeave	  
PictureButton 	DragWithin	  
PictureButton 	GetFocus	  
PictureButton 	LoseFocus	  
PictureButton 	Other	  
PictureButton 	RButtonDown	  
PictureListBox	Constructor	  
PictureListBox	Destructor	  
PictureListBox	DoubleClicked	  
PictureListBox	DragDrop	  
PictureListBox	DragEnter	  
PictureListBox	DragLeave	  
PictureListBox	DragWithin	  
PictureListBox	GetFocus	  
PictureListBox	LoseFocus	  
PictureListBox	Other	  
PictureListBox	RButtonDown	  
PictureListBox	SelectionChanged	  
RadioButton	Clicked	  
RadioButton	Constructor	  
RadioButton	Destructor	  
RadioButton	DragDrop	  
RadioButton	DragEnter	  
RadioButton	DragLeave	  
RadioButton	DragWithin	  
RadioButton	GetFocus	  
RadioButton	LoseFocus	  
RadioButton	Other	  
RadioButton	RButtonDown	  
RichTextEdit 	Constructor	  
RichTextEdit 	Destructor	  
RichTextEdit 	DoubleClicked	  
RichTextEdit 	DragDrop	  
RichTextEdit 	DragEnter	  
RichTextEdit 	DragLeave	  
RichTextEdit 	DragWithin	  
RichTextEdit 	FileExists	  
RichTextEdit 	GetFocus	  
RichTextEdit 	InputFieldSelected	  
RichTextEdit 	Key	  
RichTextEdit 	LoseFocus	  
RichTextEdit 	Modified	  
RichTextEdit 	MouseDown	  
RichTextEdit 	MouseMove	  
RichTextEdit 	MouseUp	  
RichTextEdit 	Other	  
RichTextEdit 	PictureSelected	  
RichTextEdit 	PrintFooter	  
RichTextEdit 	PrintHeader	  
RichTextEdit 	RButtonDown	  
RichTextEdit 	RButtonUp	  
SingleLineEdit	Constructor	  
SingleLineEdit	Destructor	  
SingleLineEdit	DragDrop	  
SingleLineEdit	DragEnter	  
SingleLineEdit	DragLeave	  
SingleLineEdit	DragWithin	  
SingleLineEdit	GetFocus	  
SingleLineEdit	LoseFocus	  
SingleLineEdit	Modified	  
SingleLineEdit	Other	  
SingleLineEdit	RButtonDown	  
StaticText 	Clicked	  
StaticText 	Constructor	  
StaticText 	Destructor	  
StaticText 	DoubleClicked	  
StaticText 	DragDrop	  
StaticText 	DragEnter	  
StaticText 	DragLeave	  
StaticText 	DragWithin	  
StaticText 	GetFocus	  
StaticText 	LoseFocus	  
StaticText 	Other	  
StaticText 	RButtonDown	  
Tab	Clicked	  
Tab	Constructor	  
Tab	Destructor	  
Tab	DoubleClicked	  
Tab	DragDrop	  
Tab	DragEnter	  
Tab	DragLeave	  
Tab	DragWithin	  
Tab	GetFocus	  
Tab	Key	  
Tab	LoseFocus	  
Tab	Other	  
Tab	RightClicked	  
Tab	RightDoubleClicked	  
Tab	SelectionChanged	  
Tab	SelectionChanging	  
TreeView	BeginDrag	  
TreeView	BeginLabelEdit	  
TreeView	BeginRightDrag	  
TreeView	Clicked	  
TreeView	Constructor	  
TreeView	DeleteItem	  
TreeView	Destructor	  
TreeView	DoubleClicked	  
TreeView	DragDrop	  
TreeView	DragEnter	  
TreeView	DragLeave	  
TreeView	DragWithin	  
TreeView	EndLabelEdit	  
TreeView	GetFocus	  
TreeView	ItemCollapsed	  
TreeView	ItemCollapsing	  
TreeView	ItemExpanded	  
TreeView	ItemExpanding	  
TreeView	ItemPopulate	  
TreeView	Key	  
TreeView	LoseFocus	  
TreeView	Other	  
TreeView	RightClicked	  
TreeView	RightDoubleClicked	  
TreeView	SelectionChanged	  
TreeView	SelectionChanging	  
TreeView	Sort	  
UserObject 	Constructor	  
UserObject 	Destructor	  
UserObject 	DragDrop	  
UserObject 	DragEnter	  
UserObject 	DragLeave	  
UserObject 	DragWithin	  
UserObject 	Other	  
UserObject 	RButtonDown	  
VScrollBar 	Constructor	  
VScrollBar 	Destructor	  
VScrollBar 	DragDrop	  
VScrollBar 	DragEnter	  
VScrollBar 	DragLeave	  
VScrollBar 	DragWithin	  
VScrollBar 	GetFocus	  
VScrollBar 	LineDown	  
VScrollBar 	LineUp	  
VScrollBar 	LoseFocus	  
VScrollBar 	Moved	  
VScrollBar 	Other	  
VScrollBar 	PageDown	  
VScrollBar 	PageUp	  
VScrollBar 	RButtonDown	  
Application	Close	  
Application	ConnectionBegin	  
Application	ConnectionEnd	  
Application	Idle	  
Application	Open	  
Application	SystemError	  
Connection	Constructor	  
Connection	Destructor	  
Connection	Error	  
ContextInformation	Constructor	  
ContextInformation	Destructor	  
ContextKeyword	Constructor	  
ContextKeyword	Destructor	  
CPlusPlus 	Constructor	  
CPlusPlus 	Destructor	  
DataStore 	Constructor	  
DataStore 	DBError	  
DataStore 	Destructor	  
DataStore 	Error	  
DataStore 	ItemChanged	  
DataStore 	ItemError	  
DataStore 	PrintEnd	  
DataStore 	PrintPage	  
DataStore 	PrintStart	  
DataStore 	RetrieveEnd	  
DataStore 	RetrieveRow	  
DataStore 	RetrieveStart	  
DataStore 	SQLPreview	  
DataStore 	UpdateEnd	  
DataStore 	UpdateStart	  
DynamicDescriptionArea 	Constructor	  
DynamicDescriptionArea 	Destructor	  
Error	Constructor	  
Error	Destructor	  
Inet	Constructor	  
Inet	Destructor	  
InternetResult 	Constructor	  
InternetResult 	Destructor	  
mailSession 	Constructor	  
mailSession 	Destructor	  
Menu	Clicked	  
Menu	Selected	  
MenuCascade 	Clicked	  
MenuCascade 	Selected	  
Message 	Constructor	  
Message 	Destructor	  
OLEObject 	Constructor	  
OLEObject 	Destructor	  
OLEObject 	Error	  
OLEObject 	ExternalException	  
OLEStorage 	Constructor	  
OLEStorage 	Destructor	  
OLEStream 	Constructor	  
OLEStream 	Destructor	  
Pipeline 	Constructor	  
Pipeline 	Destructor	  
Pipeline 	PipeEnd	  
Pipeline 	PipeMeter	  
Pipeline 	PipeStart	  
Timing 	Constructor	  
Timing 	Destructor	  
Timing 	Timer	  
Transaction 	Constructor	  
Transaction 	Destructor	  
UserObject	Constructor	  
UserObject	Destructor	  
UserObject	DragDrop	  
UserObject	DragEnter	  
UserObject	DragLeave	  
UserObject	DragWithin	  
UserObject	Other	  
UserObject	RButtonDown	  
Window	Activate	  
Window	Clicked	  
Window	Close 	  
Window	CloseQuery	  
Window	Deactivate	  
Window	DoubleClicked	  
Window	DragDrop	  
Window	DragEnter	  
Window	DragLeave	  
Window	DragWithin	  
Window	Hide 	  
Window	HotLinkAlarm	  
Window	Key	  
Window	MouseDown	  
Window	MouseMove	  
Window	MouseUp	  
Window	Open 	  
Window	Other	  
Window	RButtonDown	  
Window	RemoteExec	  
Window	RemoteHotLinkStart	  
Window	RemoteHotLinkStop	  
Window	RemoteRequest	  
Window	RemoteSend	  
Window	Resize	  
Window	Show	  
Window	SystemKey	  
Window	Timer	  
Window	ToolbarMoved	  
SystemEvent	HotLinkAlarm	  
SystemEvent	RemoteExec	  
SystemEvent	RemoteHotLinkStart	  
SystemEvent	RemoteHotLinkStop	  
SystemEvent	RemoteRequest	  
SystemEvent	RemoteSend	  
----------------------------------------------------------------*/

end subroutine

public function integer of_save_new_words (string as_word, ref string rsa_words[]);//====================================================================
// Function: nvo_pbformater.of_save_new_words()
//--------------------------------------------------------------------
// Description:	Save new words so to indent other word into first format
//--------------------------------------------------------------------
// Arguments:
// 	      	string	as_word	
// 	ref   	string 	rsa_words[]	
//--------------------------------------------------------------------
// Returns:  integer
//--------------------------------------------------------------------
// Author:	PB.BaoGa		Date: 2021/11/03
//--------------------------------------------------------------------
// Usage: nvo_pbformater.of_save_new_words ( string as_word, ref string rsa_words[] )
//--------------------------------------------------------------------
//	Copyright (c) PB.BaoGa(TM), All rights reserved.
//--------------------------------------------------------------------
// Modify History:
//
//====================================================================

Long		ll_Index, ll_Count

ll_Count = UpperBound(rsa_Words)
For ll_Index = 1 To ll_Count
	If Upper(as_Word) = Upper(rsa_Words[ll_Index]) Then
		Return 1
	End If
Next

rsa_Words[UpperBound(rsa_Words) + 1] = as_Word

Return 1


end function

public function long of_search_new_word (string as_word, string asa_words[]);//====================================================================
// Function: nvo_pbformater.of_search_new_word()
//--------------------------------------------------------------------
// Description:
//--------------------------------------------------------------------
// Arguments:
// 	string	as_word    	
// 	string	asa_words[]	
//--------------------------------------------------------------------
// Returns:  long
//--------------------------------------------------------------------
// Author:	PB.BaoGa		Date: 2021/11/03
//--------------------------------------------------------------------
// Usage: nvo_pbformater.of_search_new_word ( string as_word, string asa_words[] )
//--------------------------------------------------------------------
//	Copyright (c) PB.BaoGa(TM), All rights reserved.
//--------------------------------------------------------------------
// Modify History:
//
//====================================================================

Long		ll_Index
Long		ll_Pos

For ll_Index = 1 To UpperBound(asa_Words[])
	If Upper(asa_Words[ll_Index]) = Upper(as_Word) Then
		ll_Pos = ll_Index
	End If
Next

Return ll_Pos


end function

public function boolean of_isemptyline (string as_line);//====================================================================
// Function: nvo_pbformater.of_isemptyline()
//--------------------------------------------------------------------
// Description:	Determine whether the current line is a blank line
//--------------------------------------------------------------------
// Arguments:
// 	string	as_line	
//--------------------------------------------------------------------
// Returns:  boolean
//--------------------------------------------------------------------
// Author:	PB.BaoGa		Date: 2021/11/03
//--------------------------------------------------------------------
// Usage: nvo_pbformater.of_isemptyline ( string as_line )
//--------------------------------------------------------------------
//	Copyright (c) PB.BaoGa(TM), All rights reserved.
//--------------------------------------------------------------------
// Modify History:
//
//====================================================================

Long		ll_ii, ll_count

ll_count = Len(as_line)
For ll_ii = 1 To ll_count
	If Not ( Mid(as_line, ll_ii, 1) = " "  Or Mid(as_line, ll_ii, 1) = "~t" ) Then
		Return False
	End If
Next
Return True



end function

public function string of_get_word (string as_source, ref integer ai_pos, ref boolean ab_isfunction);//====================================================================
// Function: nvo_pbformater.of_get_word()
//--------------------------------------------------------------------
// Description:	Get a complete word 
//--------------------------------------------------------------------
// Arguments:
// 	      	string	as_source	
// 	ref   	integer  	ai_pos       	
// 	ref   	boolean  	ab_isfunction	
//--------------------------------------------------------------------
// Returns:  string
//--------------------------------------------------------------------
// Author:	PB.BaoGa		Date: 2021/11/03
//--------------------------------------------------------------------
// Usage: nvo_pbformater.of_get_word ( string as_source, ref integer ai_pos, ref boolean ab_isfunction )
//--------------------------------------------------------------------
//	Copyright (c) PB.BaoGa(TM), All rights reserved.
//--------------------------------------------------------------------
// Modify History:
//
//====================================================================


String  ls_word,lch
Integer li_pos,li_len

li_pos = ai_pos
li_len = Len(as_source)
For li_pos = ai_pos To li_len
	lch = Mid(as_source,li_pos,1)
	If of_IsIdentifiers(lch) Then
		Continue
	ElseIf lch = "!" Then
		ls_word       = Mid(as_source,ai_pos,li_pos - ai_pos )
		ai_pos        = li_pos
		ab_IsFunction = False
		Return ls_word
	Else
		ls_word       = Mid(as_source,ai_pos,li_pos - ai_pos)
		ai_pos        = li_pos
		ab_IsFunction = False
		//li_pos = 1
		lch    = Mid(as_source,li_pos, 1)
		Do While	(lch = CONST_SPACE Or lch = CONST_TAB)
			li_pos ++
			lch = Mid(as_source,li_pos, 1)
		Loop
		If lch = "(" Then
			ab_IsFunction = True
		End If
		Return ls_word
	End If
Next

ls_word       =  Mid(as_source,ai_pos)
ai_pos        =  li_len + 1
ab_IsFunction = False
Return ls_word

end function

public function integer of_indent_code (string as_alphatype, ref s_indent_info asu_indent);//====================================================================
// Function: nvo_pbformater.of_indent_code()
//--------------------------------------------------------------------
// Description:	Indent the words of script code into dainty format
//--------------------------------------------------------------------
// Arguments:
// 	      	string	as_alphatype 	
// 	ref   	s_indent_info	asu_indent	
//--------------------------------------------------------------------
// Returns:  integer
//--------------------------------------------------------------------
// Author:	PB.BaoGa		Date: 2021/11/03
//--------------------------------------------------------------------
// Usage: nvo_pbformater.of_indent_code ( string as_alphatype, ref s_indent_info asu_indent )
//--------------------------------------------------------------------
//	Copyright (c) PB.BaoGa(TM), All rights reserved.
//--------------------------------------------------------------------
// Modify History:
//
//====================================================================

String  ls_source,ls_source_new
String  ls_line_pre_this,ls_line_pre_next
String  ls_line1,lch,lch1
String  ls_word,ls_word_new,ls_word_type
Integer li_line_tab_next,li_line_tab_this
Integer li_pos1,li_pos2,li_pos3
Boolean lb_IsFunction
String  ls_SqlType,ls_StatementType,ls_ReservedType,ls_ScriptsType,ls_OtherType


ls_SqlType       = Left(as_alphatype,1)
ls_StatementType = Mid(as_alphatype,2,1)
ls_ReservedType  = Mid(as_alphatype,3,1)
ls_ScriptsType   = Mid(as_alphatype,4,1)
ls_OtherType     = Mid(as_alphatype,5,1)


lch1 = Mid(asu_indent.Line,asu_indent.Pos - 1,1)
ls_word = This.of_Get_Word(asu_indent.Line,asu_indent.Pos,lb_IsFunction)
ls_word_new = This.of_Convert_Word(ls_word,ls_word_type)


//====================================================================
// Added By Trueway Lee, 2003.01.26 
//====================================================================
of_Save_New_Words(ls_word_new, asu_indent.Words)
//====================================================================

If asu_indent.issqlline Then // Is SQL script line
	If Left(ls_word_type,1) <> "0" Then
		Choose Case ls_SqlType
			Case "U"
				asu_indent.line_new += Upper(ls_word_new)
			Case "L"
				asu_indent.line_new += Lower(ls_word_new)
				//			CASE "F"
				//				asu_indent.line_new += Upper(Left(ls_word_new,1))+Lower(Mid(ls_word_new,2))
			Case Else
				asu_indent.line_new += ls_word_new
		End Choose
	Else
		If lch1 = ":" Then
			Choose Case ls_OtherType
				Case "U"
					asu_indent.line_new += Upper(ls_word_new)
				Case "L"
					asu_indent.line_new += Lower(ls_word_new)
					//				CASE "F"
					//					asu_indent.line_new += Upper(Left(ls_word_new,1))+Lower(Mid(ls_word_new,2))
				Case Else
					asu_indent.line_new += ls_word_new
			End Choose
		Else
			asu_indent.line_new += ls_word
		End If
	End If
Else
	If lb_IsFunction Then // Added By Trueway Lee, 2004.09.07
		Choose Case ls_ScriptsType
			Case "U"
				asu_indent.line_new += Upper(ls_word_new)
			Case "L"
				asu_indent.line_new += Lower(ls_word_new)
				//			CASE "F"
				//				asu_indent.line_new += Upper(Left(ls_word_new,1))+Lower(Mid(ls_word_new,2))
			Case Else
				asu_indent.line_new += ls_word_new
		End Choose
		
	ElseIf Left(ls_word_type,1) = "2" Then
		Choose Case ls_SqlType
			Case "U"
				asu_indent.line_new += Upper(ls_word_new)
			Case "L"
				asu_indent.line_new += Lower(ls_word_new)
				//			CASE "F"
				//				asu_indent.line_new += Upper(Left(ls_word_new,1))+Lower(Mid(ls_word_new,2))
			Case Else
				asu_indent.line_new += ls_word_new
		End Choose
	ElseIf Mid(ls_word_type,2,1) = "2" Then
		Choose Case ls_StatementType
			Case "U"
				asu_indent.line_new += Upper(ls_word_new)
			Case "L"
				asu_indent.line_new += Lower(ls_word_new)
				//			CASE "F"
				//				asu_indent.line_new += Upper(Left(ls_word_new,1))+Lower(Mid(ls_word_new,2))
			Case Else
				asu_indent.line_new += ls_word_new
		End Choose
	ElseIf Mid(ls_word_type,2,1) = "1" Then
		Choose Case ls_ReservedType
			Case "U"
				asu_indent.line_new += Upper(ls_word_new)
			Case "L"
				asu_indent.line_new += Lower(ls_word_new)
				//			CASE "F"
				//				asu_indent.line_new += Upper(Left(ls_word_new,1))+Lower(Mid(ls_word_new,2))
			Case Else
				asu_indent.line_new += ls_word_new
		End Choose
	ElseIf Mid(ls_word_type,3,1) = "1" Then
		Choose Case ls_ScriptsType
			Case "U"
				asu_indent.line_new += Upper(ls_word_new)
			Case "L"
				asu_indent.line_new += Lower(ls_word_new)
				//			CASE "F"
				//				asu_indent.line_new += Upper(Left(ls_word_new,1))+Lower(Mid(ls_word_new,2))
			Case Else
				asu_indent.line_new += ls_word_new
		End Choose
	Else
		Choose Case ls_OtherType
			Case "U"
				asu_indent.line_new += Upper(ls_word_new)
			Case "L"
				asu_indent.line_new += Lower(ls_word_new)
				//			CASE "F"
				//				asu_indent.line_new += Upper(Left(ls_word_new,1))+Lower(Mid(ls_word_new,2))
			Case Else
				//====================================================================
				// Modified By Trueway Lee, 2003.01.26 
				//====================================================================
				//asu_indent.line_new += ls_word_new
				Long		ll_Pos
				ll_Pos 		 = of_Search_New_Word(ls_word_new, asu_indent.Words)
				If ll_Pos > 0 Then
					asu_indent.line_new += asu_indent.Words[ll_Pos]
				Else
					asu_indent.line_new += ls_word_new
				End If
				//====================================================================
		End Choose
	End If // ls_word_type
End If // asu_indent.issqlline

Return 1

end function

public function integer of_indent_expression (s_indent_info asu_indent, ref string rs_return);//====================================================================
// Function: nvo_pbformater.of_indent_expression()
//--------------------------------------------------------------------
// Description:	Indent expression into dainty format
//--------------------------------------------------------------------
// Arguments:
// 	             	s_indent_info	asu_indent	
// 	ref          	string    	rs_return	
//--------------------------------------------------------------------
// Returns:  integer
//--------------------------------------------------------------------
// Author:	PB.BaoGa		Date: 2021/11/03
//--------------------------------------------------------------------
// Usage: nvo_pbformater.of_indent_expression ( s_indent_info asu_indent, ref string rs_return )
//--------------------------------------------------------------------
//	Copyright (c) PB.BaoGa(TM), All rights reserved.
//--------------------------------------------------------------------
// Modify History:
//
//====================================================================

String	ls_TempText
ls_TempText =    asu_Indent.Char // Default value
Choose	Case	asu_Indent.Char
	Case	"="
		If Right(asu_Indent.line_new, 1) <> " " And Right(asu_Indent.line_new, 1) <> "+"  &
			And Right(asu_Indent.line_new, 1) <> "-" And Right(asu_Indent.line_new, 1) <> "*" &
			And Right(asu_Indent.line_new, 1) <> "/" And Right(asu_Indent.line_new, 1) <> ">" &
			And Right(asu_Indent.line_new, 1) <> "<" Then ls_TempText	 =   " " + asu_Indent.Char
		If Mid(asu_Indent.Line, asu_Indent.Pos + 1, 1) <> " " Then 	ls_TempText	+=    " "
		
	Case	">"
		If Right(asu_Indent.line_new, 1) <> " " And Right(asu_Indent.line_new, 1) <> "<"	Then
			ls_TempText	 =   " " + asu_Indent.Char
		End If
		If Mid(asu_Indent.Line, asu_Indent.Pos + 1, 1) <> " "  &
			And Mid(asu_Indent.Line, asu_Indent.Pos + 1, 1) <> "=" Then	ls_TempText	+=    " "
	Case	"<"
		If Right(asu_Indent.line_new, 1) <> " " Then ls_TempText	 =   " " + asu_Indent.Char
		If Mid(asu_Indent.Line, asu_Indent.Pos + 1, 1) <> " "  &
			And Mid(asu_Indent.Line, asu_Indent.Pos + 1, 1) <> "=" &
			And Mid(asu_Indent.Line, asu_Indent.Pos + 1, 1) <> ">"  Then	ls_TempText	+=    " "
End Choose

rs_return  =   ls_TempText

Return 1

end function

public function integer of_indent_quote (ref s_indent_info asu_indent);//====================================================================
// Function: nvo_pbformater.of_indent_quote()
//--------------------------------------------------------------------
// Description:
//--------------------------------------------------------------------
// Arguments:
// 	ref	s_indent_info	asu_indent	
//--------------------------------------------------------------------
// Returns:  integer
//--------------------------------------------------------------------
// Author:	PB.BaoGa		Date: 2021/11/03
//--------------------------------------------------------------------
// Usage: nvo_pbformater.of_indent_quote ( ref s_indent_info asu_indent )
//--------------------------------------------------------------------
//	Copyright (c) PB.BaoGa(TM), All rights reserved.
//--------------------------------------------------------------------
// Modify History:
//
//====================================================================

Integer		li_pos1
String		lch1

li_pos1 = asu_Indent.Pos
Do
	li_pos1 ++
	If li_pos1 > Len(asu_Indent.Line) Then
		// Error string end, will process next line script code string
		asu_Indent.line_new += Mid(asu_Indent.Line,asu_Indent.Pos,li_pos1 - asu_Indent.Pos + 1)
		Return -1
	End If
	lch1 = Mid(asu_Indent.Line,li_pos1,1)
Loop Until ( (lch1 = asu_Indent.Char)  And &
( &
( Mid(asu_Indent.Line,li_pos1 - 1, 1 ) <>  CONST_TILDE)  Or &
(   ( Mid(asu_Indent.Line,li_pos1 - 1, 1 ) =  CONST_TILDE) And &
( Mid(asu_Indent.Line,li_pos1 - 2, 1 ) =  CONST_TILDE)  &
) &
) &
)

asu_Indent.line_new += Mid(asu_Indent.Line,asu_Indent.Pos,li_pos1 - asu_Indent.Pos + 1)
// next 
asu_Indent.Pos = li_pos1 + 1

Return 1


end function

public function integer of_indent_semicolon (ref s_indent_info asu_indent);//====================================================================
// Function: nvo_pbformater.of_indent_semicolon()
//--------------------------------------------------------------------
// Description:	Process ";"
//--------------------------------------------------------------------
// Arguments:
// 	ref	s_indent_info	asu_indent	
//--------------------------------------------------------------------
// Returns:  integer
//--------------------------------------------------------------------
// Author:	PB.BaoGa		Date: 2021/11/03
//--------------------------------------------------------------------
// Usage: nvo_pbformater.of_indent_semicolon ( ref s_indent_info asu_indent )
//--------------------------------------------------------------------
//	Copyright (c) PB.BaoGa(TM), All rights reserved.
//--------------------------------------------------------------------
// Modify History:
//
//====================================================================

If asu_Indent.IsSqlLine Then asu_Indent.IsSqlLine = False
asu_Indent.line_new += asu_Indent.Char
asu_Indent.line_new    = This.of_Remove_NoPrintable(asu_Indent.line_new)
asu_Indent.Source_new += asu_Indent.pre_this + asu_Indent.line_new + CONST_CRLF
asu_Indent.Line        = Mid(asu_Indent.Line,asu_Indent.Pos + 1)
asu_Indent.Line        = This.of_Remove_NoPrintable(asu_Indent.Line)
asu_Indent.Pos         = 1
asu_Indent.line_new    = ""
If asu_Indent.Line = "" Then
	//  next line
	asu_Indent.Pos         = 1
	asu_Indent.line_new    = ""
	asu_Indent.Line        = This.of_Get_Next_Line(asu_Indent.Source)
	asu_Indent.Line        = This.of_Remove_NoPrintable(asu_Indent.Line)
End If

Return 1

end function

public function integer of_indent_reset (ref s_indent_info asu_indent);//====================================================================
// Function: nvo_pbformater.of_indent_reset()
//--------------------------------------------------------------------
// Description:	Initialize PowerIndent tool internal structure
//--------------------------------------------------------------------
// Arguments:
// 	ref	s_indent_info	asu_indent	
//--------------------------------------------------------------------
// Returns:  integer
//--------------------------------------------------------------------
// Author:	PB.BaoGa		Date: 2021/11/03
//--------------------------------------------------------------------
// Usage: nvo_pbformater.of_indent_reset ( ref s_indent_info asu_indent )
//--------------------------------------------------------------------
//	Copyright (c) PB.BaoGa(TM), All rights reserved.
//--------------------------------------------------------------------
// Modify History:
//
//====================================================================

asu_Indent.Source = '' // Original script code
asu_Indent.Source_New = '' // The script code has been processed
asu_Indent.IsSqlLine = False // Is the SQL statement being processed
asu_Indent.IsChooseCase = False // Is it processing Choose...Case
asu_Indent.IsAmpersand = False // Is it processing &
asu_Indent.IsAmpersandEnd = False // Are you processing &, and & is the last one
asu_Indent.tab_next = 0 // The next line should be indented on the current basis, -1 means backspace, 1 means indent one space
asu_Indent.tab_this = 0 // The indentation processing method that the current line should do
asu_Indent.Line = "" // The current line to be processed
asu_Indent.line_new = "" // The currently processed line
asu_Indent.pre_this = "" // The prefix of the current line
asu_Indent.Pos = 1 // The character position of the current line is being processed
Return 1


end function

public function string of_get_next_line (ref string as_source);//====================================================================
// Function: nvo_pbformater.of_get_next_line()
//--------------------------------------------------------------------
// Description:	Extract a new line from the original code segment
//--------------------------------------------------------------------
// Arguments:
// 	ref	string	as_source	
//--------------------------------------------------------------------
// Returns:  string
//--------------------------------------------------------------------
// Author:	PB.BaoGa		Date: 2021/11/03
//--------------------------------------------------------------------
// Usage: nvo_pbformater.of_get_next_line ( ref string as_source )
//--------------------------------------------------------------------
//	Copyright (c) PB.BaoGa(TM), All rights reserved.
//--------------------------------------------------------------------
// Modify History:
//
//====================================================================

String  ls_line
Integer li_pos

// Get Next Line
li_pos         = Pos(as_source, CONST_CRLF)
ls_line        = Left(as_source, li_pos - 1)

// Form the remaining code segment
as_source      = Mid(as_source,li_pos + 2)

Return ls_line


end function

public function string of_convert_word (string as_word, ref string as_type);//====================================================================
// Function: nvo_pbformater.of_convert_word()
//--------------------------------------------------------------------
// Description:	Search words from PB script 
//--------------------------------------------------------------------
// Arguments:
// 	      	string	as_word	
// 	ref   	string 	as_type	
//--------------------------------------------------------------------
// Returns:  string
//--------------------------------------------------------------------
// Author:	PB.BaoGa		Date: 2021/11/03
//--------------------------------------------------------------------
// Usage: nvo_pbformater.of_convert_word ( string as_word, ref string as_type )
//--------------------------------------------------------------------
//	Copyright (c) PB.BaoGa(TM), All rights reserved.
//--------------------------------------------------------------------
// Modify History:
//
//====================================================================

Integer li_pos
String  ls_words_standard
String  ls_word,ls_word1

ls_word1 = as_word
ls_word  = "," + Lower(Trim(as_word)) + ","

li_pos = Pos ( Lower(PB_SqlWord), ls_word ) // Search in SQL words
If li_pos > 0 Then
	ls_word1          = Mid(PB_SqlWord,li_pos + 1, Len(Trim(as_word)))
	ls_words_standard = Lower(Left(PB_SqlWord,Pos(PB_SqlWord,",,")+1))
	If Pos ( ls_words_standard, ls_word ) > 0 Then
		// Standard SQL words
		as_type = "2"
	Else // Extended SQL words
		as_type = "1"
	End If
Else // Not SQL words
	as_type = "0"
End If

li_pos = Pos ( Lower(PB_ReservedWord), ls_word ) // Search in Reserved words
If li_pos > 0 Then
	ls_word1          = Mid(PB_ReservedWord,li_pos + 1, Len(Trim(as_word)))
	ls_words_standard = Lower(Left(PB_ReservedWord,Pos(PB_ReservedWord,",,")+1))
	If Pos ( ls_words_standard, ls_word ) > 0 Then
		as_type += "2"
	Else
		as_type += "1"
	End If
Else
	as_type += "0"
End If

li_pos = Pos ( Lower(PB_ScriptWord), ls_word ) // Search in Script words
If li_pos > 0 Then
	ls_word1 = Mid(PB_ScriptWord,li_pos + 1, Len(Trim(as_word)))
	as_type += "1"
Else
	as_type += "0"
End If
Return ls_word1

end function

public function integer of_indent_slash (ref s_indent_info asu_indent);//====================================================================
// Function: nvo_pbformater.of_indent_slash()
//--------------------------------------------------------------------
// Description:	Handling comment symbols
//--------------------------------------------------------------------
// Arguments:
// 	ref	s_indent_info	asu_indent	
//--------------------------------------------------------------------
// Returns:  integer
//--------------------------------------------------------------------
// Author:	PB.BaoGa		Date: 2021/11/03
//--------------------------------------------------------------------
// Usage: nvo_pbformater.of_indent_slash ( ref s_indent_info asu_indent )
//--------------------------------------------------------------------
//	Copyright (c) PB.BaoGa(TM), All rights reserved.
//--------------------------------------------------------------------
// Modify History:
//
//====================================================================

Integer ll_pos1

If Mid(asu_Indent.Line,asu_Indent.Pos,2) = CONST_COMMENTS1 Then
	//====================================================================
	// Single line comment //
	//====================================================================
	
	asu_Indent.line_new	 = of_Trim(asu_Indent.line_new) // Trim Left and Right space and tab char
	
	If ( asu_Indent.line_new <> "" ) Then
		asu_Indent.line_new += " " + Mid(asu_Indent.Line,asu_Indent.Pos)
	Else
		asu_Indent.line_new = Mid(asu_Indent.Line,asu_Indent.Pos)
	End If
	
	//  next line
	asu_Indent.source_new += asu_Indent.pre_this + asu_Indent.line_new + CONST_CRLF
	asu_Indent.Pos         = 1
	asu_Indent.line_new    = ""
	asu_Indent.Line        = This.of_Get_Next_Line(asu_Indent.Source)
	
ElseIf Mid(asu_Indent.Line,asu_Indent.Pos,2) = CONST_COMMENTS2 Then
	//====================================================================
	// Multi-line comments
	//====================================================================
	ll_pos1 = Pos(asu_Indent.Line,CONST_COMMENTS3, asu_Indent.Pos + 2)
	If ll_pos1 > 0 Then
		asu_Indent.line_new += Mid(asu_Indent.Line,asu_Indent.Pos,ll_pos1 - asu_Indent.Pos + 1)
		asu_Indent.Pos = ll_pos1 + 1
	Else
		asu_Indent.line_new += Mid(asu_Indent.Line,asu_Indent.Pos)
		// next line
		asu_Indent.source_new += asu_Indent.pre_this + asu_Indent.line_new + CONST_CRLF
		asu_Indent.Pos         = 1
		asu_Indent.line_new    = ""
		asu_Indent.Line        = This.of_Get_Next_Line(asu_Indent.Source)
		// search end comments flag 
		Do While (ll_pos1 = 0)
			If asu_Indent.Source = ""  Then
				// some error exists
				// Return
				Return -1
			End If
			ll_pos1 = Pos(asu_Indent.Line,CONST_COMMENTS3, asu_Indent.Pos)
			If ll_pos1 > 0 Then
				asu_Indent.line_new += Mid(asu_Indent.Line,asu_Indent.Pos,ll_pos1 - asu_Indent.Pos + 1)
				// next 
				asu_Indent.Pos = ll_pos1 + 1
			Else
				asu_Indent.line_new = asu_Indent.Line
				// add next line
				asu_Indent.source_new += asu_Indent.pre_this + asu_Indent.line_new + CONST_CRLF
				asu_Indent.Pos         = 1
				asu_Indent.line_new    = ""
				asu_Indent.Line        = This.of_Get_Next_Line(asu_Indent.Source)
			End If
		Loop
	End If
Else
	asu_Indent.line_new += asu_Indent.Char
	asu_Indent.Pos ++
End If

Return 1


end function

public function string of_trimleft (string as_text);//====================================================================
// Function: nvo_pbformater.of_trimleft()
//--------------------------------------------------------------------
// Description:	Trim " " and "~t" from the left of string 
//--------------------------------------------------------------------
// Arguments:
// 	string	as_text	
//--------------------------------------------------------------------
// Returns:  string
//--------------------------------------------------------------------
// Author:	PB.BaoGa		Date: 2021/11/03
//--------------------------------------------------------------------
// Usage: nvo_pbformater.of_trimleft ( string as_text )
//--------------------------------------------------------------------
//	Copyright (c) PB.BaoGa(TM), All rights reserved.
//--------------------------------------------------------------------
// Modify History:
//
//====================================================================

String		ls_return
Long			ll_index = 1, ll_len
ls_return = as_text
ll_len	 = Len(ls_return)
For ll_index = 1 To ll_len
	If Not (Mid(ls_return, ll_index, 1) = " " Or Mid(ls_return, ll_index, 1) = "~t") Then
		Exit
	End If
Next
ls_return = Mid(ls_return, ll_index, ll_len - ll_index + 1)

Return ls_return

end function

public function string of_trimright (string as_text);//====================================================================
// Function: nvo_pbformater.of_trimright()
//--------------------------------------------------------------------
// Description:	Trim " " and "~t" from the right of string 
//--------------------------------------------------------------------
// Arguments:
// 	string	as_text	
//--------------------------------------------------------------------
// Returns:  string
//--------------------------------------------------------------------
// Author:	PB.BaoGa		Date: 2021/11/03
//--------------------------------------------------------------------
// Usage: nvo_pbformater.of_trimright ( string as_text )
//--------------------------------------------------------------------
//	Copyright (c) PB.BaoGa(TM), All rights reserved.
//--------------------------------------------------------------------
// Modify History:
//
//====================================================================

String		ls_return
Long			ll_index, ll_len
ls_return = as_text
ll_len	 = Len(ls_return)
ll_index  = Len(ls_return)
For ll_index = ll_len To 1 Step -1
	If Not (Mid(ls_return, ll_index, 1) = " " Or Mid(ls_return, ll_index, 1) = "~t") Then
		Exit
	End If
Next
ls_return = Left(ls_return, ll_index)

Return ls_return

end function

public function string of_trim (string as_text);//====================================================================
// Function: nvo_pbformater.of_trim()
//--------------------------------------------------------------------
// Description:	Trim Left and Right
//--------------------------------------------------------------------
// Arguments:
// 	string	as_text	
//--------------------------------------------------------------------
// Returns:  string
//--------------------------------------------------------------------
// Author:	PB.BaoGa		Date: 2021/11/03
//--------------------------------------------------------------------
// Usage: nvo_pbformater.of_trim ( string as_text )
//--------------------------------------------------------------------
//	Copyright (c) PB.BaoGa(TM), All rights reserved.
//--------------------------------------------------------------------
// Modify History:
//
//====================================================================

Return of_TrimLeft(of_TrimRight(as_Text))


end function

public function string of_remove_comments (string as_source);//====================================================================
// Function: nvo_pbformater.of_remove_comments()
//--------------------------------------------------------------------
// Description:
//--------------------------------------------------------------------
// Arguments:
// 	string	as_source	
//--------------------------------------------------------------------
// Returns:  string
//--------------------------------------------------------------------
// Author:	PB.BaoGa		Date: 2021/11/03
//--------------------------------------------------------------------
// Usage: nvo_pbformater.of_remove_comments ( string as_source )
//--------------------------------------------------------------------
//	Copyright (c) PB.BaoGa(TM), All rights reserved.
//--------------------------------------------------------------------
// Modify History:
//
//====================================================================

Long ll_pos, ll_pos2, ll_offset
String ls_temp,ls_source

ls_source = as_source

/*  Strip out all comments of type //  */


ll_pos = Pos ( ls_source, CONST_COMMENTS1 )
If ll_pos > 0 Then
	ls_source = Left(ls_source, ll_pos - 1)
End If


/* Strip out all comments of type /* ---*/  */
ll_pos = Pos ( ls_source, CONST_COMMENTS2 )
Do While ll_pos > 0
	ll_pos2 = Pos ( ls_source, CONST_COMMENTS3, ll_pos )
	If ll_pos2 > 0 Then
		ls_source = Replace ( ls_source, ll_pos, 2 + ll_pos2 - ll_pos, "" )
	Else
		ll_pos += 2
	End If
	ll_pos = Pos ( ls_source, CONST_COMMENTS2, ll_pos )
Loop

Return ls_source


end function

public subroutine of_get_line_prefix (ref s_indent_info asu_indent);//====================================================================
// Function: nvo_pbformater.of_get_line_prefix()
//--------------------------------------------------------------------
// Description: Calculate indent
//--------------------------------------------------------------------
// Arguments:
// 	ref	s_indent_info	asu_indent	
//--------------------------------------------------------------------
// Returns:  (none)
//--------------------------------------------------------------------
// Author:	PB.BaoGa		Date: 2021/11/03
//--------------------------------------------------------------------
// Usage: nvo_pbformater.of_get_line_prefix ( ref s_indent_info asu_indent )
//--------------------------------------------------------------------
//	Copyright (c) PB.BaoGa(TM), All rights reserved.
//--------------------------------------------------------------------
// Modify History:
//
//====================================================================

String  ls_line, ls_line_old
Integer li_line_tab_pre,li_line_tab_self,li_line_tab_next,li_line_tab_this
Integer li_seed = 0,  li_seed2 = 0
ls_line         = asu_indent.Line
ls_line_old		 = ls_line

li_line_tab_pre = asu_indent.tab_next //The next line indentation method processed last time is used as the benchmark for this time

// replace TAB => SPACE
ls_line = This.of_Replace_TAB2SPACE(ls_line)
// remove comments
ls_line = This.of_Remove_Comments(ls_line)

// remove string content
ls_line = This.of_Remove_Quote(ls_line)
// remove nonprintable characters
ls_line = This.of_Remove_NoPrintable(ls_line)
// lower string
ls_line = Lower(ls_line)


If	asu_indent.IsMultiLineNoEndIf = True Then
	asu_indent.IsMultiLineNoEndIf = False
	li_seed =  -1
End If
If asu_indent.IsAmpersandEnd Then
	li_seed2 = -1
	asu_indent.IsAmpersandEnd = False
End If

// SQL Line
If asu_indent.IsSQLLine Then
	If Right(ls_line,1) = CONST_SEMICOLON Then
		li_line_tab_self = 0
		li_line_tab_next = -1
		asu_indent.IsSQLLine = False
	Else
		li_line_tab_self = 0
		li_line_tab_next = 0
	End If
	Goto label_end
End If
//

//====================================================================
// IF...THEN...ELSE...END IF
//====================================================================
If Match(ls_line,"^if .* then .* else .*" ) Then
	li_line_tab_self = 0
	li_line_tab_next = 1
ElseIf Match(ls_line,"^if .* then" ) Then
	
	If Right(ls_line,4) = "then" Then
		li_line_tab_self = 0
		li_line_tab_next = 1
	Else
		li_line_tab_self = 0
		li_line_tab_next = 0
	End If
ElseIf Match(ls_line,"^elseif .* then" ) Then
	li_line_tab_self = -1
	li_line_tab_next = 0
ElseIf Match(ls_line,"^else" ) And  ( Mid(Trim(ls_line), 5, 1 ) = "" Or Pos(" ~t/", Mid(Trim(ls_line), 5, 1) )  > 0 )     Then
	li_line_tab_self = -1
	li_line_tab_next = 0
ElseIf Match(ls_line,"^end if" ) Then
	li_line_tab_self = -1
	li_line_tab_next = -1
	//====================================================================
	
	//====================================================================
	// FOR...NEXT
	//====================================================================	
ElseIf Match(ls_line,"^for .* to .*" ) Then
	li_line_tab_self = 0
	li_line_tab_next = 1
ElseIf Match(ls_line,"^next" ) And  ( Mid(Trim(ls_line), 5, 1 ) = "" Or Pos(" ~t/", Mid(Trim(ls_line), 5, 1) )  > 0 )     Then
	li_line_tab_self = -1
	li_line_tab_next = -1
	//====================================================================
	
	
	//====================================================================
	// CHOOSE...CASE...END CHOOSE 
	//====================================================================	
ElseIf Match(ls_line,"^choose * case .*" ) Then
	li_line_tab_self = 0
	li_line_tab_next = 0
	asu_indent.ischoosecase = True
ElseIf Match(ls_line,"^case .*" ) Then
	If asu_indent.ischoosecase Then // Prior choose line is "choose * case .*"
		asu_indent.ischoosecase = False
		li_line_tab_self = 1
		li_line_tab_next = 2
	Else //  Prior choose line is "case .*"
		li_line_tab_self = -1 // "case .*" moved to prior level
		li_line_tab_next = 0 // Script code string no change
	End If
ElseIf Match(ls_line,"^end * choose" ) Then
	li_line_tab_self = -2
	li_line_tab_next = -2
	//====================================================================
	
	
	
	//====================================================================
	// TRY...CATCH...FINALLY...END TRY
	// Added By Trueway Lee, 2005.10.30
	//====================================================================	
ElseIf Match(ls_line,"^try" ) Then
	li_line_tab_self = 0
	li_line_tab_next = 1
ElseIf Match(ls_line,"^catch" ) Then
	
	li_line_tab_self = -1
	li_line_tab_next = 0
	
ElseIf Match(ls_line,"^finally" ) Then
	li_line_tab_self = -1
	li_line_tab_next = 0
	
ElseIf Match(ls_line,"^end * try" ) Then
	li_line_tab_self = -1
	li_line_tab_next = -1
	//====================================================================
	
	
	//====================================================================
	// DO...LOOP
	//====================================================================
ElseIf Match(ls_line,"^do.*" ) And  ( Mid(Trim(ls_line), 3, 1 ) = "" Or Pos(" ~t/", Mid(Trim(ls_line), 3, 1) )  > 0 )     Then
	li_line_tab_self = 0
	li_line_tab_next = 1
ElseIf Match(ls_line,"^loop" ) And  ( Mid(Trim(ls_line), 5, 1 ) = "" Or Pos(" ~t/", Mid(Trim(ls_line), 5, 1) )  > 0 )     Then
	li_line_tab_self = -1
	li_line_tab_next = -1
	//====================================================================
	
	
ElseIf Match(ls_line,".* then.*" ) Then // multi-line if statement then beginning of "then"
	If (Right(ls_line, 4) = "then" )  Then
		// Muti-line if statement and have "end if"
		li_line_tab_self = 0
		li_line_tab_next = 0
	Else // Muti-line if statement and no "end if"
		asu_indent.IsMultiLineNoEndIf = True
		li_line_tab_self = 0
		li_line_tab_next = 0
	End If
	
	// Process SQL statement
ElseIf of_Match_Sql(asu_indent, ls_line, li_line_tab_self, li_line_tab_next) <> 1 Then
	If Right(ls_line,1) = CONST_AMPERSAND Then
		// Right end with "&" char
		If asu_indent.isampersand Then // prior line is ampersand
			li_line_tab_self = 0
			li_line_tab_next = 0
		Else // First end with "&" char
			li_line_tab_self = 0
			li_line_tab_next = 1
		End If
	Else // There is no "&" end with right on the current line 
		If asu_indent.isampersand Then
			li_line_tab_self = 0
			li_line_tab_next = 0
			asu_indent.IsAmpersandEnd = True
		Else
			li_line_tab_self = 0
			li_line_tab_next = 0
		End If
	End If
End If

label_end:

asu_indent.isampersand =  ( Right(ls_line,1) =  CONST_AMPERSAND )

li_line_tab_self += li_seed2
li_line_tab_next += li_seed2

li_line_tab_self = li_line_tab_self + li_seed

li_line_tab_this = li_line_tab_pre + li_line_tab_self // Current line tab count
If li_line_tab_this < 0 Then
	li_line_tab_next = li_line_tab_next - li_line_tab_this
	li_line_tab_this = 0
End If

asu_indent.tab_next = asu_indent.tab_next + li_line_tab_next  + li_seed // Next line tab count 
asu_indent.tab_this = li_line_tab_this // Current line tab count



end subroutine

public function string of_remove_quote (string as_text);//====================================================================
// Function: nvo_pbformater.of_remove_quote()
//--------------------------------------------------------------------
// Description:	Remove script line string  content, so that we can process line prefix function correctly.
//--------------------------------------------------------------------
// Arguments:
// 	string	as_text	
//--------------------------------------------------------------------
// Returns:  string
//--------------------------------------------------------------------
// Author:	PB.BaoGa		Date: 2021/11/03
//--------------------------------------------------------------------
// Usage: nvo_pbformater.of_remove_quote ( string as_text )
//--------------------------------------------------------------------
//	Copyright (c) PB.BaoGa(TM), All rights reserved.
//--------------------------------------------------------------------
// Modify History:
//
//====================================================================

Integer		li_pos1, li_pos, li_posa, li_posb
String		lch1, ls_char


li_posa = Pos(as_text,  CONST_SINGLEQUOTE)
li_posb = Pos(as_text,  CONST_DOUBLEQUOTE)
If li_posa > li_posb Then
	li_pos = li_posb
Else
	li_pos = li_posa
	If li_pos < 1 Then li_pos = li_posb
End If
ls_char = Mid(as_text, li_pos, 1)
Do While ( li_pos > 0 ) And ( ls_char <> "" )
	li_pos1 = li_pos
	Do
		li_pos1 ++
		If li_pos1 > Len(as_text) Then
			// some error exists
			// Return
			Return as_text
		End If
		lch1 = Mid(as_text,li_pos1,1)
	Loop Until ( 	(lch1 = ls_char)  And &
	( &
	( Mid(as_text,li_pos1 - 1, 1 ) <>  CONST_TILDE)  Or &
	(   ( Mid(as_text,li_pos1 - 1, 1 ) =  CONST_TILDE) And &
	( Mid(as_text,li_pos1 - 2, 1 ) =  CONST_TILDE)  &
	) &
	) &
	)
as_text = Replace(as_text, li_pos + 1,li_pos1 - li_pos  -  1 , "")

li_posa = Pos(as_text,  CONST_SINGLEQUOTE, li_pos + 2)
li_posb = Pos(as_text,  CONST_DOUBLEQUOTE, li_pos + 2)
If li_posa > li_posb Then
	li_pos = li_posb
Else
	li_pos = li_posa
	If li_pos < 1 Then li_pos = li_posb
End If
ls_char = Mid(as_text, li_pos, 1)
Loop

Return as_text

end function

public function integer of_match_sql (ref s_indent_info asu_indent, string as_line, ref integer ai_self, ref integer ai_next);//====================================================================
// Function: nvo_pbformater.of_match_sql()
//--------------------------------------------------------------------
// Description:	Determine whether the SQL statement
//--------------------------------------------------------------------
// Arguments:
// 	ref   	s_indent_info	asu_indent	
// 	      	string	as_line      	
// 	ref   	integer      	ai_self   	
// 	ref   	integer      	ai_next   	
//--------------------------------------------------------------------
// Returns:  integer
//--------------------------------------------------------------------
// Author:	PB.BaoGa		Date: 2021/11/03
//--------------------------------------------------------------------
// Usage: nvo_pbformater.of_match_sql ( ref s_indent_info asu_indent, string as_line, ref integer ai_self, ref integer ai_next )
//--------------------------------------------------------------------
//	Copyright (c) PB.BaoGa(TM), All rights reserved.
//--------------------------------------------------------------------
// Modify History:
//
//====================================================================

If Match(as_line,"^connect .*" ) Or Match(as_line,"^disconnect .*" ) Or &
	Match(as_line,"^commit .*" ) Or Match(as_line,"^rollback .*" ) Or  &
	Match(as_line,"^select .*" ) Or Match(as_line,"^insert .*" )  Or &
	Match(as_line,"^update .*" ) Or Match(as_line,"^delete .*" ) Or &
	Match(as_line,"^declare .*" ) Or Match(as_line,"^fetch .*" ) Or &
	Match(as_line,"^execute .*" ) Or Match(as_line,"^prepare .*" ) Then
	If Pos(as_line,CONST_SEMICOLON) > 0  Then
		ai_self = 0
		ai_next = 0
	Else
		ai_self = 0
		ai_next = 1
		asu_Indent.IsSqlLine = True
	End If
ElseIf Match(as_line,"^open .*" ) Then
	If Pos(as_line,"(") = 0 Then
		If Pos(as_line,CONST_SEMICOLON) > 0  Then
			ai_self = 0
			ai_next = 0
		Else
			ai_self = 0
			ai_next = 1
			asu_Indent.IsSqlLine = True
		End If
	Else
		ai_self = 0
		ai_next = 0
	End If
ElseIf Match(as_line,"^close .*" ) Then
	If Pos(as_line,"(") = 0 Then
		If Pos(as_line,CONST_SEMICOLON) > 0  Then
			ai_self = 0
			ai_next = 0
		Else
			ai_self = 0
			ai_next = 1
			asu_Indent.IsSqlLine = True
		End If
	Else
		ai_self = 0
		ai_next = 0
	End If
Else
	Return -1
End If

Return 1


end function

public function string of_file_indent (string as_source, string as_parsemode);//====================================================================
// Function: nvo_pbformater.of_file_indent()
//--------------------------------------------------------------------
// Description:	Indent main loop 
//--------------------------------------------------------------------
// Arguments:
// 	string	as_source   	
// 	string	as_parsemode	
//--------------------------------------------------------------------
// Returns:  string
//--------------------------------------------------------------------
// Author:	PB.BaoGa		Date: 2021/11/03
//--------------------------------------------------------------------
// Usage: nvo_pbformater.of_file_indent ( string as_source, string as_parsemode )
//--------------------------------------------------------------------
//	Copyright (c) PB.BaoGa(TM), All rights reserved.
//--------------------------------------------------------------------
// Modify History:
//
//====================================================================

String  ls_source,ls_source_new,ls_line,ls_line_new
String  lch,ls_tag_end,ls_function
Integer li_pos
Integer li_line_tab_next,li_line_tab_this
Boolean lb_ShouldParse,lb_IsEndTagComments
Boolean lb_IsAmpersand,lb_IsChooseCase,lb_IsSql,lb_IsFunction

ls_source        = Trim(as_source) +CONST_CRLF
lb_ShouldParse   = False
Do
	Yield()
	// Get Next Line
	li_pos         = Pos(ls_source, CONST_CRLF)
	ls_line        = Left(ls_source, li_pos - 1)
	ls_source      = Mid(ls_source,li_pos + 2)
	
	// Judge Line
	If Match(ls_line,"^type prototypes") Then
		ls_source_new += ls_line + CONST_CRLF
		ls_tag_end     = "^end prototypes"
		lb_ShouldParse = False
		Do
			Yield()
			// Get Next Line
			li_pos         = Pos(ls_source, CONST_CRLF)
			ls_line        = Left(ls_source, li_pos - 1)
			ls_source      = Mid(ls_source,li_pos + 2)
			
			ls_source_new += ls_line + CONST_CRLF
			If Match(ls_line,ls_tag_end) Then
				Exit
			End If
		Loop Until (Len(ls_source) = 0)
	ElseIf Match(ls_line,"^forward prototypes") Then
		ls_source_new += ls_line + CONST_CRLF
		ls_tag_end     = "^end prototypes"
		lb_ShouldParse = False
		Do
			Yield()
			// Get Next Line
			li_pos         = Pos(ls_source, CONST_CRLF)
			ls_line        = Left(ls_source, li_pos - 1 )
			ls_source      = Mid(ls_source,li_pos + 2)
			
			ls_source_new += ls_line + CONST_CRLF
			If Match(ls_line,ls_tag_end) Then
				Exit
			End If
		Loop Until (Len(ls_source) = 0)
	ElseIf Match(ls_line,"^global variables") Then
		// variables
		ls_source_new += ls_line + CONST_CRLF
		ls_tag_end     = "^end variables"
		lb_ShouldParse = True
	ElseIf Match(ls_line,"^shared variables") Then
		// variables
		ls_source_new += ls_line + CONST_CRLF
		ls_tag_end     = "^end variables"
		lb_ShouldParse = True
	ElseIf Match(ls_line,"^type variables") Then
		// variables
		ls_source_new += ls_line + CONST_CRLF
		ls_tag_end     = "^end variables"
		lb_ShouldParse = True
	ElseIf Match(ls_line,"^on .*;.*") Then
		// pb event
		li_pos         = Pos(ls_line,";")
		ls_source_new += Left(ls_line,li_pos)
		ls_source      = Mid(ls_line,li_pos + 1)+CONST_CRLF + ls_source
		ls_tag_end     = "^end on"
		lb_ShouldParse = True
	ElseIf Match(ls_line,"^event .*;.*") Then
		// event
		li_pos         = Pos(ls_line,";")
		ls_source_new += Left(ls_line,li_pos)
		ls_source      = Mid(ls_line,li_pos + 1)+CONST_CRLF + ls_source
		ls_tag_end     = "^end event"
		lb_ShouldParse = True
		ElseIf(Match(ls_line,"^global function .*);.*") Or &
			Match(ls_line,"^public function .*);.*") Or &
			Match(ls_line,"^private function .*);.*") Or &
			Match(ls_line,"^protected function .*);.*")) Then
			// function 
			li_pos         = Pos(ls_line,";")
			ls_source_new += Left(ls_line,li_pos)
			ls_source      = Mid(ls_line,li_pos + 1)+CONST_CRLF + ls_source
			ls_tag_end     = "^end function"
			lb_ShouldParse = True
			ElseIf(Match(ls_line,"^global subroutine .*);.*") Or  &
				Match(ls_line,"^public subroutine .*);.*") Or  &
				Match(ls_line,"^private subroutine .*);.*") Or &
				Match(ls_line,"^protected subroutine .*);.*")) Then
				// subroutine
				li_pos         = Pos(ls_line,";")
				ls_source_new += Left(ls_line,li_pos)
				ls_source      = Mid(ls_line,li_pos + 1)+CONST_CRLF + ls_source
				ls_tag_end     = "^end subroutine"
				lb_ShouldParse = True
			ElseIf Match(ls_line,"^Start of PowerBuilder Binary Data Section :.*") Then
				ls_source_new += ls_line + CONST_CRLF
				ls_source_new += ls_source
				ls_source      = ""
				lb_ShouldParse = False
			Else
				// continue
				ls_source_new += ls_line + CONST_CRLF
				lb_ShouldParse = False
			End If
			If lb_ShouldParse Then
				ls_function = ""
				Do
					Yield()
					// Get Next Line
					li_pos         = Pos(ls_source, CONST_CRLF)
					ls_line        = Left(ls_source, li_pos - 1 )
					If Not Match(ls_line,ls_tag_end) Then
						ls_function   += ls_line + CONST_CRLF
						ls_source      = Mid(ls_source,li_pos + 2)
					Else
						Exit
					End If
				Loop Until (Len(ls_source) = 0)
				
				// Process current sub indent 
				ls_source_new += This.of_Indent(ls_function,as_parsemode)
				
				lb_ShouldParse = False
			End If
		Loop Until (Len(ls_source) = 0)
		
		Return ls_source_new
end function

public function string of_indent (string as_source, string as_alphatype);//====================================================================
// Function: nvo_pbformater.of_indent()
//--------------------------------------------------------------------
// Description:	Code beautification
//--------------------------------------------------------------------
// Arguments:
// 	string	as_source   	
// 	string	as_alphatype	[U|L|F|F]  SQL + Statements + Reserved + Scripts + Other
//--------------------------------------------------------------------
// Returns:  string
//--------------------------------------------------------------------
// Author:	PB.BaoGa		Date: 2021/11/03
//--------------------------------------------------------------------
// Usage: nvo_pbformater.of_indent ( string as_source, string as_alphatype )
//--------------------------------------------------------------------
//	Copyright (c) PB.BaoGa(TM), All rights reserved.
//--------------------------------------------------------------------
// Modify History:
//
//====================================================================

String  ls_line1,lch1, ls_line
Integer li_pos1,li_pos2,li_pos3


of_Indent_Reset(Indent_Info) // Reset indent info 

Indent_Info.Source  = as_source  + CONST_CRLF  +   CONST_SPACE +  CONST_CRLF
Indent_Info.Line    = This.of_Remove_NoPrintable(This.of_Get_Next_Line(Indent_Info.Source))

Do
	
	If Indent_Info.Pos > Len(Indent_Info.Line) Then
		
		label_next_line:
		//  next line
		Indent_Info.line_new    = This.of_Remove_NoPrintable(Indent_Info.line_new)
		Indent_Info.Source_new += Indent_Info.pre_this + Indent_Info.line_new + CONST_CRLF
		Indent_Info.Pos         = 1
		Indent_Info.line_new    = ""
		Indent_Info.Line        = This.of_Remove_NoPrintable(This.of_Get_Next_Line(Indent_Info.Source))
	End If
	
	Indent_Info.Char       = Mid(Indent_Info.Line,Indent_Info.Pos,1)
	
	
	If Indent_Info.Pos = 1 Then
		// Get line prefix char string
		This.of_Get_Line_Prefix(Indent_Info)
		Indent_Info.pre_this  = Fill(CONST_TAB,Indent_Info.tab_this)
		
	End If
	
	
	Choose Case Indent_Info.Char
		Case CONST_SINGLEQUOTE,CONST_DOUBLEQUOTE
			
			// Handling single quotes, double quotes' "
			If of_Indent_Quote(Indent_Info ) <> 1 Then
				Goto label_next_line // Error to next line process
			End If
			
		Case CONST_SLASHLEFT
			//Processing comments  // /**/
			If of_Indent_Slash(Indent_Info ) <> 1 Then
				Goto label_next_line // Error to next line process
			End If
			
		Case CONST_SEMICOLON
			// Handle semicolon ;
			If of_Indent_Semicolon(Indent_Info ) <> 1 Then
				Goto label_next_line // Error to next line process
			End If
		Case Else
			// Other as script code
			If This.of_IsIdentifiers_First(Indent_Info.Char) Then
				// Power script Words involved in the language
				of_Indent_Code(as_alphatype, Indent_Info )
			Else // Expression word, string
				of_Indent_Expression(Indent_Info, ls_line1)
				Indent_Info.line_new += ls_line1
				Indent_Info.Pos ++
			End If
	End Choose
	
Loop Until (Len(Indent_Info.Source) = 0)


Return Indent_Info.Source_new


end function

public function integer of_checkstatement (string as_line);//====================================================================
// Function: nvo_pbformater.of_checkstatement()
//--------------------------------------------------------------------
// Description:
//--------------------------------------------------------------------
// Arguments:
// 	string	as_line	
//--------------------------------------------------------------------
// Returns:  integer
//--------------------------------------------------------------------
// Author:	PB.BaoGa		Date: 2021/11/03
//--------------------------------------------------------------------
// Usage: nvo_pbformater.of_checkstatement ( string as_line )
//--------------------------------------------------------------------
//	Copyright (c) PB.BaoGa(TM), All rights reserved.
//--------------------------------------------------------------------
// Modify History:
//
//====================================================================

String ls_line
ls_line = Lower( as_line)
//sqlline
If Right(ls_line,1) = CONST_SEMICOLON Then
	Return 1
End If

//====================================================================
// IF...THEN...ELSE...END IF
//====================================================================
If Match(ls_line,"^if .* then .* else .*" ) Then
	Return 1
ElseIf Match(ls_line,"^if .* then" ) Then
	If Right(ls_line,4) = "then" Then
		Return 1
	Else
		Return 1
	End If
ElseIf Match(ls_line,"^elseif .* then" ) Then
	Return 1
ElseIf Match(ls_line,"^else" ) And  ( Mid(Trim(ls_line), 5, 1 ) = "" Or Pos(" ~t/", Mid(Trim(ls_line), 5, 1) )  > 0 )     Then
	Return 1
ElseIf Match(ls_line,"^end if" ) Then
	Return 1
	
	//====================================================================
	// FOR...NEXT
	//====================================================================	
ElseIf Match(ls_line,"^for .* to .*" ) Then
	Return 1
ElseIf Match(ls_line,"^next" ) And  ( Mid(Trim(ls_line), 5, 1 ) = "" Or Pos(" ~t/", Mid(Trim(ls_line), 5, 1) )  > 0 )     Then
	Return 1
	
	//====================================================================
	// CHOOSE...CASE...END CHOOSE 
	//====================================================================	
ElseIf Match(ls_line,"^choose * case .*" ) Then
	Return 1
ElseIf Match(ls_line,"^case .*" ) Then
	Return 1
ElseIf Match(ls_line,"^end * choose" ) Then
	Return 1
	
	//====================================================================
	// TRY...CATCH...FINALLY...END TRY
	// Added By Trueway Lee, 2005.10.30
	//====================================================================	
ElseIf Match(ls_line,"^try" ) Then
	Return 1
ElseIf Match(ls_line,"^catch" ) Then
	Return 1
ElseIf Match(ls_line,"^finally" ) Then
	Return 1
ElseIf Match(ls_line,"^end * try" ) Then
	Return 1
	
	//====================================================================
	// DO...LOOP
	//====================================================================
ElseIf Match(ls_line,"^do.*" ) And  ( Mid(Trim(ls_line), 3, 1 ) = "" Or Pos(" ~t/", Mid(Trim(ls_line), 3, 1) )  > 0 )     Then
	Return 1
ElseIf Match(ls_line,"^loop" ) And  ( Mid(Trim(ls_line), 5, 1 ) = "" Or Pos(" ~t/", Mid(Trim(ls_line), 5, 1) )  > 0 )     Then
	Return 1
ElseIf Match(ls_line,".* then.*" ) Then // multi-line if statement then beginning of "then"
	Return 1
	
	// // Process SQL statement
	//ElseIf of_Match_Sql(asu_indent, ls_line, li_line_tab_self, li_line_tab_next) <> 1 Then
	//	If Right(ls_line,1) = CONST_AMPERSAND Then
	//		Return 1
	//	Else
	//		Return 1
	//	End If
End If
Return 0




end function

public function long of_lastpos (string as_source, string as_target, long al_start);//====================================================================
// Function: nvo_pbformater.of_lastpos()
//--------------------------------------------------------------------
// Description:	Search backwards through a string to find the last occurrence of another string.
//--------------------------------------------------------------------
// Arguments:
// 	value	string	as_source	The string being searched.
// 	value	string	as_target	The being searched for.
// 	value	long  	al_start 		The starting position, 0 means start at the end.
//--------------------------------------------------------------------
// Returns:  long	The position of as_Target.	If as_Target is not found, function returns a 0. If any argument's value is NULL, function returns NULL.
//--------------------------------------------------------------------
// Author:	PB.BaoGa		Date: 2021/11/03
//--------------------------------------------------------------------
// Usage: nvo_pbformater.of_lastpos ( string as_source, string as_target, long al_start )
//--------------------------------------------------------------------
//	Copyright (c) PB.BaoGa(TM), All rights reserved.
//--------------------------------------------------------------------
// Modify History:
//
//====================================================================

Long	ll_Cnt, ll_Pos

//Check for Null Parameters.
If IsNull(as_source) Or IsNull(as_target) Or IsNull(al_start) Then
	SetNull(ll_Cnt)
	Return ll_Cnt
End If

//Check for an empty string
If Len(as_source) = 0 Then
	Return 0
End If

// Check for the starting position, 0 means start at the end.
If al_start = 0 Then
	al_start = Len(as_source)
End If

//Perform find
For ll_Cnt = al_start To 1 Step -1
	ll_Pos = Pos(as_source, as_target, ll_Cnt)
	If ll_Pos = ll_Cnt Then
		//String was found
		Return ll_Cnt
	End If
Next

//String was not found
Return 0


end function

public function long of_lastpos (string as_source, string as_target);//====================================================================
// Function: nvo_pbformater.of_lastpos()
//--------------------------------------------------------------------
// Description:	Search backwards through a string to find the last occurrence of another string
//--------------------------------------------------------------------
// Arguments:
// 	value	string	as_source	The string being searched.
// 	value	string	as_target	The string being searched for.
//--------------------------------------------------------------------
// Returns:  long	The position of as_Target. If as_Target is not found, function returns a 0. If any argument's value is NULL, function returns NULL.
//--------------------------------------------------------------------
// Author:	PB.BaoGa		Date: 2021/11/03
//--------------------------------------------------------------------
// Usage: nvo_pbformater.of_lastpos ( string as_source, string as_target )
//--------------------------------------------------------------------
//	Copyright (c) PB.BaoGa(TM), All rights reserved.
//--------------------------------------------------------------------
// Modify History:
//
//====================================================================

//Check for Null Parameters.
If IsNull(as_source) Or IsNull(as_target) Then
	Long ll_null
	SetNull(ll_null)
	Return ll_null
End If

//Set the starting position and perform the search
Return of_LastPos (as_source, as_target, Len(as_source))


end function

on nvo_pbformatter.create
call super::create
TriggerEvent( this, "constructor" )
end on

on nvo_pbformatter.destroy
TriggerEvent( this, "destructor" )
call super::destroy
end on

event constructor;//====================================================================
// Event: nvo_pbformater.constructor()
//--------------------------------------------------------------------
// Description:	PB all kinds of sentences, function lexicon
//--------------------------------------------------------------------
// Arguments:
//--------------------------------------------------------------------
// Returns:  long
//--------------------------------------------------------------------
// Author:	PB.BaoGa		Date: 2021/11/03
//--------------------------------------------------------------------
// Usage: nvo_pbformater.constructor for nvo_pbformater
//--------------------------------------------------------------------
//	Copyright (c) PB.BaoGa(TM), All rights reserved.
//--------------------------------------------------------------------
// Modify History:
//
//====================================================================

PB_ReservedWord  =",Call,Case,Choose,Continue,Do,Loop,Exit,For,Next,Goto,Halt,If,Then,Else,ElseIf,End,"
PB_ReservedWord +="Until,While,Return,Try,Catch,Finally,,Alias,And,AutoInstantiate,Close,Commit,Connect,Constant,"
PB_ReservedWord +="Create,Cursor,Declare,Delete,Describe,Descriptor,Destroy,Disconnect,"
PB_ReservedWord +="Dynamic,Enumerated,Event,Execute,External,False,"
PB_ReservedWord +="Fetch,First,Forward,From,Function,Global,"
PB_ReservedWord +="Immediate,Indirect,Insert,Into,Intrinsic,Is,Last,Library,"
PB_ReservedWord +="Not,Of,On,Open,Or,Parent,Post,Prepare,Prior,Private,PrivateRead,PrivateWrite,"
PB_ReservedWord +="Procedure,Protected,ProtectedRead,ProtectedWrite,Prototypes,Public,Readonly,Ref,"
PB_ReservedWord +="Rollback,Rpcfunc,Select,SelectBlob,Shared,Static,Step,Subroutine,Super,"
PB_ReservedWord +="System,SystemRead,SystemWrite,This,To,Trigger,True,Type,Update,"
PB_ReservedWord +="UpdateBlob,Using,Variables,With,Whith,_Debug,"

PB_SqlWord  =",Connect,Disconnect,Commit,Rollback,Select,Insert,Update,Delete,Declare,Open,"
PB_SqlWord +="Fetch,Close,Execute,Prepare,,Create,Alter,Table,Procedure,Proc,"
PB_SqlWord +="Trigger,View,Index,Null,Not,Identity,Into,Using,Cursor,For,"
PB_SqlWord +="Immediate,Dynamic,All,From,Where,Group,By,Having,Order,Asc,"
PB_SqlWord +="Desc,Between,In,Like,And,Or,Union,Inner,Outer,Cross,Exists,Set,"
PB_SqlWord +="Where,Values,Begin,End,Transaction,Tran,Exec,"

PB_ScriptWord  = ",Blob,Integer,Int,Boolean,Long,Char,Character,Real,Date,String,DateTime,Time,Decimal,Dec,UnsignedInteger,"
PB_ScriptWord += ",UnsignedInt,UInt,Double,UnsignedLong,ULong,Any,"
PB_ScriptWord += ",Clicked,Constructor,Destructor,DragDrop,DragEnter,DragLeave,DragWithin,GetFocus,LoseFocus,Other,"
PB_ScriptWord += ",RButtonDown,DBError,DoubleClicked,EditChanged,Error,ItemChanged,ItemError,ItemFocusChanged,PrintEnd,PrintPage,"
PB_ScriptWord += ",PrintStart,Resize,RetrieveEnd,RetrieveRow,RetrieveStart,RowFocusChanged,ScrollHorizontal,ScrollVertical,SQLPreview,UpdateEnd,"
PB_ScriptWord += ",UpdateStart,Modified,SelectionChanged,LineLeft,LineRight,Moved,PageLeft,PageRight,BeginDrag,BeginLabelEdit,"
PB_ScriptWord += ",BeginRightDrag,ColumnClick,DeleteAllItems,DeleteItem,EndLabelEdit,InsertItem,ItemChanging,Key,RightClicked,RightDoubleClicked,"
PB_ScriptWord += ",Sort,Close,DataChange,ExternalException,PropertyChanged,PropertyRequestEdit,Rename,Save,ViewChange,FileExists,"
PB_ScriptWord += ",InputFieldSelected,MouseDown,MouseMove,MouseUp,PictureSelected,PrintFooter,PrintHeader,RButtonUp,SelectionChanging,ItemCollapsed,"
PB_ScriptWord += ",ItemCollapsing,ItemExpanded,ItemExpanding,ItemPopulate,LineDown,LineUp,PageDown,PageUp,ConnectionBegin,ConnectionEnd,"
PB_ScriptWord += ",Idle,Open,SystemError,Selected,PipeEnd,PipeMeter,PipeStart,Timer,Activate,CloseQuery,"
PB_ScriptWord += ",Deactivate,Hide,HotLinkAlarm,RemoteExec,RemoteHotLinkStart,RemoteHotLinkStop,RemoteRequest,RemoteSend,Show,SystemKey,"
PB_ScriptWord += ",ToolbarMoved,ClassName,Drag,GetContextService,GetParent,Move,PointerX,PointerY,PostEvent,Print,"
PB_ScriptWord += ",SetFocus,SetPosition,SetRedraw,TriggerEvent,TypeOf,AcceptText,CanUndo,CategoryCount,CategoryName,Clear,"
PB_ScriptWord += ",ClearValues,Clipboard,Copy,CopyRTF,Create,CrosstabDialog,Cut,DataCount,DBCancel,DBErrorCode,"
PB_ScriptWord += ",DBErrorMessage,DeletedCount,DeleteRow,Describe,Filter,FilteredCount,Find,FindCategory,FindGroupChange,FindNext,"
PB_ScriptWord += ",FindRequired,FindSeries,GenerateHTMLForm,GetBandAtPointer,GetBorderStyle,GetChanges,GetChild,GetClickedColumn,GetClickedRow,GetColumn,"
PB_ScriptWord += ",GetColumnName,GetData,GetDataPieExplode,GetDataStyle,GetDataValue,GetFormat,GetFullState,GetItemDate,GetItemDateTime,GetItemDecimal,"
PB_ScriptWord += ",GetItemNumber,GetItemStatus,GetItemString,GetItemTime,GetMessageText,GetNextModified,GetObjectAtPointer,GetRow,GetSelectedRow,GetSeriesStyle,"
PB_ScriptWord += ",GetSQLPreview,GetSQLSelect,GetStateStatus,GetText,GetTrans,GetUpdateStatus,GetValidate,GetValue,GroupCalc,ImportClipboard,"
PB_ScriptWord += ",ImportFile,ImportString,InsertDocument,InsertRow,IsSelected,LineCount,ModifiedCount,Modify,ObjectAtPointer,OLEActivate,"
PB_ScriptWord += ",Paste,PasteRTF,Position,PrintCancel,ReplaceText,ReselectRow,Reset,ResetDataColors,ResetTransObject,ResetUpdate,"
PB_ScriptWord += ",Retrieve,RowCount,RowsCopy,RowsDiscard,RowsMove,SaveAs,SaveAsAscii,Scroll,ScrollNextPage,ScrollNextRow,"
PB_ScriptWord += ",ScrollPriorPage,ScrollPriorRow,ScrollToRow,SelectedLength,SelectedLine,SelectedStart,SelectedText,SelectRow,SelectText,SelectTextAll,"
PB_ScriptWord += ",SelectTextLine,SelectTextWord,SeriesCount,SeriesName,SetActionCode,SetBorderStyle,SetChanges,SetColumn,SetDataPieExplode,SetDataStyle,"
PB_ScriptWord += ",SetDetailHeight,SetFilter,SetFormat,SetFullState,SetItem,SetItemStatus,SetRow,SetRowFocusIndicator,SetSeriesStyle,SetSort,"
PB_ScriptWord += ",SetSQLPreview,SetSQLSelect,SetTabOrder,SetText,SetTrans,SetTransObject,SetValidate,SetValue,ShareData,ShareDataOff,"
PB_ScriptWord += ",ShowHeadFoot,TextLine,Undo,Update,AddItem,DirList,DirSelect,FindItem,SelectItem,Text,"
PB_ScriptWord += ",TotalItems,AddPicture,DeletePicture,DeletePictures,LineLength,SetMask,AddCategory,AddData,AddSeries,DeleteCategory,"
PB_ScriptWord += ",DeleteData,DeleteSeries,InsertCategory,InsertData,InsertSeries,ModifyData,SelectedIndex,SelectedItem,SetState,SetTop,"
PB_ScriptWord += ",State,Top,TotalSelected,AddColumn,AddLargePicture,AddSmallPicture,AddstatePicture,Arrange,DeleteColumn,DeleteColumns,"
PB_ScriptWord += ",DeleteItems,DeleteLargePicture,DeleteLargePictures,DeleteSmallPicture,DeleteSmallPictures,DeleteStatePicture,DeleteStatePictures,EditLabel,GetItem,GetOrigin,"
PB_ScriptWord += ",InsertColumn,SetOverlayPicture,TotalColumns,DoVerb,GetNativePointer,InsertClass,InsertFile,InsertObject,LinkTo,PasteLink,"
PB_ScriptWord += ",PasteSpecial,ReleaseNativePointer,SelectObject,SetData,UpdateLinksDialog,SetAutomationLocale,Draw,SetPicture,DataSource,GetAlignment,"
PB_ScriptWord += ",GetParagraphSetting,GetSpacing,GetTextColor,GetTextStyle,InputFieldChangeData,InputFieldCurrentName,InputFieldDeleteCurrent,InputFieldGetData,InputFieldInsert,InputFieldLocate,"
PB_ScriptWord += ",InsertPicture,IsPreview,PageCount,Preview,SaveDocument,SelectedColumn,SelectedPage,SetAlignment,SetParagraphSetting,SetSpacing,"
PB_ScriptWord += ",SetTextColor,SetTextStyle,CloseTab,MoveTab,OpenTab,OpenTabWithParm,SelectTab,TabPostEvent,TabTriggerEvent,AddStatePicture,"
PB_ScriptWord += ",CollapseItem,ExpandAll,ExpandItem,InsertItemFirst,InsertItemLast,InsertItemSort,SetDropHighlight,SetFirstVisible,SetLevelPictures,SortAll,"
PB_ScriptWord += ",EventParmDouble,EventParmString,SetLibraryList,SetTransPool,FindMatchingFunction,ConnectToServer,CreateInstance,DisconnectServer,GetServerInfo,RemoteStopConnection,"
PB_ScriptWord += ",RemoteStopListening,GetCompanyName,GetFixesVersion,GetHostObject,GetMajorVersion,GetMinorVersion,GetName,GetShortName,GetVersionName,GetContextKeywords,"
PB_ScriptWord += ",GetDynamicDate,GetDynamicDateTime,GetDynamicNumber,GetDynamicString,GetDynamicTime,SetDynamicParm,GetURL,HyperLinkToURL,PostURL,InternetData,"
PB_ScriptWord += ",Classname,mailAddress,mailDeleteMessage,mailGetMessages,mailHandle,mailLogoff,mailLogon,mailReadMessage,mailRecipientDetails,mailResolveRecipient,"
PB_ScriptWord += ",mailSaveMessage,mailSend,Check,Disable,Enable,PopMenu,Uncheck,ConnectToNewObject,ConnectToNewRemoteObject,ConnectToObject,"
PB_ScriptWord += ",ConnectToRemoteObject,DisconnectObject,Pointer,NativePointer,SetAutomationPointer,SetAutomationTimeout,MemberDelete,MemberExists,MemberRename,Length,"
PB_ScriptWord += ",Read,Seek,Write,Cancel,Repair,Start,RoutineList,OutGoingCallList,IncomingCallList,LineList,"
PB_ScriptWord += ",OutgoingCallList,BuildModel,ClassList,DestroyModel,SetTraceFileName,SystemRoutine,NextActivity,EntryList,GetChildrenList,Stop,"
PB_ScriptWord += ",DBHandle,SyntaxFromSQL,Listen,StopListening,ArrangeSheets,ChangeMenu,CloseUserObject,GetActiveSheet,GetFirstSheet,GetNextSheet,"
PB_ScriptWord += ",GetToolbar,GetToolbarPos,OpenUserObject,OpenUserObjectWithParm,ParentWindow,SetMicroHelp,SetToolbar,SetToolbarPosition,WorkSpaceHeight,WorkSpaceWidth,"
PB_ScriptWord += ",WorkSpaceX,WorkSpaceY,LowerBound,UpperBound,Blob,BlobEdit,BlobMid,Len,String,Asc,"
PB_ScriptWord += ",Char,Dec,Double,Integer,Long,Real,Date,DateTime,IsDate,IsNull,"
PB_ScriptWord += ",IsNumber,IsTime,Time,Day,DayName,DayNumber,DaysAfter,Hour,Minute,Month,"
PB_ScriptWord += ",Now,RelativeDate,RelativeTime,Second,Today,Year,CloseChannel,ExecRemote,GetDataDDE,GetDataDDEOrigin,"
PB_ScriptWord += ",GetRemote,OpenChannel,RespondRemote,SetRemote,StartHotLink,StopHotLink,GetCommandDDE,GetCommandDDEOrigin,SetDataDDE,StartServerDDE,"
PB_ScriptWord += ",StopServerDDE,FileClose,FileDelete,FileLength,FileOpen,FileRead,FileSeek,FileWrite,GetFileOpenName,GetFileSaveName,"
PB_ScriptWord += ",IsAllArabic,IsAllHebrew,IsAnyArabic,IsAnyHebrew,IsArabic,IsArabicAndNumbers,IsHebrew,IsHebrewAndNumbers,Reverse,ToAnsi,"
PB_ScriptWord += ",ToUnicode,LibraryCreate,LibraryDelete,LibraryDirectory,LibraryExport,LibraryImport,Beep,DebugBreak,DraggedObject,IntHigh,"
PB_ScriptWord += ",IntLow,IsValid,KeyDown,MessageBox,PixelsToUnits,PopulateError,RGB,SetNull,SetPointer,SignalError,"
PB_ScriptWord += ",UnitsToPixels,Abs,Ceiling,Cos,Exp,Fact,Int,Log,LogTen,Max,"
PB_ScriptWord += ",Min,Mod,Pi,Rand,Randomize,Round,Sign,Sin,Sqrt,Tan,"
PB_ScriptWord += ",Truncate,PrintBitmap,PrintClose,PrintDataWindow,PrintDefineFont,PrintLine,PrintOpen,PrintOval,PrintRect,PrintRoundRect,"
PB_ScriptWord += ",PrintScreen,PrintSend,PrintSetFont,PrintSetSpacing,PrintSetup,PrintText,PrintWidth,PrintX,PrintY,RegistryDelete,"
PB_ScriptWord += ",RegistryGet,RegistryKeys,RegistrySet,RegistryValues,Fill,Left,LeftTrim,Lower,Match,Mid,"
PB_ScriptWord += ",Pos,Replace,Right,RightTrim,Space,Trim,Upper,CommandParm,DoScript,GetApplication,"
PB_ScriptWord += ",GetEnvironment,Post,ProfileInt,ProfileString,Restart,Run,Send,SetProfileString,ShowHelp,Yield,"
PB_ScriptWord += ",CPU,CloseWithReturn,OpenSheet,OpenSheetWithParm,OpenWithParm,Automatic,BackColor,BorderStyle,BringToTop,Checked,"
PB_ScriptWord += ",DragAuto,DragIcon,Enabled,FaceName,FontCharSet,FontFamily,FontPitch,Height,Italic,LeftText,"
PB_ScriptWord += ",RightToLeft,TabOrder,Tag,TextColor,TextSize,ThirdState,ThreeState,Underline,Visible,Weight,"
PB_ScriptWord += ",Width,X,Y,Default,Border,ControlMenu,DataObject,HScrollBar,HSplitScroll,Icon,"
PB_ScriptWord += ",LiveScroll,MaxBox,MinBox,Object,Resizable,Title,TitleBar,VScrollBar,Accelerator,AllowEdit,"
PB_ScriptWord += ",AutoHScroll,Item,Limit,ShowList,Sorted,ItemPictureIndex,PictureHeight,PictureWidth,PictureMaskColor,PictureName,"
PB_ScriptWord += ",Alignment,AutoSkip,AutoVScroll,DisplayData,DisplayOnly,HideSelection,IgnoreDefaultButton,Increment,Mask,MaskDataType,"
PB_ScriptWord += ",MinMax,Spin,TabStop,TextCase,UnderLine,UseCodeTable,Category,CategorySort,Depth,Elevation,"
PB_ScriptWord += ",FocusRectangle,GraphType,Legend,LegendDispAttr,OverlapPercent,Perspective,PieDispAttr,Rotation,Series,SeriesSort,"
PB_ScriptWord += ",ShadeColor,Spacing,TitleDispAttr,Values,MaxPosition,MinPosition,StdHeight,BeginX,BeginY,EndX,"
PB_ScriptWord += ",EndY,LineColor,LineStyle,LineThickness,DisableNoScroll,ExtendedSelect,MultiSelect,AutoArrange,ButtonHeader,EditLabels,"
PB_ScriptWord += ",FixedLocations,LabelWrap,LargePictureHeight,LargePictureMaskColor,LargePictureName,LargePictureWidth,Scrolling,ShowHeader,SmallPictureHeight,SmallPictureMaskColor,"
PB_ScriptWord += ",SmallPictureName,SmallPictureWidth,SortType,StatePictureHeight,StatePictureMaskColor,StatePictureName,StatePictureWidth,View,Activation,ClassLongName,"
PB_ScriptWord += ",ClassShortName,ContentsAllowed,DisplayName,DisplayType,DocFileName,IsDragTarget,LinkItem,LinkUpdateOptions,ObjectData,ParentStorage,"
PB_ScriptWord += ",FillColor,FillPattern,Invert,OriginalSize,PictureName,HTextAlign,DisabledName,VTextAlign,BottomMargin,DocumentName,"
PB_ScriptWord += ",HeaderFooter,InputFieldBackColor,InputFieldNamesVisible,InputFieldsVisible,LeftMargin,PicturesAsFrame,ReturnsVisible,RightMargin,RulerBar,SpacesVisible,"
PB_ScriptWord += ",TabBar,TabsVisible,ToolBar,TopMargin,UndoDepth,WordWrap,CornerHeight,CornerWidth,Password,BorderColor,"
PB_ScriptWord += ",BoldSelectedText,CreateOnDemand,Control,FixedWidth,FocusOnButtonDown,Multiline,PerpendicularText,PictureOnRight,PowerTips,RaggedRight,"
PB_ScriptWord += ",SelectedTab,ShowPicture,ShowText,TabPosition,DisableDragDrop,HasButtons,HasLines,Indent,LinesAtRoot,Color,"
PB_ScriptWord += ",StatePictureName,ColumnsPerPage,LibraryName,LinesPerPage,ObjectType,PowerTipText,Style,TabBackColor,TabTextColor,UnitsPerColumn,"
PB_ScriptWord += ",UnitsPerLine,StdWidth,AppName,DDETimeOut,DWMessageTitle,MicroHelpDefault,ToolbarFrameTitle,ToolbarPopMenuText,ToolbarSheetTitle,ToolbarText,"
PB_ScriptWord += ",ToolbarTips,ToolbarUserControl,ClassDefinition,Ancestor,DataTypeOf,IsAutoinstantiate,IsStructure,IsSystemType,IsVariableLength,IsVisualType,"
PB_ScriptWord += ",Name,NestedClassList,ParentClass,ScriptList,VariableList,Application,ConnectString,Driver,ErrCode,ErrText,"
PB_ScriptWord += ",Location,Options,Trace,UserID,Busy,CallCount,ClientID,ConnectTime,ConnectUserID,LastCallTime,"
PB_ScriptWord += ",NumInputs,NumOutputs,InParmType,OutParmType,Enumeration,Value,CPUType,MachineCode,OSFixesRevision,OSMajorRevision,"
PB_ScriptWord += ",OSMinorRevision,PBFixesRevision,PBMajorRevision,PBMinorRevision,NumberOfColors,ScreenHeight,ScreenWidth,OSType,PBType,Win16,"
PB_ScriptWord += ",Line,Number,ObjectEvent,WindowMenu,AutoScale,DataType,DisplayAttr,DisplayEveryNLabels,DropLines,Frame,"
PB_ScriptWord += ",Label,LabelDispAttr,MajorDivisions,MajorGridLine,MajorTic,MaximumValue,MaxValDateTime,MinimumValue,MinorDivisions,MinorGridLine,"
PB_ScriptWord += ",MinorTic,MinValDateTime,OriginLine,PrimaryLine,RoundTo,RoundToUnitTo,ScaleType,ScaleValue,SecondaryLine,ShadeBackEdge,"
PB_ScriptWord += ",AutoSize,DisplayExpression,Escapement,Format,lassDefinition,CutHighlighted,Data,DropHighlighted,HasFocus,ItemX,"
PB_ScriptWord += ",ItemY,OverlayPictureIndex,PictureIndex,StatePictureIndex,FileType,Filename,Pathname,AttachmentFile,ConversationID,DateReceived,"
PB_ScriptWord += ",MessageSent,MessageType,NoteText,ReceiptRequested,Recipient,Subject,Unread,Address,EntryID,RecipientType,"
PB_ScriptWord += ",MessageID,SessionID,MicroHelpHeight,MenuItemType,MergeOption,MicroHelp,ShiftToRight,Shortcut,ToolbarItemDown,ToolbarItemDownName,"
PB_ScriptWord += ",ToolbarItemBarIndex,ToolbarItemName,ToolbarItemOrder,ToolbarItemSpace,ToolbarItemText,ToolbarItemVisible,Columns,CurrentItem,DropDown,Handle,"
PB_ScriptWord += ",WordParm,LongParm,DoubleParm,StringParm,PowerObjectParm,Processed,ReturnValue,Storage,RowsInError,RowsRead,"
PB_ScriptWord += ",RowsWritten,Syntax,AbsoluteSelfTime,AbsoluteTotalTime,CalledRoutine,CallingLine,CallingRoutine,HitCount,PercentCalleeSelfTime,PercentCalleeTotalTime,"
PB_ScriptWord += ",PercentCallerTotalTime,LineNumber,MaxSelfTime,MaxTotalTime,MinSelfTime,MinTotalTime,PercentSelfTime,PercentTotalTime,Routine,Class,"
PB_ScriptWord += ",Kind,ApplicationName,CollectionTime,NumberOfActivities,TraceFileName,Access,AliasName,ArgumentList,EventId,EventIdName,"
PB_ScriptWord += ",ExternalUserFunction,IsExternalEvent,IsLocallyDefined,IsLocallyScripted,IsRPCFunction,IsScripted,LocalVariableList,ReturnType,Source,SystemFunction,"
PB_ScriptWord += ",ActivityType,TimerValue,Message,Severity,ActivityNode,LastError,FileName,IsCreate,ObjectID,IsEvent,"
PB_ScriptWord += ",ParentNode,EnterTimerValue,ExitTimerValue,Argument,Interval,Running,AutoCommit,Database,DBMS,DBParm,"
PB_ScriptWord += ",DBPass,Lock,LogID,LogPass,ServerName,SQLCode,SQLDBCode,SQLErrText,SQLNRows,SQLReturnData,"
PB_ScriptWord += ",TimeOut,Bold,Children,CutHighLighted,DropHighLighted,Expanded,ExpandedOnce,ItemHandle,Level,SelectedPictureIndex,"
PB_ScriptWord += ",ArrayDefinition,Cardinality,CallingConvention,InitialValue,IsConstant,IsControl,IsUserDefined,OverridesAncestorValue,ReadAccess,TypeInfo,"
PB_ScriptWord += ",WriteAccess,KeyboardIcon,MenuID,MenuName,ToolbarAlignment,ToolbarHeight,ToolbarVisible,ToolbarWidth,ToolbarX,ToolbarY,"
PB_ScriptWord += ",WindowState,WindowType,"

end event

