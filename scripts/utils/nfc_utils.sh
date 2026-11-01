# SPDX-License-Identifier: GPL-3.0-or-later
# A compressed and an uncompressed NFC APEX own the same Java/JNI contract.
HAS_NFC_SERVICE_APEX()
{
    [[ "$#" -eq 1 && -d "$1" ]] || return 1
    local NFC_APEX
    for NFC_APEX in \
        "$1"/system/system/apex/com.android.nfcservices.{apex,capex} \
        "$1"/system/apex/com.android.nfcservices.{apex,capex} \
        "$1"/system_ext/apex/com.android.nfcservices.{apex,capex} \
        "$1"/product/apex/com.android.nfcservices.{apex,capex}; do
        [ -f "$NFC_APEX" ] && return 0
    done
    return 1
}
