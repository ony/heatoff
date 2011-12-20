TARGET = heatoff
VALA_PKGS += sensors cpufreq posix-regex posix-missing
VAPI_DIRS += .
LIBS += sensors cpufreq
CFLAGS += -g
VALAFLAGS += --save-temps --profile=posix -v

include vala.mk

$(TARGET): sensors.vapi cpufreq.vapi posix-regex.vapi posix-missing.vapi

clean: clean-generated-c
clean-generated-c:
	rm -f CpuHealth.c heatoff.c
