#include once "windows.bi"
#include once "common.bi"

#include once "CList.bi"

constructor CListNode()
	_next = NULL
	_prev = NULL
end constructor

destructor CListNode()
end destructor

sub CListNode.Insert( byval prevnode as CListNode ptr, byval nextnode as CListNode ptr )

	if( prevnode ) then

		_prev = prevnode
		_next = prevnode->_next

		prevnode->_next = @this

		if( _next ) then
			_next->_prev = @this
		end if

	elseif( nextnode ) then

		_next = nextnode
		_prev = nextnode->_prev

		nextnode->_prev = @this

		if( _prev ) then
			_prev->_next = @this
		end if

	else

		_next = NULL
		_prev = NULL

	end if

end sub

sub CListNode.Remove()

	if( _prev ) then
		_prev->_next = _next
	end if

	if( _next ) then
		_next->_prev = _prev
	end if

	_next = NULL
	_prev = NULL

end sub

function CListNode.GetNext() as CListNode ptr
	return _next
end function

function CListNode.GetPrev() as CListNode ptr
	return _prev
end function

'' --------------------------------------------------------

constructor CList()
	_head = NULL
	_count = 0
end constructor

destructor CList()
end destructor

function CList.Insert( byval node as CListNode ptr, byval prevnode as CListNode ptr, byval nextnode as CListNode ptr ) as CListNode ptr

	if( node ) then

		node->Insert( prevnode, nextnode )

		if( node->GetNext() = _head ) then
			_head = node
		end if

		_count += 1
	end if

	return node

end function


sub CList.Remove( byval node as CListNode ptr )

	if( node ) then
	
		if( node = _head ) then
			_head = node->GetNext()
		end if

		node->Remove()

		_count -= 1

	end if

end sub


function CList.GetFirst() as CListNode ptr
	return _head
end function

function CList.GetNext( byval node as CListNode ptr ) as CListNode ptr
	if( node ) then
		return node->GetNext()
	end if
	return NULL
end function

function CList.GetPrev( byval node as CListNode ptr ) as CListNode ptr
	if( node ) then
		return node->GetPrev()
	end if
	return NULL
end function

function CList.GetCount() as integer
	return _count
end function
