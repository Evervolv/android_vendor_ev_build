# Build information
PRODUCT_BUILD ?= userbuild
ifneq ($(filter nightly testing release,$(PRODUCT_BUILD)),)
ADDITIONAL_SYSTEM_PROPERTIES += \
    ro.evervolv.releasetype=$(PRODUCT_BUILD)
endif

ADDITIONAL_SYSTEM_PROPERTIES += \
    ro.evervolv.device=$(TARGET_DEVICE) \
    ro.evervolv.version=$(PLATFORM_VERSION)

# SDK
EV_PLATFORM_SDK_VERSION ?= 4
EV_PLATFORM_REV ?= 0

ADDITIONAL_SYSTEM_PROPERTIES += \
    ro.evervolv.build.version.plat.sdk=$(EV_PLATFORM_SDK_VERSION) \
    ro.evervolv.build.version.plat.rev=$(EV_PLATFORM_REV)

# Package name
ifneq ($(SKIP_VERBOSE_DATE),true)
TARGET_OTA_PACKAGE_NAME := $(TARGET_PRODUCT)-$(PLATFORM_VERSION)-$(PRODUCT_BUILD)-$(BUILD_DATETIME_FROM_FILE)
endif
TARGET_OTA_PACKAGE_NAME ?= $(TARGET_PRODUCT)-$(PLATFORM_VERSION)-$(PRODUCT_BUILD)
