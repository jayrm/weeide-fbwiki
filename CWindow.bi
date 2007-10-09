#ifndef __CWINDOW_INCLUDE__
#define __CWINDOW_INCLUDE__

#include once "TString.bi"

type CWindow

	private:
		_hwnd as HWND

	public:

		declare constructor ( byval hwnd as HWND = NULL )

		declare sub Attach( byval hwnd as HWND )
		declare function Detach () as HWND
		declare operator let( byval hwnd as HWND )
		declare operator cast() as HWND

		declare function IsNull() as BOOL

		declare function SetFocus() as BOOL
		declare function ShowWindow( byval nCmdShow as integer ) as BOOL
		declare function UpdateWindow() as BOOL
		declare function MoveWindow( byval x as integer, byval y as integer, byval w as integer, byval h as integer, byval bRepaint as BOOL ) as BOOL
		declare sub DestroyWindow()

		declare function GetText() as TString
		declare function SetText( byref s as TString ) as BOOL
		declare function GetTextLength() as LONG

end type

#endif
