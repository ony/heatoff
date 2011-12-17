TARGET = heatoff
VALA_PKGS += sensors
VAPI_DIRS += .
LIBS += sensors
CFLAGS += -g

include ../mk/top.mk
-include vala.mk
#-include opt.mk

$(TARGET): sensors.vapi
