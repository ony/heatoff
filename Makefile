TARGET = heatoff
#VALA_VERSION=0.12
VALA_PKGS += sensors
VAPI_DIRS += .
LIBS += sensors
CFLAGS += -g

include ../mk/top.mk
-include vala.mk
#-include vala.mk opt.mk

all: heatoff.c

$(TARGET) heatoff.c: sensors.vapi
