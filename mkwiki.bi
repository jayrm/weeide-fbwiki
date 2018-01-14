#ifndef __MKWIKI_INCLUDE__
#define __MKWIKI_INCLUDE__

declare function mkwiki_RefreshPageIndex ( byval bForceDownload as integer ) as integer
declare function mkwiki_Create() as integer
declare function mkwiki_Destroy() as integer
declare function mkwiki_HookPrintLogger( byval frm as MainWindow ptr ) as integer
declare function mkwiki_UnhookPrintLogger() as integer
declare function mkwiki_LoadPageIndexToList( byval ctl as HWND, byval filter_ctl as HWND ) as integer
declare function mkwiki_Login( byval bForce as integer ) as integer

declare function mkwiki_LoadPage( byref sPage as string, byref sBody as string ) as integer
declare function mkwiki_SavePage( byref sPage as string, byref sBody as string, byref sNote as string ) as integer

declare function mkwiki_SavePageToCache( byref sPage as string, byref sBody as string ) as integer

declare function HtmlPreview_Init _
	( _
		byref sPrefixDir as string _
	) as integer

declare function HtmlPreview_Generate _
	( _
		byref sPage as string _
	) as integer

#endif
