[CCode (lower_case_cprefix = "sensors_", cheader_filename = "sensors/sensors.h")]
namespace Sensors {
    [CCode (cname = "libsensors_version")]
    public const string version;

    [CCode (cname = "SENSORS_API_VERSION")]
    public const int api;


    /* Data structures */

    [CCode (cprefix = "SENSORS_FEATURE_", cname = "sensors_feature_type")]
    public enum FeatureType {
        IN,
        FAN,
        TEMP,
        POWER,
        ENERGY,
        CURR,
        HUMIDITY,
        MAX_MAIN,
        VID,
        INTRUSION,
        BEEP_ENABLE,
        UNKNOWN
    }

    [CCode (cprefix = "SENSORS_BUS_TYPE_")]
    public enum BusType {
        ANY,
        I2C,
        ISA,
        PCI,
        SPI,
        VIRTUAL,
        ACPI,
        HID
    }

    [CCode (cname = "sensors_feautre")]
    public struct Feature {
        public const string name;
        public int number;
        public FeatureType type;
    }

    [CCode (cname = "sensors_bus_id")]
    public struct BusId {
        public short type;
        public short nr;

        [CCode]
        public unowned string get_adapter_name();
    }

    [CCode (cname = "sensors_chip_name", cprefix = "sensors_", lower_case_csuffix = "chip_name", destroy_function = "sensors_free_chip_name", has_copy_function = false)]
    public struct ChipName {
        [CCode (default_value = "SENSORS_CHIP_NAME_PREFIX_ANY")]
        public string prefix;
        public BusId bus;
        [CCode (default_value = "SENSORS_CHIP_NAME_ADDR_ANY")]
        public int addr;
        public string path;

        [CCode (cname = "snesors_chip_parse", instance_pos = -1)]
        public ChipName(string orig_name);

        [CCode (instance_pos = -1)]
        public int parse(string orig_name);

        [CCode (instance_pos = -1)]
        public int snprintf(char[] buf);

        public string to_string()
        {
            int n;
            {
                char buf[256];
                n = snprintf(buf);
                if (n < 0 ) return @"(error: $(strerror(n)))";
                if (n < buf.length) return (string)buf;
            }
            // Vala wants only literals as size of array
            //char buf[n];
            var buf = new char[n];
            n = snprintf(buf);
            if (n < 0 ) return @"(error: $n)";
            if (n < buf.length) return (string)buf;
        }
    }

    /* Library initialization and clean-up */
    [CCode]
    public int init(Posix.FILE? config = null);

    public int init_filename(string name)
    { return init(Posix.FILE.open(name, "r")); }

    [CCode]
    public void cleanup();

    [CCode]
    public unowned ChipName? get_detected_chips(ChipName? match, ref int nr);

    /* Error decoding */
    [CCode (cheader_file = "sensors/error.h")]
    public unowned string strerror(int errnum);

}

