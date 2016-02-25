# UX305FA-DSDT-Patch

This is a collection of DSDT/SSDT patches and tools for the ASUS UX305FA laptop for OS X 10.11 El Capitan.

It requires Clover r3328 or later.

#### What you should expect works

* Keyboard and touchpad
* Battery
* Fn-keys
* Brightness
* Sleep
* Bluetooth
* WiFi when replaced (tested: Dell DW1560 WiFi)

#### Lightly tested

* Ambient Light Sensor (ALS)

#### Optional, drivers included:

* Sound, using VoodooHDA or patched AppleHDA
* The Ethernet dongle included with the UX305FA

#### Will never work

* Factory Intel WiFi card.

## About hotpatches

If you're not interested in the details of DSDT patching, skip ahead to the "Intro" section.

If you've used other guides, you're probably familiar with the process of `DSDT.dsl` patching, using a tool like MaciASL.. This guide doesn't do that.  Instead, it uses a different approach for ACPI patches: RehabMan's "hotpatch" style. The special `clover.plist` works together with small SSDT files to accomplish the same purpose as text-based DSDT/SSDT patching.

This set of hotpatches should work across BIOS revisions of the UX305FA. (It looks like it may work on the Broadwell-based 303LA and LB as well.)

### How hotpatching works

Clover supports binary "search&amp;replace" patch operations on DSDT/SSDT tables. Even simple binary patching can be very powerful.

* Some text DSDT patches like "rename GFX0 to IGPU" can be replaced with a single binary patch
* Methods effectively can be deleted by renaming them to an unused name. For example the existing `_DSM` methods are renamed to `XDSM`, which nothing calls.
* Existing methods like `GPRW` can be replaced. First, the original method definition is renamed to an unused name like `XPRW`. Then, a separate small SSDT provides a replacement "GPRW" method.

### The only AML files you want

Later in this guide you will install SSDT files. The only files you should expect to see in `EFI/CLOVER/ACPI/patched` are these:

|File|Description|
|----|----|
|[`SSDT-HACK.aml`](https://github.com/gfoury/UX305FA-DSDT-Patch/blob/master/SSDT-HACK.dsl)|Brightness keys, USB, graphics properties, HDMI sound|
|[`SSDT-BATT.aml`](https://github.com/gfoury/UX305FA-DSDT-Patch/blob/master/SSDT-BATT.dsl)|Battery monitorying|
|[`SSDT-DEBUG.aml`](https://github.com/gfoury/UX305FA-DSDT-Patch/blob/master/SSDT-DEBUG.dsl)|ACPI logging|
|[`SSDT-ALS.aml`](https://github.com/gfoury/UX305FA-DSDT-Patch/blob/master/SSDT-ALS.dsl)|Ambient light sensor. Optional.|
|[`SSDT-RMNE.am`](https://github.com/gfoury/UX305FA-DSDT-Patch/blob/master/SSDT-RMNE.dsl)|MAC address for NullEthernet. Optional.|
|`SSDT.aml`|CPU power management. You will create this after installation with [`ssdtPRGen.sh`](https://github.com/Piker-Alpha/ssdtPRGen.sh/tree/Beta).|

Do not include `DSDT.aml` or any of the numeric `SSDT-1.aml` files. They will cause trouble.

## Intro

These instructions are broken into two sections. The first, "Building", needs to be done on a working Mac. The second, "Target", is run on the UX305FA.

## Building

### Downloading

Clone or download `UX305FA-DSDT-Patch` from GitHub.

In this directory, the command `sh download.sh` will download a collection of drivers into `downloads/`. If you don't have `iasl` on your PATH, unzip it from `downloads/tools/` into `tools/`, which is on the `PATH` for the Makefile.

### Building AML files

For your UX305FA, you may later need a builtin Ethernet device (for the App Store, for example). If so, edit the `Makefile` and uncomment the `USE_NULLETHERNET=1` line; then edit `SSDT-RMNE.dsl` to include a MAC address not in use by anyone. The MAC address of the factory WiFi card is a reasonable choice.

To build the AML files from DSL source, type `make`.

After `sh download.sh` and `make`, you will later copy this whole directory, `UX305FA-DSDT-Patch`, to the destination machine.

### Installation media

Create your 10.11 installation USB drive according to [RehabMan's guide] (http://www.tonymacx86.com/el-capitan-laptop-support/148093-guide-booting-os-x-installer-laptops-clover.html). Some notes:

* We want Clover UEFI, not Clover Legacy.
* For partitioning the USB drive, GPT is preferred. (I have not tested MBR.)

#### Mounting the installer's EFI partition

Because we're using the GPT format, the EFI partition on the USB installer is not automatically mounted when the drive is inserted.

There is a quirk in the Clover installer: after installing to USB, the USB EFI partition may be mounted at `/Volumes/ESP`.

If you want to mount the USB EFI partition at another time:

1. If `/Volumes/EFI` already exists, use `diskutil unmont /Volumes/EFI` to unmount it.
2. Run `diskutil list` to find the disk number of the USB drive, like `disk1`
3. Run `diskutil mount /dev/disk1s1` to mount the EFI partition at `/Volumes/EFI`

### Configuring Clover for the installer

On the USB EFI partition, the only directory in `EFI/CLOVER/kexts` should be `Other`. `EFI/CLOVER/kexts/Other` should only contain `FakeSMC.kext` (from `downloads/kexts/RehabMan-FakeSMC-2015-1230.zip`) and `ApplePS2SmartTouchPad.kext` (from `SmartTouchPad_v4.4_Final_64bit.zip`).

RehabMan's config file [`config_HD5300_5500_5600_6000.plist`] (https://github.com/RehabMan/OS-X-Clover-Laptop-Config/raw/master/config_HD5300_5500_5600_6000.plist) is a good choice for `config.plist`. Change `Graphics/Inject/Intel` to `false` for initial installation.

There should not be any files in `EFI/CLOVER/ACPI/patched` yet.

### Copying files to USB

You will need these files handy on the target machine: the `UX305FA-DSDT-Patch` directory you prepared, `FakeSMC.kext`, `ApplePS2SmartTouchPad.kext`, `HFSPlus.efi`, and the Clover installer. Copy them to a USB drive. If you do not have another USB drive handy, you could copy those files to a folder on the `Install OS X El Capitan` disk.

## Target

### BIOS settings

To get into the BIOS on this machine, press `ESC` while the "ASUS" logo is on screen.

Reset the BIOS settings to default with the menu item "Save & Exit: Restore Defaults".

Under "Security: Secure Boot menu", set "Secure Boot Control" to Disabled.

Under "Boot", set "Fast Boot" to Disabled, and "Launch CSM" to Enabled.

Under "Advanced", set "VT-d" to Disabled.

Under "Advanced: Graphics Configuration", set "DVMT Pre-Allocated" to 128M.

Don't forget to "Save & Exit: Save Changes".

### Installing OS X

Follow [RehabMan's installation guide] (http://www.tonymacx86.com/el-capitan-laptop-support/148093-guide-booting-os-x-installer-laptops-clover.html#post917904).

Once you've reached "Post Installation" in RehabMan's guide, you'll need to copy the files described in "Copying files to USB" to the Desktop. After copying, I recommend ejecting all USB drives at this point.

There is currently a bug in the trackpad driver: scrolling will not work until you have opened System Preferences:Trackpad, and changed "Scrolling speed" at least once. It can be difficult to navigate the Clover installer without scrolling.

Install Clover as described in the guide.

There is a quirk in the Clover installer: after installing, the EFI partition may be mounted at `/Volumes/ESP`.

Otherwise, to mount the *hard drive* EFI partition:

1. If `/Volumes/EFI` already exists, use `diskutil unmont /Volumes/EFI` to unmount it.
2. Run `diskutil list` to find the disk number of the hard drive. It is very likely `disk0`.
3. Run `diskutil mount /dev/disk0s1` to mount the EFI partition at `/Volumes/EFI`

Because there will be an EFI partition on both your installation media and the hard drive, mounting the right EFI partition can be tricky. It is less prone to human error if you don't have any USB disks plugged in.

After installing Clover, remember to install `HFSPlus.efi`, `FakeSMC.kext`, and `ApplePS2SmartTouchPad.kext` to the hard drive's EFI partition as you did with the USB install media.

### Installing the patches

This is where you install the hotpatches.

From the `UX305FA-DSDT-Patch` directory, copy `build/*.aml` to the EFI partition's `EFI/CLOVER/ACPI/patched` directory.

The AML files completely depend on DSDT/SSDT patches done by Clover according to the `config.plist`. Copy `build/config.plist` to `EFI/CLOVER/config.plist`.

If you have the 1920x1080 display, `config.plist` is done. See the next section if you have a QHD/UHD display.

I hate the ambient light sensor, and its driver has never worked quite right for me. Feel free to remove `EFI/CLOVER/ACPI/patched/SSDT-ALS.dsl`.

Once you're done with this section, you should be able to reboot from the hard drive.

#### Side note: QHD/UHD displays

(Skip this section if you have the FHD/1920x1080 display.)

If you have the QHD/UHD display, the `config.plist` option `Graphics/Inject/Intel` set to true will cause a hang at boot until you have patched IOKit. Turn off Intel injection by setting `Graphics/Inject/Intel` to false until then.

To patch IOKit on QHD/UHD machines, I use `macPixelClockPatcher.command` from [floris497's repository] (https://github.com/floris497/mac-pixel-clock-patch).

OS upgrades tend to overwrite the IOKit patch, which can make your QHD/UHD machine unbootable with injection. You can disable `Graphics/Inject/Intel` for a single boot using Clover options. On the main Clover screen, press `O` to bring up Options, choose `Graphics Injector menu` then press space on the `InjectIntel` option. Press `ESC` twice and boot normally. Once you're in the OS, you can re-run the IOKit patcher.

### Installing drivers and tools

I recommend not logging into any Apple services until you have completed this section and the next.

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

Sound won't work without a driver. There are three choices for that:

#### VoodooHDA

The VoodooHDA installer is available in `downloads/pkgs/`.

The directory `voodohda-fix` contains a patch for headphone detaction. See `voodoohda-fix/readme.txt`.

Mic switching is unsupported.

#### Patched AppleHDA

Thanks to anerik70, there is a patched AppleHDA. It also supports HDMI audio (with the current `config.plist`). I have not tested it as much.

The dummy kext is in `ADummy.kext.zip`.  You can install it  with `sudo unzip -X ADummy.kext.zip -d /Library/Extensions`. If you installed VoodooHDA previously, remember to remove `/System/Library/Extensions/AppleHDADisabler.kext`. 

Like this VoodooHDA, this particular AppleHDA does not support mic switching. If you feel like messing with it, https://github.com/Mirone/AppleHDAPatcher/tree/master/Patches/Laptop/CX20752 may have useful files.

#### Hybrid VoodooHDA/AppleHDA

McShmoopy has built a hybrid VoodooHDA/AppleHDA configuration, which handles both internal and HDMI audio. See http://www.tonymacx86.com/el-capitan-laptop-support/185868-voodoohda-jack-sense-auto-switching-hdmi-audio.html for details.

### Once you have a network

You still need CPU power management. See [the Beta branch of `Piker-Alpha/ssdtPRGen.sh`] (https://github.com/Piker-Alpha/ssdtPRGen.sh/tree/Beta). (The `master` branch will not work.) The `SSDT.aml` it generates needs to go in the EFI partition's `EFI/CLOVER/ACPI/patched` directory.

To improve performance and to (potentially) enable Apple services, you need SMBIOS information configured. You can add appropriate SMBIOS settings to `EFI/CLOVER/config.plist`, probably using a tool like Clover Configurator. This guide does not cover the subject, but a good choice for `ProductName` is `MacBookAir7,2`.

You're done!

## Driver sources

Most drivers are downloaded as part of `download.sh`. Here are the sources for the other drivers:

* ApplePS2SmartTouchPad v4.4: http://forum.osxlatitude.com/index.php?/topic/1948-elan-focaltech-and-synaptics-smart-touchpad-driver-mac-os-x/
* AsusNBFKeys v2.4: http://forum.osxlatitude.com/index.php?/topic/1968-fn-hotkey-and-als-a-driver-for-asus-notebooks/
* AX88772: http://www.asix.com.tw/download.php?sub=driverdetail&PItemID=86

## Random notes

The command to force-enable HiDPI mode is

```
sudo defaults write /Library/Preferences/com.apple.windowserver.plist DisplayResolutionEnabled -bool true
```

On the 1920x1080 display: in order to use HiDPI mode at resolutions above 960x540, you need [SwitchResX] (http://www.madrau.com/srx_download/download.html). Select your monitor, switch to the "Custom Resolutions" tab, then use "+" to add "Scaled" resolutions at twice the size you really want. "3200x1800" gives a virtual 1600x900 display.

## Credits

jhawk wrote the UX305FA installation guide for 10.10. See http://www.tonymacx86.com/yosemite-laptop-guides/166818-guide-asus-zenbook-ux305fa-using-clover-uefi.html 

Machanical's guide to the similar UX303LA was helpful. http://www.tonymacx86.com/el-capitan-laptop-guides/172279-guide-asus-zenbook-ux303la-broadwell-edition.html

EMlyDinEsH maintains the touchpad driver.

RehabMan seems to maintain...just about everything else. :-) He also convinced me to try the no-patch DSDT technique.
