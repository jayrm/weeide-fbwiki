#include once "windows.bi"
#include once "common.bi"

#include once "CWindow.bi"

''
constructor CWindow ( byval hNewWnd as HWND )

	_hWnd = hNewWnd

end constructor

''
sub CWindow.Attach( byval hNewWnd as HWND )

	_hWnd = hNewWnd

end sub

''
function CWindow.Detach( ) as HWND

	function = _hWnd
	_hWnd = NULL

end function

''
operator CWindow.let( byval hNewWnd as HWND )

	_hWnd = hNewWnd

end operator

''
operator CWindow.cast() as HWND

	return _hwnd

end operator

''
function CWindow.IsNull() as BOOL

	return iif( _hwnd, FALSE, TRUE )

end function

''
function CWindow.ShowWindow( byval nCmdShow as integer ) as BOOL

	function = ..ShowWindow( _hWnd, nCmdShow )

end function

''
function CWindow.UpdateWindow( ) as BOOL

	function = ..UpdateWindow( _hWnd )

end function

''
sub CWindow.DestroyWindow( )

	..DestroyWindow( _hWnd )

end sub

''
function CWindow.SetFocus() as BOOL

	return iif( ..SetFocus( _hwnd ), TRUE, FALSE )

end function

''
function CWindow.MoveWindow( byval x as integer, byval y as integer, byval w as integer, byval h as integer, byval bRepaint as BOOL ) as BOOL

	return ..MoveWindow( _hwnd, x, y, w, h, bRepaint )

end function

''
function CWindow.GetText( ) as TString

	dim as integer n = GetWindowTextLength( _hwnd )
	dim as TString s
	s.SetSize( n )
	GetWindowText( _hwnd, s.GetPtr(), n + 1 )
	return s

end function

''
function CWindow.SetText( byref s as TString ) as BOOL

	return SetWindowText( _hwnd, s )

end function

''
function CWindow.GetTextLength() as LONG

	return GetWindowTextLength( _hwnd )

end function
