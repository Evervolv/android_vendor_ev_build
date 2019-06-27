# Target-specific configuration

# Populate the qcom hardware variants in the project pathmap.
define wlan-set-path-variant
$(call project-set-path-variant,wlan,TARGET_WLAN_VARIANT,hardware/qcom/$(1))
endef
define bt-vendor-set-path-variant
$(call project-set-path-variant,bt-vendor,TARGET_BT_VENDOR_VARIANT,hardware/qcom/$(1))
endef

# Set device-specific HALs into project pathmap
define set-device-specific-path
$(if $(USE_DEVICE_SPECIFIC_$(1)), \
    $(if $(DEVICE_SPECIFIC_$(1)_PATH), \
        $(eval path := $(DEVICE_SPECIFIC_$(1)_PATH)), \
        $(eval path := $(TARGET_DEVICE_DIR)/$(2))), \
    $(eval path := $(3))) \
$(call project-set-path,qcom-$(2),$(strip $(path)))
endef

ifeq ($(TARGET_HW_DISK_ENCRYPTION),true)
    TARGET_CRYPTFS_HW_PATH ?= vendor/qcom/opensource/cryptfs_hw
endif

ifeq ($(BOARD_USES_QCOM_HARDWARE),true)
    BOARD_USES_QTI_HARDWARE := true
endif

ifeq ($(BOARD_USES_QTI_HARDWARE),true)

    A_FAMILY := msm7x27a msm7x30 msm8660 msm8960
    B_FAMILY := msm8226 msm8610 msm8974
    B64_FAMILY := msm8992 msm8994
    BR_FAMILY := msm8909 msm8916
    UM_3_18_FAMILY := msm8937 msm8953 msm8996
    UM_4_4_FAMILY := msm8998 sdm660
    UM_4_9_FAMILY := sdm845
    UM_PLATFORMS := $(UM_3_18_FAMILY) $(UM_4_4_FAMILY) $(UM_4_9_FAMILY)

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
    ifneq ($(filter $(UM_4_9_FAMILY),$(TARGET_BOARD_PLATFORM)),)
        TARGET_USES_DRM_PP := true
    endif

    # Mark GRALLOC_USAGE_PRIVATE_WFD as valid gralloc bits
    TARGET_ADDITIONAL_GRALLOC_10_USAGE_BITS ?= 0
    TARGET_ADDITIONAL_GRALLOC_10_USAGE_BITS += | (1 << 21)

    # Mark GRALLOC_USAGE_PRIVATE_10BIT_TP as valid gralloc bits on UM platforms that support it
    ifneq ($(filter $(UM_4_9_FAMILY),$(TARGET_BOARD_PLATFORM)),)
        TARGET_ADDITIONAL_GRALLOC_10_USAGE_BITS += | (1 << 27)
    endif

    # List of targets that use master side content protection
    MASTER_SIDE_CP_TARGET_LIST := msm8996 msm8998 sdm660 sdm845

    # Every qcom platform is considered a vidc target
    MSM_VIDC_TARGET_LIST := $(TARGET_BOARD_PLATFORM)

    ifneq ($(filter $(A_FAMILY),$(TARGET_BOARD_PLATFORM)),)
        QCOM_HARDWARE_VARIANT := msm8960
    else
    ifneq ($(filter $(B_FAMILY),$(TARGET_BOARD_PLATFORM)),)
        QCOM_HARDWARE_VARIANT := msm8974
    else
    ifneq ($(filter $(B64_FAMILY),$(TARGET_BOARD_PLATFORM)),)
        QCOM_HARDWARE_VARIANT := msm8994
    else
    ifneq ($(filter $(BR_FAMILY),$(TARGET_BOARD_PLATFORM)),)
        QCOM_HARDWARE_VARIANT := msm8916
    else
    ifneq ($(filter $(UM_3_18_FAMILY),$(TARGET_BOARD_PLATFORM)),)
        QCOM_HARDWARE_VARIANT := msm8996
    else
    ifneq ($(filter $(UM_4_4_FAMILY),$(TARGET_BOARD_PLATFORM)),)
        QCOM_HARDWARE_VARIANT := msm8998
    else
    ifneq ($(filter $(UM_4_9_FAMILY),$(TARGET_BOARD_PLATFORM)),)
        QCOM_HARDWARE_VARIANT := sdm845
    else
        QCOM_HARDWARE_VARIANT := $(TARGET_BOARD_PLATFORM)
    endif
    endif
    endif
    endif
    endif
    endif
    endif

$(call set-device-specific-path,AUDIO,audio,hardware/qcom/audio-caf/$(QCOM_HARDWARE_VARIANT))
$(call set-device-specific-path,DISPLAY,display,hardware/qcom/display-caf/$(QCOM_HARDWARE_VARIANT))
$(call set-device-specific-path,MEDIA,media,hardware/qcom/media-caf/$(QCOM_HARDWARE_VARIANT))

$(call set-device-specific-path,CAMERA,camera,hardware/qcom/camera)
$(call set-device-specific-path,DATA_IPA_CFG_MGR,data-ipa-cfg-mgr,vendor/qcom/opensource/data-ipa-cfg-mgr)
$(call set-device-specific-path,GPS,gps,hardware/qcom/gps)
$(call set-device-specific-path,SENSORS,sensors,hardware/qcom/sensors)
$(call set-device-specific-path,LOC_API,loc-api,vendor/qcom/opensource/location)
$(call set-device-specific-path,DATASERVICES,dataservices,vendor/qcom/opensource/dataservices)
$(call set-device-specific-path,POWER,power,hardware/qcom/power)
$(call set-device-specific-path,THERMAL,thermal,hardware/qcom/thermal)
$(call set-device-specific-path,VR,vr,hardware/qcom/vr)

$(call wlan-set-path-variant,wlan-caf)
$(call bt-vendor-set-path-variant,bt-caf)

PRODUCT_SOONG_NAMESPACES += \
    hardware/qcom/audio-caf/$(QCOM_HARDWARE_VARIANT) \
    hardware/qcom/display-caf/$(QCOM_HARDWARE_VARIANT) \
    hardware/qcom/media-caf/$(QCOM_HARDWARE_VARIANT)

PRODUCT_CFI_INCLUDE_PATHS += \
    hardware/qcom/wlan-caf/qcwcn/wpa_supplicant_8_lib 

else

$(call project-set-path,qcom-audio,hardware/qcom/audio)
$(call project-set-path,qcom-display,hardware/qcom/display/$(TARGET_BOARD_PLATFORM))
$(call project-set-path,qcom-media,hardware/qcom/media)

$(call project-set-path,qcom-camera,hardware/qcom/camera)
$(call project-set-path,qcom-data-ipa-cfg-mgr,hardware/qcom/data/ipacfg-mgr)
$(call project-set-path,qcom-gps,hardware/qcom/gps)
$(call project-set-path,qcom-sensors,hardware/qcom/sensors)
$(call project-set-path,qcom-loc-api,vendor/qcom/opensource/location)
$(call project-set-path,qcom-dataservices,$(TARGET_DEVICE_DIR)/dataservices)

$(call wlan-set-path-variant,wlan)
$(call bt-vendor-set-path-variant,bt)

endif
