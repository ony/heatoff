TARGET = heatoff
VALA_PKGS += sensors cpufreq posix-regex posix-getopt
VAPI_DIRS += .
LIBS += sensors cpufreq
CFLAGS += -g
VALAFLAGS += --save-temps -v

include vala.mk

$(TARGET): sensors.vapi cpufreq.vapi posix-regex.vapi posix-getopt.vapi

clean: clean-generated-c
clean-generated-c:
	rm -f CpuHealth.c heatoff.c
