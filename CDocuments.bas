#include once "windows.bi"
#include once "common.bi"

#include once "TString.bi"
#include once "CList.bi"
#include once "CDocuments.bi"

constructor CDocumentItem()
	_name = TEXT( "" )
	_hwnd = NULL
end constructor

constructor CDocumentItem( byref newName as TString, byval hwnd as HWND )
	_name = newName
	_hwnd = hwnd
end constructor

destructor CDocumentItem()
	_name = TEXT( "" )
end destructor

function CDocumentItem.GetNext() as CDocumentItem ptr
	return cast(CDocumentItem ptr, _node.GetNext() )
end function

function CDocumentItem.GetPrev() as CDocumentItem ptr
	return cast(CDocumentItem ptr, _node.GetPrev() )
end function

function CDocumentItem.GetHwnd() as HWND
	return _hwnd
end function

sub CDocumentItem.SetHwnd( byval newHwnd as HWND )
	_hwnd = newHwnd
end sub

function CDocumentItem.GetName() as TString 
	return _name
end function

function CDocumentItem.GetNamePtr() as TCHAR ptr
	return _name.GetPtr()
end function

sub CDocumentItem.SetName( byref newName as TString )
	_name = newName
end sub

'' --------------------------------------------------------

constructor CDocuments()
end constructor

destructor CDocuments()
end destructor

function CDocuments.Add() as CDocumentItem ptr
	dim as CDocumentItem ptr item = new CDocumentItem
	if( item ) then
		_list.Insert( cast(CListNode ptr,item), NULL, _list.GetFirst() )
	end if

	return item
end function

function CDocuments.Add( byref newName as TString, byval hwnd as HWND ) as CDocumentItem ptr
	dim as CDocumentItem ptr item = new CDocumentItem( newName, hwnd )
	if( item ) then
		_list.Insert( cast(CListNode ptr,item), NULL, _list.GetFirst() )
	end if

	return item
end function

sub CDocuments.Remove( byval item as CDocumentItem ptr )
	if( item ) then
		_list.Remove( cast(CListNode ptr, item ) )
		delete item
	end if
end sub

sub CDocuments.Remove( byref newName as TString )
	dim as CDocumentItem ptr item = FindByName( newName )
	Remove( item )
end sub

function CDocuments.GetFirst() as CDocumentItem ptr
	return cast(CDocumentItem ptr, _list.GetFirst())
end function

function CDocuments.GetCount() as integer
	return _list.GetCount()
end function

function CDocuments.FindByName( byref newName as TString ) as CDocumentItem ptr
	dim as CDocumentItem ptr item = GetFirst()
	while( item )
		'' TODO: Use TString operator or compare, etc.
		if( lstrcmpi( newName, item->GetNamePtr() ) = 0 ) then
			exit while
		end if
		item = item->GetNext()
	wend
	return item
end function

function CDocuments.NameExists( byref newName as TString ) as BOOL
	dim as CDocumentItem ptr item = FindByName( newName )
	return iif(item,TRUE,FALSE)
end function

function CDocuments.FindByHwnd(byval hwnd as HWND ) as CDocumentItem ptr
	dim as CDocumentItem ptr item = GetFirst()

	if( hwnd = NULL ) then
		return NULL
	end if

	while( item )
		if( item->GetHwnd() = hwnd ) then
			exit while
		end if
		item = item->GetNext()
	wend
	return item

end function

function CDocuments.HwndExists( byval newHwnd as HWND ) as BOOL
	dim as CDocumentItem ptr item = FindByHwnd( newHwnd )
	return iif(item,TRUE,FALSE)
end function

function CDocuments.Rename( byref oldname as TString, byref newname as TString, byval hwnd as HWND ) as BOOL

	dim as CDocumentItem ptr newitem = FindByName( newname )
	dim as CDocumentItem ptr olditem = FindByName( oldname )

	if( newitem = olditem ) then
		return TRUE
	end if
	
	if( newitem ) then
		return FALSE
	end if

	if( olditem )	 then
		if( hwnd = NULL ) then
			hwnd = olditem->GetHwnd()
		end if
		Remove( olditem )
		Add( newname, hwnd )
		return TRUE
	end if

	return FALSE

end function