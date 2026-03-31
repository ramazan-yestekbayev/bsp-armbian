# BL32_AP_MM.fd

This board uses a prebuilt StandaloneMM image (`BL32_AP_MM.fd`) for secure UEFI variable storage.

## Purpose

UEFI variable storage was migrated from a non-secure FAT-based backend to a secure backend using:

- EDK2 StandaloneMM
- OP-TEE secure storage
- eMMC RPMB

This resolved the SCT failure:

`RT.SetVariable - Create one Time Base Auth Variable -- FAILURE`

## U-Boot requirements

The following U-Boot options are required:

```ini
CONFIG_SUPPORT_EMMC_RPMB=y
CONFIG_CMD_OPTEE_RPMB=y
CONFIG_EFI_MM_COMM_TEE=y
```

## Notes

This Armbian integration does not build EDK2 / StandaloneMM as part of the normal build flow.
Instead, a prebuilt `BL32_AP_MM.fd` is provided and used directly.

## EDK2 changes used to produce this binary

The shipped StandaloneMM binary was built with the following functional changes.

### 1. Increased EFI variable store sizing

File:
`edk2-platforms/Platform/StandaloneMm/PlatformStandaloneMmPkg/PlatformStandaloneMmRpmb.dsc`

Key settings:

- `PcdMaxVariableSize = 0x10000`
- `PcdMaxAuthVariableSize = 0x10000`
- `PcdFlashNvStorageVariableSize = 0x00020100`
- `PcdFlashNvStorageFtwWorkingSize = 0x00004000`
- `PcdFlashNvStorageFtwSpareSize = 0x00020000`
- `PcdVariableStoreSize = 0x00020100`

This fixes:

`RT.SecurityVariableSizeTest - BBSR Variable Size test -- FAILURE`

Required minimums:

- MaxStorageSize >= 128KB
- MaxVariableSize >= 64KB

### 2. RPMB FVB block size fix

File:
`edk2-platforms/Drivers/OpTee/OpteeRpmbPkg/OpTeeRpmbFvb.c`

The FVB driver was adjusted to use the RPMB block size (256 bytes) instead of assuming 4KB blocks.

Result:

- excessive RPMB operations were eliminated
- boot time dropped from ~15–20 minutes to ~10 seconds
- EFI variable access became stable

Reference patch:

```diff
--- a/edk2-platforms/Drivers/OpTee/OpteeRpmbPkg/OpTeeRpmbFvb.c
+++ b/edk2-platforms/Drivers/OpTee/OpteeRpmbPkg/OpTeeRpmbFvb.c
@@ -33,6 +33,7 @@
 // the autodiscovery failed scenario
 //
 STATIC CONST UINT16 mStorageId = 4U;
+STATIC CONST UINTN  mRpmbBlockSize = 256U;

 STATIC MEM_INSTANCE mInstance;

@@ -794,18 +795,21 @@
   VOID         *Addr;
   UINTN        FvLength;
   UINTN        NBlocks;
+  UINTN        NPages;

   FvLength = PcdGet32 (PcdFlashNvStorageVariableSize) +
              PcdGet32 (PcdFlashNvStorageFtwWorkingSize) +
              PcdGet32 (PcdFlashNvStorageFtwSpareSize);

-  NBlocks = EFI_SIZE_TO_PAGES (ALIGN_VARIABLE (FvLength));
-  Addr = AllocatePages (NBlocks);
+  NPages = EFI_SIZE_TO_PAGES (ALIGN_VARIABLE (FvLength));
+  Addr = AllocatePages (NPages);
   if (Addr == NULL) {
     ASSERT (0);
     return EFI_OUT_OF_RESOURCES;
   }

+  NBlocks = ALIGN_VALUE (FvLength, mRpmbBlockSize) / mRpmbBlockSize;
+
   ZeroMem (&mInstance, sizeof (mInstance));

   mInstance.FvbProtocol.GetPhysicalAddress = OpTeeRpmbFvbGetPhysicalAddress;
@@ -819,7 +823,7 @@
   mInstance.MemBaseAddress = (EFI_PHYSICAL_ADDRESS)(UINTN)Addr;
   mInstance.Signature      = FLASH_SIGNATURE;
   mInstance.Initialize     = FvbInitialize;
-  mInstance.BlockSize      = EFI_PAGE_SIZE;
+  mInstance.BlockSize      = mRpmbBlockSize;
   mInstance.NBlocks        = NBlocks;

   // Update the defined PCDs related to Variable Storage
```