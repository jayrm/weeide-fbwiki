#ifndef __WEEIDE_INI_BI_INCLUDE__
#define __WEEIDE_INI_BI_INCLUDE__

	declare sub      weeide_ini_clearopts( )
	declare function weeide_ini_findopt( byref optname as const string ) as integer
	declare function weeide_ini_getopt( byref optname as const string, byref optdefault as const string = "" ) as string
	declare function weeide_ini_setopt( byref optname as const string, byref optvalue as const string = "", byval create as const boolean = true ) as boolean

	declare function weeide_ini_get_filename() as string
	declare function weeide_ini_set_filename( byref filename as const string ) as boolean
	declare function weeide_ini_openfile( byref filename as const string = "" ) as boolean
	declare function weeide_ini_readfile( ) as boolean
	declare function weeide_ini_closefile( ) as boolean

	declare function weeide_ini_loadfile( byref filename as const string = "", byval create as boolean = true ) as boolean

#endif
