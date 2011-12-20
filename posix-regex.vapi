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

namespace Posix {
    [Flags]
    [CCode (cname = "int", cprefix = "REG_", cheader_filename = "regex.h")]
    public enum RegCFlags {
        [CCode (cname = "0")]
        NONE,
        EXTENDED,
        ICASE,
        NOSUB,
        NEWLINE
    }

    [Flags]
    [CCode (cname = "int", cprefix = "REG_", cheader_filename = "regex.h")]
    public enum RegEFlags {
        [CCode (cname = "0")]
        NONE,
        NOTBOL,
        NOTEOL,
    }

    [CCode (cname = "int", cprefix = "REG_", cheader_filename = "regex.h")]
    public enum RegResult {
        [CCode (cname = "0")]
        SUCCESS,
        NOMATCH
        // rest isn't so useful
    }

    [SimpleType]
    [CCode (cname = "regoff_t", cheader_filename = "regex.h")]
    public struct RegOff : int {
    }

    [CCode (cname = "regmatch_t", cheader_filename = "regex.h")]
    public struct RegMatch {
        [CCode (cname = "rm_so")]
        RegOff start;

        [CCode (cname = "rm_eo")]
        RegOff end;

        public string for_string(string s) {
            return strndup((string)((char*)s + start), end - start);
        }
    }

    [CCode (cname = "regex_t", destroy_function = "regfree", lower_case_cprefix = "reg", cheader_filename = "regex.h")]
    public struct RegEx {
        public RegResult comp(string regex, RegCFlags cflags = RegCFlags.NONE);

        public RegResult exec(string str, [CCode (array_length_pos = 1)] RegMatch[] pmatch, int eflags = RegEFlags.NONE);

        public static size_t error(RegResult result, RegEx preg, char[] errbuf);

        // more friendly interface
        public bool parse(string regex, RegCFlags cflags = RegCFlags.NONE)
        {
            var result = comp(regex, cflags);
            if (result == RegResult.SUCCESS) return true;
            stderr.printf("RegEx.comp() error: %s\n", error_to_string(result));
            return false;
        }

        public bool match(string str, RegMatch[] pmatch, int eflags = RegEFlags.NONE)
        {
            var result = exec(str, pmatch, eflags);
            switch (result) {
            case RegResult.SUCCESS: return true;
            case RegResult.NOMATCH: return false;
            default:
                stderr.printf("RegEx.exec() error: %s\n", error_to_string(result));
                return false;
            }
        }

        public string error_to_string(RegResult result)
        {
            char buf[128];
            var n = error(result, this, buf);
            if (n <= buf.length) return (string)buf;

            // in a very rare cases
            var bigbuf = new char[n];
            error(result, this, bigbuf);
            return (string)bigbuf;
        }
    }
}
