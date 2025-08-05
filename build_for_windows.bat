call .venv/Scripts/activate.bat

@REM 确保编码格式为UTF-8
set PYTHONUTF8=1

sphinx-build -M html . build/
deactivate
pause