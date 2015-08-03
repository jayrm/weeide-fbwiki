#include once "windows.bi"
#include once "win/richedit.bi"
#include once "common.bi"

#include once "weeide.bi"
#include once "weeide_code.bi"

#include once "utils.bi"

#define MYCLASSNAME TEXT( "CodeWindow" )
#define IDC_EDIT_CONTROL 1

'' --------------------------------------------------------
constructor CodeWindow()
end constructor 

destructor CodeWindow()
end destructor

'' --------------------------------------------------------
function CodeWindow.GetHwnd() as HWND
	return _hwnd
end function

'' --------------------------------------------------------
sub CodeWindow.UpdateWindowTitle( byval bForce as BOOL )
	'' !!! wnd.UpdateWindowTitle( bForce )
end sub

function CodeWindow.GetTitle() as TString
	return _props.GetTitle()
end function

sub CodeWindow.SetTitle( byref newTitle as TString )
	_props.SetTitle( newTitle )
end sub

function CodeWindow.GetFileName() as TString
	return _props.GetFileName()
end function

sub CodeWindow.SetFileName( byref newFilename as TString )
	_props.SetFileName( newFilename )
end sub

'' --------------------------------------------------------
function CodeWindow.OpenFile( byref filename as TString ) as BOOL

	if( _txt.OpenFile( filename ) ) then

		Docs.Add( filename, _hwnd )
		_props.SetFileName( filename )
		_props.SetTitle( filename )
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

function CodeWindow.SaveFile( byval bForcePrompt as BOOL ) as BOOL

	dim as TString filename = _props.GetFileName()

	if( (filename.GetLength() = 0) or ( bForcePrompt <> FALSE ) ) then
	
		if(filename.GetLength() = 0) then
			filename = _props.GetTitle()
		end if

		if( Application.PromptSaveFile( _hwnd, filename ) = FALSE ) then
			return FALSE
		end if

		'' File already Opened?
		if( Docs.NameExists( filename ) ) then
		
			dim as TString msg = filename
			msg += TEXT( " is already opened.\nChoose a different file name, or close the other window." )
			Application.MessageBox( msg )
			return FALSE

		end if

	end if

	if( _txt.SaveFile( filename )) then
	
		'' Save the filename and title
		Docs.Rename( _props.GetFileName(), filename, _hwnd )
		_props.SetFileName( filename )
		_props.SetTitle( filename )
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

function CodeWindow.GetModify() as BOOL
	return _props.GetModify()
end function

function CodeWindow.SetModify( byval flag as BOOL ) as BOOL
	_props.SetModify( flag )
	_txt.SetModify( flag )
	return TRUE
end function

function CodeWindow.GetHasFileName() as BOOL
	return _props.GetHasFileName()
end function

function CodeWindow.GetSelText() as TString 
	return _txt.GetSelText()
end function

function CodeWindow.ReplaceSel( byref s as TString ) as BOOL
	return _txt.ReplaceSel( s )
end function

function CodeWindow.GetText() as TString
	return _txt.GetText()
end function

function CodeWindow.SetText( byref s as TString ) as BOOL
	return _txt.SetText( s )
end function

function CodeWindow.FindNext( byval fnd as FINDCTX ptr ) as BOOL	
	return _txt.FindNext( fnd )
end function

function CodeWindow.HideSelection( byval fHide as BOOL, byval fChangeStyle as BOOL ) as BOOL
	return _txt.HideSelection( fHide, fChangeStyle )
end function

'' --------------------------------------------------------
function CodeWindow.InitInstance( byval hwndParent as HWND , byref title as TString ) as CodeWindow ptr
	dim as CodeWindow ptr _this
	dim as RECT rc

	'' must have a parent
	if( hwndParent = NULL ) then
		return NULL
	end if

	'' create our class
	_this = new CodeWindow
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
	_this->_info.SetWindowInfo( _this->_hwnd, _this, WID_CODEWINDOW )

	'' get client area
	GetClientRect( _this->_hwnd, @rc ) 

	_this->_txt.Create( FALSE, @rc, _this->_hwnd, IDC_EDIT_CONTROL )

	_this->_txt.ShowWindow( SW_SHOW )
	_this->_txt.UpdateWindow()
	_this->_txt.SetFocus()

	return _this

end function

'' --------------------------------------------------------
'' WM_APP_QUERYCOMMAND
'' --------------------------------------------------------
function CodeWindow.OnQueryCommand( byval menuid as UINT, byval state as UINT ptr ) as BOOL

	select case menuid
	case IDM_FILE_SAVE, IDM_FILE_SAVE_AS:
		if( state ) then
			*state = MF_ENABLED
		end if
		return TRUE

	end select

	return _txt.OnQueryCommand( menuid, state )

end function

'' --------------------------------------------------------
'' WM_COMMAND
'' --------------------------------------------------------
function CodeWindow.OnCommand( byval wParam as WPARAM, byval lParam as LPARAM ) as BOOL

	select case LOWORD( wParam )
	case IDC_EDIT_CONTROL:
		select case( HIWORD( wParam ) )
		case EN_CHANGE:
			OnChange()
		end select
	end select

	return _txt.OnCommand( wParam, lParam )

end function

'' --------------------------------------------------------
'' WM_CLOSE
'' --------------------------------------------------------
function CodeWindow.OnClose( byval bNoPrompt as BOOL ) as BOOL

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
function CodeWindow.OnChange() as BOOL
	_props.SetModify( TRUE )
	return TRUE

end function


'' --------------------------------------------------------
function CodeWindow.SelfRegister() as BOOL 

	static as BOOL bClassRegistered = FALSE

	dim as WNDCLASS wcls

	if( bClassRegistered = FALSE ) then
	
		'' Setup window class
		wcls.style         = CS_HREDRAW or CS_VREDRAW
		wcls.lpfnWndProc   = procptr( CodeWindow.WindowProc )
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
		
			Application.ErrorMessage( GetLastError(), TEXT( "Could not register the CodeWindow class" ))
			return FALSE
		end if

		bClassRegistered = TRUE
	end if

	return bClassRegistered

end function

'' --------------------------------------------------------
'' The CodeWindow's WNDPROC
'' --------------------------------------------------------
function CodeWindow.WindowProc( _
	byval hwnd as HWND, _
	byval uMsg as UINT, _
	byval wParam as WPARAM, _
	byval lParam as LPARAM _
	) as LRESULT

	dim as CodeWindow ptr _this = GetCodeWindowPtr( hwnd )

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
		dim as integer nWidth = LOWORD(lParam)
		dim as integer nHeight = HIWORD(lParam)
		if( _this ) then
			_this->_txt.MoveWindow( 0, 0, nWidth, nHeight , TRUE )
		end if

	case WM_APP_QUERYCOMMAND:
		return _this->OnQueryCommand( LOWORD(wParam), cast(UINT ptr, lParam ))

	case WM_COMMAND:
		_this->OnCommand( wParam, lParam )

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
