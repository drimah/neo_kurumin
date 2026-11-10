@echo off
chcp 65001 >nul
title NEO KURUMIN LAB - Windows
echo ==============================================
echo        NEO KURUMIN LAB v0.1 - Windows
echo ==============================================
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0windows\criar-vm.ps1"
if errorlevel 1 echo. & echo  Deu erro. Copie as mensagens acima e mande no chat.
echo.
pause
