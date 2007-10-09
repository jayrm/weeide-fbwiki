#include once "windows.bi"
#include once "common.bi"

#include "CWindowInfo.bi"

'' All this business here is just for one thing: allow us
'' to attach an ID number and a pointer to any HWND.
'' A pointer to this class is stored in a window's
'' extra window data at GWL_USERDATA.  When we create a
'' window (or control, etc) we also call

constructor CWindowInfo()

	_hwnd = NULL
	_WindowType = 0
	_WindowPtr = NULL

end constructor

constructor CWindowInfo( byval hwnd as HWND, byval wptr as any ptr, byval wid as DWORD )

	_hwnd = hwnd
	_WindowType = wid
	_WindowPtr = wptr
	SetWindowLong( _hwnd, GWL_USERDATA, cast(LONG, @this ) )

end constructor

destructor CWindowInfo()
	if( _hwnd ) then
		SetWindowLong( _hwnd, GWL_USERDATA, cast(LONG, 0 ) )
	end if
end destructor

function CWindowInfo.GetWindowType() as DWORD

	return _WindowType

end function

sub CWindowInfo.SetWindowType( byval wid as DWORD )

	_WindowType = wid
	if( _hwnd ) then
		SetWindowLong( _hwnd, GWL_USERDATA, cast(LONG, @this ) )
	end if

end sub

function CWindowInfo.GetWindowPtr() as any ptr

	return _WindowPtr

end function

sub CWindowInfo.SetWindowPtr( byval wptr as any ptr )

	_WindowPtr = wptr
	if( _hwnd ) then
		SetWindowLong( _hwnd, GWL_USERDATA, cast(LONG, @this ) )
	end if
end sub

sub CWindowInfo.SetWindowInfo( byval hwnd as HWND, byval wptr as any ptr, byval wid as DWORD )

	_hwnd = hwnd
	_WindowType = wid
	_WindowPtr = wptr
	if( _hwnd ) then
		SetWindowLong( _hwnd, GWL_USERDATA, cast(LONG, @this ) )
	end if

end sub

function CWindowInfo.GetWindowPtr( byval hwnd as HWND ) as any ptr

	if( hwnd ) then
	
		dim as CWindowInfo ptr info = cast(CWindowInfo ptr, GetWindowLong( hwnd, GWL_USERDATA ))
		if( info ) then
			return info->_WindowPtr
		end if

	end if
	
	return NULL

end function

function CWindowInfo.GetWindowType( byval hwnd as HWND ) as DWORD

	if( hwnd ) then
	
		dim as CWindowInfo ptr info = cast(CWindowInfo ptr, GetWindowLong( hwnd, GWL_USERDATA ))
		if( info ) then
			return info->_WindowType
		end if

	end if
	
	return 0

end function

function GetWindowInfoPtr( byval hwnd as HWND ) as CWindowInfo ptr

	if( hwnd ) then
		return cast(CWindowInfo ptr, GetWindowLong( hwnd, GWL_USERDATA ))
	end if

	return NULL

end function