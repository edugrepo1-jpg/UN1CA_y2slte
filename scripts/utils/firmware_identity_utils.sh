# SPDX-License-Identifier: GPL-3.0-or-later
# FUS may append a fourth (PDA) component to the configured PDA/CSC/CP triple.
# Pin all three actual inputs; comparing only the PDA can reuse a wrong CSC/CP.
FIRMWARE_VERSIONS_EQUAL()
{
    local A1 A2 A3 A4 A5 B1 B2 B3 B4 B5
    IFS=/ read -r A1 A2 A3 A4 A5 <<< "$1"
    IFS=/ read -r B1 B2 B3 B4 B5 <<< "$2"
    [[ -n "$A1" && -n "$A2" && -n "$A3" && -z "$A5" &&
       -n "$B1" && -n "$B2" && -n "$B3" && -z "$B5" &&
       "$A1/$A2/$A3" == "$B1/$B2/$B3" ]]
}
