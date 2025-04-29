#!/bin/bash
git submodule update --init
cp -r OvmfPkg edk2/
cp -r Build edk2/
cd edk2
#sed begin OvmfPkg/OvmfPkg.dec OvmfPkgX64.dsc OvmfPkgX64.fdf
grep "do this once" OvmfPkg/OvmfPkg.dec >/dev/null
if [ $? -eq 0 ]; then
	echo "OvmfPkg/OvmfPkg.dec OvmfPkgX64.dsc OvmfPkgX64.fdf 文件只能处理一次！以前已经处理，本次不执行！"
else
	sed -i '/gOvmfLoadedX86LinuxKernelProtocolGuid/a\\  gPlatformGOPPolicyGuid                = {0xec2e931b, 0x3281, 0x48a5, {0x81, 0x07, 0xdf, 0x8a, 0x8b, 0xed, 0x3c, 0x5d}} #do this once' OvmfPkg/OvmfPkg.dec
	sed -i '/VirtioSerial.inf/a\\  OvmfPkg/IgdAssignmentDxe/IgdAssignment.inf\n  OvmfPkg/PlatformGopPolicy/PlatformGopPolicy.inf #do this once' OvmfPkg/OvmfPkgX64.dsc
	sed -i '/VirtioSerial.inf/a\\INF  OvmfPkg/IgdAssignmentDxe/IgdAssignment.inf\nINF  OvmfPkg/PlatformGopPolicy/PlatformGopPolicy.inf #do this once' OvmfPkg/OvmfPkgX64.fdf
	echo "OvmfPkg/OvmfPkg.dec OvmfPkgX64.dsc OvmfPkgX64.fdf 文件处理完成（第一次处理，只处理一次）"
fi
#sed end

git diff > edk2-autoGenPatch.patch
git submodule update --init
source edksetup.sh
sed -i 's:^ACTIVE_PLATFORM\s*=\s*\w*/\w*\.dsc*:ACTIVE_PLATFORM       = OvmfPkg/OvmfPkgX64.dsc:g' Conf/target.txt
sed -i 's:^TARGET_ARCH\s*=\s*\w*:TARGET_ARCH           = X64:g' Conf/target.txt
sed -i 's:^TOOL_CHAIN_TAG\s*=\s*\w*:TOOL_CHAIN_TAG        = GCC5:g' Conf/target.txt
make -C BaseTools
build -DFD_SIZE_4MB -DDEBUG_ON_SERIAL_PORT=TRUE
cp Build/OvmfX64/DEBUG_GCC5/X64/PlatformGOPPolicy.efi Build/
cp Build/OvmfX64/DEBUG_GCC5/X64/IgdAssignmentDxe.efi Build/
cp ./BaseTools/Source/C/bin/EfiRom Build/
cd Build
./EfiRom -e pc-4-5-IntelGopDriver.efi pc-6-7-8-9-IntelGopDriver.efi j4125.efi pc-10-IntelGopDriver.efi pc-11-IntelGopDriver.efi pc-12-13-14-IntelGopDriver.efi 11-J6412.efi 11-n5095.efi 12-1240p.efi 12-n100.efi N2930.efi N3350.efi nb-11-11700h.efi nb-11-1185G7E.efi nb-12-12700h.efi nb-13-13700h.efi IgdAssignmentDxe.efi PlatformGOPPolicy.efi -f 0x8086 -i 0xffff -o 6-14.rom
ls
./EfiRom -e IntelGopDriver.efi IgdAssignmentDxe.efi PlatformGOPPolicy.efi -f 0x8086 -i 0xffff -o 11800h.rom
ls
