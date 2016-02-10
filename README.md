# UX305FA-DSDT-Patch

This is a collection of DSDT/SSDT patches and tools for the ASUS UX305FA laptop for OS X 10.11 El Capitan.

It requires Clover r3328 or later.

Note that the UX305FA's factory WiFi card does not have drivers. The Dell DW1560 is a good replacement.

These instructions are broken into two sections. The first, "Building", needs to be done on a working Mac. The second, "Target", is run on the UX305FA.

## Building

### Downloading

The command `sh download.sh` will download a collection of drivers into `downloads/`. If you don't have `iasl` on your PATH, unzip it from `downloads/tools/` into `tools/`, which is on the `PATH` for the Makefile.

### Building AML files

For your UX305FA, you may later need a builtin Ethernet device (for the App Store, for example). If so, edit the `Makefile` and uncomment the `USE_NULLETHERNET=1` line; then edit `SSDT-RMNE.dsl` to include a MAC address not in use by anyone. The MAC address of the factory WiFi card is a reasonable choice.

To build the AML files from DSL source, type `make`.

After `sh download.sh` and `make`, you'll copy this whole directory, `UX305FA-DSDT-Patch`, to the destination machine.

### Installation media

Create your 10.11 installation USB drive according to [RehabMan's guide] (http://www.tonymacx86.com/el-capitan-laptop-support/148093-guide-booting-os-x-installer-laptops-clover.html).

The only directory in `EFI/CLOVER/kexts` should be `Other`. `EFI/CLOVER/kexts/Other` should only contain `FakeSMC.kext` (from `downloads/kexts/RehabMan-FakeSMC-2015-1230.zip`) and `ApplePS2SmartTouchPad.kext` (from `SmartTouchPad_v4.4_Final_64bit.zip`).

RehabMan's config file [`config_HD5300_5500_5600_6000.plist`] (https://github.com/RehabMan/OS-X-Clover-Laptop-Config/raw/master/config_HD5300_5500_5600_6000.plist) is a good choice for `config.plist`. Change `Graphics/Inject/Intel` to `false` for initial installation.

You will need these files handy on the target machine: `FakeSMC.kext`, `ApplePS2SmartTouchPad.kext`, `HFSPlus.efi`, this `UX305FA-DSDT-Patch` directory, and the Clover installer. If you do not have another USB drive handy, you could copy those files to a folder on the `Install OS X El Capitan` disk.

## Target

### Installing OS X

Follow [RehabMan's installation guide] (http://www.tonymacx86.com/el-capitan-laptop-support/148093-guide-booting-os-x-installer-laptops-clover.html#post917904).

There is currently a bug in the trackpad driver: scrolling will not work until you have opened System Preferences:Trackpad, and changed "Scrolling speed" at least once. It can be difficult to navigate the Clover installer without scrolling.

Remember to install `HFSPlus.efi`, `FakeSMC.kext`, and `ApplePS2SmartTouchPad.kext` to the EFI partition. You should be able to reboot from the target disk after that.

### Installing the patches

From the `UX305FA-DSDT-Patch` directory, copy `build/*.aml` to the EFI partition's `EFI/CLOVER/ACPI/patched` directory.

The AML files completely depend on DSDT/SSDT patches done by Clover according to `config.plist`. Copy `build/config.plist` to `EFI/CLOVER/config.plist`.

If you have the 1920x1080 display, `config.plist` is done. However, if you have the QHD/UHD display, `Graphics/Install/Intel` set to true will cause a hang at boot until you have patched IOKit. For QHD/UHD, set it back to false until patched. On other machines, I use `macPixelClockPatcher.command` from [floris497's repository] (https://github.com/floris497/mac-pixel-clock-patch) to patch IOKit.

I hate the ambient light sensor, and its driver has never worked right for me. Feel free to remove `EFI/CLOVER/ACPI/patched/SSDT-ALS.dsl`.

Once you're done with file copying (don't forget to put `HFSPlus.efi` in `EFI/CLOVER/drivers64UEFI/`) you should be able to reboot from the installed disk.

### Installing drivers and tools

I recommend not logging into any Apple services until you have completed this section.

On the target machine, you can run `sudo ./install_downloads.sh` in this `UX305FA-DSDT-Patch` directory to set up kexts. This installs:

* `ACPIBatteryManager`
* `ACPIDebug`
* `ApplePS2SmartTouchPad` v4.4 (4.5 doesn't work as well on UX305FA)
* `AsusNBFnKeys` v2.4 (matches v4.4, try a later version for ALS)
* `BrcmPatchRAM2` and `BrcmFirmwareRepo`
* `FakePCIID`
* `FakePCIID_Broadcom_WiFi` (for DW1560)
* `FakeSMC`
* `IntelBacklight`
* `NullEthernet`

The kexts will be installed into `/Library/Extensions`.

`NullEthernet` will only be loaded if you edited the Makefile and `SSDT-RMNE.dsl`.

In this `UX305FA-DSDT-Patch` directory is `AX88772-USB-Ethernet.dmg`, which is a driver for the USB Ethernet dongle which comes with the UX305FA. Note that it appears to replace the Apple USB Ethernet driver. It does come with an uninstall/restore script.

Sound won't work without a driver. I currently use VoodooHDA  for sound. It is available in `downloads/pkgs/`. If you want to try patching `AppleHDA`, the `SSDT-HACK.aml` already includes layout-3 properties. It is untested.

You still need CPU power management. See [the Beta branch of `Piker-Alpha/ssdtPRGen.sh`] (https://github.com/Piker-Alpha/ssdtPRGen.sh/tree/Beta). (The `master` branch will not work.) The `SSDT.aml` it generates needs to go in the EFI partition's `EFI/CLOVER/ACPI/patched` directory.

You also need to add appropriate SMBIOS settings to `EFI/CLOVER/config.plist`, probably using a tool like Clover Configurator. This guide does not cover the subject, but a good choice for `ProductName` is `MacBookAir7,2`.

You're done!

## Driver sources

Most drivers are downloaded as part of `download.sh`. Here are the sources for the other drivers:

* ApplePS2SmartTouchPad v4.4: http://forum.osxlatitude.com/index.php?/topic/1948-elan-focaltech-and-synaptics-smart-touchpad-driver-mac-os-x/
* AsusNBFKeys v2.4: http://forum.osxlatitude.com/index.php?/topic/1968-fn-hotkey-and-als-a-driver-for-asus-notebooks/
* AX88772: http://www.asix.com.tw/download.php?sub=driverdetail&PItemID=86

## Notes to self

The command to enable HiDPI mode is

```
sudo defaults write /Library/Preferences/com.apple.windowserver.plist DisplayResolutionEnabled -bool true
```

In order to use HiDPI mode at resolutions above 960x540, you need [SwitchResX] (http://www.madrau.com/srx_download/download.html). Select your monitor, switch to the "Custom Resolutions" tab, then use "+" to add "Scaled" resolutions at twice the size you really want. "3200x1800" gives a virtual 1600x900 display.

## Credits

jhawk wrote the UX305FA installation guide for 10.10. See http://www.tonymacx86.com/yosemite-laptop-guides/166818-guide-asus-zenbook-ux305fa-using-clover-uefi.html 

Machanical's guide to the similar UX303LA was helpful. http://www.tonymacx86.com/el-capitan-laptop-guides/172279-guide-asus-zenbook-ux303la-broadwell-edition.html

EMlyDinEsH maintains the touchpad driver.

RehabMan seems to maintain...just about everything else. :-) He also convinced me to try the no-patch DSDT technique.
