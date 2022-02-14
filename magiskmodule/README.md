# ViPER4Android FX 2.7
This module is a downloader and more for V4A 2.7. This includes profile converter and vdcs from original v4a (copied to DDC-Orig so you can cherry pick what you want)
This is a much needed update to the old v4a app that fixed all of the app bugs in previous version.
Due to this, there's no need for Audio Compatibility Patch or any other hacky workarounds - the app handles all of that now
[More details in support thread](https://forum.xda-developers.com/apps/magisk/module-viper4android-fx-2-5-0-5-t3577058).

## Flash in Magisk Manager ONLY

## Compatibility
* Android Marshmallow+
* Selinux enforcing

## Change Log
### 10.16.2020
* Updated profile converter for new preset format
* Misc installer improvements
* Updated V4A app to v2.7.2.1!
  * Updated driver install to support android 11
  * Automatically save/restore settings based on the device type/name
  * Added preset widget
  * Reworked presets
  * Performance improvements
  * Close service when no music playback is active if legacy mode is disabled
  * Add optional crashlytics to help improving future versions

### 9.12.2020
* Updated to MMTEx v1.6

### 3.17.2020
* Changed to MMT-Ex
* Updated profile converter/installer for new apk, rest of changelog is apk changelog
* Support Magisk 20.3
* Add feature descriptions (long press feature to display)
* Theme updates
* ViPER4Android now makes use of scoped storage. You'll need to copy your old presets to /android/data/com.pittvandewitt.viperfx/

### 12.30.2019
* Update to latest magisk module template

### 12.18.2019
* Fix curl binaries

### 5.29.2019
* Use curl instead of wget due to odd issues some devices were having with wget

### v2.7.1.0 - 5.17.2019
* Initial release

## Credits
* [ViPER's Audio](http://vipersaudio.com/blog)
* [Zhuhang](https://forum.xda-developers.com/showthread.php?t=2191223) @ XDA Developers
* [Team_DeWitt](https://forum.xda-developers.com/android/apps-games/app-viper4android-fx-2-6-0-0-t3774651) @ XDA Developers
