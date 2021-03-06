PATH_OVERRIDE_SOONG := $(shell echo $(TOOLS_PATH_OVERRIDE))

# Add variables that we wish to make available to soong here.
EXPORT_TO_SOONG := \
    KERNEL_ARCH \
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
  SOONG_CONFIG_evervolvVarsPlugin_$(1) := $$(subst ",\",$$($1))
endef

$(foreach v,$(EXPORT_TO_SOONG),$(eval $(call addVar,$(v))))

SOONG_CONFIG_NAMESPACES += evervolvGlobalVars
SOONG_CONFIG_evervolvGlobalVars += \
    additional_gralloc_10_usage_bits \
    disable_postrender_cleanup \
    has_legacy_camera_hal1 \
    has_memfd_backport \
    target_init_vendor_lib \
    target_ld_shim_libs \
    target_process_sdk_version_override \
    target_surfaceflinger_fod_lib

SOONG_CONFIG_NAMESPACES += evervolvQcomVars
SOONG_CONFIG_evervolvQcomVars += \
    device_support_wait_for_qsee \
    device_support_hw_fde \
    device_support_hw_fde_perf \
    legacy_hw_disk_encryption \
    supports_audio_accessory \
    supports_debug_accessory \
    uses_pre_uplink_features_netmgrd \
    uses_qcom_bsp_legacy \
    uses_qti_camera_device

# Only create display_headers_namespace var if dealing with UM platforms to avoid breaking build for all other platforms
ifneq ($(filter $(UM_PLATFORMS),$(TARGET_BOARD_PLATFORM)),)
SOONG_CONFIG_evervolvQcomVars += \
    qcom_display_headers_namespace
endif

# Set default values
TARGET_DISABLE_POSTRENDER_CLEANUP ?= false
TARGET_HAS_LEGACY_CAMERA_HAL1 ?= false
TARGET_HAS_MEMFD_BACKPORT ?= false
TARGET_KEYMASTER_WAIT_FOR_QSEE ?= false
TARGET_HW_DISK_ENCRYPTION ?= false
TARGET_HW_DISK_ENCRYPTION_PERF ?= false
TARGET_LEGACY_HW_DISK_ENCRYPTION ?= false
TARGET_USES_PRE_UPLINK_FEATURES_NETMGRD ?= false
TARGET_USES_QCOM_BSP_LEGACY ?= false
TARGET_USES_QTI_CAMERA_DEVICE ?= false
TARGET_QTI_USB_SUPPORTS_AUDIO_ACCESSORY ?= false
TARGET_QTI_USB_SUPPORTS_DEBUG_ACCESSORY ?= false

# Soong bool variables
SOONG_CONFIG_evervolvGlobalVars_disable_postrender_cleanup := $(TARGET_DISABLE_POSTRENDER_CLEANUP)
SOONG_CONFIG_evervolvGlobalVars_has_legacy_camera_hal1 := $(TARGET_HAS_LEGACY_CAMERA_HAL1)
SOONG_CONFIG_evervolvGlobalVars_has_memfd_backport := $(TARGET_HAS_MEMFD_BACKPORT)
SOONG_CONFIG_evervolvQcomVars_device_support_wait_for_qsee := $(TARGET_KEYMASTER_WAIT_FOR_QSEE)
SOONG_CONFIG_evervolvQcomVars_device_support_hw_fde := $(TARGET_HW_DISK_ENCRYPTION)
SOONG_CONFIG_evervolvQcomVars_device_support_hw_fde_perf := $(TARGET_HW_DISK_ENCRYPTION_PERF)
SOONG_CONFIG_evervolvQcomVars_legacy_hw_disk_encryption := $(TARGET_LEGACY_HW_DISK_ENCRYPTION)
SOONG_CONFIG_evervolvQcomVars_supports_audio_accessory := $(TARGET_QTI_USB_SUPPORTS_AUDIO_ACCESSORY)
SOONG_CONFIG_evervolvQcomVars_supports_debug_accessory := $(TARGET_QTI_USB_SUPPORTS_DEBUG_ACCESSORY)
SOONG_CONFIG_evervolvQcomVars_uses_pre_uplink_features_netmgrd := $(TARGET_USES_PRE_UPLINK_FEATURES_NETMGRD)
SOONG_CONFIG_evervolvQcomVars_uses_qcom_bsp_legacy := $(TARGET_USES_QCOM_BSP_LEGACY)
SOONG_CONFIG_evervolvQcomVars_uses_qti_camera_device := $(TARGET_USES_QTI_CAMERA_DEVICE)

# Set default values
TARGET_ADDITIONAL_GRALLOC_10_USAGE_BITS ?= 0
TARGET_INIT_VENDOR_LIB ?= vendor_init
TARGET_SURFACEFLINGER_FOD_LIB ?= surfaceflinger_fod_lib

# Soong value variables
SOONG_CONFIG_evervolvGlobalVars_additional_gralloc_10_usage_bits := $(TARGET_ADDITIONAL_GRALLOC_10_USAGE_BITS)
SOONG_CONFIG_evervolvGlobalVars_target_init_vendor_lib := $(TARGET_INIT_VENDOR_LIB)
SOONG_CONFIG_evervolvGlobalVars_target_ld_shim_libs := $(subst $(space),:,$(TARGET_LD_SHIM_LIBS))
SOONG_CONFIG_evervolvGlobalVars_target_process_sdk_version_override := $(TARGET_PROCESS_SDK_VERSION_OVERRIDE)
SOONG_CONFIG_evervolvGlobalVars_target_surfaceflinger_fod_lib := $(TARGET_SURFACEFLINGER_FOD_LIB)
ifneq ($(filter $(QSSI_SUPPORTED_PLATFORMS),$(TARGET_BOARD_PLATFORM)),)
SOONG_CONFIG_evervolvQcomVars_qcom_display_headers_namespace := vendor/qcom/opensource/commonsys-intf/display
else
SOONG_CONFIG_evervolvQcomVars_qcom_display_headers_namespace := $(QCOM_SOONG_NAMESPACE)/display
endif
ifneq ($(TARGET_USE_QTI_BT_STACK),true)
PRODUCT_SOONG_NAMESPACES += packages/apps/Bluetooth
endif #TARGET_USE_QTI_BT_STACK
