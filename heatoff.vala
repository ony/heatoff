using Posix;
//using Gee;

public static int main(string[] args)
{
    Sensors.init();
    printf("libsensors version=%s\n", Sensors.version);

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
