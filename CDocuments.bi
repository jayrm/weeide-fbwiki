#ifndef __WEEIDE_LIST_INCLUDE__
#define __WEEIDE_LIST_INCLUDE__

#include once "TString.bi"
#include once "CList.bi"

type CDocumentItem

	private:
		'' extends CListNode
		as CListNode _node
		as TString _name
		as HWND _hwnd

	public:
		declare function GetHwnd() as HWND
		declare sub      SetHwnd( byval newHwnd as HWND )

		declare function GetName() as TString
		declare function GetNamePtr() as TCHAR ptr
		declare sub      SetName( byref newName as TString )

		declare constructor ()
		declare constructor ( byref name as TString, byval hwnd as HWND )
		declare destructor ()

		declare function GetNext() as CDocumentItem ptr
		declare function GetPrev() as CDocumentItem ptr
end type

type CDocuments

	private:
		'' extends CList, must be first
		as CList _list

	public:
		declare constructor ()
		declare destructor ()

		declare function Add() as CDocumentItem ptr
		declare function Add( byref name as TString, byval hwnd as HWND ) as CDocumentItem ptr

		declare sub Remove( byval item as CDocumentItem ptr)
		declare sub Remove( byref name as TString )

		declare function GetFirst() as CDocumentItem ptr

		declare function GetCount() as integer

		declare function FindByName( byref name as TString ) as CDocumentItem ptr
		declare function NameExists( byref name as TString ) as BOOL

		declare function FindByHwnd( byval hwnd as HWND ) as CDocumentItem ptr
		declare function HwndExists( byval hwnd as HWND ) as BOOL

		declare function Rename( byref oldname as TString, byref newname as TString, byval hwnd as HWND = NULL ) as BOOL

end type

#endif

