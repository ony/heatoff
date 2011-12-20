/* posix-regex.vapi
 *
 * Copyright (C) 2011 Nikolay Orlyuk
 *
 * This library is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Lesser General Public
 * License as published by the Free Software Foundation; either
 * version 2.1 of the License, or (at your option) any later version.
 *
 * This library is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public
 * License along with this library; if not, write to the Free Software
 * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301  USA
 *
 * Author:
 * 	Nikolay Orlyuk <virkony@gmail.com>
 */


public struct CoreSensor {
    public unowned Sensors.ChipName chip;
    public unowned Sensors.Feature feature;
    public unowned Sensors.SubFeature subfeature;
    public ushort core;
    public double level {
        get {
            double y;
            Sensors.get_value(chip, subfeature.number, out y);
            return y;
        }
    }
}

public struct CpuHealth {
    private uint sensors_count;
    private CoreSensor sensors[64];

    public CpuHealth() {
        scan_chips();
    }

    public CoreSensor @get(uint n) { return sensors[n]; }

    public uint cores { get { return sensors_count; } }

    public void scan_chips() {
        sensors_count = 0;

        var re_core = RegEx();
        if (!re_core.parse("^Core \\(.*\\)$")) return;

        unowned Sensors.ChipName? chip_name;
        int chip_nr = 0;
        while((chip_name = Sensors.get_detected_chips(null, ref chip_nr)) != null) {
            Sensors.Feature? feature;
            int feature_nr = 0;
            while((feature = chip_name.get_features(ref feature_nr)) != null) {
                if (feature.type != Sensors.FeatureType.TEMP) continue;
                string label = chip_name.get_label(feature);

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

                    ++sensors_count;
                }
            }
        }
    }
}
