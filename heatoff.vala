using Posix;
using CpuFreq;
//using Gee;

public static int main(string[] args)
{
    Sensors.init();
    printf("libsensors version=%s\n", Sensors.version);
    for(CpuFreq.Cpu cpu = 0; cpu.exists; ++cpu)
    {
        var x = cpu.policy;
        //cpu.policy = (owned)x;
        printf("%u %s %lu\n", cpu.number, cpu.driver, cpu.freq);
        //printf("%d\n", CpuFreq.cpu_exists(10));
    }

    unowned CpuHealth health = CpuHealth.instance;
    while(true) {
        health.scan_values((core, temp) => {
            printf("Core %d: %f\n", core, temp);
        });
        sleep(3);
    }

    Sensors.cleanup();
    return 0;
}
