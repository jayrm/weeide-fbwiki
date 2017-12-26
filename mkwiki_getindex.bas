#include once "fbdoc_defs.bi"
#include once "CWikiCon.bi"
#include once "printlog.bi"

#include once "file.bi"

using fb
using fbdoc

extern mkwikicon_index as CWikiCon ptr
extern wiki_url as string

dim shared mkwikicon_index as fb.fbdoc.CWikiCon ptr = NULL

private function RemoveHtmlTags( byref sBody as string ) as string

	dim as string txt, html
	dim as integer n, b = 0, j = 1, atag = 0, i = 1
	n = len(sBody)
	txt = ""

	printlog "Removing html tags"
	while( i <= n )

		if( lcase(mid( sBody, i, 4 )) = "&lt;" ) then
			txt += "<"
			i += 4
		elseif( lcase(mid( sBody, i, 4 )) = "&gt;" ) then
			txt += ">"
			i += 4
		elseif( lcase(mid( sBody, i, 5 )) = "&amp;" ) then
			txt += "&"
			i += 5
		elseif( lcase(mid( sBody, i, 6 )) = "&nbsp;" ) then
			txt += " "
			i += 6
		elseif( mid( sBody, i, 4 ) = "All<" and atag = 1 ) then
			txt += "All" + crlf + "----" + crlf
			i += 3
		elseif( mid( sBody, i, 5 ) = "All <" and atag = 1 ) then
			txt += "All " + crlf + "----" + crlf
			i += 3
		elseif( lcase(mid( sBody, i, 1 )) = "<" ) then
			atag = 0
			b = 1
			j = i + 1
			while( j <= n and b > 0 )
				select case ( mid( sBody, j, 1 ))
				case "<"
					b += 1
					j += 1
				case ">"
					b -= 1
					j += 1
				case chr(34)
					j += 1
					while( j <= n )
						select case ( mid( sBody, j, 1 ))
						case chr(34)
							j += 1
							exit while
						case else
							j += 1
						end select
					wend
				case else
					j += 1
				end select
			wend 

			html = mid( sBody, i, j - i )
			select case lcase( html )
			case "<br>","<br />"
				txt += crlf
			case "<hr>","<hr />"
				txt += "----"
			case else
				if left( html, 3 ) = "<a " then
					atag = 2
				end if
			end select
			i = j

		else
			txt += mid( sBody, i, 1 )
			i += 1
		end if

		if( atag = 2 ) then
			atag = 1
		else
			atag = 0
		end if

	wend

	return txt

end function

private function ScanForPageNames( byref sTxt as string ) as string

	dim as integer b = 0, i, j, k, n
	dim as string x, ret = ""

	i = 1
	n = len( sTxt )

	printlog "Scanning for page names"

	while( i <= n )
		
		j = instr( i, sTxt, any chr(10) + chr(13) )

		if j = 0 then
			x = trim( mid( sTxt, i ), any chr(10) + chr(13) + chr(33) + chr(9) )
			i = n + 1
		else
			x = trim( mid( sTxt, i, j - i ), any chr(10) + chr(13) + chr(33) + chr(9)  )
			i = j + 1
		end if

		if( b ) then
			if x = "----" then
				b = 0
				exit while
			elseif( len(x) > 2 ) then
				for k = 1 to len(x)
					select case mid(x,k,1)
					case "A" to "Z", "a" to "z", "0" to "9", "_"
					case else
					  exit for
					end select
				next
				if k > 1 then
					ret += left(x,k-1) + chr(10)
				end if
			end if
		else
			if x = "----" then
				b = 1
			end if
		end if
	wend

	return ret

end function

private function GetPageIndex _
	(_
		byref sFileName as string _
	) as integer

	dim as string sPage, sBody, sTxt, sPageList

	function = FALSE

	sPage = "PageIndex"

	printlog "Getting PageIndex (from " & wiki_url & "): ", TRUE

	if( mkwikicon_index->LoadPage( sPage, FALSE, FALSE, sBody ) = FALSE ) then
		printlog "Error"
	else

		printlog "OK"
		
		sTxt = RemoveHtmlTags( sBody )
		sPageList = ScanForPageNames( sTxt )

		printlog "Writing '" + sFileName + "': ", TRUE

		dim h as integer
		h = freefile
		if( open( sFileName for output as #h ) = 0 ) then
			printlog "OK"

			print #h, sPageList;
			close #h

			function = TRUE

		else
			printlog "ERROR"

		end if
	end if	

end function

public sub RefreshPageIndex ( byval bForceDownload as integer )
	
	dim bDownload as integer = FALSE

	if( bForceDownload = FALSE ) then
		'' ///
		if( fileexists( exepath + "/PageIndex.txt" ) = FALSE ) then
			bDownload = TRUE
		end if
	else
		bDownload = TRUE
	end if

	if( bDownload ) then
		'' ///
		GetPageIndex( exepath + "/PageIndex.txt" )
	end if

end sub
