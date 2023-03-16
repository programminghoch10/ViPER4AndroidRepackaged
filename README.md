# ViPER4AndroidRepackaged in AOSP ROMs

This branch hosts all required files for the android buildsystem
for including `ViPER4AndroidRepackaged` into a ROM easily.

## Instructions
1. Add the local manifest: \
    `.repo/local_manifests/ViPER4AndroidRepackaged.xml`:
    ```xml
    <?xml version="1.0" encoding="UTF-8"?>
    <manifest>
      <project
        path="vendor/ViPER4AndroidRepackaged"
        remote="github"
        name="programminghoch10/ViPER4AndroidRepackaged"
        revision="sooooong" />
    </manifest>
    ```
1. Include this in your own vendor or device makefile:
    ```makefile
    ifneq ($(wildcard vendor/ViPER4AndroidRepackaged/*),)
        # $(warning Including ViPER4AndroidRepackaged into build.)
        PRODUCT_PACKAGES += ViPER4AndroidRepackaged
    endif
    ```
1. Add the `ViPER4Android` driver to the `audio_effects.xml` in your device tree:
    ```xml
    <libraries>
      <library name="v4a_fx" path="libv4a_fx.so"/>

    <!-- ... -->

    <effects>
        <effect name="v4a_standard_fx" library="v4a_fx" uuid="41d3c987-e6cf-11e3-a88a-11aba5d5c51b"/>
    ```
    and/or `audio_effects.conf`:
    ```
    libraries {
      v4a_fx {
        path /system/vendor/lib/soundfx/libv4a_fx.so
      }

    // ...

    effects {
      v4a_standard_fx {
        library v4a_fx
        uuid 41d3c987-e6cf-11e3-a88a-11aba5d5c51b
      }
    ```
