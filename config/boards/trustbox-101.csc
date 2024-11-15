# Scalys Trustbox 101
BOARD_NAME="Scalys Trustbox 101"
BOARDFAMILY="qoriq"

BOOTCONFIG_DEFAULT="tbe101_tfa_defconfig"
[[ $SECUREBOOT = yes ]] && BOOTCONFIG="tbe101_tfa_secureboot_defconfig" || BOOTCONFIG=${BOOTCONFIG_DEFAULT}

RCWPATH=( \
    ["qspi"]="trustbox/N_SSNH_3308/rcw_1000_default.bin" \
)

KERNEL_TARGET="current"

IMAGE_PARTITION_TABLE="gpt"
ATF_PLATFORM=tbe101
ATF_BOOT_MODE=qspi
OPTEE_PLATFORM=ls-ls1012ardb

RCWSOURCE='https://github.com/Scalys/rcw.git'
RCWBRANCH='branch:trustbox-2012'

# ---- Board QSPI Flash layout
# Ofset      | Size     | Type
# 0x0        | 0x100000 | bl2_qspi.bin
# 0x100000   | 0x400000 | fip.bin
# 0x500000   | -        | Environment
# 0xA00000   | -        | pfe_fw_sbl.itb

# ---- Script for reflash QSPI
# setenv load_addr 0x80100000
# setenv erase_pbl 'sf erase 0x0 B00000'
#
# setenv load_pbl 'ext4load mmc 0:1 $load_addr /bl2_qspi.pbl'
# setenv write_pbl 'sf write $load_addr 0x0 $filesize'
#
# setenv load_fip 'ext4load mmc 0:1 $load_addr /fip.bin'
# setenv write_fip 'sf write $load_addr 0x100000 $filesize'
#
# setenv load_pfe 'ext4load mmc 0:1 $load_addr /pfe_fw_sbl.itb'
# setenv write_pfe 'sf write $load_addr 0xa00000 $filesize'
#
# setenv reflash_qspi 'sf probe 0:0; run erase_pbl; run load_pbl; run write_pbl; run load_fip; run write_fip; run load_pfe; run write_pfe'
# run reflash_qspi