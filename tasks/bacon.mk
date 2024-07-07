# Copyright (C) 2017 Unlegacy-Android
# Copyright (C) 2017,2020 The LineageOS Project
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# -----------------------------------------------------------------
# Bacon update package
ifneq ($(TARGET_OTA_PACKAGE_NAME),)
OTA_PACKAGE_NAME := $(shell echo ${TARGET_OTA_PACKAGE_NAME} | tr [:upper:] [:lower:])
else
OTA_PACKAGE_NAME := $(TARGET_PRODUCT)-ota-$(FILE_NAME_TAG)
endif

ifdef PRODUCT_DEFAULT_DEV_CERTIFICATE
OTA_PACKAGE_NAME := $(patsubst %,%-signed,$(OTA_PACKAGE_NAME))
endif

MD5 := prebuilts/build-tools/path/$(HOST_PREBUILT_TAG)/md5sum

INTERNAL_BACON_PACKAGE := $(PRODUCT_OUT)/$(OTA_PACKAGE_NAME).zip

$(INTERNAL_BACON_PACKAGE): $(INTERNAL_OTA_PACKAGE_TARGET)
	$(hide) ln -f $(INTERNAL_OTA_PACKAGE_TARGET) $@
	$(hide) $(MD5) $@ | sed "s|$(PRODUCT_OUT)/||" > $(INTERNAL_BACON_PACKAGE).md5sum
	@echo "Package Complete: $@" >&2

.PHONY: bacon
bacon: $(DEFAULT_GOAL) $(INTERNAL_BACON_PACKAGE)
