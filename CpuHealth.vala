
public struct CoreSensor {
    public unowned Sensors.ChipName chip;
    public unowned Sensors.Feature feature;
    public unowned Sensors.SubFeature subfeature;
    public ushort core;
}

[CCode (has_target = false)]
public delegate void core_temp_visitor(int core, double temp);

public struct CpuHealth {
    private int sensors_count;
    private CoreSensor sensors[64];

    public CpuHealth() {
        scan_chips();
    }

    public int cores { get { return sensors_count; } }

    public void scan_chips() {
        sensors_count = 0;

        var re_core = RegEx();
        if (!re_core.parse("^Core \\(.*\\)$")) return;

        unowned Sensors.ChipName? chip_name;
        int chip_nr = 0;
        while((chip_name = Sensors.get_detected_chips(null, ref chip_nr)) != null) {
            //printf("sensor%d: %s\n", chip_nr - 1, chip_name.to_string());
            chip_name.parse("XXX");

            Sensors.Feature? feature;
            int feature_nr = 0;
            while((feature = chip_name.get_features(ref feature_nr)) != null) {
                if (feature.type != Sensors.FeatureType.TEMP) continue;
                string label = chip_name.get_label(feature);

                //printf("  %s\n", label);

                Sensors.SubFeature? subfeature;
                int subfeature_nr = 0;
                while((subfeature = chip_name.get_subfeatures(feature, ref subfeature_nr)) != null) {
                    if (subfeature.type != Sensors.SubFeatureType.TEMP_INPUT) continue;
                    RegMatch m[2];
                    if (!re_core.match(label, m)) continue;

                    sensors[sensors_count].chip = chip_name;
                    sensors[sensors_count].feature = feature;
                    sensors[sensors_count].subfeature = subfeature;
                    sensors[sensors_count].core = (ushort) m[1].for_string(label).to_int();

                    //printf("    Core: %d\n", sensors[sensors_count].core);
                    ++sensors_count;
                }
            }
        }
    }

    public void visit_sensors(core_temp_visitor visitor) {
        for(int i = 0; i < sensors_count; ++i) {
            double v;
            Sensors.get_value(sensors[i].chip, sensors[i].subfeature.number, out v);
            visitor(sensors[i].core, v);
        }
    }

}
