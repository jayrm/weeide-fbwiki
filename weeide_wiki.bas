#include once "windows.bi"
#include once "win/richedit.bi"
#include once "common.bi"

#include once "weeide.bi"
#include once "weeide_wiki.bi"

#include once "utils.bi"

#include once "weeide_main.bi"
#include once "mkwiki.bi"

#define MYCLASSNAME TEXT( "WikiWindow" )

#define IDC_WIKI_NOTE_LABEL 1
#define IDC_WIKI_NOTE_EDIT  2
#define IDC_WIKI_EDIT  3

'' --------------------------------------------------------
constructor WikiWindow()
	_note = NULL
	_swissfnt = NULL
end constructor 

destructor WikiWindow()
	if( _swissfnt ) then
		DeleteObject( _swissfnt )
		_swissfnt = NULL
	end if
end destructor

'' --------------------------------------------------------
function WikiWindow.GetHwnd() as HWND
	return _hwnd
end function

'' --------------------------------------------------------
sub WikiWindow.UpdateWindowTitle( byval bForce as BOOL )
	'' !!! wnd.UpdateWindowTitle( bForce )
end sub

function WikiWindow.GetTitle() as TString
	return _props.GetTitle()
end function

sub WikiWindow.SetTitle( byref newTitle as TString )
	_props.SetTitle( newTitle )
end sub

function WikiWindow.GetFileName() as TString
	return _props.GetFileName()
end function

sub WikiWindow.SetFileName( byref newFilename as TString )
	_props.SetFileName( newFilename )
end sub

'' --------------------------------------------------------
function WikiWindow.OpenFile( byref filename as TString ) as BOOL

	dim as String sPage, sBody

	sPage = *filename.GetPtr()

	if( mkwiki_LoadPage( sPage, sbody ) ) then

		Docs.Add( filename, _hwnd )
		_props.SetTitle( filename )
		_props.SetFileName( filename )
		dim as TString s
		s = sBody
		_txt.SetText( s )
		_props.SetModify( FALSE )

		return TRUE

	else

		dim as TString msg 
		msg = TEXT( "Unable to open " )
		msg += filename
		msg += TEXT( ".\n" )
		Application.ErrorMessage( GetLastError(), msg )

	end if

	return FALSE

end function

function WikiWindow.SaveFile( byval bForcePrompt as BOOL ) as BOOL

	dim as TString filename = _props.GetFileName()

	if( filename.GetLength() = 0 ) then
		return FALSE
	end if
	
	dim as string sPage, sBody, sNote

	dim as TString s = _txt.GetText()
	dim as TString n = _note.GetText()

	sPage = *filename.GetPtr()
	sBody = *s.GetPtr()
	sNote = *n.GetPtr()

	if( mkwiki_SavePage( sPage, sBody, sNote )) then
	
		'' Save the filename and title
		_props.SetModify( FALSE )
		return TRUE
	
	else
		dim as TString msg 
		msg = TEXT( "Unable to save " )
		msg += filename
		msg += TEXT( ".\n" )
		Application.ErrorMessage( GetLastError(), msg )

	end if

	return FALSE

end function

function WikiWindow.GetModify() as BOOL
	return _props.GetModify()
end function

function WikiWindow.SetModify( byval flag as BOOL ) as BOOL
	_props.SetModify( flag )
	_txt.SetModify( flag )
	return TRUE
end function

function WikiWindow.GetHasFileName() as BOOL
	return _props.GetHasFileName()
end function

function WikiWindow.GetSelText() as TString 
	return _txt.GetSelText()
end function

function WikiWindow.GetText() as TString
	return _txt.GetText()
end function

function WikiWindow.SetText( byref s as TString ) as BOOL
	return _txt.SetText( s )
end function

function WikiWindow.FindNext( byval fnd as FINDCTX ptr ) as BOOL	
	return _txt.FindNext( fnd )
end function

function WikiWindow.HideSelection( byval fHide as BOOL, byval fChangeStyle as BOOL ) as BOOL
	return _txt.HideSelection( fHide, fChangeStyle )
end function

'' --------------------------------------------------------
function WikiWindow.InitInstance( byval hwndParent as HWND , byref title as TString ) as WikiWindow ptr

	dim as WikiWindow ptr _this
	dim as RECT rc

	'' must have a parent
	if( hwndParent = NULL ) then
		return NULL
	end if

	'' create our class
	_this = new WikiWindow
	if( _this = NULL ) then
		return NULL
	end if

	_this->_hInstance = cast(HINSTANCE, GetWindowLong( hwndParent, GWL_HINSTANCE ))

	'' make sure our class is registered
	if( _this->SelfRegister() = FALSE ) then
		delete _this
		return NULL
	end if

	'' find out if we should create the MDI child maximized
	dim as BOOL maximized
	dim as DWORD style = 0
	SendMessage( hwndParent, WM_MDIGETACTIVE, 0, cast(LPARAM, @maximized) )
	if( maximized ) then
		style = WS_MAXIMIZE
	end if

	'' create the actual window
	_this->_hwnd = CreateWindowEx( WS_EX_MDICHILD, _
		MYCLASSNAME, title, _
		style, _
		CW_USEDEFAULT, CW_USEDEFAULT, CW_USEDEFAULT, CW_USEDEFAULT, _
		hwndParent, NULL, _this->_hInstance, NULL ) 

	if( _this->_hwnd.IsNull() ) then
		Application.ErrorMessage( GetLastError(), TEXT( "Unable to create MDI child window" ) )
		delete _this
		return NULL
	end if

	_this->_props.SetHwnd( _this->_hwnd )
	_this->_props.SetTitle( title )
	_this->_info.SetWindowInfo( _this->_hwnd, _this, WID_WIKIWINDOW )

	'' get client area
	GetClientRect( _this->_hwnd, @rc ) 

	_this->_txt.Create( TRUE, @rc, _this->_hwnd, IDC_WIKI_EDIT )

	_this->_txt.ShowWindow( SW_SHOW )
	_this->_txt.UpdateWindow()
	_this->_txt.SetFocus()

	_this->_swissfnt = CreateSwissFont( -11 )

	'' frame label and edit for entering a note
	dim as HWND ctl
	ctl = CreateWindowEx( WS_EX_CLIENTEDGE, "STATIC", TEXT( "Note:" ), _
		WS_VISIBLE or WS_CHILD or SS_CENTER, _
		0, 0, 0, 0, _this->_hwnd, cast(HMENU, IDC_WIKI_NOTE_LABEL), _this->_hInstance, NULL )
	SendMessage( ctl, WM_SETFONT, cast(WPARAM, _this->_swissfnt), TRUE )

	_this->_note = CreateWindowEx( WS_EX_CLIENTEDGE, "EDIT", TEXT(""), _
		WS_VISIBLE or WS_CHILD or ES_AUTOHSCROLL, _
		0, 0, 0, 0, _this->_hwnd, cast(HMENU, IDC_WIKI_NOTE_EDIT), _this->_hInstance, NULL )
	SendMessage( _this->_note, WM_SETFONT, cast(WPARAM, _this->_swissfnt), TRUE )
	SendMessage( _this->_note, EM_LIMITTEXT, 75, 0 )

	_this->OnSize( rc.right - rc.left, rc.bottom - rc.top )

	return _this

end function

'' --------------------------------------------------------
'' WM_APP_QUERYCOMMAND
'' --------------------------------------------------------
function WikiWindow.OnQueryCommand( byval menuid as UINT, byval state as UINT ptr ) as BOOL
	
	select case menuid
	case IDM_FILE_SAVE:
		*state = MF_ENABLED
		return TRUE

	case IDM_WIKI_PREVIEW:
		*state = MF_ENABLED
		return TRUE

	end select

	return _txt.OnQueryCommand( menuid, state )

end function

'' --------------------------------------------------------
'' WM_COMMAND
'' --------------------------------------------------------
function WikiWindow.OnCommand( byval wParam as WPARAM, byval lParam as LPARAM ) as BOOL

	select case LOWORD( wParam )
	case IDC_WIKI_EDIT:
		select case( HIWORD( wParam ) )
		case EN_CHANGE:
			OnChange()
		end select
	end select

	return _txt.OnCommand( wParam, lParam )

end function

'' --------------------------------------------------------
'' WM_SIZE
'' --------------------------------------------------------
function WikiWindow.OnSize( byval nWidth as integer, byval nHeight as integer ) as BOOL

	/'
		+------+-----------------------+
		| (1)  | (2)                   |
		+------+-----------------------+
		| (3)                          |
		|                              |
		+------------------------------+

		(1) w1xh1, IDC_WIKI_NOTE_LABEL
		(2) w2xh1, IDC_WIKI_NOTE_EDIT
		(3) w3xh2, IDC_WIKI_EDIT
	'/

	dim as integer w1 = 80
	dim as integer w2 = nWidth - w1
	dim as integer w3 = nWidth
	dim as integer h1 = 23
	dim as integer h2 = nHeight - h1

	dim as CWindow ctl

	ctl = GetDlgItem( _hwnd, IDC_WIKI_NOTE_LABEL )
	ctl.MoveWindow(  0,  0, w1, h1, TRUE )

	ctl = GetDlgItem( _hwnd, IDC_WIKI_NOTE_EDIT )
	ctl.MoveWindow( w1,  0, w2, h1, TRUE )

	_txt.MoveWindow(  0, h1, w3, h2, TRUE )

	return TRUE

end function

'' --------------------------------------------------------
'' WM_CLOSE
'' --------------------------------------------------------
function WikiWindow.OnClose( byval bNoPrompt as BOOL ) as BOOL

	dim as BOOL ret = TRUE

	if( (bNoPrompt = FALSE) and (GetModify() <> FALSE) ) then
	
		dim as TString msg

		msg = TEXT( "Save changes to " )

		if( _props.GetHasFileName() ) then
			msg += _props.GetFileName()
		else
			msg += _props.GetTitle()
		end if

		msg += TEXT( "?" )

		'' Prompt to save
		select case( Application.MessageBox( msg, MB_YESNOCANCEL ) )
		case IDYES:
			ret = SaveFile()
		case IDNO:
			ret = TRUE
		case else
			ret = FALSE
		end select
	end if

	if( ret ) then
		Docs.Remove( _props.GetFileName() )
	end if

	return ret

end function

'' --------------------------------------------------------
'' EN_CHANGE
'' --------------------------------------------------------
function WikiWindow.OnChange() as BOOL
	_props.SetModify( TRUE )
	return _txt.OnChange()
end function

'' --------------------------------------------------------
function WikiWindow.SelfRegister() as BOOL 

	static as BOOL bClassRegistered = FALSE

	dim as WNDCLASS wcls

	if( bClassRegistered = FALSE ) then
	
		'' Setup window class
		wcls.style         = CS_HREDRAW or CS_VREDRAW
		wcls.lpfnWndProc   = procptr( WikiWindow.WindowProc )
		wcls.cbClsExtra    = 0
		wcls.cbWndExtra    = 0
		wcls.hInstance     = _hInstance
		wcls.hIcon         = LoadIcon( _hInstance, MAKEINTRESOURCE( IDI_DOCUMENT ))
		wcls.hCursor       = LoadCursor( NULL, IDC_ARROW )
		wcls.hbrBackground = cast(HBRUSH, COLOR_BTNFACE + 1)
		wcls.lpszMenuName  = NULL
		wcls.lpszClassName = @MYCLASSNAME

		'' Register the window class     
		if( RegisterClass( @wcls ) = FALSE ) then
		
			Application.ErrorMessage( GetLastError(), TEXT( "Could not register the WikiWindow class" ))
			return NULL
		end if

		bClassRegistered = TRUE
	end if

	return bClassRegistered

end function

'' --------------------------------------------------------
'' The WikiWindow's WNDPROC
'' --------------------------------------------------------
function WikiWindow.WindowProc( _
	byval hwnd as HWND, _
	byval uMsg as UINT, _
	byval wParam as WPARAM, _
	byval lParam as LPARAM _
	) as LRESULT

	dim as WikiWindow ptr _this = GetWikiWindowPtr( hwnd )

	if( _this = NULL ) then
		return DefMDIChildProc( hwnd, uMsg, wParam, lParam )
	end if

	/' NOTE: Even if these are processed, they must still be passed on
		WM_CHILDACTIVATE 
		WM_GETMINMAXINFO 
		WM_MENUCHAR 
		WM_MOVE 
		WM_SETFOCUS 
		WM_SIZE 
		WM_SYSCOMMAND 
	'/

	select case ( uMsg )
	case WM_SETFOCUS:
		_this->_txt.SetFocus()

	case WM_SIZE:
		_this->OnSize( LOWORD(lParam), HIWORD(lParam) )

	case WM_APP_QUERYCOMMAND:
		return _this->OnQueryCommand( LOWORD(wParam), cast(UINT ptr, lParam ))

	case WM_COMMAND:
		return _this->OnCommand( wParam, lParam )

	case WM_QUERYENDSESSION:
		return _this->OnClose( FALSE )

	case WM_CLOSE:
		'' If OnClose() is successful, pass WM_CLOSE to DefMDIChildProc
		'' wParam is set to TRUE if no prompt should be made
		if( _this->OnClose( cast(BOOL, LOWORD(wParam) )) ) then
		else
			return 0	
		end if

	case WM_DESTROY:	
		if( _this ) then
			delete _this
		end if
		return 0

	end select

	return DefMDIChildProc( hwnd, uMsg, wParam, lParam )

end function
