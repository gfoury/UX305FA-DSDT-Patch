# makefile

# Patches/Builds DSDT patches for the ASUS UX305FA
#
# Originally based on https://github.com/RehabMan/HP-Envy-K-DSDT-Patch

# In Clover, press F4 to dump the ACPI tables.
# 
# Copy the contents of EFI/CLOVER/ACPI/origin to
# this directory's native_clover/origin.

# If you don't have a working built-in Ethernet (DW1560?) then:
#
#  1) Edit SSDT-RMNE.dsl to change 11:22:33:44:55:66 to an Ethernet
#  MAC address not in use with Apple
#
# 2) Uncomment the following line

# USE_NULLETHERNET=1

# You need iasl and patchmatic on your PATH. If you don't have them,
# the download.sh script will download the zip files into
# downloads/tools/. Copy iasl and patchmatic into tools/.

export PATH:=tools:$(PATH)

LAPTOPGIT=./laptop-dsdt-patch
CLOVERCONFIG=./clover-laptop-config
#DEBUGGIT=../debug.git
BUILDDIR=./build
PATCHED=./patched
UNPATCHED=./unpatched
NATIVE=./native_clover
NATIVE_ORIGIN=./native_clover/origin

ifneq ($(wildcard $(NATIVE_ORIGIN)/DSDT*.aml),$(NATIVE_ORIGIN)/DSDT.aml)
$(error You need to dump the native DSDT/SSDT tables in Clover (press F4). Then copy the contents of EFI/CLOVER/ACPI/origin to this directory under $(NATIVE_ORIGIN))
endif

VERSION_ERA=$(shell ./print_version.sh)
ifeq "$(VERSION_ERA)" "10.10-"
	INSTDIR=/System/Library/Extensions
else
	INSTDIR=/Library/Extensions
endif
SLE=/System/Library/Extensions

# DSDT is easy to find...
DSDT=DSDT

AML_PRODUCTS:=$(BUILDDIR)/$(DSDT).aml $(BUILDDIR)/SSDT-HACK.aml $(BUILDDIR)/SSDT-ALS.aml $(BUILDDIR)/SSDT-DEBUG.aml

ifdef USE_NULLETHERNET
AML_PRODUCTS+=$(BUILDDIR)/SSDT-RMNE.aml
endif

PRODUCTS=$(AML_PRODUCTS) $(BUILDDIR)/config.plist

ALL_PATCHED=$(PATCHED)/$(DSDT).dsl

IASLFLAGS=-ve
IASL=iasl

.PHONY: all
all: $(PRODUCTS)
	@echo ---------------
	@echo Now copy $(BUILDDIR)/*.aml to EFI/CLOVER/ACPI/patched and
	@echo copy $(BUILDDIR)/config.plist to EFI/CLOVER/config.plist

$(BUILDDIR)/DSDT.aml: $(PATCHED)/$(DSDT).dsl
	$(IASL) $(IASLFLAGS) -p $@ $<

.PHONY: clean
clean:
	rm -f $(PATCHED)/*.dsl
	rm -f $(BUILDDIR)/*.dsl $(BUILDDIR)/*.aml $(BUILDDIR)/*.plist

.PHONY: cleanall
cleanall:
	make clean
	rm -f $(UNPATCHED)/*.dsl

.PHONY: cleanallex
cleanallex:
	make cleanall
	rm -f native_patchmatic/*.aml

# Clover Install
.PHONY: do-not-use-install
do-not-use-install: $(PRODUCTS)
	$(error You do not want to run this)
	$(eval EFIDIR:=$(shell sudo ./mount_efi.sh /))
	cp $(BUILDDIR)/$(DSDT).aml $(EFIDIR)/EFI/CLOVER/ACPI/patched
	cp $(BUILDDIR)/$(PPC).aml $(EFIDIR)/EFI/CLOVER/ACPI/patched/SSDT-2.aml
	cp $(BUILDDIR)/$(DYN).aml $(EFIDIR)/EFI/CLOVER/ACPI/patched/SSDT-3.aml
	cp $(BUILDDIR)/$(IGPU).aml $(EFIDIR)/EFI/CLOVER/ACPI/patched/SSDT-4.aml
ifneq "$(PEGP)" ""
	cp $(BUILDDIR)/$(PEGP).aml $(EFIDIR)/EFI/CLOVER/ACPI/patched/SSDT-5.aml
endif
ifneq "$(IAOE)" ""
	cp $(BUILDDIR)/$(IAOE).aml $(EFIDIR)/EFI/CLOVER/ACPI/patched/SSDT-7.aml
endif

# $(HDAINJECT): $(RESOURCES)/ahhcd.plist $(RESOURCES)/layout/Platforms.xml.zlib $(RESOURCES)/layout/$(HDALAYOUT).xml.zlib ./patch_hda.sh
# 	./patch_hda.sh
# 	touch $@

# $(RESOURCES)/layout/Platforms.xml.zlib: $(RESOURCES)/layout/Platforms.plist $(SLE)/AppleHDA.kext/Contents/Resources/Platforms.xml.zlib
# 	./tools/zlib inflate $(SLE)/AppleHDA.kext/Contents/Resources/Platforms.xml.zlib >/tmp/rm_Platforms.plist
# 	/usr/libexec/plistbuddy -c "Delete ':PathMaps'" /tmp/rm_Platforms.plist
# 	/usr/libexec/plistbuddy -c "Merge $(RESOURCES)/layout/Platforms.plist" /tmp/rm_Platforms.plist
# 	./tools/zlib deflate /tmp/rm_Platforms.plist >$@

# $(RESOURCES)/layout/$(HDALAYOUT).xml.zlib: $(RESOURCES)/layout/$(HDALAYOUT).plist
# 	./tools/zlib deflate $< >$@

.PHONY: update_kernelcache
update_kernelcache:
	sudo touch $(SLE)
	sudo kextcache -update-volume /

# .PHONY: install_hda
# install_hda:
# 	sudo rm -Rf $(INSTDIR)/$(HDAINJECT)
# 	sudo cp -R ./$(HDAINJECT) $(INSTDIR)
# 	if [ "`which tag`" != "" ]; then sudo tag -a Blue $(INSTDIR)/$(HDAINJECT); fi
# 	make update_kernelcache

# Patch with 'patchmatic'

.PHONY: patch
patch: $(ALL_PATCHED)

PATCHTITLE=@./patchtitle

$(PATCHED)/$(DSDT).dsl: $(UNPATCHED)/$(DSDT).dsl
	cp $(UNPATCHED)/$(DSDT).dsl $(PATCHED)
	@# Changing _T temporaries to T makes it harder to diff against origin. So don't do that.
	@# $(PATCHTITLE) $@ patches syntax.txt
	#$(PATCHTITLE) $@ $(LAPTOPGIT) syntax/remove_DSM.txt
	@# $(PATCHTITLE) $@ patches misc-UX303-LPC.txt
	@# This is probably *not* AddDTGP_0001. Examine more.
	@# $(PATCHTITLE) $@ patches DTGP.txt
	@# probably FixSBUS_0080
	@# $(PATCHTITLE) $@ $(LAPTOPGIT) system/system_SMBUS.txt
	# Does not seem to hurt, might help some:
	#$(PATCHTITLE) $@ $(LAPTOPGIT) audio/audio_HDEF-layout3.txt
	$(PATCHTITLE) $@ $(LAPTOPGIT) battery/battery_ASUS-N55SL.txt
	@# This would be FIX_WAK_200000 but is allegedly not necessary for >10.10.2, possibly 10.10.*
	@#$(PATCHTITLE) $@ $(LAPTOPGIT) system/system_WAK2.txt
	@# This appears to be FixHPET_0010
	@#$(PATCHTITLE) $@ $(LAPTOPGIT) system/system_HPET.txt
	@# this appears to be FixIPIC_0040
	@#$(PATCHTITLE) $@ $(LAPTOPGIT) system/system_IRQ.txt
	@# this appears to be FIX_RTC_20000
	@#$(PATCHTITLE) $@ $(LAPTOPGIT) system/system_RTC.txt
	@# no equivalent, patch makes no changes anyway
	@# $(PATCHTITLE) $@ $(LAPTOPGIT) system/system_PNOT.txt
	@# probably AddIMEI_80000
	@#$(PATCHTITLE) $@ $(LAPTOPGIT) system/system_IMEI.txt
	@# already fixed ADGB
	#$(PATCHTITLE) $@ $(LAPTOPGIT) usb/usb_prw_0x6d_xhc.txt
	@# For IntelBacklight.kext, AddPNLF_1000000 is good enough.
	@# $(PATCHTITLE) $@ patches graphics_PNLF_haswell.txt
	#$(PATCHTITLE) $@ patches ZenBooksLidSleepandScreenBackLightPatch.txt
	@# This is now done through SSDT-ALS and Clover
	@#$(PATCHTITLE) $@ patches ALSPatch-Haswell.txt
	# Try without EMlyDinEsH's patch
	#$(PATCHTITLE) $@ patches KeyboardBacklight.txt
	@# This is in SSDT-HACK now.
	@#$(PATCHTITLE) $@ patches BrightnessKeys_Patch.txt
	@# This is done through DSDT patching in Clover
	@#$(PATCHTITLE) $@ $(LAPTOPGIT) graphics/graphics_Rename-GFX0.txt

# $(PATCHED)/$(IGPU).dsl: $(UNPATCHED)/$(IGPU).dsl 
# 	cp $(UNPATCHED)/$(IGPU).dsl $(PATCHED)
# 	cd $(PATCHED) && patch -p0 <../SSDT-11-ref.patch
# 	# $(PATCHTITLE) $@ $(LAPTOPGIT) graphics/graphics_Rename-GFX0.txt

# $(PATCHED)/$(DPTF).dsl: $(UNPATCHED)/$(DPTF).dsl 
# 	cp $(UNPATCHED)/$(DPTF).dsl $(PATCHED)
# 	cd $(PATCHED) && patch -p0 <../SSDT-8-ref.patch
# 	# $(PATCHTITLE) $@ $(LAPTOPGIT) graphics/graphics_Rename-GFX0.txt

.PHONY: build2
build2:
	rm -f build2/*.dsl build2/*.aml
	cp native_clover/origin/SSDT-[0-9].aml native_clover/origin/SSDT-[0-9][0-9].aml native_clover/origin/DSDT.aml build2
	../cloverbinpatch/cloverbinpatch.py -v build2/*.aml
	cd build2 && iasl -da -dl -fe ../refs.txt *.aml

INSTDIR=/Volumes/EFI/EFI/CLOVER
INSTDISK=/dev/disk1s1
.PHONY: install2
install2: build/config-full.plist $(AML_PRODUCTS)
	[ ! -d /Volumes/EFI ] || diskutil unmount /Volumes/EFI
	diskutil mount $(INSTDISK)
	cp build/config-full.plist $(INSTDIR)/config.plist
	cp $(AML_PRODUCTS) $(INSTDIR)/ACPI/patched
	sync; sync; sleep 2
	diskutil eject $(INSTDISK)

build/config-full.plist: config_master.plist smbios.plist
	cp config_master.plist build/config-full.plist
	cat pbuddy-merge-smbios | /usr/libexec/PlistBuddy -x build/config-full.plist

$(BUILDDIR)/config.plist: config.patch $(CLOVERCONFIG)/config_HD5300_5500_5600_6000.plist
	patch -o $(BUILDDIR)/config.plist $(CLOVERCONFIG)/config_HD5300_5500_5600_6000.plist config.patch

$(BUILDDIR)/SSDT-RMNE.aml: SSDT-RMNE.dsl
	$(IASL) $(IASLFLAGS) -p $@ $<

$(BUILDDIR)/SSDT-HACK.aml: SSDT-HACK.dsl
	$(IASL) $(IASLFLAGS) -p $@ $<

$(BUILDDIR)/SSDT-ALS.aml: SSDT-ALS.dsl
	$(IASL) $(IASLFLAGS) -p $@ $<

$(BUILDDIR)/SSDT-DEBUG.aml: SSDT-DEBUG.dsl
	$(IASL) $(IASLFLAGS) -p $@ $<



binpatch-list:
	../cloverbinpatch/makebinpatch.py '_Q0E\x00' 'XQ0E\x00' 'Rename Method(_Q0E,0) to XQ0E'
	../cloverbinpatch/makebinpatch.py '_Q0F\x00' 'XQ0F\x00' 'Rename Method(_Q0E,0) to XQ0F'
	../cloverbinpatch/makebinpatch.py '_QCD\x00' 'XQCD\x00' 'Rename Method(_QCD,0) to XQCD'

