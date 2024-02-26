# ViPER4AndroidRepackaged
A refined ViPER4Android installer.

This is an updated and enhanced `ViPER4Android FX 2.7` installer. \
It contains many useability enhancements and all the major fixes needed to run `ViPER4Android` on modern ROMs effortlessly.

![GitHub Latest Release (by date)](https://img.shields.io/github/v/release/programminghoch10/ViPER4AndroidRepackaged?label=latest&logo=github&display_name=release)
![GitHub Latest Release Date](https://img.shields.io/github/release-date/programminghoch10/ViPER4AndroidRepackaged?logo=github) \
![GitHub Global Download Counter](https://img.shields.io/github/downloads/programminghoch10/Viper4AndroidRepackaged/total?logo=github)
![GitHub Latest Download Counter](https://img.shields.io/github/downloads/programminghoch10/Viper4AndroidRepackaged/latest/total?logo=github) \
![GitHub Workflow Status](https://img.shields.io/github/actions/workflow/status/programminghoch10/ViPER4AndroidRepackaged/build.yml?logo=github%20actions&logoColor=white)
[![GitHub Workflow ShellCheck Status](https://img.shields.io/github/actions/workflow/status/programminghoch10/ViPER4AndroidRepackaged/shellcheck.yml?logo=github%20actions&logoColor=white&label=shellcheck)](https://github.com/programminghoch10/ViPER4AndroidRepackaged/actions/workflows/shellcheck.yml)
![GitHub commits since last release](https://img.shields.io/github/commits-since/programminghoch10/ViPER4AndroidRepackaged/latest?logo=git&logoColor=white)
![GitHub last commit](https://img.shields.io/github/last-commit/programminghoch10/ViPER4AndroidRepackaged?logo=git&logoColor=white) \
![GitHub Repo stars](https://img.shields.io/github/stars/programminghoch10/ViPER4AndroidRepackaged?style=social) \
[![GitHub followers](https://img.shields.io/github/followers/programminghoch10?style=social)](https://github.com/programminghoch10)

## Features

* **Install `ViPER4Android` in one go** \
  No need for additional modules or multiple reboots.
* **Quick install** \
  The entire install procedure has been rewritten from the ground up
  to be quick, simple and robust.
* **`ViPER4Android` APK included** \
  There is no longer a need for an active internet connection during install,
  as the [`ViPER4Android` APK](https://zackptg5.com/downloads/v4afx.apk)
  is included in the install zip.
* **Automatic seamless ViPER driver install** \
  This installer installs the ViPER driver seamlessly during module installation,
  there is no need to have the app install the driver.
* **`MagiskPolicy` included** \
  The necessary `SELinux` rules for running on modern Android ROMs are included,
  there is no need for [`Audio Compatibility Patch`](https://github.com/Magisk-Modules-Repo/acp) anymore.
* **Enforce the law** \
  This installer does not require switching `SELinux` to
  [`permissive`](https://stopdisablingselinux.com/)
  temporarily for installing the APK,
  which mostly helps with devices where `permissive` has been disabled in the kernel.
* **Old folder gone legacy** \
  The old folder `ViPER4Android` in your personal files has been redundant for long time already,
  as all files have been moved to the new scoped storage location anyways. \
  This installer doesn't depend on the old folder anymore,
  you can safely delete it and not have it clutter your files anymore.
* **ViperFX, not AudioFX!** \
  Who needs [`LineageOS AudioFX`](https://github.com/LineageOS/android_packages_apps_AudioFX) anyways
  when you have `ViPER4Android` installed.
  This installer automatically disables
  [`LineageOS AudioFX`](https://github.com/LineageOS/android_packages_apps_AudioFX)
  during install and also reenables it during uninstall.
* **Viper Atmos** \
  [Experience breakthrough audio that flows above and around you](https://github.com/LineageOS/android_hardware_samsung/blob/2359bd00227d706a9dda5378e7537b2e43e3c965/dap/res/values/strings.xml#L10)
  with `ViPER4Android`. \
  `Dolby Atmos` has become a simple
  [marketing term](https://www.youtube.com/watch?v=ua-JnXlDcTU)
  anyways, you don't need it anymore, you got somethin' better now!
* **To AML or not to AML** \
  [`Audio Modification Library`](https://github.com/Magisk-Modules-Repo/aml) is not included,
  but is usually not needed either.
  You can still combine `ViPER4Android` with other audio mods
  using [`Audio Modification Library`](https://github.com/Magisk-Modules-Repo/aml) if you want to.
* **Automatic VDC, IRS and preset import** \
  If you have [bought a VDC file](https://t.me/vdcservice)
  or downloaded an IRS file or preset,
  you don't have to copy it over manually.
  The installer automatically finds and copies them to the correct place
  for `ViPER4Android` to find them
  and for you to enjoy the audiophile feeling.
* **Original DDCs included** \
  If you have not yet bought a VDC file,
  this installer will automatically install all original `ViPER4Android` DDC files
  for you to enjoy them
  until you notice you can [buy even better ones](https://t.me/vdcservice).
* **IRS ([tax](https://www.youtube.com/results?search_query=kitboga+irs+scammer)) included** \
  [The whole pack of IRS files](https://drive.google.com/file/d/1Bii6ER0cNgHMspVozMIfYfFAu3l16d_-/view?usp=sharing)
  commonly distributed in the
  [`ViPER4Android` Telegram group](https://t.me/ViPER4AndroidFX)
  is included and will be automatically copied to the correct place.
  You can select an IRS in the convolver option.
* **`Legacy mode` for the win** \
  To this day I don't see why one would want to have `Legacy mode` disabled.
  Yes I know it's because a media app should send it's audio session id, but to be honest:
  Who cares?
  `Legacy mode` just always works reliably and this is why this installer enables it by default.
  Does anyone remember the time when this option was called "`Process audio session 0`"?
* **Opt-in instead of Opt-out** \
  `ViPER4Android 2.7` comes with `Crashlytics bug report metrics` enabled by default.
  Personally I don't like to send bug reports, so I always disable it.
  I think Opt-in is the way to go here.
  This is why in this module `Crashlytics` is disabled by default and you may enable if it you wish to.
* **Keep the vibes alive** \
  Measures have been put in place to ensure `ViPER4Android` doesn't get killed by the OOM-killer.
  Though should `ViPER4Android` stop working anyways, it will automatically be restarted.
  This may be of great convenience on low ram devices
  where the OOM-killer is very aggressive,
  even towards foreground services.
* **I know you're doing fine** \
  The notifications of `ViPER4Android` have been permanently disabled.
  There is no need for this permanent cluttering of the notifications list.
  ([more](#where-is-the-notification))

## Install

1. [Download the latest module ZIP from GitHub Releases](https://github.com/programminghoch10/ViPER4AndroidRepackaged/releases)
1. Flash in [Magisk](https://github.com/topjohnwu/Magisk)/[Lygisk](https://github.com/programminghoch10/Lygisk)
1. Reboot

The installer installs the `ViPER4Android` app for you.
Don't install it yourself.

This mod is targeted at `LineageOS 21`. \
It has been tested to work on:
* `LineageOS 16.0` on `s3ve3gjv`
* `LineageOS 17.1` on `a5xelte`
* `LineageOS 18.1` on `sailfish`
* `LineageOS 19.1` on `dreamlte`
* `LineageOS 20.0` on `beyond1lte`, `beyond2lte`, `gts4lv`
* `LineageOS 21.0` on `beyond2lte`

_Please don't submit pull requests adding your device/ROM combination._ \
_I will only add devices which I can test myself._

### Upgrade

Just install the update normally
by clicking the update button within your `Magisk` app
or do it manually following the [install instructions](#install)

A reboot is recommended afterwards,
but usually not required.
You can just postpone it
and combine it with the next reboot that you'd do anyways.

### Reimport VDC/IRS files

For reimporting newly downloaded VDC or IRS files
from your downloads directory,
just follow the [upgrade instructions](#upgrade).

You don't need to restart afterwards,
the new files will be available immediately.

## Bugs and support

I am not a ViPER dev, nor am I capable of fixing your broken install or ROM. \
If you have trouble to install ViPER4Android this way, please **do hesitate** to ask me. \
Try to install it the normal way and if that doesn't work either,
ask in the
[ViPER4Android Telegram group](https://t.me/ViPER4AndroidFX)
or the
[ViPER4Android XDA Thread](https://forum.xda-developers.com/android/apps-games/app-viper4android-fx-2-6-0-0-t3774651)
instead.

### Where is the notification?
The notification has been disabled on purpose,
as I don't see the necessity of it. \
I know the App-Info toggle to enable notifications does not work. \
If you really need it, run this command:
`pm set-distracting-restriction com.pittvandewitt.viperfx`

## Thanks

If you want to invest into a great dev,
go and [donate to @pittvandewitt](https://www.paypal.com/donate/?cmd=_s-xclick&hosted_button_id=53H9TP89FLWUU).

Thank you
[@pittvandewitt](https://github.com/pittvandewitt)
for keeping my absolute favorite mod alive for so long!
If you read this [@pittvandewitt](https://t.me/pittvandewitt),
please [message me on Telegram](https://t.me/programminghoch10),
so that we can make the next `ViPER4Android` version even more epic than it already is!
