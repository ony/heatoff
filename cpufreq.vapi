// note that this vapi is based on cpufrequtils-008
using Posix;

[CCode (lower_case_cprefix = "cpufreq_", cheader_filename = "cpufreq.h")]
namespace CpuFreq {
    [Compact]
    [CCode (cname = "char", free_function = "cpufreq_put_driver")]
    public class Driver : string {
    }

    [Compact]
    [CCode (cname = "struct cpufreq_policy", free_function = "cpufreq_put_policy")]
    public class Policy {
        ulong min;
        ulong max;
        unowned string governor;
    }

    [Compact]
    [CCode (cname = "cpufreq_available_governors", free_function = "cpufreq_put_available_governors")]
    public class AvailableGovernors {
        unowned string governor;
        unowned AvailableGovernors next;
        unowned AvailableGovernors first;
    }

    [Compact]
    [CCode (cname = "cpufreq_available_frequencies", free_function = "cpufreq_put_available_frequencies")]
    public class AvailableFrequencies {
        ulong frequency;
        unowned AvailableFrequencies next;
        unowned AvailableFrequencies first;
    }

    [Compact]
    [CCode (cname = "cpufreq_affected_cpus", free_function = "cpufreq_put_affected_cpus")]
    public class AffectedCpus {
        Cpu cpu;
        unowned AffectedCpus next;
        unowned AffectedCpus first;
    }

    [Compact]
    [CCode (cname = "cpufreq_affected_cpus", free_function = "cpufreq_put_related_cpus")]
    public class RelatedCpus {
        Cpu cpu;
        unowned RelatedCpus next;
        unowned RelatedCpus first;
    }

    [Compact]
    [CCode (cname = "cpufreq_stats", free_function = "cpufreq_put_stats")]
    public class Stats {
        ulong frequency;
        uint64 time_in_state;
        unowned Stats next;
        unowned Stats first;
    }

    [SimpleType]
    [CCode (cname = "unsigned int", lower_case_cprefix = "cpufreq_")]
    public struct Cpu : uint {
        public int cpu_exists();
        public bool exists { get { return cpu_exists() == 0; } }

        public ulong freq_kernel { get; }
        public ulong freq_hardware { get; }
        public ulong frequency {
            [CCode (cname = "cpufreq_get")]
            get;
            set;
        }
        
        public ulong transition_latency { get; }

        public int get_hardware_limits(out ulong min, out ulong max);

        public Driver driver { owned get; }

        public Policy policy { owned get; set; }
        public int modify_policy_min(ulong min_freq);
        public int modify_policy_max(ulong min_freq);
        public int modify_policy_governor(string governor);

        public AvailableGovernors available_governors { owned get; }
        public AvailableFrequencies available_frequencies { owned get; }
        public AffectedCpus affected_cpus { owned get; }
        public RelatedCpus related_cpus { owned get; }

        public Stats stats { owned get; }
        public ulong transitions { get; }

        /* modifications */
    }

    public int cpu_exists(Cpu cpu);
}
