TARGET = heatoff
VALA_PKGS += sensors cpufreq posix-regex posix-getopt posix-missing
VAPI_DIRS += .
LIBS += sensors cpufreq
CFLAGS += -g
VALAFLAGS += --profile=posix
VALAFLAGS += --save-temps -v

include vala.mk

$(TARGET): sensors.vapi cpufreq.vapi posix-regex.vapi posix-getopt.vapi posix-missing.vapi

clean: clean-generated-c
clean-generated-c:
	rm -f CpuHealth.c heatoff.c
