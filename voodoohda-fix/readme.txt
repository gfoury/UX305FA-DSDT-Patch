This is a patch for VoodooHDA to enable speaker/headphone detection,
courtesy of victor123ong. See
http://www.tonymacx86.com/laptop-compatibility/159314-asus-zenbook-ux305-compatability-33.html#post1061029

Apply the patch VoodooHDA-Info.plist.patch to
/System/Library/Extensions/VoodooHDA/Contents/Info.plist :

cd /System/Library/Extensions/VoodooHDA/Contents
sudo patch <~/Desktop/UX305-DSDT-Patch/voodoohda-fix/VoodooHDA-Info.plist.patch
sudo touch /System/Library/Extensions && sudo kextcache -u /

A pre-patched version for version 2.8.8 of VoodooHDA is in
VoodooHDA-2.8.8-Info.plist . I do not recommend using it with any
other version.
 
