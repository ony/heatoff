using Posix;
using CpuFreq;
//using Gee;

public static int main(string[] args)
{
    Sensors.init();
    printf("libsensors version=%s\n", Sensors.version);
    CpuFreq.Cpu cpu;
    for(cpu = 0; cpu.exists; ++cpu)
    {
        var x = cpu.policy;
        //cpu.policy = (owned)x;
        cpu.modify_policy_governor("alpha");
        print("%u %s %lu\n", cpu, cpu.driver, cpu.frequency);
        //printf("%d\n", CpuFreq.cpu_exists(10));
    }

    CpuHealth health = CpuHealth();
    while(true) {
        health.visit_sensors((core, temp) => {
            print("Core %d: %f\n", core, temp);
        });
        sleep(3);
    }
    Sensors.cleanup();
    return 0;
}
