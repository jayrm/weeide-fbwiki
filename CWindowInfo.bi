#ifndef __CWINDOWINFO_INCLUDE__
#define __CWINDOWINFO_INCLUDE__

type CWindowInfo

	private:
		as HWND _hwnd
		as DWORD _WindowType
		as any ptr _WindowPtr

	public:
		declare constructor()
		declare constructor( byval hwnd as HWND, byval wptr as any ptr, byval wid as DWORD )
		declare destructor()

		declare function GetWindowType() as DWORD
		declare sub SetWindowType( byval wid as DWORD )

		declare function GetWindowPtr() as any ptr
		declare sub SetWindowPtr( byval wptr as any ptr )

		declare static function GetWindowType( byval hwnd as HWND ) as DWORD
		declare static function GetWindowPtr( byval hwnd as HWND ) as any ptr

		declare sub SetWindowInfo( byval hwnd as HWND, byval wptr as any ptr, byval wid as DWORD = 0 )

		declare static function GetWindowInfoPtr( byval hwnd as HWND ) as CWindowInfo ptr

end type

#endif
