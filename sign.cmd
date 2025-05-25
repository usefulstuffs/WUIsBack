@echo off
:: Parameters
set certFile=%1
set certPassword=%2
set description=%3
set file=%4

:: Sign the file with SHA1
signtool sign /f %certFile% /p %certPassword% /tr http://timestamp.digicert.com /td sha256 /fd sha1 /v /d %description% %file%

:: Check if SHA1 sign was successful
if %errorlevel% neq 0 (
    echo Error signing file with SHA1.
    exit /b %errorlevel%
)

:: Sign the file with SHA256 (SHA2)
signtool sign /f %certFile% /p %certPassword% /tr http://timestamp.digicert.com /td sha256 /fd sha256 /v /as /d %description% %file%

:: Check if SHA256 sign was successful
if %errorlevel% neq 0 (
    echo Error signing file with SHA256.
    exit /b %errorlevel%
)

echo File signed successfully with both SHA1 and SHA256!