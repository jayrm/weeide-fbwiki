#ifndef __WEEIDE_ABOUT_INCLUDE__
#define __WEEIDE_ABOUT_INCLUDE__

type CAboutDialog

	private:
		as CWindow _hwnd

	public:
		declare static function DialogProc( _
				byval hwnd as HWND, _
				byval uMsg as UINT, _
				byval wParam as WPARAM, _
				byval lParam as LPARAM _
			) as BOOL

		declare function Show( byval hwndParent as HWND ) as BOOL

end type

#endif

