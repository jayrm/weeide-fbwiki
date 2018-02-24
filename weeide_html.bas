#include once "windows.bi"
#include once "common.bi"

#include once "weeide.bi"
#include once "weeide_html.bi"

#include once "utils.bi"

#define MYCLASSNAME TEXT( "HtmlDoc" )

'' --------------------------------------------------------
constructor HtmlWindow()

	_hInstance = NULL
	_hwnd = NULL
	_title.Clear()
	browser = NULL

end constructor 

destructor HtmlWindow()
	if( browser ) then
		delete browser
	end if

end destructor

'' --------------------------------------------------------
function HtmlWindow.GetHwnd() as HWND
	return _hwnd
end function

'' --------------------------------------------------------
sub HtmlWindow.UpdateWindowTitle( byval bForce as BOOL )
	SetWindowText( _hwnd, _title )
end sub

function HtmlWindow.GetTitle() as TString
	return _title
end function

sub HtmlWindow.SetTitle( byref newTitle as TString )
	if( _title.GetLength() > 0 ) then
		Docs.Remove( _title )
	end if
	_title = newTitle
	if( newTitle.GetLength() > 0 ) then
		Docs.Add( newTitle, _hwnd )
	end if
	UpdateWindowTitle( TRUE )
end sub

'' --------------------------------------------------------
function HtmlWindow.SelfRegister() as BOOL 

	static as BOOL bClassRegistered = FALSE

	dim as WNDCLASS wcls

	if( bClassRegistered = FALSE ) then
	
		'' Setup window class
		wcls.style         = CS_HREDRAW or CS_VREDRAW
		wcls.lpfnWndProc   = procptr( HtmlWindow.WindowProc )
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
			Application.ErrorMessage( GetLastError(), TEXT( "Could not register the HtmlWindow class" ))
		else
			bClassRegistered = TRUE
		end if

	end if

	return bClassRegistered

end function

'' --------------------------------------------------------
'' Create a code window
'' hwndParent is the MDI Client window
'' --------------------------------------------------------
function HtmlWindow.InitInstance( byval hwndParent as HWND , byref title as TString, byval bWordWrap as BOOL ) as HtmlWindow ptr

	dim as HtmlWindow ptr _this
	dim as RECT rc

	'' must have a parent
	if( hwndParent = NULL ) then
		return NULL
	end if

	'' create our class
	_this = new HtmlWindow
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

	_this->SetTitle( title )
	_this->_info.SetWindowInfo( _this->_hwnd, _this, WID_HTMLWINDOW )

	'' get client area
	GetClientRect( _this->_hwnd, @rc ) 

	_this->browser = new webctrl( _this->_hwnd, _
						   0, _
						   0, _
						   rc.right-rc.left, _
						   rc.bottom-rc.top, _
						   WIN_BROWSER )

	'' For some reason we need this or else it won't display
	_this->browser->move( 0,0,rc.right-rc.left,rc.bottom-rc.top)

	return _this

end function

'' --------------------------------------------------------
'' WM_APP_QUERYCOMMAND
'' --------------------------------------------------------
function HtmlWindow.OnQueryCommand( byval menuid as UINT, byval state as UINT ptr ) as BOOL
	'' don't care
	return -1
end function

'' --------------------------------------------------------
'' WM_COMMAND
'' --------------------------------------------------------
function HtmlWindow.OnCommand( byval wParam as WPARAM, byval lParam as LPARAM ) as BOOL
	return FALSE
end function

'' --------------------------------------------------------
'' WM_CLOSE
'' --------------------------------------------------------
function HtmlWindow.OnClose( byval bNoPrompt as BOOL ) as BOOL
	Docs.Remove _title
	return TRUE
end function

'' --------------------------------------------------------
'' BROWSER stuff
'' --------------------------------------------------------
function HtmlWindow.Navigate( byref sUrl as string ) as BOOL
	if( browser ) then
		return browser->Navigate( sUrl )
	end if
	return FALSE
end function

'' --------------------------------------------------------
'' The HtmlWindow's WNDPROC
'' --------------------------------------------------------
function HtmlWindow.WindowProc( _
	byval hwnd as HWND, _
	byval uMsg as UINT, _
	byval wParam as WPARAM, _
	byval lParam as LPARAM _
	) as LRESULT

	dim as HtmlWindow ptr _this = GetHtmlWindowPtr( hwnd )

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
''		..SetFocus( _this->_txt )

	case WM_SIZE:
		dim as integer nWidth = LOWORD(lParam)
		dim as integer nHeight = HIWORD(lParam)
		if( _this ) then
			if( _this->browser ) then
				_this->browser->Move( 0, 0, nWidth, nHeight )
			end if
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

	case WM_CHAR:
		if( wParam = 27 ) then
			SendMessage( hwnd, WM_CLOSE, 0, 0 )
		end if
		return 0

	case WM_DESTROY:	
		if( _this ) then
			delete _this
		end if
		return 0

	end select

	return DefMDIChildProc( hwnd, uMsg, wParam, lParam )

end function
