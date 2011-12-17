TARGET = heatoff
VALA_PKGS += sensors cpufreq
VAPI_DIRS += .
LIBS += sensors cpufreq
CFLAGS += -g
VALAFLAGS += --save-temps

include ../mk/top.mk
-include vala.mk
#-include opt.mk

$(TARGET): sensors.vapi cpufreq.vapi
