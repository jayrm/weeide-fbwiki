#include once "weeide_ini.bi"
#include once "fbdoc_string.bi"

type OPT_T
	sKey as string
	sValue as string
	sDefault as string
end type

dim shared m_max_opts as integer = 1
dim shared m_num_opts as integer = 0
redim shared m_opts(1 to m_max_opts) as OPT_T

''
dim shared m_filename as string
dim shared m_fhandle as integer = 0
dim shared m_fileopened as boolean = false
dim shared m_overwrite as boolean = false

''
sub weeide_ini_clearopts( )

	m_max_opts = 1
	m_num_opts = 0
	redim m_opts(1 to m_max_opts) as OPT_T

end sub

''
function weeide_ini_findopt( byref optname as const string ) as integer
	
	for i as integer = 1 to m_num_opts
		if( lcase(optname) = lcase(m_opts(i).sKey) ) then
			function = i
			exit function
		end if
	next

	function = 0

end function

''
function weeide_ini_addopt _
	( _
		byref optname as const string, _
		byref optvalue as const string = "", _
		byref optdefault as const string = "", _
		byval overwrite as boolean = false _
	) as boolean

	function = false

	if( optname = "" ) then
		exit function
	end if

	dim index as integer = weeide_ini_findopt( optname )

	if( index > 0 ) then
		if( overwrite ) then
			m_opts( index ).sValue = optvalue
		end if
		m_opts( index ).sDefault = optdefault	

	else
		if( m_num_opts = m_max_opts ) then
			m_max_opts *= 2
			redim preserve m_opts( 1 to m_max_opts ) as OPT_T
		end if

		m_num_opts += 1
		with m_opts( m_num_opts )
			.sKey = optname
			.sValue = optvalue
			.sDefault = optdefault
		end with

	end if

	function = true

end function

''
function weeide_ini_getopt( byref optname as const string ) as string

	function = ""

	dim index as integer = weeide_ini_findopt( optname )

	if( index > 0 ) then
		function = m_opts( index ).sValue
	end if

end function

''
function weeide_ini_setopt( byref optname as const string, byref optvalue as const string ) as boolean
	
	function = false

	dim index as integer = weeide_ini_findopt( optname )

	if( index > 0 ) then
		m_opts( index ).sValue = optvalue
	end if

end function

''
function weeide_ini_get_filename() as string

	if( m_filename = "" ) then
		m_filename = exepath() & "weeide.ini"
	end if

	function = m_filename

end function

''
function weeide_ini_set_filename( byref filename as const string ) as boolean

	m_filename = m_filename

	function = true

end function

''
function weeide_ini_openfile( byref filename as const string = "" ) as boolean

	weeide_ini_closefile()

	dim h as integer = freefile

	dim f as string = filename

	if( f = "" ) then
		f = m_filename
	end if

	if( open( f for input access read as #h ) = 0 ) then
		m_fileopened = true
		m_fhandle = h
		return true
	end if

	return false

end function

''
function weeide_ini_readfile( ) as boolean

	function = false

	if( m_fileopened = false ) then
		exit function
	end if

	while( eof(m_fhandle) = false )
		dim x as string
		line input #m_fhandle, x

		x = ltrim(x)

		'' is empty line?
		if( x = "") then
			continue while
		end if

		'' is comment line?
		select case left(x, 1)
		case "#", ";", "'"
			continue while
		end select

		'' has assignment char?
		dim i as integer = instr( x, "=" )
		if( i > 0 ) then
			dim sKey as string = trim( left( x, i-1 ) )
			dim sValue as string = fb.fbdoc.StripQuotes( ltrim( mid( x, i + 1 ) ) )
			
			weeide_ini_addopt( sKey, sValue, , m_overwrite )

		end if

	wend

	function = true

end function

''
function weeide_ini_closefile( ) as boolean

	function = false

	if( m_fileopened ) then
		close #m_fhandle
		m_fhandle = 0
		m_fileopened = false
		function = true
	end if

end function

''
function weeide_ini_loadfile( byref filename as const string = "", byval overwrite as boolean = false ) as boolean

	dim f as string = filename

	function = false

	if( f = "" ) then
		f = m_filename
	end if

	if( f = "" ) then
		exit function
	end if

	if( weeide_ini_openfile( filename ) = false ) then
		exit function
	end if

	m_overwrite = overwrite

	weeide_ini_readfile( )

	weeide_ini_closefile()

	function = true

end function
