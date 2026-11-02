from pathlib import Path
import subprocess
import unittest

ROOT=Path(__file__).resolve().parents[1]

class JavaPreflightTests(unittest.TestCase):
    def check(self, runtime, compiler, runtime_code=0, compiler_code=0):
        # Functions receive command arguments; retain fixture values outside
        # their positional parameters, as a real command executable would.
        script='''FIX_RUNTIME="$2"; FIX_COMPILER="$3"; FIX_RC="$4"; FIX_CC="$5"
LOGE() { printf '%s\\n' "$*" >&2; }
source "$1/scripts/utils/java_utils.sh"
java() { printf '    java.specification.version = %s\\n' "$FIX_RUNTIME" >&2; return "$FIX_RC"; }
javac() { printf 'javac %s.0.1\\n' "$FIX_COMPILER"; return "$FIX_CC"; }
if VERIFY_BUILD_JAVA 17; then exit 0; else exit 8; fi
'''
        return subprocess.run(['bash','-c',script,'java-check',ROOT.as_posix(),runtime,compiler,
                               str(runtime_code),str(compiler_code)],capture_output=True,text=True)

    def test_jdk17_is_accepted(self):
        r=self.check('17','17');self.assertEqual(r.returncode,0,r.stderr)

    def test_other_or_mixed_jdk_is_rejected_before_tool_builds(self):
        for runtime,compiler in (('25','25'),('17','25'),('21','17'),('1.8','8'),('','17')):
            with self.subTest(runtime=runtime,compiler=compiler):
                r=self.check(runtime,compiler)
                self.assertEqual(r.returncode,8,r.stderr)
                self.assertIn('validated with JDK 17',r.stderr)

    def test_broken_runtime_or_compiler_is_rejected(self):
        for runtime_code,compiler_code in ((1,0),(0,1)):
            r=self.check('17','17',runtime_code,compiler_code)
            self.assertEqual(r.returncode,8,r.stderr)
            self.assertIn('cannot start',r.stderr)

if __name__=='__main__':unittest.main()
