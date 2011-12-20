ifndef __VALA_MK__
__VALA_MK__=1

SRCS = $(wildcard *.vala)
VALA_VERSION ?= 0.14
VALAC := /usr/local/pkgs/vala-git/bin/valac-0.16
#VALAC ?= valac$(VALA_SUFFIX)
VALA_SUFFIX ?= -$(VALA_VERSION)
#VALA_PACKAGES += gtk+-3.0
VALAFLAGS += $(patsubst %,--pkg=%,$(VALA_PKGS)) $(patsubst %,-X %,$(CFLAGS))
VALAFLAGS += $(patsubst %,--vapidir=%,$(VAPI_DIRS))
LDLIBS += $(patsubst %,-l%,$(LIBS))
VALA_LDLIBS += $(patsubst %,-X %,$(LDLIBS))


.PHONY: all clean clean-vala
.SUFFIXES: .c .vala .vapi

all: $(TARGET)

clean: clean-vala

clean-vala:
	rm -f $(TARGET)

$(TARGET): $(SRCS)
	$(VALAC) $(VALAFLAGS) -o $(@) $(filter %.vala,$(^)) $(VALA_LDLIBS)

%.c: %.vala
	$(VALAC) $(VALAFLAGS) -C -o $(@) $(<)

%: %.vala
	$(VALAC) $(VALAFLAGS) -o $(@) $(<)

endif
