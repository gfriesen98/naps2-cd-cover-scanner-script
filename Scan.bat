@ECHO OFF
setlocal EnableDelayedExpansion

rem This script uses the console exe for NAPS2 and ImageMagick to help automate scanning cds
rem Executable variables:
set NAPS2PATH=C:\Program Files\NAPS2\
set NAPS2EXE=NAPS2.Console.exe
rem Please place your magick.exe in the NAPS2PATH folder
set IMEXE=convert.exe

rem Output Variables:
rem INIPATH - set path for saving scanner settings
set INIPATH=%appdata%\NAPS2\gortscanner.ini
rem OUTPUTPATH - Full path to save scans. Example: C:\Ripping\cds\cover scans\new. set during device setup
set OUTPUTPATH=.
rem Output filename is just an incrementing number
set COUNTER=0

rem NAPS2 variables:
rem Most of these settings will be prompted for.
rem These variables represent arguments found from "%NAPS2PATH%\NAPS2.Console.exe --help"
rem Run NAPS2.Console.exe --help in the commandline for more information
rem DEVICE - Set automatically on device setup
set DEVICE=.
rem DRIVER - Change this if needed. I think wia should find anything™
set DRIVER=wia
rem SOURCE - glass, feeder, duplex. set during device setup
set SOURCE=.
rem PAGESIZE - page size dimensions. Can be inches (in) or millimeters (mm). set during page setup
set PAGESIZE=.
rem DPI - scan resolution (dots per inch). set during device setup
set DPI=400
rem BITDEPTH - color for color, gray for grey, bw for black and white. set during device setup
set BITDEPTH=.
rem ROTATE - rotate scanned image. if placed in the top left of a flatbed, not upside down, rotate by 90deg for your sanity
set ROTATE=90

cd %NAPS2PATH%
goto checksavedscannersettings

:checksavedscannersettings
cls
echo ===  Gorts NAPS2 CD Scanner  ===
echo ===       Reading INI        ===
echo Press Ctrl+C to quit at any time
echo.
echo Checking for %INIPATH%...
rem kinf of assume to reset COUNTER, as if user was changing output path/changing cds. should reset to 0 if this happens
set COUNTER=0
if exist %INIPATH% (
    for /F "tokens=1,*delims==" %%a in (%INIPATH%) do (
        set %%a=%%b
    )
    rem go straight to page setup
    echo Loaded %appdata%\NAPS2\gortscanner.ini
    echo.
    echo [1] Continue to scan
    echo [2] Change output path/device settings
    echo [q] Quit
    choice /N /C:12q /M "What do ? "
    echo !ERRORLEVEL!
    if !ERRORLEVEL!==1 goto :pagesettings
    if !ERRORLEVEL!==2 goto :devicesetup
    if !ERRORLEVEL!==3 (
        echo Bye bye...
        timeout /t 1
        exit
    )
    exit
) else (
    rem settings not found, go to device setup
    goto devicesetup
)

:devicesetup
cls
echo ===  Gorts NAPS2 CD Scanner  ===
echo ===       Device Setup       ===
echo Press Ctrl+C to quit at any time
echo.
echo Checking for devices...
rem --driver needs to be specified for --listdevices. this may cause issues if your device is not WIA
for /f "delims=" %%i in ('.\NAPS2.Console.exe --driver %DRIVER% --listdevices') do set DEVICE=%%i
echo Using %DEVICE%
echo.
choice /N /C:gfd /M "Select Source ([g]lass / [f]eeder / [d]uplex): " %1
if %ERRORLEVEL%==1 set SOURCE=glass
if %ERRORLEVEL%==2 set SOURCE=feeder
if %ERRORLEVEL%==3 set SOURCE=duplex
echo.
choice /N /C:cgb /M "Select Bitdepth ([c]olor / [g]ray / [b]w): " %1
if %ERRORLEVEL%==1 set BITDEPTH=color
if %ERRORLEVEL%==2 set BITDEPTH=gray
if %ERRORLEVEL%==3 set BITDEPTH=bw
set /P OUTPUTPATH=Enter the full path to save scans: 
rem save device settings to file
if exist %INIPATH% (
    del %INIPATH%
)
echo DEVICE=%DEVICE%>>%INIPATH%
echo DRIVER=%DRIVER%>>%INIPATH%
echo SOURCE=%SOURCE%>>%INIPATH%
echo BITDEPTH=%BITDEPTH%>>%INIPATH%
echo OUTPUTPATH=%OUTPUTPATH%>>%INIPATH%
goto pagesettings

:pagesettings
cls
echo ===  Gorts NAPS2 CD Scanner  ===
echo ===      Page Settings       ===
echo Press Ctrl+C to quit at any time
echo.
echo Using %DEVICE%
echo.
choice /N /C:yno /M "Is the page upside down? ([y]es / [n]o / [o]ther)" %1
if %ERRORLEVEL%==1 set /A ROTATE=-90
if %ERRORLEVEL%==2 set /A ROTATE=90
if %ERRORLEVEL%==3 set /P ROTATE=Rotate Dagreez: 
echo.
echo [1] CD Square (4.75x4.75in)
echo [2] Unfolded CD Square (4.75x9.5in)
echo [3] Default (8.5x11in)
echo [4] Custom
choice /N /C:1234 /M "Select scan size: " %1
if %ERRORLEVEL%==1 set PAGESIZE=4.75x4.75in
if %ERRORLEVEL%==2 set PAGESIZE=4.75x9.5in
if %ERRORLEVEL%==3 set PAGESIZE=8.5x11in
if %ERRORLEVEL%==4 set /P PAGESIZE=Dimensions: 
set /P DPI=Set DPI (Default: 400): 
goto scan

:scan
cls
echo ===  Gorts NAPS2 CD Scanner  ===
echo ===      Scanning Mode       ===
echo Press Ctrl+C to quit at any time
echo.
echo             SETTINGS            
echo ================================
echo DEVICE: %DEVICE%
echo SOURCE: %SOURCE%
echo PAGESIZE: %PAGESIZE%
echo DPI: %DPI%
echo BITDEPTH: %BITDEPTH%
echo ROTATE: %ROTATE% deg
echo FILENAME: %OUTPUTPATH%\%COUNTER%.jpg
echo ================================
echo.
echo Please wait don't close this window...
.\%NAPS2EXE% --verbose --noprofile -o "%OUTPUTPATH%\%COUNTER%.jpg" --driver %DRIVER% --device %DEVICE% --source %SOURCE% --pagesize %PAGESIZE% --dpi %DPI% --bitdepth %BITDEPTH% --rotate %ROTATE%
rem 4.75x4.75in is the standard size for a cd cover. therefore unfolded the length should be 2x. if so, use imagemagick to split the image in half vertically
if %PAGESIZE%==4.75x9.5in (
    echo Splitting %COUNTER%.jpg...
    .\%IMEXE% "%OUTPUTPATH%\%COUNTER%.jpg" -crop "50%%x100%%" "%OUTPUTPATH%\%COUNTER%.jpg"
)

echo Finished!
set /A COUNTER=%COUNTER%+1
echo.
echo [1] Scan Again Immediately
echo [2] Reconfigure Page Scan Settings
echo [3] Reconfigure Device Settings
echo [q] Quit
choice /N /C:123q /M "What do ? " %1
if %ERRORLEVEL%==1 goto scan
if %ERRORLEVEL%==2 goto pagesettings
if %ERRORLEVEL%==3 goto devicesetup
if %ERRORLEVEL%==4 (
    echo Bye bye... i miss you..
    timeout /t 2
    exit
)
