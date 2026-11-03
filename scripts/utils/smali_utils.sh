# Copyright (c) 2025 Salvo Giangreco
# SPDX-License-Identifier: GPL-3.0-or-later

# [
source "$SRC_DIR/scripts/utils/common_utils.sh"
# ]

# SMALI_PATCH <partition> <apk/jar> <smali> <operation> [method] [value] [replacement]
# Dynamically patches the provided smali file with the supplied arguments.
#
# Usage:
# - null <method>: Deletes the contents of supplied method in the provided smali file
# - remove: Deletes the provided smali file entirely
# - replace <method> <value> <replacement>: Replaces the occurence of the supplied string in the provided method
# - replaceall <value> <replacement>: Replaces all the occurences of the supplied string in the whole smali file
# - return <method> <value>: Patches the supplied method in order to return the desired value
# - strip <method>: Deletes the supplied method in the provided smali file
SMALI_PATCH()
{
    _CHECK_NON_EMPTY_PARAM "PARTITION" "$1" || return 1
    _CHECK_NON_EMPTY_PARAM "FILE" "$2" || return 1
    _CHECK_NON_EMPTY_PARAM "SMALI" "$3" || return 1
    _CHECK_NON_EMPTY_PARAM "OPERATION" "$4" || return 1

    local PARTITION="$1"
    local FILE="$2"
    local SMALI="$3"
    local OPERATION="$4"

    if ! IS_VALID_PARTITION_NAME "$PARTITION"; then
        LOGE "\"$PARTITION\" is not a valid partition name"
        return 1
    fi

    while [[ "${FILE:0:1}" == "/" ]]; do
        FILE="${FILE:1}"
    done

    DECODE_APK "$PARTITION" "$FILE" || return 1

    if [[ "$OPERATION" != "null" ]] && [[ "$OPERATION" != "remove" ]] && \
        [[ "$OPERATION" != "replace" ]] && [[ "$OPERATION" != "replaceall" ]] && \
            [[ "$OPERATION" != "return" ]] && [[ "$OPERATION" != "strip" ]]; then
        LOGE "Operation not valid: \"$OPERATION\""
        return 1
    fi

    if [[ "$OPERATION" == "replaceall" ]]; then
        _CHECK_NON_EMPTY_PARAM "VALUE" "$5" || return 1
        local VALUE="$5"
        local REPLACEMENT="$6"
    elif [[ "$OPERATION" != "remove" ]]; then
        _CHECK_NON_EMPTY_PARAM "METHOD" "$5" || return 1
        local METHOD="$5"

        if ! [[ "$METHOD" =~ ^[A-Za-z0-9\$\<\-].*\(.*\).* ]]; then
            LOGE "Method name not valid: \"$METHOD\""
            return 1
        fi
    fi

    if [[ "$OPERATION" == "return" ]]; then
        _CHECK_NON_EMPTY_PARAM "VALUE" "$6" || return 1
        local VALUE="$6"
    fi

    if [[ "$OPERATION" == "replace" ]]; then
        # An empty string is a valid smali literal (`const-string ..., ""`).
        # Check that the argument was supplied instead of rejecting its value.
        if [ "$#" -lt 7 ]; then
            LOGE 'Parameter "VALUE" not supplied'
            return 1
        fi
        local VALUE="$6"
        local REPLACEMENT="$7"
    fi

    local FILE_PATH="$APKTOOL_DIR/$PARTITION/${FILE//system\//}"

    # Check if provided smali exists
    if [ ! -f "$FILE_PATH/$SMALI" ]; then
        LOGE "Smali not found: \"/$PARTITION/$FILE/$SMALI\""

        local MATCHES
        MATCHES="$(find "$FILE_PATH" -type f -name "*${SMALI##*/}")"

        if [ "$MATCHES" ]; then
            echo -e "\n\033[0;31mPossible matches?" >&2
            echo -e -n "$(head -n 10 <<< "${MATCHES//$FILE_PATH\//    }")" >&2
            [ "$(wc -l <<< "$MATCHES")" -gt 10 ] && \
                echo -e -n "\n    ...and other $(($(wc -l <<< "$MATCHES") - 10)) matches"  >&2
            echo -e "\033[0m" >&2
        fi

        return 1
    elif [[ "$OPERATION" == "remove" ]]; then
        local USED
        USED="$(find "$FILE_PATH" ! -path "*$SMALI" -type f -exec grep -r -n -- "$(cut -d "." -f "1" <<< "${SMALI#*/}");" {} \+ || true)"
        USED="$(cut -d ":" -f 1-2 <<< "$USED")"

        if [ "$USED" ]; then
            LOGE "Cannot remove \"$SMALI\" from /$PARTITION/$FILE as it is used elsewhere"
            echo -e "\n\033[0;31mMatches:" >&2
            echo -e -n "$(head -n 10 <<< "${USED//$FILE_PATH\//    - }")" >&2
            [ "$(wc -l <<< "$USED")" -gt 10 ] && \
                echo -e -n "\n    ...and other $(($(wc -l <<< "$USED") - 10)) matches" >&2
            echo -e "\033[0m" >&2
            return 1
        fi

        LOG "- Removing \"$SMALI\" from /$PARTITION/$FILE"
        EVAL "LC_ALL=C rm \"$FILE_PATH/${SMALI//$/\\$}\"" || return 1
        return 0
    fi

    # Check if provided method is method and exists inside smali
    if [[ "$OPERATION" != "replaceall" ]] && ! awk -v needle="$METHOD" '
        $1 == ".method" && $NF == needle { count++ }
        END { exit count != 1 }
    ' "$FILE_PATH/$SMALI"; then
        LOGE "Method \"$METHOD\" not found in /$PARTITION/$FILE/$SMALI"

        local MATCHES
        MATCHES="$(grep -r '^\.method' "$FILE_PATH" | grep -F -- "$METHOD" || true)"

        if [ "$MATCHES" ]; then
            echo -e "\n\033[0;31mPossible matches?" >&2
            echo -e "$(head -n 10 <<< "${MATCHES//$FILE_PATH\//    - }")" >&2
            [ "$(wc -l <<< "$MATCHES")" -gt 10 ] && \
                echo -n "    ...and other $(($(wc -l <<< "$MATCHES") - 10)) matches" >&2
            echo -e "\033[0m" >&2
        fi

        return 1
    fi

    # Native and abstract declarations cannot contain a DEX code item. Leaving
    # those modifiers while inserting a body builds an invalid method. Likewise
    # an instance constructor cannot return before its superclass is initialized.
    if [[ "$OPERATION" == "null" || "$OPERATION" == "return" ]]; then
        if awk -v needle="$METHOD" '
            $1 == ".method" && $NF == needle {
                for (i = 2; i < NF; i++)
                    if ($i == "native" || $i == "abstract") found = 1
            }
            END { exit !found }
        ' "$FILE_PATH/$SMALI"; then
            LOGE "Cannot replace the body of native/abstract method \"$METHOD\""
            return 1
        fi
        if [[ "$METHOD" == '<init>('* ]]; then
            LOGE "Cannot erase constructor initialization in \"$METHOD\""
            return 1
        fi
    fi

    local BEFORE
    local AFTER

    BEFORE="$(sha1sum "$FILE_PATH/$SMALI")"

    # Remove the method completely
    if [[ "$OPERATION" == "strip" ]]; then
        local USED
        USED="$(grep -r -n -- "invoke.*$(basename "$SMALI" | cut -d "." -f "1");" "$FILE_PATH" || true)"
        USED="$(grep -F "$METHOD" <<< "$USED" | cut -d ":" -f 1-2 || true)"

        if [ "$USED" ]; then
            LOGE "Cannot strip method \"$METHOD\" in /$PARTITION/$FILE/$SMALI as it is used elsewhere"
            echo -e "\n\033[0;31mMatches:" >&2
            echo -e -n "$(head -n 10 <<< "${USED//$FILE_PATH\//    - }")" >&2
            [ "$(wc -l <<< "$USED")" -gt 10 ] && \
                echo -e -n "\n    ...and other $(($(wc -l <<< "$USED") - 10)) matches" >&2
            echo -e "\033[0m" >&2
            return 1
        fi

        LOG "- Stripping method \"$METHOD\" in /$PARTITION/$FILE/$SMALI"

        awk -v FN="$METHOD" '
            BEGIN { inside = 0 }
            $1 == ".method" && $NF == FN {
                inside = 1
                next
            }
            inside && /^\.end method/ {
                inside = 0
                next
            }
            inside { next }
            {
                print
            }
        ' "$FILE_PATH/$SMALI" > "$FILE_PATH/$SMALI.tmp" && \
            mv "$FILE_PATH/$SMALI.tmp" "$FILE_PATH/$SMALI"

        AFTER="$(sha1sum "$FILE_PATH/$SMALI")"
        if [[ "$BEFORE" == "$AFTER" ]]; then
            LOGE "Failed to strip method \"$METHOD\" in /$PARTITION/$FILE/$SMALI"
            return 1
        fi
    # Remove the contents of method, leave declaration
    elif [[ "$OPERATION" == "null" ]]; then
        local RET
        local LOC=".locals 0"

        RET="${METHOD#*)}"
        if [[ "$RET" != "V" ]]; then
            LOGE "Cannot nullify non-void method \"$METHOD\" in /$PARTITION/$FILE/$SMALI"
            return 1
        else
            RET="return-void"
        fi

        LOG "- Nullifying method \"$METHOD\" in /$PARTITION/$FILE/$SMALI"

        awk -v FN="$METHOD" -v LOC="$LOC" -v RET="$RET" '
            BEGIN { inside = 0 }
            $1 == ".method" && $NF == FN {
                print
                print "    " LOC
                print "    "
                print "    " RET
                inside = 1
                next
            }
            inside && /^\.end method/ {
                print
                inside = 0
                next
            }
            inside { next }
            { print }
        ' "$FILE_PATH/$SMALI" > "$FILE_PATH/$SMALI.tmp" && \
            mv "$FILE_PATH/$SMALI.tmp" "$FILE_PATH/$SMALI"

        AFTER="$(sha1sum "$FILE_PATH/$SMALI")"
        if [[ "$BEFORE" == "$AFTER" ]]; then
            LOG "- Method \"$METHOD\" is already nullified; skipping"
            return 0
        fi
    # Replace the method contents with a single return
    elif [[ "$OPERATION" == "return" ]]; then
        local RET
        local REG
        local LOC

        # Decide return type
        RET="${METHOD#*)}"
        # Dedicated locals work for instance/static methods with any parameter
        # list. J/D require a pair even for a static zero-argument method.
        REG="v0"
        LOC=".locals 1"
        if [[ "$RET" == "J" || "$RET" == "D" ]]; then
            LOC=".locals 2"
        fi
        if [[ "$RET" == "V" ]]; then
            LOGE "Cannot change return value of void method \"$METHOD\" in /$PARTITION/$FILE/$SMALI"
            return 1
        elif [[ "$RET" == "Ljava/lang/String;" ]]; then
            VALUE="\"$VALUE\""
            RET="return-object $REG"
        elif [[ "$RET" =~ ^[ZBCSIJFD]$ ]]; then
            # Boolean type
            if [[ "$RET" == "Z" ]]; then
                if [[ "$VALUE" == "true" ]]; then
                    VALUE="0x1"
                elif [[ "$VALUE" == "false" ]]; then
                    VALUE="0x0"
                fi

                if [[ "$VALUE" != "0x0" ]] && [[ "$VALUE" != "0x1" ]]; then
                    LOGE "Cannot use a constant value for method \"$METHOD\" in /$PARTITION/$FILE/$SMALI"
                    return 1
                fi
            fi

            # Convert decimal value to hex
            if [[ "$VALUE" =~ ^-?[0-9]+$ ]]; then
                VALUE="0x$(printf "%x" "$VALUE")"
            fi

            if [[ "$VALUE" =~ ^\".*\"$ ]]; then
                LOGE "Cannot use a string value for method \"$METHOD\" in /$PARTITION/$FILE/$SMALI"
                return 1
            fi

            # Long type
            if [[ "$RET" == "J" || "$RET" == "D" ]]; then
                RET="return-wide $REG"
            else
                RET="return $REG"
            fi
        else
            if [[ "$VALUE" == "null" ]]; then
                VALUE="0x0"
            fi

            if [[ "$VALUE" != "0x0" ]]; then
                LOGE "Cannot use a constant value for method \"$METHOD\" in /$PARTITION/$FILE/$SMALI"
                return 1
            fi

            RET="return-object $REG"
        fi

        # Decide what to return
        local hex
        local num
        if [[ "$VALUE" =~ ^-?0x[0-9a-fA-F]+$ ]]; then
            # Hexadecimal value
            if [[ "$VALUE" == "-"* ]]; then
                hex="${VALUE#-0x}"
                num="$((-16#$hex))"
            else
                hex="${VALUE#0x}"
                num="$((16#$hex))"
            fi
            # Emit signed literals instead of printf's 64-bit two's-complement
            # output for negative integers. Smali also requires an L suffix
            # for full-width wide constants.
            if [[ "$RET" != "return-wide"* ]] && \
                    [ "$num" -ge 2147483648 ] && [ "$num" -le 4294967295 ]; then
                num="$((num - 4294967296))"
            fi
            if [ "$num" -lt 0 ]; then
                VALUE="-0x$(printf '%x' "$((-num))")"
            else
                VALUE="0x$(printf '%x' "$num")"
            fi
            if [[ "$RET" == "return-wide"* ]]; then
                if [ "$num" -ge -32768 ] && [ "$num" -le 32767 ]; then
                    VALUE="const-wide/16 $REG, $VALUE"
                elif [ "$num" -ge -2147483648 ] && [ "$num" -le 2147483647 ]; then
                    VALUE="const-wide/32 $REG, $VALUE"
                else
                    VALUE="const-wide $REG, ${VALUE}L"
                fi
            elif [ "$num" -ge -8 ] && [ "$num" -le 7 ]; then
                VALUE="const/4 $REG, $VALUE"
            elif [ "$num" -ge -32768 ] && [ "$num" -le 32767 ]; then
                VALUE="const/16 $REG, $VALUE"
            elif [ "$num" -ge -2147483648 ] && [ "$num" -le 2147483647 ]; then
                VALUE="const $REG, $VALUE"
            else
                LOGE "Constant outside 32-bit return range for method \"$METHOD\""
                return 1
            fi
        elif [[ "$VALUE" =~ ^\".*\"$ ]]; then
            # String value
            VALUE="const-string $REG, $VALUE"
        else
            LOGE "Return value for method \"$METHOD\" in /$PARTITION/$FILE/$SMALI not valid: \"$VALUE\""
            return 1
        fi

        LOG "- Replacing return value of method \"$METHOD\" in /$PARTITION/$FILE/$SMALI to \"$VALUE\""

        awk -v FN="$METHOD" -v LOC="$LOC" -v VAL="$VALUE" -v RET="$RET" '
            BEGIN { inside = 0 }
            $1 == ".method" && $NF == FN {
                print
                print "    " LOC
                print ""
                print "    " VAL
                print ""
                print "    " RET
                inside = 1
                next
            }
            inside && /^\.end method/ {
                print
                inside = 0
                next
            }
            inside { next }
            { print }
        ' "$FILE_PATH/$SMALI" > "$FILE_PATH/$SMALI.tmp" && \
            mv "$FILE_PATH/$SMALI.tmp" "$FILE_PATH/$SMALI"

        AFTER="$(sha1sum "$FILE_PATH/$SMALI")"
        if [[ "$BEFORE" == "$AFTER" ]]; then
            # The decoded cache may already contain the canonical method body
            # produced above. Since the method was found and successfully
            # rewritten, identical output means the requested return value is
            # already applied rather than a patch failure.
            LOG "- Return value of method \"$METHOD\" is already patched; skipping"
            return 0
        fi
    # Replace a string with another string inside the method
    # or Replace a line with another line inside the method
    elif [[ "$OPERATION" == "replace" ]]; then
        local METHOD_CONTENT
        METHOD_CONTENT="$(awk -v FN="$METHOD" '
            $1 == ".method" && $NF == FN { inside = 1 }
            inside { print }
            inside && /^\.end method/ { exit }
        ' "$FILE_PATH/$SMALI")"

        # Decoded-cache entries may already contain a patch from an earlier
        # build. Check complete smali literals/instructions: a plain substring
        # check would mistake values such as string "2" for an unrelated 0x2.
        local VALUE_PRESENT=false
        local REPLACEMENT_PRESENT=false
        local METHOD_LINE
        local METHOD_LINE_TRIMMED
        while IFS= read -r METHOD_LINE; do
            if [[ "$METHOD_LINE" =~ ^[[:space:]]*const-string(/jumbo)?[[:space:]] ]]; then
                [[ "$METHOD_LINE" == *\"$VALUE\"* ]] && VALUE_PRESENT=true
                [[ "$METHOD_LINE" == *\"$REPLACEMENT\"* ]] && REPLACEMENT_PRESENT=true
            else
                METHOD_LINE_TRIMMED="$METHOD_LINE"
                METHOD_LINE_TRIMMED="${METHOD_LINE_TRIMMED#"${METHOD_LINE_TRIMMED%%[![:space:]]*}"}"
                METHOD_LINE_TRIMMED="${METHOD_LINE_TRIMMED%"${METHOD_LINE_TRIMMED##*[![:space:]]}"}"
                [[ "$METHOD_LINE_TRIMMED" == "$VALUE" ]] && VALUE_PRESENT=true
                [[ "$METHOD_LINE_TRIMMED" == "$REPLACEMENT" ]] && REPLACEMENT_PRESENT=true
            fi
        done <<< "$METHOD_CONTENT"

        if ! $VALUE_PRESENT && $REPLACEMENT_PRESENT; then
            LOG "- Value in method \"$METHOD\" is already patched; skipping"
            return 0
        fi

        LOG "- Replacing value \"$VALUE\" of method \"$METHOD\" in /$PARTITION/$FILE/$SMALI with \"$REPLACEMENT\""

        awk -v FN="$METHOD" -v STR="$VALUE" -v REP="$REPLACEMENT" '
            BEGIN { inside = 0; isline = (index(REP, "\n") > 0) }
            $1 == ".method" && $NF == FN { inside = 1 }
            inside {
                if (isline) {
                    if (index($0, STR)) {
                        gsub(/\\n/, "\n", REP)
                        print REP
                        next
                    }
                } else if ($0 ~ /^[[:space:]]*const-string(\/jumbo)?/) {
                    # STR is a literal smali string, not an awk regular
                    # expression. Rebuild the line around the exact match so
                    # characters such as (, ), [, + and . remain literal.
                    needle = "\"" STR "\""
                    pos = index($0, needle)
                    if (pos) {
                        $0 = substr($0, 1, pos - 1) "\"" REP "\"" \
                            substr($0, pos + length(needle))
                    }
                } else {
                    line = $0
                    gsub(/^[ \t]+|[ \t]+$/, "", line)

                    # An empty STR is used to replace a literal such as
                    # `const-string v0, ""`. It must never match formatting-only
                    # blank lines in the method body.
                    if (STR != "" && line == STR) {
                        match($0, /^[ \t]+/)
                        indent = substr($0, RSTART, RLENGTH)
                        $0 = indent REP
                    }
                }
            }
            inside && /^\.end method/ { inside = 0 }
            { print }
        ' "$FILE_PATH/$SMALI" > "$FILE_PATH/$SMALI.tmp" && \
            mv "$FILE_PATH/$SMALI.tmp" "$FILE_PATH/$SMALI"

        AFTER="$(sha1sum "$FILE_PATH/$SMALI")"
        if [[ "$BEFORE" == "$AFTER" ]]; then
            LOGE "Failed to replace value \"$VALUE\" of method \"$METHOD\" in /$PARTITION/$FILE/$SMALI with \"$REPLACEMENT\""
            return 1
        fi
    # Replace all occurrences of value with another
    #TODO: Improve, add more failchecks, currently it is unsafe
    elif [[ "$OPERATION" == "replaceall" ]]; then
        LOG "- Replacing all occurrences of \"$VALUE\" with \"$REPLACEMENT\" in /$PARTITION/$FILE/$SMALI"

        EVAL "sed -i \"s|$VALUE|$REPLACEMENT|g\" \"$FILE_PATH/${SMALI//$/\\$}\"" || return 1

        AFTER="$(sha1sum "$FILE_PATH/$SMALI")"
        if [[ "$BEFORE" == "$AFTER" ]]; then
            LOGE "Failed to replace all occurrences of \"$VALUE\" with \"$REPLACEMENT\" in /$PARTITION/$FILE/$SMALI"
            return 1
        fi
    fi

    return 0
}
