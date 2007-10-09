#ifndef __WEEIDE_HTML_INCLUDE__
#define __WEEIDE_HTML_INCLUDE__

#include once "CWindow.bi"
#include once "CWindowInfo.bi"
#include once "win/ole2.bi"
#include once "webctrl/webctrl.bi"
const WIN_BROWSER = WEBCTRL_IE 		'' or WEBCTRL_MOZILLA

type HtmlWindow

	private:
		as CWindow _hwnd
		as CWindowInfo _info
		as HINSTANCE _hInstance
		as TString _title
		as webctrl ptr browser

		declare function SelfRegister() as BOOL
		declare sub UpdateWindowTitle( byval bForce as BOOL )

	public:
		declare constructor ()
		declare destructor ()

		declare static function InitInstance( byval wid as DWORD, byval hwndParent as HWND, byref title as TString, byval bWordWrap as BOOL = FALSE ) as HtmlWindow ptr

		declare static function WindowProc( _
			byval hwnd as HWND, _
			byval uMsg as UINT, _
			byval wParam as WPARAM, _
			byval lParam as LPARAM  _
			) as LRESULT

		declare function GetHwnd() as HWND
		declare function GetWindowType() as DWORD

		declare function GetTitle() as TString
		declare sub SetTitle( byref title as TString )
		
		declare function OnQueryCommand( byval menuid as UINT, byval state as UINT ptr) as BOOL
		declare function OnCommand( byval wParam as WPARAM, byval lParam as LPARAM ) as BOOL
		declare function OnClose( byval bNoPrompt as BOOL ) as BOOL

		declare function Navigate( byref sUrl as string ) as BOOL

end type


#define GetHtmlWindowPtr( hwnd ) _
	(cast(HtmlWindow ptr, CWindowInfo.GetWindowPtr( hwnd )))

#endif
