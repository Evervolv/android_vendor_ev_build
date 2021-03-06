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

ifeq ($(BOARD_USES_QTI_HARDWARE),true)

$(call set-device-specific-path,AUDIO,audio,hardware/qcom-caf/$(QCOM_HARDWARE_VARIANT)/audio)
$(call set-device-specific-path,DISPLAY,display,hardware/qcom-caf/$(QCOM_HARDWARE_VARIANT)/display)
$(call set-device-specific-path,MEDIA,media,hardware/qcom-caf/$(QCOM_HARDWARE_VARIANT)/media)

$(call set-device-specific-path,BT_VENDOR,bt-vendor,hardware/qcom-caf/bt)
$(call set-device-specific-path,DATA_IPA_CFG_MGR,data-ipa-cfg-mgr,vendor/qcom/opensource/data-ipa-cfg-mgr)
$(call set-device-specific-path,DATASERVICES,dataservices,vendor/qcom/opensource/commonsys/dataservices)
$(call set-device-specific-path,VR,vr,hardware/qcom-caf/vr)
$(call set-device-specific-path,WLAN,wlan,hardware/qcom-caf/wlan)

# Allow a device to opt-out hardset of PRODUCT_SOONG_NAMESPACES
QCOM_SOONG_NAMESPACE ?= hardware/qcom-caf/$(QCOM_HARDWARE_VARIANT)
PRODUCT_SOONG_NAMESPACES += \
    $(call project-path-for,qcom-data-ipa-cfg-mgr) \
    $(call project-path-for,qcom-dataservices) \
    $(QCOM_SOONG_NAMESPACE)

ifeq ($(TARGET_USE_QTI_BT_STACK),true)
PRODUCT_SOONG_NAMESPACES += \
    vendor/qcom/opensource/commonsys/packages/apps/Bluetooth \
    vendor/qcom/opensource/commonsys/system/bt/conf
endif #TARGET_USE_QTI_BT_STACK

# Add display-commonsys-intf to PRODUCT_SOONG_NAMESPACES for QSSI supported platforms
ifneq ($(filter $(QSSI_SUPPORTED_PLATFORMS),$(TARGET_BOARD_PLATFORM)),)
    PRODUCT_SOONG_NAMESPACES += vendor/qcom/opensource/commonsys-intf/display
endif

PRODUCT_CFI_INCLUDE_PATHS += \
    hardware/qcom-caf/wlan/qcwcn/wpa_supplicant_8_lib

endif
