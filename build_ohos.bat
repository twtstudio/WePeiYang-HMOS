@echo off
REM 清理孤儿 hvigor daemon 进程
for /f "tokens=2" %%i in ('tasklist /fi "imagename eq node.exe" /fo list /v ^| findstr "hvigor"') do (
  taskkill /f /pid %%i >nul 2>&1
)

REM 构建
cd /d "D:\Development\WePeiYang-Flutter\harmonyos\wepei_module\.ohos"
set PUB_CACHE=D:\pub-cache
devecocli run %*
