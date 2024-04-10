# Gort's NAPS2 CD Cover Scanner Script

Do you have too much cd cover art to scan with your crappy hp flatbed scanner?

Hate having to use a gui and manually crop stuff out?

Because same, honestly

This script utilizes the commandline exe for the free and open source NAPS2 scanning software and ImageMagick to help reduce effort when scanning square or unfolded cd cover art.
Or whatever you want, the world is yours and you can burn it all down if you want

*NAPS2 is cross platform, but I have yet to make a Linux/Apple script, sowwyyy*

# Usage
- Requirement: set up a scanner on your system before using the script, obviously...
1. Ensure NAPS2 is installed to `C:\Program Files\NAPS2` (which is the default location)
    - [NAPS2](https://www.naps2.com/download "Download page for NAPS2")
3. Download the portable ImageMagick, unzip and place `convert.exe` to the NAPS2 installation directory
    - [ImageMagick](https://imagemagick.org/script/download.php), scroll to "Windows Binary Release", download `ImageMagick-[VERSION NUMBER]-portable-Q16-x64.zip`
    - You will need `convert.exe` from this archive
5. Download/clone this repository, or just download/copy `Scan.bat`
6. Run `Scan.bat`, and follow the prompts to configure the environment
  - Scanner settings will be saved to `%appdata%\NAPS2\gortscanner.ini`, and can be changed at any time

# Features (wow!)
- Auto detects your installed scanners
- Saves script variables to `%appdata%\NAPS2\gortscanner.ini` to reduce user input repetition
- Multiple page size options for scanning specific things
- Auto splits unfolded (double length of standard CD cover art) to seperate files
- Minimal user input for fast RAPID FIRE scanning
