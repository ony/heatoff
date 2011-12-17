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
    }

    [Compact]
    [CCode (cname = "cpufreq_available_governors", free_function = "cpufreq_put_available_governors")]
    public class AvailableGovernors {
    }

    [Compact]
    [CCode (cname = "cpufreq_available_frequencies", free_function = "cpufreq_put_available_frequencies")]
    public class AvailableFrequencies {
    }

    [Compact]
    [CCode (cname = "cpufreq_affected_cpus", free_function = "cpufreq_put_affected_cpus")]
    public class AffectedCpus {
    }

    [Compact]
    [CCode (cname = "cpufreq_affected_cpus", free_function = "cpufreq_put_related_cpus")]
    public class RelatedCpus : AffectedCpus {
    }

    [Compact]
    [CCode (cname = "cpufreq_stats", free_function = "cpufreq_put_stats")]
    public class Stats {
    }


    [SimpleType]
    [Immutable]
    [CCode (cname = "unsigned int", cprefix = "cpufreq_")]
    public struct Cpu : uint {
        public uint number { get { return (uint)this; } }

        public int cpu_exists();
        public bool exists { get { return cpu_exists() == 0; } }


        public ulong freq_kernel { get; }
        public ulong freq_hardware { get; }
        public ulong freq { [CCode (cname = "cpufreq_get")] get; }
        
        public ulong transition_latency { get; }

        public int get_hardware_limits(out ulong min, out ulong max);

        public Driver driver { owned get; }
        public Policy policy {
            owned get;
            //[CCode (cname = "xxx")]
            //owned set {}
        }
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
