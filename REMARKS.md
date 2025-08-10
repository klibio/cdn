# REMARKS

## git bash ssh setup on windows
requires git bash, putty pageant and plink locally installed

git config --global core.sshCommand '/c/apps/portable/putty/plink.exe'

## code with cmd window

put `set ELECTRON_NO_ATTACH_CONSOLE=1` inside `Microsoft VS Code\bin\code.cmd`
https://www.electronjs.org/docs/latest/api/environment-variables#electron_no_attach_console-windows
