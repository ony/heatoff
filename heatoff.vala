using Posix;

public static int main(string[] args)
{
    Sensors.init();
    printf("libsensors version=%s\n", Sensors.version);


    unowned Sensors.ChipName? chip_name;
    int chip_nr = 0;
    while((chip_name = Sensors.get_detected_chips(null, ref chip_nr)) != null) {
        chip_name.parse("xxx");
        printf("sensor%d: %s\n", chip_nr-1, chip_name.to_string());
    }

    Sensors.cleanup();
    return 0;
}
