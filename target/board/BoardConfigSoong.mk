PATH_OVERRIDE_SOONG := $(shell echo $(TOOLS_PATH_OVERRIDE))

# Add variables that we wish to make available to soong here.
EXPORT_TO_SOONG := \
    KERNEL_ARCH \
    KERNEL_BUILD_OUT_PREFIX \
    KERNEL_CROSS_COMPILE \
    KERNEL_MAKE_CMD \
    KERNEL_MAKE_FLAGS \
    PATH_OVERRIDE_SOONG \
    TARGET_KERNEL_CONFIG \
    TARGET_KERNEL_SOURCE

# Setup SOONG_CONFIG_* vars to export the vars listed above.
# Documentation here:
# https://github.com/Evervolv/android_build_soong/commit/8328367c44085b948c003116c0ed74a047237a69

SOONG_CONFIG_NAMESPACES += evervolvVarsPlugin

SOONG_CONFIG_evervolvVarsPlugin :=

define addVar
  SOONG_CONFIG_evervolvVarsPlugin += $(1)
  SOONG_CONFIG_evervolvVarsPlugin_$(1) := $($1)
endef

$(foreach v,$(EXPORT_TO_SOONG),$(eval $(call addVar,$(v))))

SOONG_CONFIG_NAMESPACES += evervolvGlobalVars
SOONG_CONFIG_evervolvGlobalVars += \
    additional_gralloc_10_usage_bits \
    bootloader_message_offset \
    disable_postrender_cleanup \
    has_legacy_camera_hal1 \
    has_memfd_backport \
    target_health_charging_control_charging_enabled \
    target_health_charging_control_charging_disabled \
    target_health_charging_control_deadline_path \
    target_health_charging_control_supports_bypass \
    target_health_charging_control_supports_deadline \
    target_health_charging_control_supports_limit \
    target_health_charging_control_supports_toggle \
    target_init_vendor_lib \
    target_ld_shim_libs \
    target_power_libperfmgr_mode_extension_lib \
    target_powershare_path \
    target_powershare_enabled \
    target_powershare_disabled \
    target_process_sdk_version_override \
    target_surfaceflinger_udfps_lib \
    target_trust_usb_control_path \
    target_trust_usb_control_enable \
    target_trust_usb_control_disable \
    uses_legacy_contructor_map

ifneq ($(TARGET_HEALTH_CHARGING_CONTROL_CHARGING_PATH),)
SOONG_CONFIG_evervolvGlobalVars += \
    target_health_charging_control_charging_path
endif

SOONG_CONFIG_NAMESPACES += evervolvQcomVars
SOONG_CONFIG_evervolvQcomVars += \
    qti_vibrator_effect_lib \
    qti_vibrator_use_effect_stream \
    supports_audio_accessory \
    supports_debug_accessory \
    uses_pre_uplink_features_netmgrd \
    uses_qcom_bsp_legacy

# Set default values
TARGET_DISABLE_POSTRENDER_CLEANUP ?= false
TARGET_HAS_LEGACY_CAMERA_HAL1 ?= false
TARGET_HAS_MEMFD_BACKPORT ?= false
TARGET_HEALTH_CHARGING_CONTROL_CHARGING_ENABLED ?= 1
TARGET_HEALTH_CHARGING_CONTROL_CHARGING_DISABLED ?= 0
TARGET_HEALTH_CHARGING_CONTROL_SUPPORTS_BYPASS ?= true
TARGET_HEALTH_CHARGING_CONTROL_SUPPORTS_DEADLINE ?= false
TARGET_HEALTH_CHARGING_CONTROL_SUPPORTS_LIMIT ?= false
TARGET_HEALTH_CHARGING_CONTROL_SUPPORTS_TOGGLE ?= true
TARGET_KEYMASTER_WAIT_FOR_QSEE ?= false
TARGET_USES_LEGACY_HIDL_CONSTRUCTOR ?= $(if $(call math_lt,$(PRODUCT_SHIPPING_API_LEVEL),33),true))
TARGET_USES_PRE_UPLINK_FEATURES_NETMGRD ?= false
TARGET_USES_QCOM_BSP_LEGACY ?= false
TARGET_QTI_USB_SUPPORTS_AUDIO_ACCESSORY ?= false
TARGET_QTI_USB_SUPPORTS_DEBUG_ACCESSORY ?= false

# Soong bool variables
SOONG_CONFIG_evervolvGlobalVars_disable_postrender_cleanup := $(TARGET_DISABLE_POSTRENDER_CLEANUP)
SOONG_CONFIG_evervolvGlobalVars_has_legacy_camera_hal1 := $(TARGET_HAS_LEGACY_CAMERA_HAL1)
SOONG_CONFIG_evervolvGlobalVars_has_memfd_backport := $(TARGET_HAS_MEMFD_BACKPORT)
ifneq ($(TARGET_HEALTH_CHARGING_CONTROL_CHARGING_PATH),)
SOONG_CONFIG_evervolvGlobalVars_target_health_charging_control_charging_path := $(TARGET_HEALTH_CHARGING_CONTROL_CHARGING_PATH)
endif
SOONG_CONFIG_evervolvGlobalVars_target_health_charging_control_charging_enabled := $(TARGET_HEALTH_CHARGING_CONTROL_CHARGING_ENABLED)
SOONG_CONFIG_evervolvGlobalVars_target_health_charging_control_charging_disabled := $(TARGET_HEALTH_CHARGING_CONTROL_CHARGING_DISABLED)
SOONG_CONFIG_evervolvGlobalVars_target_health_charging_control_deadline_path := $(TARGET_HEALTH_CHARGING_CONTROL_DEADLINE_PATH)
SOONG_CONFIG_evervolvGlobalVars_target_health_charging_control_supports_bypass := $(TARGET_HEALTH_CHARGING_CONTROL_SUPPORTS_BYPASS)
SOONG_CONFIG_evervolvGlobalVars_target_health_charging_control_supports_deadline := $(TARGET_HEALTH_CHARGING_CONTROL_SUPPORTS_DEADLINE)
SOONG_CONFIG_evervolvGlobalVars_target_health_charging_control_supports_limit := $(TARGET_HEALTH_CHARGING_CONTROL_SUPPORTS_LIMIT)
SOONG_CONFIG_evervolvGlobalVars_target_health_charging_control_supports_toggle := $(TARGET_HEALTH_CHARGING_CONTROL_SUPPORTS_TOGGLE)
SOONG_CONFIG_evervolvGlobalVars_uses_legacy_contructor_map := $(TARGET_USES_LEGACY_HIDL_CONSTRUCTOR)
SOONG_CONFIG_evervolvQcomVars_qti_vibrator_use_effect_stream := $(TARGET_QTI_VIBRATOR_USE_EFFECT_STREAM)
SOONG_CONFIG_evervolvQcomVars_supports_audio_accessory := $(TARGET_QTI_USB_SUPPORTS_AUDIO_ACCESSORY)
SOONG_CONFIG_evervolvQcomVars_supports_debug_accessory := $(TARGET_QTI_USB_SUPPORTS_DEBUG_ACCESSORY)
SOONG_CONFIG_evervolvQcomVars_uses_pre_uplink_features_netmgrd := $(TARGET_USES_PRE_UPLINK_FEATURES_NETMGRD)
SOONG_CONFIG_evervolvQcomVars_uses_qcom_bsp_legacy := $(TARGET_USES_QCOM_BSP_LEGACY)

# Set default values
BOOTLOADER_MESSAGE_OFFSET ?= 0
TARGET_ADDITIONAL_GRALLOC_10_USAGE_BITS ?= 0
TARGET_INIT_VENDOR_LIB ?= vendor_init
TARGET_POWER_LIBPERFMGR_MODE_EXTENSION_LIB ?= libperfmgr-ext
TARGET_POWERSHARE_ENABLED ?= 1
TARGET_POWERSHARE_DISABLED ?= 0
TARGET_QTI_VIBRATOR_EFFECT_LIB ?= libqtivibratoreffect
TARGET_SURFACEFLINGER_UDFPS_LIB ?= surfaceflinger_udfps_lib
TARGET_TRUST_USB_CONTROL_PATH ?= /proc/sys/kernel/deny_new_usb
TARGET_TRUST_USB_CONTROL_ENABLE ?= 1
TARGET_TRUST_USB_CONTROL_DISABLE ?= 0

# Soong value variables
SOONG_CONFIG_evervolvGlobalVars_additional_gralloc_10_usage_bits := $(TARGET_ADDITIONAL_GRALLOC_10_USAGE_BITS)
SOONG_CONFIG_evervolvGlobalVars_bootloader_message_offset := $(BOOTLOADER_MESSAGE_OFFSET)
SOONG_CONFIG_evervolvGlobalVars_target_init_vendor_lib := $(TARGET_INIT_VENDOR_LIB)
SOONG_CONFIG_evervolvGlobalVars_target_ld_shim_libs := $(subst $(space),:,$(TARGET_LD_SHIM_LIBS))
SOONG_CONFIG_evervolvGlobalVars_target_power_libperfmgr_mode_extension_lib := $(TARGET_POWER_LIBPERFMGR_MODE_EXTENSION_LIB)
SOONG_CONFIG_evervolvGlobalVars_target_powershare_path := $(TARGET_POWERSHARE_PATH)
SOONG_CONFIG_evervolvGlobalVars_target_powershare_enabled := $(TARGET_POWERSHARE_ENABLED)
SOONG_CONFIG_evervolvGlobalVars_target_powershare_disabled := $(TARGET_POWERSHARE_DISABLED)
SOONG_CONFIG_evervolvGlobalVars_target_process_sdk_version_override := $(TARGET_PROCESS_SDK_VERSION_OVERRIDE)
SOONG_CONFIG_evervolvGlobalVars_target_surfaceflinger_udfps_lib := $(TARGET_SURFACEFLINGER_UDFPS_LIB)
SOONG_CONFIG_evervolvGlobalVars_target_trust_usb_control_path := $(TARGET_TRUST_USB_CONTROL_PATH)
SOONG_CONFIG_evervolvGlobalVars_target_trust_usb_control_enable := $(TARGET_TRUST_USB_CONTROL_ENABLE)
SOONG_CONFIG_evervolvGlobalVars_target_trust_usb_control_disable := $(TARGET_TRUST_USB_CONTROL_DISABLE)
SOONG_CONFIG_evervolvQcomVars_qti_vibrator_effect_lib := $(TARGET_QTI_VIBRATOR_EFFECT_LIB)
