# UX305FA-DSDT-Patch

This is a collection of DSDT/SSDT patches and tools for the ASUS UX305FA laptop.

## Downloading

This repository depends on two of RehabMan's repositories as git submodules. After you've cloned this repository, run

```
git submodule init
git submodule update
```

to download those modules. 

The command `sh download.sh` will download a collection of drivers into `downloads/`. If you don't have `iasl` and `patchmatic` on your PATH, unzip them from `downloads/tools/` into `tools/`, which is on the PATH for the Makefile.

## Patching

Patching does not need to be run on an UX305FA, but you do need the ACPI files from your UX305FA.

To generate your ACPI files, boot your UX305FA with Clover from a USB drive, and press `F4`. This will dump a bunch of files in `YOURDISK/EFI/CLOVER/ACPI/origin/`. Copy those files into `native_clover/origin/` in this repository's directory. After copying, run the command `sh disassemble.sh` to generate the .dsl files to patch.

Most of the SSDTs do not need to be modified. Unmodified SSDTs are copied without disassembly/reassembly.

The factory WiFi card does not have a driver. If you have not replaced the card, edit the `Makefile` and uncomment the NullEthernet line; then edit SSDT-RMNE.dsl to include a MAC address not currently in use. (The MAC address of the factory WiFi card is a reasonable choice.)

To run the patcher, run `make`.

Copy `UX305FA-DSDT-Patch` to the destination machine.

## Installing patched files

Copy `build/*.aml` to the `EFI/CLOVER/ACPI/patched` directory.

Make sure that your Clover plist has `DropOem` set. The file `build/config.plist` is suitable to copy to `EFI/CLOVER/config.plist`.

## Installing drivers and tools

On the destination machine, you can run `install_downloads.sh` to set up kexts. This installs:

* ACPIBatteryManager
* ApplePS2SmartTouchPad v4.4 (4.5 doesn't work as well on UX305FA)
* AsusNBFnKeys v2.4 (matches v4.4)
* BrcmPatchRAM2 and BrcmFirmwareRepo
* FakePCIID
* FakePCIID_Broadcom_WiFi (for DW1560)
* FakeSMC
* IntelBacklight
* NullEthernet

NullEthernet is only loaded if you edited the Makefile and `SSDT-RMNE.dsl`.

In this directory is `AX88772-USB-Ethernet.dmg`, which is a driver for the USB Ethernet dongle which comes with the UX305FA. (It appears to replace the Apple USB Ethernet driver, but it does come with an uninstall script.)

## Driver sources

Most drivers are downloaded as part of `download.sh`. Here are the sources for the other drivers:

* ApplePS2SmartTouchPad v4.4: http://forum.osxlatitude.com/index.php?/topic/1948-elan-focaltech-and-synaptics-smart-touchpad-driver-mac-os-x/
* AsusNBFKeys v2.4: http://forum.osxlatitude.com/index.php?/topic/1968-fn-hotkey-and-als-a-driver-for-asus-notebooks/
* AX88772: http://www.asix.com.tw/download.php?sub=driverdetail&PItemID=86

## Credits

jhawk wrote the UX305FA installation guide. See http://www.tonymacx86.com/yosemite-laptop-guides/166818-guide-asus-zenbook-ux305fa-using-clover-uefi.html 

Machanical's guide to the similar UX303LA was helpful. http://www.tonymacx86.com/el-capitan-laptop-guides/172279-guide-asus-zenbook-ux303la-broadwell-edition.html

EMlyDinEsH maintains the touchpad driver.

RehabMan seems to maintain...just about everything else. :-)
