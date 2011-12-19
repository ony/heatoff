using Posix;
using CpuFreq;

// volatile?
bool interrupt = false;

static void sig_handler(int signum) {
    switch (signum) {
    case SIGINT: interrupt = true; break;
    }
}

public struct CpuCC {
    Cpu cpu;
    Hz min_freq;
    Hz max_freq;
    Policy policy;
    bool control;
    
    public CpuCC(Cpu target_cpu) {
        cpu = target_cpu;
        control = false;

        // find out our real range
        cpu.get_hardware_limits(out min_freq, out max_freq);

        // get our current policy
        policy = cpu.policy;
        print("CPU #%u: %s (current = %.3f MHz, range = [%.3f Mhz; %.3f MHz])\n",
            cpu, policy.governor,
            cpu.frequency.mhz,
            policy.min.mhz, policy.max.mhz);
        
        if (policy.min != min_freq) {
            cpu.modify_policy_min(min_freq);
            print("  adjusted range to [%.3f MHz; %.3f MHz]\n", policy.min.mhz, policy.max.mhz);
            policy = cpu.policy;
        }
    }

    public void destroy() {
        policy = null;
        print("CPU CC #%u destroyed\n", cpu);
    }

    public double throttle(double temp, double target) {
        var freq = cpu.frequency;
        if (target < temp && min_freq < policy.max) {
            policy.max = min_freq;
            control = true;
            return (min_freq * temp / freq);
        }
        else if (temp < target && policy.max < max_freq) {
            policy.max = max_freq;
            control = true;
            return temp;
        }
        else {
            return temp;
        }
    }

    public void commit() {
        if (!control) return;
        cpu.modify_policy_max(policy.max);
        policy = cpu.policy;
        print("CPU #%u: current = %.3f, range = [%.3f; %.3f]\n", cpu, cpu.frequency.mhz, policy.min.mhz, policy.max.mhz);
    }
}

public struct CpuMasterCC {
    CpuCC[] children;
    CpuHealth health;
    uint cpus_per_core;
    double level_hi;
    double level_lo;
    public bool fully_throttled { get; private set; }

    public CpuMasterCC() {
        level_hi = 69;
        level_lo = 55;
        fully_throttled = false;

        detect_children();

        // preparing sensors
        health = CpuHealth();

        assert ((children.length % health.cores) == 0);

        cpus_per_core = children.length / health.cores;
    }

    public void destroy() {
        for(uint i = 0; i < children.length; ++i) children[i].destroy();
        children = null;
        print("CPU MasterCC destroyed\n");
    }


    void detect_children() {
        // find out amount of CPU
        Cpu last_cpu;
        for (last_cpu = 1; last_cpu.exists; last_cpu *= 2);
        while (last_cpu-- > 0) {
            if (last_cpu.exists) break;
        }
        children = new CpuCC[(uint)last_cpu + 1];
        print("Detected %u CPUs\n", children.length);

        // init control circles
        for (uint i = 0; i < children.length; ++i) {
            children[i] = CpuCC(i);
        }

    }

    double throttle_core(uint core, double temp, double target) {
        var base_cpu = core * cpus_per_core;
        var esteem_heat = 0.0;
        for (uint cpu = base_cpu; cpu < (base_cpu + cpus_per_core); ++cpu) {
            esteem_heat += children[cpu].throttle(temp, target);
        }
        return esteem_heat / health.cores;
    }

    void commit_core(uint core) {
        var base_cpu = core * cpus_per_core;
        for (uint cpu = base_cpu; cpu < (base_cpu + cpus_per_core); ++cpu) {
            children[cpu].commit();
        }
    }

    public void adjust() {
        double total_heat = 0.0;
        double esteem_overheat = 0.0;
        for (uint core = 0; core < health.cores; ++core) {
            var sensor = health[core];
            var level = sensor.level;
            total_heat += level;
            print("Core %d: %.1f C%s\n", sensor.core, level,
                (level < level_lo) ? " [underheat]" : (level_hi < level) ? " [overheat]" : "");

            if (level_hi < level) {
                print("  throttling\n");
                esteem_overheat += throttle_core(core, level, level_lo) - level_hi;
            }
            else if (level < level_lo) {
                print("  releassing throttle\n");
                esteem_overheat += throttle_core(core, level, level_hi) - level_lo;
                fully_throttled = false;
            }
        }
        var heat_per_core = total_heat / health.cores;
        if (esteem_overheat > 5) {
            print("Expecting overheat %.1f C. Cooldown in panic from %.1fC to zero!\n", esteem_overheat, heat_per_core);
            for (uint core = 0; core < health.cores; ++core) throttle_core(core, heat_per_core, 0);
            fully_throttled = true;
        }
        for (uint core = 0; core < health.cores; ++core) commit_core(core);
    }
}


int main(string[] args) {
    Sensors.init();
    print("libsensors version=%s\n", Sensors.version);

    sigaction(SIGINT, sigaction_t() { sa_handler = sig_handler } , null);

    var master_cc = CpuMasterCC();

    while(!interrupt) {
        master_cc.adjust();
        if (master_cc.fully_throttled) sleep(10);
        else sleep(3);
    }
    print("Exiting...");


    //var ccpu = CpuControl { cpu = 0, sensor
    //var cpus = CpuRange(0, 3);

    Cpu cpu;
    uint cpu_count;

    ulong fmin, fmax;
    ((Cpu)0).get_hardware_limits(out fmin, out fmax);

    for(cpu = 0; cpu.exists; ++cpu)
    {
        var policy = cpu.policy;
        printf("CPU #%u: %s (current = %.3f MHz, range = [%.3f MHz; %.3f MHz])\n",
                cpu, policy.governor,
                cpu.frequency.mhz,
                policy.min.mhz, policy.max.mhz);

        if (policy.min != fmin || policy.max != fmax) {
            policy.min = fmin;
            policy.max = fmax;
            printf("  adjusting range to [%.3f MHz; %.3f MHz]\n", policy.min.mhz, policy.max.mhz);
            //cpu.policy = policy;
        }
    }
    cpu_count = cpu;

    //double hi_level = 69;
    double hi_level = 40;
    //double low_level = 56;
    double low_level = 20;
    bool throttle_all = false;
    bool throttled = false;

    CpuHealth health = CpuHealth();
    while(!interrupt) {
        break;
        if (throttle_all && !throttled) throttled = true;
        bool throttle = false;
        for(int i = 0; i < health.cores; ++i) {
            var sensor = health[i];
            cpu = sensor.core * 2;
            var level = sensor.level;
            var freq = cpu.frequency;
            var policy = cpu.policy;

            print("Core %d: %.3f MHz, %.1f C%s\n", sensor.core, freq / 1000000f, level, (level < low_level) ? " [underheat]" : (hi_level < level) ? " [overheat]" : "");


            if (throttle_all || (hi_level < level)) {
                if (hi_level < level) throttle = true;

                if (policy.max > fmin) {
                    cpu.modify_policy_max(fmin);
                    (cpu+1).modify_policy_max(fmin);
                    print("  throttling to %.3f MHz\n", fmin / 1000000f);
                } else {
                    if (!throttle_all) {
                        throttle_all = true;
                        printf("  throttling all\n");
                    }
                }

            } else if (level < low_level) {
                if (policy.max < fmax) {
                    cpu.modify_policy_max(fmax);
                    (cpu+1).modify_policy_max(fmax);
                    print("  releasing throttling to %.3f MHz\n", fmax / 1000000f);
                }
            }
        }
        if (!throttle) {
            throttle_all = false;
            throttled = false;
        }
        if (throttled) sleep(10);
        else sleep(2);
    }
    printf("Exiting...\n");
    Sensors.cleanup();
    return 0;
}
