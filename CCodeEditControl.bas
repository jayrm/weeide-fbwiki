#include once "windows.bi"
#include once "win/richedit.bi"
#include once "win/commdlg.bi"
#include once "common.bi"

#include once "weeide.bi"
#include once "TString.bi"
#include once "CCodeEditControl.bi"
#include once "utils.bi"

#define MYCLASSNAME TEXT( "CodeEdit" )

static shared as WNDPROC _orgeditproc = NULL
static shared as integer _orgeditcbbytes

#define GetCodeEditControlPtr( hwnd ) _
	(cast(CCodeEditControl ptr, GetWindowLong( hwnd, GWL_USERDATA )))

''
constructor CCodeEditControl()
	_hwnd = NULL
	_hInstance = NULL
	_fnt = NULL
end constructor

''
destructor CCodeEditControl()
	if( _fnt ) then
		DeleteObject( _fnt )
		_fnt = NULL
	end if
end destructor

''
function CCodeEditControl.GetHwnd() as HWND
	return _hwnd
end function

''
operator CCodeEditControl.Cast() as HWND
	return _hwnd
end operator

''
function OpenCallback(byval dwCookie as DWORD, _
		byval pbBuff as LPBYTE, byval cb as LONG, byval pcb as LONG ptr ) as DWORD

	if( ReadFile( cast(HANDLE, dwCookie), pbBuff, cb, cast(ULONG ptr, pcb), NULL )) then
		return FALSE
	end if
	
	return GetLastError()
end function

function CCodeEditControl.OpenFile( byval filename as TCHAR ptr ) as BOOL

	dim as HANDLE h
	dim as EDITSTREAM es

	if( _hwnd.IsNull() ) then
		return FALSE
	end if

	h = CreateFile( filename, GENERIC_READ, FILE_SHARE_READ, NULL, _
			OPEN_EXISTING, 0, NULL )

	if( h = INVALID_HANDLE_VALUE ) then
		return FALSE
	end if
		
	es.dwCookie    = cast(DWORD, h)
	es.dwError     = 0
	es.pfnCallback = procptr( OpenCallback )

	SendMessage( _hwnd, EM_STREAMIN, SF_TEXT, cast(LPARAM, @es) ) 

	SendMessage( _hwnd, EM_SETMODIFY, 0, 0L ) 
 
	CloseHandle( h )

	return TRUE 
end function

''
function SaveCallback(byval dwCookie as DWORD, _
		byval pbBuff as LPBYTE, byval cb as LONG, byval pcb as LONG ptr ) as DWORD

	if( WriteFile( cast(HANDLE, dwCookie), pbBuff, cb, cast(ULONG ptr, pcb), NULL )) then
		return FALSE
	end if

	return GetLastError() 
end function

function CCodeEditControl.SaveFile( byval filename as TCHAR ptr ) as BOOL

	dim as HANDLE h
	dim as EDITSTREAM es

	if( _hwnd.IsNull() ) then
		return FALSE
	end if

	h = CreateFile( filename, GENERIC_WRITE, 0, NULL, _
			CREATE_ALWAYS, 0, NULL )

	if( h = INVALID_HANDLE_VALUE ) then
		return FALSE
	end if

	es.dwCookie    = cast(DWORD, h)
	es.dwError     = 0
	es.pfnCallback = procptr( SaveCallback )
 
	SendMessage( _hwnd, EM_STREAMOUT, SF_TEXT, cast(LPARAM, @es) )

	SendMessage( _hwnd, EM_SETMODIFY, 0, 0L ) 
 
	CloseHandle( h )

	return TRUE 

end function

''
function CCodeEditControl.FindNext( byval fnd as FINDCTX ptr ) as BOOL

	dim as FINDTEXTEX ft
	dim as UINT fuFlags = 0

	if( (fnd->flags and FINDFLAG_UP) = 0 ) then
		fuFlags or= FR_DOWN
	end if

	if( (fnd->flags and FINDFLAG_MATCHCASE) <> 0 ) then
		fuFlags or= FR_MATCHCASE
	end if

	if( (fnd->flags and FINDFLAG_WHOLEWORD) <> 0 ) then
		fuFlags or= FR_WHOLEWORD
	end if

	SendMessage( _hwnd, EM_EXGETSEL, 0, cast(LPARAM,@ft.chrg ))

	if( (fnd->flags and FINDFLAG_UP) <> 0 ) then
		if( (fnd->flags and FINDFLAG_FROMSTART) <> 0 ) then
			ft.chrg.cpMin = GetWindowTextLength( _hwnd )
			ft.chrg.cpMax = 0
		else
			ft.chrg.cpMax = -1
		end if
	else
		if( (fnd->flags and FINDFLAG_FROMSTART) <> 0 ) then
			ft.chrg.cpMin = 0
			ft.chrg.cpMax = -1
		else
			ft.chrg.cpMin = ft.chrg.cpMax
			ft.chrg.cpMax = -1
		end if
	end if

	ft.lpstrText = fnd->sFind

	dim ret as integer = SendMessage( _hwnd, EM_FINDTEXTEX, fuFlags, cast(LONG, @ft) )
	if( ret >= 0 ) then
		'' ??? Should we automatically to this, use a flag, or let the caller do it.
		SendMessage( _hwnd, EM_EXSETSEL, 0, cast(LPARAM, @ft.chrgText ) )
		SendMessage( _hwnd, EM_HIDESELECTION, FALSE, FALSE )
		SendMessage( _hwnd, EM_SCROLLCARET, 0, 0 )
		return TRUE
	end if
	
	return FALSE

end function

''
function CCodeEditControl.NextWord() as BOOL

	dim as CHARRANGE range
	dim as integer n
	SendMessage( _hwnd, EM_EXGETSEL, 0, cast(LPARAM, @range ))

	dim as GETTEXTLENGTHEX tlenex = (0, 0)
	n = SendMessage( _hwnd, EM_GETTEXTLENGTHEX, cast(WPARAM, @tlenex), 0 )

	if( range.cpMin <> range.cpMax ) then
	
		range.cpMin = range.cpMax
	
	end if

	if( range.cpMin = range.cpMax ) then
	
		'' Skip over non-word characters
		while( range.cpMin < n )
		
			if( SendMessage( _hwnd, EM_FINDWORDBREAK, WB_CLASSIFY, range.cpMin ) = 0 ) then
				exit while
			end if
			range.cpMin += 1

		wend
		range.cpMax = range.cpMin

		'' Move to beginning of word
		while( range.cpMin > 0 )
		
			if( SendMessage( _hwnd, EM_FINDWORDBREAK, WB_CLASSIFY, range.cpMin - 1) <> 0 ) then
				exit while
			end if
			range.cpMin -= 1
		
		wend

		'' Scan to end of word
		while( range.cpMax < n )
		
			if( SendMessage( _hwnd, EM_FINDWORDBREAK, WB_CLASSIFY, range.cpMax ) <> 0 ) then
				exit while
			end if
			range.cpMax += 1
		
		wend

	end if

	if( range.cpMin >= range.cpMax ) then
		return FALSE
	end if
	
	SendMessage( _hwnd, EM_EXSETSEL, 0, cast(LPARAM, @range) )
	return TRUE

end function

''
function CCodeEditControl.TabIndent( byval bOutdent as BOOL ) as BOOL
	dim as CHARRANGE range, r

	SendMessage( _hwnd, EM_EXGETSEL, 0, cast(LPARAM, @range) )
	if( range.cpMin <> range.cpMax ) then

		dim as integer line1 = SendMessage( _hwnd, EM_LINEFROMCHAR, range.cpMin, 0 )
		dim as integer line2 = SendMessage( _hwnd, EM_LINEFROMCHAR, range.cpMax, 0 )
		if( line1 <> line2 ) then

			'' We have a multi-line selection.

			dim as integer idx, length, i
			dim as WCHAR buf(0 to 1)

			'' don't change the last line if it has no text selected
			idx = SendMessage( _hwnd, EM_LINEINDEX, line2, 0 )
			if( idx = range.cpMax ) then
				line2 -= 1
			end if

			'' prevent flicker
			SendMessage( _hwnd, WM_SETREDRAW, FALSE, 0 )

			if( bOutdent ) then
				
				'' do an outdent
				for i = line2 to line1 step -1

					idx = SendMessage( _hwnd, EM_LINEINDEX, i, 0 )
					length = SendMessage( _hwnd, EM_LINELENGTH, idx, 0 )
					if( length > 0 ) then

						r.cpMin = idx
						r.cpMax = idx + 1
						SendMessage( _hwnd, EM_EXSETSEL, 0, cast(LPARAM, @r) )
						SendMessage( _hwnd, EM_GETSELTEXT, 0, cast(LPARAM, @buf(0)) )
						if( IsCharWhiteSpace( buf(0) )) then
							SendMessage( _hwnd, EM_REPLACESEL, TRUE, cast(LPARAM, @TEXT( "" )) )
							range.cpMax -= 1
						end if
					end if
				next
				SendMessage( _hwnd, EM_EXSETSEL, 0, cast(LPARAM, @range ))

			else
				'' do an indent
				for i = line2 to line1 step -1
					idx = SendMessage( _hwnd, EM_LINEINDEX, i, 0 )
					length = SendMessage( _hwnd, EM_LINELENGTH, idx, 0 )
					if( length > 0 ) then

						dim b as integer = FALSE
					
						if( idx > 0 ) then
							r.cpMin = idx - 1
							r.cpMax = idx
							SendMessage( _hwnd, EM_EXSETSEL, 0, cast(LPARAM, @r) )
							SendMessage( _hwnd, EM_GETSELTEXT, 0, cast(LPARAM, @buf(0)) )
							if( IsCharLineBreak( buf(0) )) then
								b = TRUE
							end if
						else
							b = TRUE
						end if

						if( b = TRUE ) then
							r.cpMin = idx
							r.cpMax = idx
							SendMessage( _hwnd, EM_EXSETSEL, 0, cast(LPARAM, @r))
							SendMessage( _hwnd, EM_REPLACESEL, TRUE, cast(LPARAM, @TEXT( "\t" ) ))
							range.cpMax += 1
						end if
					
					end if
				next 
				SendMessage( _hwnd, EM_EXSETSEL, 0, cast(LPARAM, @range ))
			end if

			SendMessage( _hwnd, WM_SETREDRAW, TRUE, 0 )
			InvalidateRect( _hwnd, NULL, TRUE )

			return TRUE
		
		end if
	
	end if

	return FALSE

end function

function CCodeEditControl.HideSelection( byval fHide as BOOL, byval fChangeStyle as BOOL ) as BOOL 
	return SendMessage( _hwnd, EM_HIDESELECTION, fHide, fChangeStyle )
end function

'' EditWordBreakProc
function CCodeEditControl.WordBreakProc( _
	byval s as WCHAR ptr, _
	byval i as integer, _
	byval n as integer, _
	byval code as integer _
	) as integer

	'' Rich Edit 2.0 only pass unicode buffers to this procedure

	select case ( code )
	case WB_CLASSIFY:

		'' According to the MS docs, these are the 
		'' possible return flags ( plus a 4 bit char class in the low nibble)
		'' WBF_BREAKAFTER 0x40
		'' WBF_BREAKLINE  0x20
		'' WBF_ISWHITE    0x10

		'' But had to use these weird flags based on the Rich Edit's built-in
		'' Wordbreakproc. I couldn't get this to work with any other values.
		'' '\t' actually returns decimal 19 in rich edit built-in wordbreakproc
		'' Probably because I am using the wrong flags or some such bullshit.
		'' For now, I just don't care as it seems to work OK with EM_FINDTEXTEX 
		'' and FR_WHOLEWORD.
		
		if( IsCharWhiteSpace( s[0] ) ) then
			return 50
		elseif( IsCharDelimiter( s[0] ) ) then
			return 1
		elseif( IsCharLineBreak( s[0] ) ) then
			return 20
		else
			return 0
		end if
	
	case WB_ISDELIMITER:
		if( IsCharDelimiter( s[0] )) then
			return TRUE
		end if

	case WB_LEFT:
		return i

	case WB_LEFTBREAK:
		while( i > 0 )
		
			if( IsCharSymbol( s[i] ) and IsCharSymbol( s[i-1] )) then
				i -= 1
			elseif( IsCharAnySpace( s[i] ) and IsCharAnySpace( s[i-1] )) then
				i -= 1
			elseif( IsCharDelimiter( s[i] ) and IsCharDelimiter( s[i-1] )) then
				i -= 1
			else
				exit while
			end if

		wend
		return i

	case WB_RIGHT:

		while( i < n )

			if( IsCharSymbol( s[i] )) then
				i += 1
			else
				exit while
			end if
		
		wend
		return i

	case WB_RIGHTBREAK:
		return i
		
	case WB_MOVEWORDLEFT:
		if( i > 0 ) then
		
			if( IsCharSymbol( s[i-1] )) then
				while( (i > 0) and (IsCharSymbol( s[i-1] ) <> FALSE) )
					i -= 1
				wend
			elseif( IsCharAnySpace( s[i-1] )) then
				while( (i > 0) and (IsCharAnySpace( s[i-1] ) <> FALSE) )
					i -= 1
				wend
			else
				i -= 1
			end if
		end if
		return i

	case WB_MOVEWORDRIGHT:
		if( i < n ) then
			if( IsCharSymbol( s[i] )) then
				while( (i < n) and (IsCharSymbol( s[i] ) <> FALSE) )
					i += 1
				wend
			elseif( IsCharAnySpace( s[i] )) then
				while( (i < n) and (IsCharAnySpace( s[i] ) <> FALSE) )
					i += 1
				wend
			else
				i += 1
			end if
		end if
		return i

	end select

	return 0

end function

function CCodeEditControl.GetModify() as BOOL
	return SendMessage( _hwnd, EM_GETMODIFY, 0, 0)
end function

function CCodeEditControl.SetModify( byval flag as BOOL ) as BOOL
	return SendMessage( _hwnd, EM_SETMODIFY, flag, 0)
end function

function CCodeEditControl.GetSelText() as TString 

	dim as TString ret

	dim as CHARRANGE range
	SendMessage( _hwnd, EM_EXGETSEL, 0, cast(LPARAM, @range))
	
	if( range.cpMin = range.cpMax ) then
		ret = TEXT("")
	else
		ret.SetSize( range.cpMax - range.cpMin )
		SendMessage( _hwnd, EM_GETSELTEXT, 0, cast(LPARAM, ret.GetPtr()) )
	end if
	
	return ret

end function

function CCodeEditControl.ReplaceSel( byref s as TString ) as BOOL

	SendMessage( _hwnd, EM_REPLACESEL, TRUE, cast(LPARAM, s.GetPtr()) )

	return TRUE

end function

function CCodeEditControl.GetText() as TString
	return _hwnd.GetText()
end function

function CCodeEditControl.SetText( byref s as TString ) as BOOL
	return _hwnd.SetText( s )
end function

''
'' --------------------------------------------------------
'' The superclasses edit procedure
'' --------------------------------------------------------
function CCodeEditControl.EditProc _
	( _
		byval hwnd as HWND, _
		byval uMsg as UINT, _
		byval wParam as WPARAM, _
		byval lParam as LPARAM _
	) as LRESULT

	'' We are superclassing the Rich Edit Control, so we can use CCodeEditControl	
	dim as CCodeEditControl ptr _this = GetCodeEditControlPtr( hwnd )

	select case ( uMsg )
	case WM_CHAR:

		'' If it is a tab key, check if we have a selection spanning
		'' multiple lines.
		
		if( cast(TCHAR, wParam) = ASC(TEXT( "\t" )) ) then

			if( _this->TabIndent( GetKeyState( VK_SHIFT ) and &h8000 )) then
				return 0
			else
				if( GetKeyState( VK_SHIFT ) and &h8000 ) then
					'' !!! TODO: If the shift key was down, move back by one tab stop
					return 0
				end if
			end if

		else

			if( IsCharAnySpace( cast(TCHAR, wParam ))) then
				SendMessage( hwnd, EM_STOPGROUPTYPING, 0, 0 )
			end if

		end if
	end select

	'' call the original window proc
	return CallWindowProc( _orgeditproc, hwnd, uMsg, wParam, lParam )

end function

function CCodeEditControl.SelfRegister() as BOOL

	static as BOOL bClassRegistered = FALSE

	dim as WNDCLASS wcls

	if( bClassRegistered = FALSE ) then
	
		'' superclass the richedit control
		if( GetClassInfo( _hInstance, RICHEDIT_CLASS, @wcls ) = FALSE ) then
			Application.ErrorMessage( GetLastError(), TEXT( "Unable to superclass Richedit control" ))
			return FALSE
		end if

		'' save this, we'll need it later.
		_orgeditproc = wcls.lpfnWndProc
		_orgeditcbbytes = wcls.cbWndExtra

		wcls.lpfnWndProc   = procptr( CCodeEditControl.EditProc )
		wcls.hInstance     = _hInstance
		wcls.lpszMenuName  = NULL
		wcls.lpszClassName = @MYCLASSNAME

		'' Register the superclassed richedit class     
		if( RegisterClass( @wcls ) = FALSE ) then
			Application.ErrorMessage( GetLastError(), TEXT( "Could not register the CodeEdit class" ))
			return FALSE
		end if

		bClassRegistered = TRUE
	end if

	return bClassRegistered

end function

function CCodeEditControl.Create _
	( _
		byval wordwrap as BOOL, _
		byval rc as RECT ptr, _
		byval hwndParent as HWND, _
		byval id as integer _
	) as BOOL

	dim as DWORD styles

	'' must have a parent
	if( hwndParent = NULL ) then
		return FALSE
	end if

	_hInstance = cast(HINSTANCE, GetWindowLong( hwndParent, GWL_HINSTANCE ))

	'' make sure our class is registered
	if( SelfRegister() = FALSE ) then
		return FALSE
	end if

	styles = WS_CHILD or ES_MULTILINE _
				or ES_WANTRETURN or WS_VSCROLL or ES_AUTOVSCROLL _
				or ES_DISABLENOSCROLL

	if( wordwrap = FALSE ) then
		styles or= WS_HSCROLL or ES_AUTOHSCROLL
	end if

	dim as RECT tmprc = (0,0,0,0)
	if( rc = NULL ) then
		rc = @tmprc
	end if

	'' Create the superclassed edit control for the window
	_hwnd = CreateWindowEx( WS_EX_CLIENTEDGE, _
				MYCLASSNAME, NULL, _
				styles, _
				0, 0, rc->right-rc->left, rc->bottom-rc->top, _
				hwndParent, cast(HMENU, id), _hInstance, NULL )

	'' Initialize the edit control
	if( _hwnd ) then

		_info.SetWindowInfo( _hwnd, @this, 0 )

		'' Set the text mode
		SendMessage( _hwnd, EM_LIMITTEXT, 0, 0 )
		SendMessage( _hwnd, EM_SETTEXTMODE, TM_PLAINTEXT, 0 )
		SendMessage( _hwnd, EM_SETUNDOLIMIT, 1000, 0 )

		_fnt = CreateFixedFont( -11 )
		SendMessage( _hwnd, WM_SETFONT, cast( WPARAM, _fnt ), TRUE )

		if( WordWrap = FALSE ) then
			SendMessage( _hwnd, EM_SETWORDBREAKPROC, 0, cast(LPARAM, procptr(CCodeEditControl.WordBreakProc)) )
		end if

		SendMessage( _hwnd, EM_SETEVENTMASK, 0, ENM_CHANGE or ENM_KEYEVENTS )

		return TRUE
	end if

	return FALSE

end function

