#include once "windows.bi"
#include once "win/richedit.bi"
#include once "common.bi"

#include once "CCodeEditControl.bi"

#include once "weeide.bi"
#include once "weeide_edit.bi"

#include once "utils.bi"

'' --------------------------------------------------------
constructor CWeeIdeEditControl()
end constructor 

''
destructor CWeeIdeEditControl()
end destructor

''
function CWeeIdeEditControl.GetHwnd() as HWND
	return _txt
end function

''
operator CWeeIdeEditControl.Cast() as HWND
	return _txt
end operator

'' --------------------------------------------------------
function CWeeIdeEditControl.GetModify() as BOOL
	return _txt.GetModify()
end function

function CWeeIdeEditControl.SetModify( byval flag as BOOL ) as BOOL
	return _txt.SetModify( flag )
end function

function CWeeIdeEditControl.GetSelText() as TString 
	return _txt.GetSelText()
end function

function CWeeIdeEditControl.ReplaceSel( byref s as TString ) as BOOL
	return _txt.ReplaceSel( s )
end function

function CWeeIdeEditControl.GetText() as TString
	return _txt.GetText()
end function

function CWeeIdeEditControl.SetText( byref s as TString ) as BOOL
	return _txt.SetText( s )
end function

function CWeeIdeEditControl.FindNext( byval fnd as FINDCTX ptr ) as BOOL	
	return _txt.FindNext( fnd )
end function

function CWeeIdeEditControl.NextWord() as BOOL	
	return _txt.NextWord()
end function

function CWeeIdeEditControl.HideSelection( byval fHide as BOOL, byval fChangeStyle as BOOL ) as BOOL
	return _txt.HideSelection( fHide, fChangeStyle )
end function

function CWeeIdeEditControl.OpenFile( byval filename as TCHAR ptr ) as BOOL
	return _txt.OpenFile( filename )
end function

function CWeeIdeEditControl.SaveFile( byval filename as TCHAR ptr ) as BOOL
	return _txt.SaveFile( filename )
end function

function CWeeIdeEditControl.ShowWindow( byval nCmdShow as integer ) as BOOL
	return ..ShowWindow( _txt, nCmdShow )
end function

function CWeeIdeEditControl.UpdateWindow() as BOOL
	return ..UpdateWindow( _txt )
end function

function CWeeIdeEditControl.SetFocus() as BOOL
	return iif(..SetFocus( _txt ), TRUE, FALSE )
end function

function CWeeIdeEditControl.MoveWindow( byval x as integer, byval y as integer, byval w as integer, byval h as integer, byval bRepaint as BOOL ) as BOOL
	return ..MoveWindow( _txt, x, y, w, h, bRepaint )
end function

'' --------------------------------------------------------
'' Create a code window
'' hwndParent is the MDI Client window
'' --------------------------------------------------------
function CWeeIdeEditControl.Create( byval bWordWrap as BOOL, byval rc as RECT ptr, byval hwndParent as HWND, byval nID as UINT ) as BOOL

	'' must have a parent
	if( hwndParent = NULL ) then
		return FALSE
	end if

	return _txt.Create( bWordWrap, rc, hwndParent, nID )

end function

'' --------------------------------------------------------
'' WM_APP_QUERYCOMMAND
'' --------------------------------------------------------
function CWeeIdeEditControl.OnQueryCommand( byval menuid as UINT, byval state as UINT ptr ) as BOOL

	'' result -1=don't care
	dim as integer s = -1

	select case ( menuid )
	
	case IDM_EDIT_UNDO:
		if( SendMessage( _txt, EM_CANUNDO, 0, 0 ) ) then
			s = MF_ENABLED
		else
			s = MF_GRAYED
		end if

	case IDM_EDIT_REDO:
		if( SendMessage( _txt, EM_CANREDO, 0, 0 ) ) then
			s = MF_ENABLED
		else
			s = MF_GRAYED
		end if

	case IDM_EDIT_CUT, IDM_EDIT_COPY, IDM_EDIT_DELETE:
	
		dim as DWORD p1, p2
		SendMessage( _txt, EM_GETSEL, cast(WPARAM, @p1), cast(LPARAM, @p2) )
		if( p1 <> p2 ) then
			s = MF_ENABLED
		else
			s = MF_GRAYED
		end if

	case IDM_EDIT_PASTE:
		if( SendMessage( _txt, EM_CANPASTE, CF_TEXT, 0 ) ) then
			s = MF_ENABLED
		else
			s = MF_GRAYED
		end if

	case IDM_EDIT_SELECTALL, IDM_EDIT_FIND, IDM_EDIT_REPLACE
		s = MF_ENABLED

	end select

	if( s >= 0 ) then
		if( state ) then
			*state = s
		end if
		return TRUE
	end if

	return FALSE

end function

'' --------------------------------------------------------
'' WM_COMMAND
'' --------------------------------------------------------
function CWeeIdeEditControl.OnCommand( byval wParam as WPARAM, byval lParam as LPARAM ) as BOOL

	select case LOWORD( wParam )
	case IDM_EDIT_UNDO:
		return SendMessage( _txt, EM_UNDO, 0, 0 )
	case IDM_EDIT_REDO:
		return SendMessage( _txt, EM_REDO, 0, 0 )
	case IDM_EDIT_CUT:
		return SendMessage( _txt, WM_CUT, 0, 0 )
	case IDM_EDIT_COPY:
		return SendMessage( _txt, WM_COPY, 0, 0 )
	case IDM_EDIT_PASTE:
		return SendMessage( _txt, EM_PASTESPECIAL, CF_TEXT, cast(..LPARAM, NULL) )
	case IDM_EDIT_DELETE:
		return SendMessage( _txt, WM_CLEAR, 0, 0 )
	case IDM_EDIT_SELECTALL:
		dim as CHARRANGE range = (0, -1)
		return SendMessage( _txt, EM_EXSETSEL, 0, cast(..LPARAM, @range) )
	end select

	return FALSE

end function

'' --------------------------------------------------------
'' WM_CLOSE
'' --------------------------------------------------------
function CWeeIdeEditControl.OnClose( byval bNoPrompt as BOOL ) as BOOL

	return FALSE

end function

'' --------------------------------------------------------
'' EN_CHANGE
'' --------------------------------------------------------
function CWeeIdeEditControl.OnChange() as BOOL

	return FALSE

end function


