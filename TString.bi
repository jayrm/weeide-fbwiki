#ifndef __TSTRING_INCLUDE__
#define __TSTRING_INCLUDE__

type TString

	private:
		_data as TCHAR ptr
		_length as integer
		_size as integer

		declare sub _initialize()

	public:
		declare constructor ()
		declare constructor ( byval s as TCHAR ptr, byval length as integer )
		declare constructor ( byval s as TCHAR ptr )
		declare constructor ( byref s as TString )
		declare destructor ()

		declare sub Clear()

		declare function SetSize( byval size as integer ) as BOOL

		declare function GetSize() as integer
		declare function GetByteSize() as integer

		declare function GetLength() as integer
		declare function GetByteLength() as integer

		declare function Assign( byval s as TCHAR ptr, byval length as integer ) as BOOL
		declare function Assign( byval s as TCHAR ptr ) as BOOL
		declare function Assign( byref s as Tstring ) as BOOL

		declare function Concat( byval s as TCHAR ptr, byval length as integer ) as BOOL
		declare function Concat( byval s as TCHAR ptr ) as BOOL
		declare function Concat( byref s as Tstring ) as BOOL

		declare operator let( byref s as TString )
		declare operator let( byval s as TCHAR ptr )
		declare operator let( byval s as LPTSTR )

		declare operator +=( byref s as TString )
		declare operator +=( byval s as TCHAR ptr )
		declare operator +=( byval s as LPTSTR )

		declare operator cast() as TCHAR ptr
		declare operator cast() as LPCTSTR
		declare function GetPtr() as TCHAR ptr

		declare static function ToStr( byval number as integer ) as TString
end type

#endif