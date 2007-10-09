#ifndef __CLIST_INCLUDE__
#define __CLIST_INCLUDE__

type CListNode

	private:
		as CListNode ptr _next
		as CListNode ptr _prev

	public:
		declare constructor ()
		declare destructor ()

		declare sub Insert( byval prevnode as CListNode ptr, byval nextnode as CListNode ptr )
		declare sub Remove()

		declare function GetNext() as CListNode ptr
		declare function GetPrev() as CListNode ptr

end type

type CList

	private:
		as CListNode ptr _head
		as integer _count
		
	public:
		declare constructor ()
		declare destructor ()

		declare function Insert( byval node as CListNode ptr, byval prevnode as CListNode ptr, byval nextnode as CListNode ptr ) as CListNode ptr
		declare sub Remove( byval node as CListNode ptr )

		declare function GetFirst() as CListNode ptr
		declare function GetNext( byval node as CListNode ptr) as CListNode ptr
		declare function GetPrev( byval node as CListNode ptr) as CListNode ptr

		declare function GetCount() as integer

end type

#endif
