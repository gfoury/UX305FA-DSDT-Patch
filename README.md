# UX305FA-DSDT-Patch

This is a collection of DSDT/SSDT patches and tools for the ASUS UX305FA laptop.

This repository depends on two of RehabMan's repositories as git submodules. After you've cloned this repository, run

```
git submodule init
git submodule update
```

to download those modules.

The patch is based on the ACPI files from your machine. To generate the files, press `F4` within Clover. This will dump a bunch of files in `YOURDISK/EFI/CLOVER/ACPI/origin/`. Copy those files into `native_clover/origin/` in this directory.
