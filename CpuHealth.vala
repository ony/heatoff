using Posix;

public class CpuHealth {
    private static CpuHealth _instance;
    public static CpuHealth instance {
        get {
            if (_instance == null) _instance = new CpuHealth();
            return _instance;
        }
    }

    private Value values[64];
    private int values_count = 0;

    private CpuHealth() {
        scan_chips();
    }

    public void scan_chips() {
        var re_core = new Regex("^Core (\\d+)$");
        unowned Sensors.ChipName? chip_name;
        int chip_nr = 0;
        while((chip_name = Sensors.get_detected_chips(null, ref chip_nr)) != null) {
            //printf("sensor%d: %s\n", chip_nr - 1, chip_name.to_string());

            Sensors.Feature? feature;
            int feature_nr = 0;
            while((feature = chip_name.get_features(ref feature_nr)) != null) {
                if (feature.type != Sensors.FeatureType.TEMP) continue;
                string label = chip_name.get_label(feature);

                //printf("  %s\n", label);

                unowned Sensors.SubFeature? subfeature;
                int subfeature_nr = 0;
                while((subfeature = chip_name.get_subfeatures(feature, ref subfeature_nr)) != null) {
                    if (subfeature.type != Sensors.SubFeatureType.TEMP_INPUT) continue;
                    //double v;
                    //Sensors.get_value(chip_name, subfeature.number, out v);
                    //printf("    %s: %f\n", subfeature.name, v);

                    MatchInfo match;
                    if (!re_core.match(label, 0, out match)) continue;

                    values[values_count].chip = chip_name;
                    values[values_count].feature = feature;
                    values[values_count].subfeature = subfeature;
                    values[values_count].core = (ushort)match.fetch(1).to_int();

                    //printf("    Core: %d\n", values[values_count].core);
                    ++values_count;
                }
            }
        }
    }

    public delegate void temp_handler(int core, double temp);
    public void scan_values(temp_handler handler) {
        for(int i = 0; i < values_count; ++i) {
            double v;
            Sensors.get_value(values[i].chip, values[i].subfeature.number, out v);
            handler(values[i].core, v);
        }
    }

    [Compact]
    [SimpleType]
    private struct Value {
        public unowned Sensors.ChipName chip;
        public unowned Sensors.Feature feature;
        public unowned Sensors.SubFeature subfeature;
        public ushort core;
    }

}
