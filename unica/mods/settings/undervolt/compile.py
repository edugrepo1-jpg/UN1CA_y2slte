#!/usr/bin/env python3
"""Compile SDK-backed Settings views; generated smali requires no SDK on CI."""
from pathlib import Path
import argparse
import hashlib
import json
import os
import shutil
import subprocess
import tempfile

def compile_sources(root, sdk, java_home, apktool):
    exe='.exe' if os.name=='nt' else ''
    java=str(java_home/'bin'/('java'+exe))
    javac=str(java_home/'bin'/('javac'+exe))
    android=sdk/'platforms/android-37.0/android.jar'
    sources=sorted((root/'src').rglob('*.java'))
    with tempfile.TemporaryDirectory(prefix='gmhub-uv-') as d:
        tmp=Path(d);classes=tmp/'classes';classes.mkdir()
        subprocess.run([javac,'--release','8','-Xlint:-options','-cp',str(android),'-d',str(classes),*map(str,sources)],check=True)
        subprocess.run([java,'-cp',str(sdk/'build-tools/36.0.0/lib/d8.jar'),'com.android.tools.r8.D8',
                        '--release','--min-api','33','--lib',str(android),'--output',str(tmp),
                        *map(str,classes.rglob('*.class'))],check=True)
        subprocess.run([java,'-cp',str(apktool),'com.android.tools.smali.baksmali.Main','disassemble',
                        '--api','37','--use-locals','--output',str(tmp/'smali'),str(tmp/'classes.dex')],check=True)
        generated=sorted((tmp/'smali').rglob('*.smali'))
        if not generated or any('com/gmhub/uv/' not in p.as_posix() for p in generated):
            raise ValueError('Unexpected generated classes')
        dest=root.parent/'SecSettings.apk/smali_classes4'
        records={}
        for p in generated:
            target=dest/p.relative_to(tmp/'smali');target.parent.mkdir(parents=True,exist_ok=True)
            target.write_text(p.read_text(encoding='utf-8'),encoding='utf-8',newline='\n')
            records[target.relative_to(root.parent).as_posix()]=hashlib.sha256(target.read_bytes()).hexdigest()
        result={'sdk_api':37,'min_api':33,
                'sources':{p.relative_to(root.parent).as_posix():hashlib.sha256(p.read_bytes()).hexdigest() for p in sources},
                'generated':records}
        (root/'compiled.json').write_text(json.dumps(result,indent=2)+'\n',encoding='utf-8',newline='\n')
    print('Undervolt: SDK37 sources compiled and disassembled; no compiler stubs shipped')

if __name__=='__main__':
    p=argparse.ArgumentParser()
    p.add_argument('--sdk',type=Path,required=True)
    p.add_argument('--java-home',type=Path,required=True)
    p.add_argument('--apktool',type=Path,required=True)
    a=p.parse_args()
    compile_sources(Path(__file__).resolve().parent,a.sdk,a.java_home,a.apktool)
