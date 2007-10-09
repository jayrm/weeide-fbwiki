#ifndef __WEEIDE_EDIT_INCLUDE__
#define __WEEIDE_EDIT_INCLUDE__

#include once "CCodeEditControl.bi"

'' --------------------------------------------------------
'' Wraps CCodeEditContol to have the expected procedures
'' to work with the WeeIDE main window.  Main purpose is 
'' to tie link the edit control and the WeeIDE edit menu 
'' through OnQueryCommand() and OnCommand().
'' --------------------------------------------------------

type CWeeIdeEditControl

	private:
		as CCodeEditControl _txt

	public:
		declare constructor ()
		declare destructor ()

		declare function Create _
			( _
				byval wordwrap as BOOL, _
				byval rc as RECT ptr, _
				byval hwndParent as HWND, _
				byval id as UINT _
			) as BOOL

		declare static function WindowProc( _
			byval hwnd as HWND, _
			byval uMsg as UINT, _
			byval wParam as WPARAM, _
			byval lParam as LPARAM  _
			) as LRESULT

		declare function GetModify() as BOOL
		declare function SetModify( byval flag as BOOL ) as BOOL

		declare function GetSelText() as TString
		declare function GetText() as TString
		declare function SetText( byref s as TString ) as BOOL

		declare function SetFocus() as BOOL
		declare function ShowWindow( byval nCmdShow as integer ) as BOOL
		declare function UpdateWindow() as BOOL
		declare function MoveWindow( byval x as integer, byval y as integer, byval w as integer, byval h as integer, byval bRepaint as BOOL ) as BOOL

		declare function OnQueryCommand( byval menuid as UINT, byval state as UINT ptr) as BOOL
		declare function OnCommand( byval wParam as WPARAM, byval lParam as LPARAM ) as BOOL
		declare function OnClose( byval bNoPrompt as BOOL ) as BOOL
		declare function OnChange() as BOOL

		declare function OpenFile( byval filename as TCHAR ptr ) as BOOL
		declare function SaveFile( byval filename as TCHAR ptr ) as BOOL
		declare function FindNext( byval fnd as FINDCTX ptr ) as BOOL
		declare function HideSelection( byval fHide as BOOL, byval bChangeStyle as BOOL ) as BOOL

end type

#endif
