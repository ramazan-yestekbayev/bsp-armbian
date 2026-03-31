# Scalys Trustbox 401
BOARD_NAME="Scalys Trustbox 401"
BOARDFAMILY="qoriq"
BOOTCONFIG_DEFAULT="tbe401_tfa_defconfig"
[[ $SECUREBOOT = yes ]] && BOOTCONFIG="tbe401_tfa_SECURE_BOOT_defconfig" || BOOTCONFIG=${BOOTCONFIG_DEFAULT}
KERNEL_TARGET="current"
IMAGE_PARTITION_TABLE="msdos"
OFFSET=32

RCWPATH=( \
    ["sd"]="tbe401/NN_NNQNNPNP_3040_0506/rcw_1600_sdboot.bin" \
)

RCWSOURCE='https://github.com/Scalys/rcw.git'
RCWBRANCH='branch:trusstbox-2412'

OPTEE_PLATFORM='ls-ls1046ardb'

TFABOOT=yes
ATF_PLATFORM='ls1046atbe401'
ATF_BOOT_MODE='sd'

FMAN_UCODE='fsl_fman_ucode_ls1046_r1.0_106_4_18.bin'
