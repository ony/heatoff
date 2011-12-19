TARGET = heatoff
VALA_PKGS += sensors cpufreq posix-regex posix-latest
VAPI_DIRS += .
LIBS += sensors cpufreq
CFLAGS += -g
VALAFLAGS += --save-temps --profile=posix -v

include ../mk/top.mk
-include vala.mk
#-include opt.mk

$(TARGET): sensors.vapi cpufreq.vapi posix-regex.vapi

clean: clean-generated-c
clean-generated-c:
	rm -f CpuHealth.c heatoff.c
