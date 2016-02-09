# makefile

# Builds SSDT patches for the ASUS UX305FA
#
# Originally based on https://github.com/RehabMan/HP-Envy-K-DSDT-Patch

# If you don't have a working built-in Ethernet (DW1560?) then:
#
#  1) Edit SSDT-RMNE.dsl to change 11:22:33:44:55:66 to an Ethernet
#  MAC address not in use with Apple (like your Intel wireless adapter)
#
# 2) Uncomment the following line

# USE_NULLETHERNET=1

# You need iasl on your PATH. If you don't have it, the download.sh
# script will download zip files into downloads/tools/. Unzip iasl
# into tools/.

export PATH:=tools:$(PATH)

BUILDDIR=./build
NATIVE=./native_clover
NATIVE_ORIGIN=./native_clover/origin

AML_PRODUCTS:= $(BUILDDIR)/SSDT-HACK.aml $(BUILDDIR)/SSDT-ALS.aml $(BUILDDIR)/SSDT-DEBUG.aml $(BUILDDIR)/SSDT-BATT.aml

ifdef USE_NULLETHERNET
AML_PRODUCTS+=$(BUILDDIR)/SSDT-RMNE.aml
endif

PRODUCTS=$(AML_PRODUCTS) $(BUILDDIR)/config.plist

IASLFLAGS=-ve
IASL=iasl

.PHONY: all
all: $(PRODUCTS)
	@echo
	@echo ---------------
	@echo
	@echo Now you may copy $(BUILDDIR)/\*.aml to EFI/CLOVER/ACPI/patched and
	@echo copy $(BUILDDIR)/config.plist to EFI/CLOVER/config.plist
	@echo

.PHONY: clean
clean:
	rm -f $(BUILDDIR)/*.dsl $(BUILDDIR)/*.aml $(BUILDDIR)/*.plist

.PHONY: cleanall
cleanall:
	make clean
	rm -f $(UNPATCHED)/*.dsl

.PHONY: cleanallex
cleanallex:
	make cleanall
	rm -f native_clover/origin/*.aml

.PHONY: install
install: all
	@echo There is no automated installation.


#$(BUILDDIR)/config.plist: config.patch $(CLOVERCONFIG)/config_HD5300_5500_5600_6000.plist
#	patch -o $(BUILDDIR)/config.plist $(CLOVERCONFIG)/config_HD5300_5500_5600_6000.plist config.patch

$(BUILDDIR)/config.plist: config_master.plist
	cp config_master.plist $(BUILDDIR)/config.plist

$(BUILDDIR)/SSDT-RMNE.aml: SSDT-RMNE.dsl
	$(IASL) $(IASLFLAGS) -p $@ $<

$(BUILDDIR)/SSDT-HACK.aml: SSDT-HACK.dsl
	$(IASL) $(IASLFLAGS) -p $@ $<

$(BUILDDIR)/SSDT-ALS.aml: SSDT-ALS.dsl
	$(IASL) $(IASLFLAGS) -p $@ $<

$(BUILDDIR)/SSDT-DEBUG.aml: SSDT-DEBUG.dsl
	$(IASL) $(IASLFLAGS) -p $@ $<

$(BUILDDIR)/SSDT-BATT.aml: SSDT-BATT.dsl
	$(IASL) $(IASLFLAGS) -p $@ $<

#########
# Maintainer-only below this block.
#########

# This is how I test. I have a USB drive which I know will be at
# /dev/disk1 when I plug it in. The EFI partition is at /dev/disk1s1
#
# Unless you are certain /dev/disk1 is the right place, you do not
# want to use this.
#
# You'll also need an SMBIOS.plist to be merged into config.plist.
INSTDIR=/Volumes/EFI/EFI/CLOVER
INSTDISK=/dev/disk1s1
.PHONY: install-to-disk1s1
install-to-disk1s1: build/config-full.plist $(AML_PRODUCTS)
	[ ! -d /Volumes/EFI ] || diskutil unmount /Volumes/EFI
	diskutil mount $(INSTDISK)
	cp build/config-full.plist $(INSTDIR)/config.plist
	cp $(AML_PRODUCTS) $(INSTDIR)/ACPI/patched
	sync; sync; sleep 2
	diskutil eject $(INSTDISK)

build/config-full.plist: config_master.plist smbios.plist
	cp config_master.plist build/config-full.plist
	[ -f SMBIOS.plist ] && cat pbuddy-merge-smbios | /usr/libexec/PlistBuddy -x build/config-full.plist


# This is a more readable version of the plist.
binpatch-list:
	@../cloverbinpatch/makebinpatch.py '_Q0E\x00' 'XQ0E\x00' 'Rename Method(_Q0E,0) to XQ0E'
	@../cloverbinpatch/makebinpatch.py '_Q0F\x00' 'XQ0F\x00' 'Rename Method(_Q0E,0) to XQ0F'
	@../cloverbinpatch/makebinpatch.py '_QCD\x00' 'XQCD\x00' 'Rename Method(_QCD,0) to XQCD'
	@../cloverbinpatch/makebinpatch.py 'GPRW\x02' 'XPRW\x02' 'Rename Method(GPRW,2) to Method(XPRW,2)'
	@../cloverbinpatch/makebinpatch.py '_BIX\x00' 'XBIX\x00' 'Rename Method(_BIX,0) to Method(XBIX,0)'
	@../cloverbinpatch/makebinpatch.py 'TACH\x09' 'XTAC\x09' 'Battery: Rename Method(TACH,0) to Method(XTAC,0)'
	@../cloverbinpatch/makebinpatch.py 'BIFA\x00' 'XBIF\x00' 'Battery: Rename Method(BIFA,0) to Method(XBIF,0)'
	@../cloverbinpatch/makebinpatch.py 'SMBR\x0b' 'XSMB\x0b' 'Battery: Rename Method(SMBR,3,Serialized) to Method(XSMB,3,Serialized)'
	@../cloverbinpatch/makebinpatch.py 'SMBW\x0d' 'XSMW\x0d' 'Battery: Rename Method(SMBW,5,Serialized) to Method(XSMW,5,Serialized)'
	@../cloverbinpatch/makebinpatch.py 'ECSB\x07' 'XCSB\x07' 'Battery: Rename Method(ECSB,7) to Method(XCSB,7)'
	@../cloverbinpatch/makebinpatch.py 'FBST\x04' 'XBST\x04' 'Battery: Rename Method(FBST,4) to Method(XBST,4)'
