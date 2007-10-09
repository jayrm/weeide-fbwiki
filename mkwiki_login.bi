#ifndef __WEEIDE_LOGIN_INCLUDE__
#define __WEEIDE_LOGIN_INCLUDE__

type CLoginDialog

	private:
		as CWindow _hwnd

	public:
		as TString username
		as TString password

		declare function SaveData() as BOOL

		declare static function DialogProc( _
				byval hwnd as HWND, _
				byval uMsg as UINT, _
				byval wParam as WPARAM, _
				byval lParam as LPARAM _
			) as BOOL

		declare function Show( byval hwndParent as HWND ) as BOOL

end type

#endif

