# Target-specific configuration

# Set device-specific HALs into project pathmap
define set-device-specific-path
$(if $(USE_DEVICE_SPECIFIC_$(1)), \
    $(if $(DEVICE_SPECIFIC_$(1)_PATH), \
        $(eval path := $(DEVICE_SPECIFIC_$(1)_PATH)), \
        $(eval path := $(TARGET_DEVICE_DIR)/$(2))), \
    $(eval path := $(3))) \
$(call project-set-path,qcom-$(2),$(strip $(path)))
endef

QC_OPEN_PATH := vendor/qcom/opensource

ifeq ($(call is-board-platform-in-list, $(QCOM_BOARD_PLATFORMS)),true)

ifneq ($(filter $(A_FAMILY),$(TARGET_BOARD_PLATFORM)),)
    QCOM_HARDWARE_VARIANT ?= msm8960
else ifneq ($(filter $(B_FAMILY),$(TARGET_BOARD_PLATFORM)),)
    QCOM_HARDWARE_VARIANT ?= msm8974
else ifneq ($(filter $(B64_FAMILY),$(TARGET_BOARD_PLATFORM)),)
    QCOM_HARDWARE_VARIANT ?= msm8994
else ifneq ($(filter $(BR_FAMILY),$(TARGET_BOARD_PLATFORM)),)
    QCOM_HARDWARE_VARIANT ?= msm8916
else ifneq ($(filter $(UM_3_18_FAMILY),$(TARGET_BOARD_PLATFORM)),)
    QCOM_HARDWARE_VARIANT ?= msm8996
else ifneq ($(filter $(UM_4_4_FAMILY),$(TARGET_BOARD_PLATFORM)),)
    QCOM_HARDWARE_VARIANT ?= msm8998
else ifneq ($(filter $(UM_4_9_FAMILY),$(TARGET_BOARD_PLATFORM)),)
    QCOM_HARDWARE_VARIANT ?= sdm845
else ifneq ($(filter $(UM_4_14_FAMILY),$(TARGET_BOARD_PLATFORM)),)
    QCOM_HARDWARE_VARIANT ?= sm8150
else ifneq ($(filter $(UM_4_19_FAMILY),$(TARGET_BOARD_PLATFORM)),)
    QCOM_HARDWARE_VARIANT ?= sm8250
else ifneq ($(filter $(UM_5_4_FAMILY),$(TARGET_BOARD_PLATFORM)),)
    QCOM_HARDWARE_VARIANT ?= sm8350
else ifneq ($(filter $(UM_5_10_FAMILY),$(TARGET_BOARD_PLATFORM)),)
    QCOM_HARDWARE_VARIANT ?= sm8450
else ifneq ($(filter $(UM_5_15_FAMILY),$(TARGET_BOARD_PLATFORM)),)
    QCOM_HARDWARE_VARIANT := sm8550
endif
QCOM_HARDWARE_VARIANT ?= $(TARGET_BOARD_PLATFORM)

# Allow a device to opt-out hardset of PRODUCT_SOONG_NAMESPACES
QCOM_SOONG_NAMESPACE ?= hardware/qcom-caf/$(QCOM_HARDWARE_VARIANT)

$(call set-device-specific-path,AUDIO,audio,$(QCOM_SOONG_NAMESPACE)/audio)
$(call set-device-specific-path,DISPLAY,display,$(QCOM_SOONG_NAMESPACE)/display)
$(call set-device-specific-path,MEDIA,media,$(QCOM_SOONG_NAMESPACE)/media)
$(call set-device-specific-path,BT_VENDOR,bt-vendor,hardware/qcom-caf/bt)
ifneq ($(filter $(LEGACY_QCOM_PLATFORMS),$(TARGET_BOARD_PLATFORM)),)
$(call set-device-specific-path,DATA_IPA_CFG_MGR,data-ipa-cfg-mgr,$(QC_OPEN_PATH)/data-ipa-cfg-mgr-legacy-um)
else
$(call set-device-specific-path,DATA_IPA_CFG_MGR,data-ipa-cfg-mgr,$(QC_OPEN_PATH)/data-ipa-cfg-mgr)
endif
$(call set-device-specific-path,DATASERVICES,dataservices,$(QC_OPEN_PATH)/dataservices)
$(call set-device-specific-path,VR,vr,hardware/qcom-caf/vr)
$(call set-device-specific-path,WLAN,wlan,hardware/qcom-caf/wlan)

PRODUCT_SOONG_NAMESPACES += \
    $(call project-path-for,qcom-data-ipa-cfg-mgr) \
    $(call project-path-for,qcom-dataservices) \
    $(QCOM_SOONG_NAMESPACE)

# Add display-commonsys-intf to PRODUCT_SOONG_NAMESPACES for QSSI supported platforms
ifneq ($(filter $(QSSI_SUPPORTED_PLATFORMS),$(TARGET_BOARD_PLATFORM)),)
PRODUCT_SOONG_NAMESPACES += \
    $(QC_OPEN_PATH)/commonsys-intf/display

ifeq ($(filter $(UM_5_10_FAMILY) $(UM_5_15_FAMILY),$(TARGET_BOARD_PLATFORM)),)
PRODUCT_SOONG_NAMESPACES += \
    $(QC_OPEN_PATH)/commonsys/display
endif

endif

PRODUCT_CFI_INCLUDE_PATHS += \
    hardware/qcom-caf/wlan/qcwcn/wpa_supplicant_8_lib

endif
