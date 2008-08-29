#ifndef __WEEIDE_CODE_INCLUDE__
#define __WEEIDE_CODE_INCLUDE__

#include once "weeide_edit.bi"
#include once "CWindowInfo.bi"
#include once "CWindowProps.bi"

type CodeWindow

	private:
		as CWindow _hwnd
		as CWindowInfo _info
		as CWindowProps _props
		as CWeeIdeEditControl _txt
		as HINSTANCE _hInstance

		declare function SelfRegister() as BOOL
		declare sub UpdateWindowTitle( byval bForce as BOOL )

	public:
		declare constructor ()
		declare destructor ()

		declare static function InitInstance( byval hwndParent as HWND, byref title as TString ) as CodeWindow ptr

		declare static function WindowProc( _
			byval hwnd as HWND, _
			byval uMsg as UINT, _
			byval wParam as WPARAM, _
			byval lParam as LPARAM  _
			) as LRESULT

		declare function GetHwnd() as HWND

		declare function GetTitle() as TString
		declare sub SetTitle( byref title as TString )
		
		declare function GetFileName() as TString
		declare sub SetFileName( byref title as TString )
		declare function GetHasFileName() as BOOL
		
		declare function GetModify() as BOOL
		declare function SetModify( byval flag as BOOL ) as BOOL
		declare function GetSelText() as TString
		declare function ReplaceSel( byref s as TString ) as BOOL
		declare function GetText() as TString
		declare function SetText( byref s as TString ) as BOOL

		declare function OnQueryCommand( byval menuid as UINT, byval state as UINT ptr) as BOOL
		declare function OnCommand( byval wParam as WPARAM, byval lParam as LPARAM ) as BOOL
		declare function OnClose( byval bNoPrompt as BOOL ) as BOOL
		declare function OnChange() as BOOL

		declare function OpenFile( byref filename as TString ) as BOOL
		declare function SaveFile( byval bForcePrompt as BOOL = FALSE ) as BOOL
		declare function FindNext( byval fnd as FINDCTX ptr ) as BOOL
		declare function HideSelection( byval fHide as BOOL, byval bChangeStyle as BOOL ) as BOOL

end type


#define GetCodeWindowPtr( hwnd ) _
	(cast(CodeWindow ptr, CWindowInfo.GetWindowPtr( hwnd )))

#endif
