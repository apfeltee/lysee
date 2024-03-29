set path = @file.filePath()
set fpc_exe = 'fpc.exe'
set fpc_opt = '-MObjFPC -Sgi -CX -Cr -O2 -OoREGVAR -Xs -XX -vewn -Fu.'
set fpc_map = {
    {'lpr': 'lysee_fpc.lpr'
     'out': 'lysee_fpc.exe'
     'fup': '.'}
    {'lpr': 'lysee_cgi_fpc.lpr'
     'out': 'lysee_cgi_fpc.exe'
     'fup': '.'}
    {'lpr': 'lysee_kernel.lpr'
     'out': 'lysee_kernel.dll'
     'fup': '.'}
    {'lpr': 'lysee_pad_fpc.lpr'
     'out': 'lysee_pad_fpc.exe'
     'fup': '..\..\..\..\Developments\lazarus\components\synedit\units\i386-win32\
             ..\..\..\..\Developments\lazarus\lcl\units\i386-win32\
             ..\..\..\..\Developments\lazarus\lcl\units\i386-win32\win32\
             ..\..\..\..\Developments\lazarus\packager\units\i386-win32\'}
    {'lpr': 'modules\lysee_sqldb.lpr'
     'out': 'modules\lysee_sqldb.dll'
     'fup': 'modules'}
    {'lpr': 'modules\lysee_sh.lpr'
     'out': 'modules\lysee_sh.dll'
     'fup': 'modules'}
    {'lpr': 'modules\lysee_zipper.lpr'
     'out': 'modules\lysee_zipper.dll'
     'fup': 'modules'}
    {'lpr': 'modules\lysee_inifs.lpr'
     'out': 'modules\lysee_inifs.dll'
     'fup': 'modules'}
    {'lpr': 'modules\lysee_strutils.lpr'
     'out': 'modules\lysee_strutils.dll'
     'fup': 'modules'}
    {'lpr': 'modules\lysee_syncobj.lpr'
     'out': 'modules\lysee_syncobj.dll'
     'fup': 'modules'}
    {'lpr': 'modules\lysee_ymd.lpr'
     'out': 'modules\lysee_ymd.dll'
     'fup': 'modules'}
    {'lpr': 'modules\lysee_ym.lpr'
     'out': 'modules\lysee_ym.dll'
     'fup': 'modules'}
    {'lpr': 'modules\lysee_hz.lpr'
     'out': 'modules\lysee_hz.dll'
     'fup': 'modules'}
    {'lpr': 'modules\lysee_math.lpr'
     'out': 'modules\lysee_math.dll'
     'fup': 'modules'}
    {'lpr': 'modules\lysee_md5.lpr'
     'out': 'modules\lysee_md5.dll'
     'fup': 'modules'}}

set cmds = {}
cmds << '@echo off'
cmds << copy(path 0 2)
cmds << 'cd ' + path
cmds << 'DEL /S /F /Q *.dcu *.exe *.dll *.o *.ppu *.tmp *.~* *.zip *.rar *.local *.identcache *.compiled *.bak *.lo'

// FPC

for hs in fpc_map do
    set src = hs.lpr
    set dst = hs.out
    set fup = ''
    for pp in hs.fup.trim().lines() do
        set fup += ' -Fu' + pp.trim()
    end
    if hs.lpr == 'lysee_pad_fpc.lpr' then
        set fup = '-WG -dSYN_LAZARUS -dLCL -dLCLwin32 ' + fup
    end
    cmds << 'echo ***** ' + src + ' => ' + dst
    cmds << 'del ' + dst
    cmds << fpc_exe + ' ' + fpc_opt + ' ' + fup + ' -o' + dst + ' ' + src
end

// DELPHI

cmds << 'dcc32.exe -B -M lysee.dpr'
cmds << 'dcc32.exe -B -M -CC lysee_exe.dpr'
cmds << 'dcc32.exe -B -M -CC lysee_cgi.dpr'
cmds << 'cd ..'
cmds << '@echo on'

set fs = openfs('build.bat' 'c')
for s in cmds do
  fs << s << @eol
end
println("done!")

