FBC = fbc.exe

objpath=obj

ifndef FBDOCDIR
FBDOCDIR := ../fbdocs/fbdoc
endif

###########################################################

MAIN := weeide

SRCS := weeide_about.bas

SRCS += spellcheck.bas

SRCS += weeide_edit.bas
SRCS += weeide_code.bas
SRCS += weeide_wiki.bas
SRCS += weeide_html.bas
SRCS += weeide_find.bas
SRCS += weeide_spell.bas
SRCS += weeide_main.bas
SRCS += weeide_menu.bas

SRCS += mkwiki.bas
SRCS += mkwiki_login.bas
SRCS += mkwiki_getindex.bas
SRCS += mkwiki_preview.bas

SRCS += TString.bas
SRCS += CList.bas
SRCS += CWindow.bas
SRCS += CApplication.bas
SRCS += CCodeEditControl.bas
SRCS += COutputControl.bas
SRCS += CDocuments.bas
SRCS += CWindowInfo.bas
SRCS += CWindowProps.bas
SRCS += utils.bas

RESDEPS := $(wildcard res/*.*)
RESDEPS += resource.bi 
RESDEPS += weeide_resource.bi

RESHDRS := resource.bi weeide_resource.bi

RCS := resource.rc
HDRS := $(wildcard *.bi)
OBJS := $(patsubst %.bas,$(objpath)/%.o,$(MAIN).bas $(SRCS))
FBCFLAGS := -w pedantic -s gui -mt

FBCFLAGS += -p $(FBDOCDIR) -i $(FBDOCDIR)

ifdef DEBUG
FBCFLAGS += -g -exx
endif

APP := $(MAIN).exe

.SUFFIXES:
.SUFFIXES: .bas .bi

VPATH = .

###########################################################

$(objpath)/%.o : %.bas $(HDRS) $(RESHDRS)
	$(FBC) $(FBCFLAGS) -c $< -o $@

###########################################################

all : $(APP)

$(APP) : $(OBJS) $(RCS) $(RESDEPS)
	$(FBC) $(FBCFLAGS) $(OBJS) $(RCS) -x $(APP)

###########################################################

.PHONY : clean
clean:
	-rm -f $(OBJS) $(APP)
