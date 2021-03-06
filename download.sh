set -e
set -x

function download()
{
    echo "downloading $2:"
    curl --location --silent --output /tmp/org.rehabman.envy15-download.txt https://bitbucket.org/RehabMan/$1/downloads
    scrape=`grep -o -m 1 href\=\".*$2.*\.zip.*\" /tmp/org.rehabman.envy15-download.txt|perl -ne 'print $1 if /href\=\"(.*)\"/'`
    url=https://bitbucket.org$scrape
    echo $url
    if [ "$3" == "" ]; then
        curl --remote-name --progress-bar --location "$url"
    else
        curl --output "$3" --progress-bar --location "$url"
    fi
    echo
}

if [ ! -d ./downloads ]; then mkdir ./downloads; fi && rm -Rf downloads/* && cd ./downloads

# download kexts
mkdir ./kexts && cd ./kexts
download os-x-fakesmc-kozlek RehabMan-FakeSMC
#download os-x-voodoo-ps2-controller RehabMan-Voodoo
#download os-x-realtek-network RehabMan-Realtek-Network
#download os-x-acpi-backlight RehabMan-Backlight
download os-x-intel-backlight RehabMan-IntelBacklight
download os-x-acpi-battery-driver RehabMan-Battery
#download os-x-eapd-codec-commander RehabMan-CodecCommander
download os-x-fake-pci-id RehabMan-FakePCIID
download os-x-brcmpatchram RehabMan-BrcmPatchRAM
download os-x-acpi-debug RehabMan-Debug
download os-x-null-ethernet RehabMan-NullEthernet
#download os-x-usb-inject-all RehabMan-USBInjectAll
cd ..

mkdir ./pkgs && cd ./pkgs
curl -o VoodooHDA-2.8.8.pkg.zip --progress-bar --location http://sourceforge.net/projects/voodoohda/files/VoodooHDA-2.8.8.pkg.zip/download
cd ..

# download tools
mkdir ./tools && cd ./tools
download os-x-maciasl-patchmatic RehabMan-patchmatic
download os-x-maciasl-patchmatic RehabMan-MaciASL
download acpica iasl iasl.zip
cd ..

