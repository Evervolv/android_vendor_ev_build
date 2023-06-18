BOARD_USES_ADRENO := true

# Add qtidisplay to soong config namespaces
SOONG_CONFIG_NAMESPACES += qtidisplay

# Add supported variables to qtidisplay config
SOONG_CONFIG_qtidisplay += \
    drmpp \
    headless \
    llvmsa \
    gralloc4 \
    displayconfig_enabled \
    udfps \
    default \
    var1 \
    var2 \
    var3

# Set default values for qtidisplay config
SOONG_CONFIG_qtidisplay_drmpp ?= false
SOONG_CONFIG_qtidisplay_headless ?= false
SOONG_CONFIG_qtidisplay_llvmsa ?= false
SOONG_CONFIG_qtidisplay_gralloc4 ?= false
SOONG_CONFIG_qtidisplay_displayconfig_enabled ?= false
SOONG_CONFIG_qtidisplay_udfps ?= false
SOONG_CONFIG_qtidisplay_default ?= true
SOONG_CONFIG_qtidisplay_var1 ?= false
SOONG_CONFIG_qtidisplay_var2 ?= false
SOONG_CONFIG_qtidisplay_var3 ?= false

# UM platforms no longer need this set on O+
ifneq ($(TARGET_USES_AOSP),true)
    ifneq ($(filter $(B_FAMILY) $(B64_FAMILY) $(BR_FAMILY),$(TARGET_BOARD_PLATFORM)),)
        TARGET_USES_QCOM_BSP := true
    endif
endif

# Tell HALs that we're compiling an AOSP build with an in-line kernel
TARGET_COMPILE_WITH_MSM_KERNEL := true

# Enable media extensions
TARGET_USES_MEDIA_EXTENSIONS := true

# Allow building audio encoders
TARGET_USES_QCOM_MM_AUDIO := true

# Enable color metadata for every UM targets
ifneq ($(filter $(UM_PLATFORMS),$(TARGET_BOARD_PLATFORM)),)
    TARGET_USES_COLOR_METADATA := true
endif

# Enable DRM PP driver on UM platforms that support it
ifneq ($(filter $(UM_4_9_FAMILY) $(UM_4_14_FAMILY) $(UM_4_19_FAMILY) $(UM_5_4_FAMILY) $(UM_5_10_FAMILY),$(TARGET_BOARD_PLATFORM)),)
    SOONG_CONFIG_qtidisplay_drmpp := true
    TARGET_USES_DRM_PP := true
endif

# Enable Gralloc4 on UM platforms that support it
ifneq ($(filter $(UM_5_4_FAMILY) $(UM_5_10_FAMILY),$(TARGET_BOARD_PLATFORM)),)
    SOONG_CONFIG_qtidisplay_gralloc4 := true
endif

ifneq ($(filter $(UM_5_10_FAMILY),$(TARGET_BOARD_PLATFORM)),)
    TARGET_USES_QCOM_AUDIO_AR ?= true
endif

# Enable displayconfig on every UM platform
ifeq ($(filter $(UM_PLATFORMS),$(TARGET_BOARD_PLATFORM)),)
    SOONG_CONFIG_qtidisplay_displayconfig_enabled := true
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
ifneq ($(filter $(UM_4_9_FAMILY) $(UM_4_14_FAMILY) $(UM_4_19_FAMILY) $(UM_5_4_FAMILY) $(UM_5_10_FAMILY),$(TARGET_BOARD_PLATFORM)),)
    TARGET_ADDITIONAL_GRALLOC_10_USAGE_BITS += | (1 << 27)
endif
