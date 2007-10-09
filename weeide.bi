#ifndef __WEENYIDE_INCLUDE__
#define __WEENYIDE_INCLUDE__

#include once "CApplication.bi"
#include once "CDocuments.bi"

#include once "weeide_resource.bi"
#include once "resource.bi"

'' list of opened documents
extern Docs as CDocuments
extern Application as CApplication

'' --------------------------------------------------------
'' CHILD WINDOW IDENTIFIERS
'' --------------------------------------------------------
#define WID_MAINWINDOW &h40000001
#define WID_CODEWINDOW &h40000002
#define WID_WIKIWINDOW &h40000003
#define WID_HTMLWINDOW &h40000004

'' --------------------------------------------------------
'' APPLICATION MESSAGES
'' --------------------------------------------------------
#define WM_APP_QUERYCOMMAND (WM_APP+1)

/'
Is sent to query the availability of a command.

WM_APP_QUERYCOMMAND
  wID = LOWORD(wParam)    '' item identifer
  state = (UINT*)lParam   '' address of integer to return new state

RETURN VALUE:
  TRUE to indicate that the command is supported, and *state holds the new
  menu state for the command. (e.g. MF_ENABLED, MF_GRAYED, etc ).
  FALSE to indicate that the command is not supported by or unknown to the
  window.

Sent to a window to query the availability of a command.

WM_APP_QUERYCOMMAND
  wParam = (WPARAM)(UINT)wID    '' item identifier
  lParam = (LPARAM)(UINT*)state '' address of integer to return new state

The window will return TRUE if the command is known, and state holds the
new requested menu state. (e.g. MF_ENABLED, MF_GRAYED, etc ).  If the
only the return value is needed, state may be set to NULL.
'/

'' --------------------------------------------------------
#define WM_APP_FINDTEXT (WM_APP+2)
/'
WM_APP_FINDTEXT
  wParam = (WPARAM)0             // item identifier
  lParam = (LPARAM)(FINDCTX*)fnd // address of integer to return new state

Message sent to main window and dispatched to child windows to
start/continue a find text operation.

Returns TRUE if a match was found
'/


'' --------------------------------------------------------
#define WM_APP_PAGEINDEXCOMPLETED (WM_APP+3)
/'
WM_APP_PAGEINDEXCOMPLETED
  wParam = (BOOL)fSuccess
  lParam = 0

Is sent by mkwiki_RefreshPageIndex() to indicate that the operation is complete.
If fSuccess is non-zero, then the operation completed successfully.
'/

#endif
