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

# The place where _SB.PCI0.PEG0 is defined is the IGPU SSDT
#IGPU=$(shell grep -l Name.*_ADR.*0x00020000 $(UNPATCHED)/SSDT*.dsl)
IGPU=$(shell grep -l Scope.*_SB.PCI0.PEG0 $(UNPATCHED)/SSDT*.dsl)
IGPU:=$(subst $(UNPATCHED)/,,$(subst .dsl,,$(IGPU)))

# The big complicated thermal table that mentionds GFX0
DPTF=$(shell grep -l DefinitionBlock.*DptfTa $(UNPATCHED)/SSDT*.dsl)
DPTF:=$(subst $(UNPATCHED)/,,$(subst .dsl,,$(DPTF)))

# Most of the AML files we aren't going to touch, only copy.
UNTOUCHED=$(shell echo $(UNPATCHED)/*.dsl)
UNTOUCHED:=$(subst $(UNPATCHED)/,,$(subst .dsl,,$(UNTOUCHED)))
UNTOUCHED:=$(filter-out $(DSDT) $(IGPU) $(DPTF),$(UNTOUCHED))

UNTOUCHED_AML=$(addsuffix .aml,$(UNTOUCHED))

# Here is the list of AML files we don't expect to touch, as a sanity check.
ifneq ($(UNTOUCHED_AML),SSDT-0.aml SSDT-1.aml SSDT-10.aml SSDT-2.aml SSDT-3.aml SSDT-7.aml SSDT-9.aml)
$(error The list of SSDTs I am planning to just copy unchanged is different than I expected. Perhaps SSDTs are missing or have been renamed. This script is expecting to only modify SSDT-8 and SSDT-11, and it uses those names in /usr/bin/patch invocations. Sorry; I wish you good luck in editing this makefile)
endif

UNTOUCHED_IN_NATIVE=$(addprefix $(NATIVE_ORIGIN)/, $(UNTOUCHED_AML))
UNTOUCHED_IN_BUILDDIR=$(addprefix $(BUILDDIR)/, $(UNTOUCHED_AML))

# Determine build products
AML_PRODUCTS:=$(BUILDDIR)/$(DSDT).aml $(BUILDDIR)/$(IGPU).aml $(BUILDDIR)/$(DPTF).aml $(UNTOUCHED_IN_BUILDDIR)

ifdef USE_NULLETHERNET
AML_PRODUCTS+=$(BUILDDIR)/SSDT-RMNE.aml
endif

PRODUCTS=$(AML_PRODUCTS) $(BUILDDIR)/config.plist

ALL_PATCHED=$(PATCHED)/$(DSDT).dsl $(PATCHED)/$(IGPU).dsl $(PATCHED)/$(DPTF).dsl

IASLFLAGS=-ve
IASL=iasl


.PHONY: all
all: $(PRODUCTS)
	@echo ---------------
	@echo Now copy $(BUILDDIR)/*.aml to EFI/CLOVER/ACPI/patched and
	@echo copy $(BUILDDIR)/config.plist to EFI/CLOVER/config.plist

$(BUILDDIR)/DSDT.aml: $(PATCHED)/$(DSDT).dsl
	$(IASL) $(IASLFLAGS) -p $@ $<

$(BUILDDIR)/$(IGPU).aml: $(PATCHED)/$(IGPU).dsl
	$(IASL) $(IASLFLAGS) -p $@ $<

$(BUILDDIR)/$(DPTF).aml: $(PATCHED)/$(DPTF).dsl
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
.PHONY: install
install: $(PRODUCTS)
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

# $(BACKLIGHTINJECT): Backlight.plist patch_backlight.sh
# 	./patch_backlight.sh
# 	touch $@

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

# .PHONY: install_usb
# install_usb:
# 	sudo rm -Rf $(INSTDIR)/$(USBINJECT)
# 	sudo cp -R ./$(USBINJECT) $(INSTDIR)
# 	if [ "`which tag`" != "" ]; then sudo tag -a Blue $(INSTDIR)/$(USBINJECT); fi
# 	make update_kernelcache

# .PHONY: install_backlight
# install_backlight:
# 	sudo rm -Rf $(INSTDIR)/$(BACKLIGHTINJECT)
# 	sudo cp -R ./$(BACKLIGHTINJECT) $(INSTDIR)
# 	if [ "`which tag`" != "" ]; then sudo tag -a Blue $(INSTDIR)/$(BACKLIGHTINJECT); fi
# 	make update_kernelcache

# Patch with 'patchmatic'

.PHONY: patch
patch: $(ALL_PATCHED)

PATCHTITLE=@./patchtitle

$(PATCHED)/$(DSDT).dsl: $(UNPATCHED)/$(DSDT).dsl
	cp $(UNPATCHED)/$(DSDT).dsl $(PATCHED)
	$(PATCHTITLE) $@ patches syntax.txt
	$(PATCHTITLE) $@ $(LAPTOPGIT) syntax/remove_DSM.txt
	$(PATCHTITLE) $@ patches misc-UX303-LPC.txt
	$(PATCHTITLE) $@ patches DTGP.txt
	$(PATCHTITLE) $@ $(LAPTOPGIT) system/system_SMBUS.txt
	# Does not seem to hurt, might help some:
	$(PATCHTITLE) $@ $(LAPTOPGIT) audio/audio_HDEF-layout3.txt
	$(PATCHTITLE) $@ $(LAPTOPGIT) battery/battery_ASUS-N55SL.txt
	$(PATCHTITLE) $@ $(LAPTOPGIT) system/system_WAK2.txt
	$(PATCHTITLE) $@ $(LAPTOPGIT) system/system_HPET.txt
	$(PATCHTITLE) $@ $(LAPTOPGIT) system/system_IRQ.txt
	$(PATCHTITLE) $@ $(LAPTOPGIT) system/system_RTC.txt
	$(PATCHTITLE) $@ $(LAPTOPGIT) system/system_PNOT.txt
	$(PATCHTITLE) $@ $(LAPTOPGIT) system/system_IMEI.txt
	# already fixed ADGB
	$(PATCHTITLE) $@ $(LAPTOPGIT) usb/usb_prw_0x6d_xhc.txt
	$(PATCHTITLE) $@ patches graphics_PNLF_haswell.txt
	$(PATCHTITLE) $@ patches ZenBooksLidSleepandScreenBackLightPatch.txt
	$(PATCHTITLE) $@ patches ALSPatch-Haswell.txt
	$(PATCHTITLE) $@ patches KeyboardBacklight.txt
	$(PATCHTITLE) $@ patches BrightnessKeys_Patch.txt
	$(PATCHTITLE) $@ $(LAPTOPGIT) graphics/graphics_Rename-GFX0.txt

$(PATCHED)/$(IGPU).dsl: $(UNPATCHED)/$(IGPU).dsl 
	cp $(UNPATCHED)/$(IGPU).dsl $(PATCHED)
	cd $(PATCHED) && patch -p0 <../SSDT-11-ref.patch
	$(PATCHTITLE) $@ $(LAPTOPGIT) graphics/graphics_Rename-GFX0.txt

$(PATCHED)/$(DPTF).dsl: $(UNPATCHED)/$(DPTF).dsl 
	cp $(UNPATCHED)/$(DPTF).dsl $(PATCHED)
	cd $(PATCHED) && patch -p0 <../SSDT-8-ref.patch
	$(PATCHTITLE) $@ $(LAPTOPGIT) graphics/graphics_Rename-GFX0.txt


$(UNTOUCHED_IN_BUILDDIR): $(BUILDDIR)/%: $(NATIVE_ORIGIN)/%
	cp $< $@

$(BUILDDIR)/config.plist: config.patch $(CLOVERCONFIG)/config_HD5300_5500_5600_6000.plist
	patch -o $(BUILDDIR)/config.plist $(CLOVERCONFIG)/config_HD5300_5500_5600_6000.plist config.patch

$(BUILDDIR)/SSDT-RMNE.aml: SSDT-RMNE.dsl
	$(IASL) $(IASLFLAGS) -p $@ $<
