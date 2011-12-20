/* posix-missing.vapi
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
    [CCode (cheader_filename = "string.h")]
    public string strndup(string s, size_t n);

    [CCode (cheader_filename = "stdlib.h")]
    public double atof(string nptr);

    [CCode (cheader_filename = "stdlib.h")]
    public double strtod(string nptr, out unowned string tail);

    [CCode (cheader_filename = "stdlib.h")]
    public float strtof(string nptr, out unowned string tail);

    // getopt
    [CCode (cheader_filename = "unistd.h")]
    public int getopt( [CCode (array_length_pos = 0)] string[] args, string optstring);

    [CCode (cheader_filename = "unistd.h")]
    public static string optarg;

    [CCode (cheader_filename = "unistd.h")]
    public static int optind;

    [CCode (cheader_filename = "unistd.h")]
    public static int opterr;

    [CCode (cheader_filename = "unistd.h")]
    public static int optopt;
}
