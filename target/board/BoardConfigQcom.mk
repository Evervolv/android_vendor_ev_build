# Bring in Qualcomm helper macros
A_FAMILY := msm7x27a msm7x30 msm8660 msm8960
B_FAMILY := msm8226 msm8610 msm8974
B64_FAMILY := msm8992 msm8994
BR_FAMILY := msm8909 msm8916
UM_3_18_FAMILY := msm8937 msm8953 msm8996
UM_4_4_FAMILY := msm8998 sdm660
UM_4_9_FAMILY := sdm845 sdm710
UM_4_14_FAMILY := msmnile sm6150
UM_PLATFORMS := $(UM_3_18_FAMILY) $(UM_4_4_FAMILY) $(UM_4_9_FAMILY) $(UM_4_14_FAMILY)
QSSI_SUPPORTED_PLATFORMS := $(UM_4_9_FAMILY) $(UM_4_14_FAMILY)

BOARD_USES_ADRENO := true

# UM platforms no longer need this set on O+
ifneq ($(TARGET_USES_AOSP),true)
    ifneq ($(filter $(B_FAMILY) $(B64_FAMILY) $(BR_FAMILY),$(TARGET_BOARD_PLATFORM)),)
        TARGET_USES_QCOM_BSP := true
    endif
endif

# Tell HALs that we're compiling an AOSP build with an in-line kernel
TARGET_COMPILE_WITH_MSM_KERNEL := true

ifeq ($(call is-board-platform-in-list, $(A_FAMILY)),true)
    # Enable legacy audio functions
    ifeq ($(BOARD_USES_LEGACY_ALSA_AUDIO),true)
        ifneq ($(filter msm8960,$(TARGET_BOARD_PLATFORM)),)
            USE_CUSTOM_AUDIO_POLICY := 1
        endif
    endif
endif

# Enable media extensions
TARGET_USES_MEDIA_EXTENSIONS := true

# Allow building audio encoders
TARGET_USES_QCOM_MM_AUDIO := true

# Enable color metadata for every UM targets
ifneq ($(filter $(UM_PLATFORMS),$(TARGET_BOARD_PLATFORM)),)
    TARGET_USES_COLOR_METADATA := true
endif

# Enable DRM PP driver on UM platforms that support it
ifneq ($(filter $(UM_4_9_FAMILY) $(UM_4_14_FAMILY),$(TARGET_BOARD_PLATFORM)),)
    TARGET_USES_DRM_PP := true
endif

# Mark GRALLOC_USAGE_PRIVATE_WFD as valid gralloc bits
TARGET_ADDITIONAL_GRALLOC_10_USAGE_BITS ?= 0

# Mark GRALLOC_USAGE_HW_2D as valid gralloc bit on legacy platforms that support it
ifneq ($(filter msm8952 $(A_FAMILY) $(B_FAMILY) $(B64_FAMILY) $(BR_FAMILY),$(TARGET_BOARD_PLATFORM)),)
    TARGET_ADDITIONAL_GRALLOC_10_USAGE_BITS += | (1 << 10)
endif

# Mark GRALLOC_USAGE_EXTERNAL_DISP as valid gralloc bit
TARGET_ADDITIONAL_GRALLOC_10_USAGE_BITS += | (1 << 13)

# Mark GRALLOC_USAGE_PRIVATE_WFD as valid gralloc bit
TARGET_ADDITIONAL_GRALLOC_10_USAGE_BITS += | (1 << 21)

# Mark GRALLOC_USAGE_PRIVATE_HEIF_VIDEO as valid gralloc bit on UM platforms that support it
ifneq ($(filter $(UM_4_9_FAMILY) $(UM_4_14_FAMILY),$(TARGET_BOARD_PLATFORM)),)
    TARGET_ADDITIONAL_GRALLOC_10_USAGE_BITS += | (1 << 27)
endif

# List of targets that use master side content protection
MASTER_SIDE_CP_TARGET_LIST := msm8996 msm8998 sdm660 sdm845 sm6150 msmnile

# Every qcom platform is considered a vidc target
MSM_VIDC_TARGET_LIST := $(TARGET_BOARD_PLATFORM)

ifneq ($(filter $(A_FAMILY),$(TARGET_BOARD_PLATFORM)),)
    QCOM_HARDWARE_VARIANT := msm8960
else ifneq ($(filter $(B_FAMILY),$(TARGET_BOARD_PLATFORM)),)
    QCOM_HARDWARE_VARIANT := msm8974
else ifneq ($(filter $(B64_FAMILY),$(TARGET_BOARD_PLATFORM)),)
    QCOM_HARDWARE_VARIANT := msm8994
else ifneq ($(filter $(BR_FAMILY),$(TARGET_BOARD_PLATFORM)),)
    QCOM_HARDWARE_VARIANT := msm8916
else ifneq ($(filter $(UM_3_18_FAMILY),$(TARGET_BOARD_PLATFORM)),)
    QCOM_HARDWARE_VARIANT := msm8996
else ifneq ($(filter $(UM_4_4_FAMILY),$(TARGET_BOARD_PLATFORM)),)
    QCOM_HARDWARE_VARIANT := msm8998
else ifneq ($(filter $(UM_4_9_FAMILY),$(TARGET_BOARD_PLATFORM)),)
    QCOM_HARDWARE_VARIANT := sdm845
else ifneq ($(filter $(UM_4_14_FAMILY),$(TARGET_BOARD_PLATFORM)),)
    QCOM_HARDWARE_VARIANT := sm8150
else
    QCOM_HARDWARE_VARIANT := $(TARGET_BOARD_PLATFORM)
endif

