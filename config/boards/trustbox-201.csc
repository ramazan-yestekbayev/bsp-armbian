# Scalys Trustbox 201
BOARD_NAME="Scalys Trustbox 201"
BOARDFAMILY="qoriq"

BOOTCONFIG_DEFAULT="tbe201_tfa_defconfig"
[[ $SECUREBOOT = yes ]] && BOOTCONFIG="tbe201_tfa_SECURE_BOOT_defconfig" || BOOTCONFIG=${BOOTCONFIG_DEFAULT}

RCWPATH=( \
	["sd"]="trustsom_tbe201/N_SQPP_0x85BE/rcw_1500.bin" \
)

KERNEL_TARGET="current"
SKIP_BOOTSPLASH="yes"
IMAGE_PARTITION_TABLE="msdos"
OFFSET=32


OPTEE_PLATFORM='ls-ls1028ardb'

TFABOOT=yes
ATF_PLATFORM='ls1028trustsom'
ATF_BOOT_MODE='sd'

RCWSOURCE='https://github.com/nxp-qoriq/rcw.git'
RCWBRANCH='branch:lf-6.6.36-2.1.0'
