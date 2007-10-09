#include once "windows.bi"
#include once "common.bi"

#include once "TString.bi"
#include once "CWindow.bi"
#include once "CWindowProps.bi"

constructor CWindowProps()

	_hwnd = NULL
	_filename.Clear()
	_title.Clear()
	_changed = FALSE

end constructor 

destructor CWindowProps()

	_filename.Clear()
	_title.Clear()

end destructor

sub CWindowProps.UpdateDisplayTitle()

	dim as TString s = _title
	if( _changed ) then
		s += "*"
	end if

	SetDisplayTitle( s )

end sub

function CWindowProps.GetHwnd() as HWND

	return _hwnd

end function

sub CWindowProps.SetHwnd( byval HWND as hwnd )

	_hwnd = hwnd

end sub

function CWindowProps.GetTitle() as TString

	return _title

end function

sub CWindowProps.SetTitle( byref title as TString )

	_title = title
	UpdateDisplayTitle()

end sub

function CWindowProps.GetFileName() as TString

	return _filename

end function

sub CWindowProps.SetFileName( byref filename as TString )

	_filename = filename

end sub

sub CWindowProps.SetFileName( byval filename as TCHAR ptr )

	dim as TString f = filename
	SetFileName( f )

end sub

function CWindowProps.GetHasFileName() as BOOl

	return iif( _filename.GetLength() <> 0, TRUE, FALSE )

end function

function CWindowProps.GetDisplayTitle() as TString

	return _hwnd.GetText()

end function

sub CWindowProps.SetDisplayTitle( byref title as TString )

	_hwnd.SetText( title )

end sub

function CWindowProps.GetModify() as BOOL

	return _changed

end function

sub CWindowProps.SetModify( byval flag as BOOL )

	flag = iif( flag, TRUE, FALSE )
	
	if( flag <> _changed ) then
	
		_changed = flag
		UpdateDisplayTitle()

	end if

end sub
