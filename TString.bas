#include once "windows.bi"
#include once "common.bi"

#include once "TString.bi"

/'
	_data
		pointer to the string data
	_length
		number of characters (not bytes) in the string
		not including null terminator.  if == -1 then
		the actual length of the string is not known until
		lstrlen( _data ) is computed.
	_size
		number of characters (not bytes) the buffer can hold
		including the null terminator

	example:
		*_data = ABCD\0\0\0\0\0\0
		 _size = 10
		 _length = 4
'/

'' Allocate space for 'n' characters plus a null terminator
#define TSTRALLOC(n) (cast(TCHAR ptr,LocalAlloc( LMEM_FIXED or LMEM_ZEROINIT,(n) * sizeof(TCHAR) )))

'' Copy 'n' characters plus a null terminator
#define TSTRCPYN(d,s,n) CopyMemory((d),(s),(n) * sizeof(TCHAR))

''
sub TString._initialize()
	_data = NULL
	_length = 0
	_size = 0
end sub

''
constructor TString()
	_initialize()
end constructor

''
constructor TString( byval s as TCHAR ptr, byval length as integer )
	_initialize()
	Assign( s, length )
end constructor

''
constructor TString( byval s as TCHAR ptr )
	_initialize()
	Assign( s, -1 )
end constructor

''
constructor TString( byref s as TString )
	_initialize()
	Assign( s._data, s._length )
end constructor

''
destructor TString()
	if( _data ) then
		LocalFree( _data )
	end if

	_data = NULL
end destructor

''
sub TString.Clear()
	if( _data ) then
		LocalFree( _data )
	end if

	_initialize()
end sub

''
function TString.SetSize( byval maxlength as integer ) as BOOL
	
	'' unusable length, return a zeroed descriptor
	if( maxlength <= 0 ) then
		Clear()
		return TRUE	
	end if

	'' allocate data if does not exist
	if( _data = NULL ) then
		_data = TSTRALLOC( maxlength + 1 )
		if( _data = NULL ) then
			return FALSE
		end if
		
		_data[0] = 0
		_size = maxlength + 1
		_length = -1
		
		return TRUE

	end if

	'' need to resize?
	if( maxlength < _size ) then
		'' _size is already large enough, just set the null terminator
		_data[maxlength] = 0
	
	else
		'' resize the space preserving contents
		dim as TCHAR ptr newdata = TSTRALLOC( maxlength + 1 )
		if( newdata = NULL ) then
			return FALSE
		end if
		_size = maxlength + 1
		if( _length >= 0 ) then
			TSTRCPYN( newdata, _data, _length + 1 )
		end if
		LocalFree( _data )
		_data = newdata
	
	end if

	return TRUE

end function

''
function TString.GetSize() as integer
	return _size
end function

''
function TString.GetByteSize() as integer
	return _size * sizeof( TCHAR )
end function

''
function TString.GetLength() as integer
	if( _length < 0 ) then
		if( _data ) then
			return lstrlen( _data )
		else
			return 0
		end if
	end if

	return _length
end function

''
function TString.GetByteLength() as integer
	return GetLength() * sizeof( TCHAR )
end function

''
function TString.Assign( byval s as TCHAR ptr, byval length as integer ) as BOOL
	if( s = NULL ) then
		Clear()
		return TRUE
	end if

	if( length < 0 ) then
		length = lstrlen( s )
	end if

	if( length <= 0 ) then
		Clear()
		return TRUE
	end if

	if( SetSize( length ) ) then
		TSTRCPYN( _data, s, length + 1)
		_length = length
		return TRUE
	end if

	return FALSE
end function

''
function TString.Assign( byval s as TCHAR ptr ) as BOOL
	return Assign( s, -1 )
end function

function TString.Assign( byref s as TString ) as BOOL
	return Assign( s._data, s._length )
end function

''
function TString.Concat( byval s as TCHAR ptr, byval length as integer ) as BOOL
	if( s = NULL ) then
		return TRUE
	end if

	if( length < 0 ) then
		length = lstrlen( s )
	end if

	if( length <= 0 ) then
		return TRUE
	end if

	if( _length < 0 ) then
		_length = lstrlen( _data )
	end if

	if( SetSize( _length + length ) ) then

		if( _length < 0 ) then
			_length = lstrlen( _data )
		end if

		TSTRCPYN( _data + _length, s, length + 1 )
		_length += length
		return TRUE
	end if

	return FALSE
end function

''
function  TString.Concat( byref s as TString ) as BOOL
	return Concat( s._data, s._length )
end function

''
function TString.Concat( byval s as TCHAR ptr ) as BOOL
	return Concat( s, -1 )
end function

''

operator TString.let( byref s as TString )
	Assign( s )
end operator

''
operator TString.let( byval s as TCHAR ptr )
	Assign( s )
end operator

''
operator TString.let( byval s as LPTSTR )
	Assign( cast(TCHAR ptr, s ) )
end operator

''
operator TString.+=( byref s as TString )
	Concat( s )
end operator

''
operator TString.+=( byval s as TCHAR ptr )
	Concat( s )
end operator

''
operator TString.+=( byval s as LPTSTR )
	Concat( cast(TCHAR ptr, s ) )
end operator

operator +( byref s1 as TString, byref s2 as TString ) as TString
	dim as TString ret = s1
	ret += s2
	return ret
end operator

operator +( byval s1 as TCHAR ptr, byref s2 as TString ) as TString
	dim as TString ret = s1
	ret += s2
	return ret
end operator

operator +( byref s1 as TString, byval s2 as TCHAR ptr ) as TString
	dim as TString ret = s1
	ret += s2
	return ret
end operator

''
operator TString.Cast() as TCHAR ptr
	return cast(TCHAR ptr, _data)
end operator

''
operator TString.Cast() as LPCTSTR
	return cast(TCHAR ptr, _data)
end operator

''
function TString.GetPtr() as zstring ptr
	return cast(zstring ptr, _data)
end function

''
function TString.ToStr( byval number as integer) as TString
	dim as TString ret
	dim as integer count
	ret.SetSize(20)
	count = wsprintf( ret.GetPtr(), "%i", number )
	ret._length = count
	return ret
end function
