##########################

LIBNAME := webctrl
LIBDEST := ../

SRCS := webctrl.bas CBrowser.bas CClientSite.bas CInPlaceSite.bas CInPlaceFrame.bas
OBJS := $(patsubst %.bas,obj/%.o,$(SRCS))

##########################

FBC := fbc
FBCFLAGS :=

ifdef DEBUG
FBCFLAGS += -g -d SPELL_CHECK_ENABLE
endif

LIBRARY := $(LIBDEST)lib$(LIBNAME).a

.SUFFIXES:
.SUFFIXES: .bas

VPATH = .

obj/%.o : %.bas 
	$(FBC) $(FBCFLAGS) -c $< -o $@

##########################

all: $(LIBRARY)


$(LIBRARY): $(OBJS)
	$(FBC) $(FBCFLAGS) -lib -x $(LIBRARY) $(OBJS)
	
	
.PHONY : clean
clean:
	-rm -f $(OBJS) $(LIBRARY)