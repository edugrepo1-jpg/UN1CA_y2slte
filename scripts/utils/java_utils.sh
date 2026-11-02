# SPDX-License-Identifier: GPL-3.0-or-later
# Check the actual executables on PATH, not just a possibly stale JAVA_HOME.
VERIFY_BUILD_JAVA()
{
    local EXPECTED="${1:-17}" RUNTIME COMPILER
    command -v java >/dev/null 2>&1 && command -v javac >/dev/null 2>&1 || {
        LOGE "A full JDK $EXPECTED (java and javac) is required; a JRE is insufficient"
        return 1
    }
    RUNTIME="$(java -XshowSettings:properties -version 2>&1)" || {
        LOGE "The selected Java runtime cannot start"
        return 1
    }
    RUNTIME="$(sed -n 's/^[[:space:]]*java.specification.version = \([0-9.]*\).*$/\1/p' <<< "$RUNTIME")"
    COMPILER="$(javac -version 2>&1)" || {
        LOGE "The selected Java compiler cannot start"
        return 1
    }
    COMPILER="$(sed -n 's/^javac \([0-9]*\).*$/\1/p' <<< "$COMPILER")"
    RUNTIME="${RUNTIME%%.*}"
    if [ "$RUNTIME" != "$EXPECTED" ] || [ "$COMPILER" != "$EXPECTED" ]; then
        LOGE "This r8s toolchain is validated with JDK $EXPECTED; PATH selects java=$RUNTIME javac=$COMPILER"
        return 1
    fi
}
