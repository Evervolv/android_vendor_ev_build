# Copyright (C) 2018-2022 The LineageOS Project
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
#
#
# Kernel build configuration variables
# ====================================
#
# These config vars are usually set in BoardConfig.mk:
#
#   TARGET_KERNEL_SOURCE               = Kernel source dir, optional, defaults
#                                          to kernel/$(TARGET_DEVICE_DIR)
#   TARGET_KERNEL_ARCH                 = Kernel Arch
#   TARGET_KERNEL_CROSS_COMPILE_PREFIX = Compiler prefix (e.g. arm-eabi-)
#                                          defaults to arm-linux-androidkernel- for arm
#                                                      aarch64-linux-android- for arm64
#                                                      x86_64-linux-android- for x86
#
#   TARGET_KERNEL_LLVM_BINUTILS        = Use LLVM's substitutes for GNU binutils, defaults to false
#
#   TARGET_KERNEL_LEGACY_COMPILE       = Use legacy options for compilation
#                                          enabled defaults to r416183b for LLVM, GCC available
#                                          disabled defaults to AOSP default (r450784d) for LLVM, GCC unavailable
#
#   TARGET_KERNEL_CLANG_VERSION        = Clang prebuilts version, optional
#
#   TARGET_KERNEL_CLANG_PATH           = Clang prebuilts path, optional
#
#   TARGET_KERNEL_VERSION              = Reported kernel version in top level kernel
#                                        makefile. Can be overriden in device trees
#                                        in the event of prebuilt kernel.
#
#   TARGET_KERNEL_DTBO_PREFIX          = Override path prefix of TARGET_KERNEL_DTBO.
#                                        Defaults to empty
#   TARGET_KERNEL_DTBO                 = Name of the kernel Makefile target that
#                                        generates dtbo.img. Defaults to dtbo.img
#   TARGET_KERNEL_DTB                  = Name of the kernel Makefile target that
#                                        generates the *.dtb targets. Defaults to dtbs
#
#   TARGET_KERNEL_EXT_MODULE_ROOT      = Optional, the external modules root directory
#                                          Defaults to empty
#   TARGET_KERNEL_EXT_MODULES          = Optional, the external modules we are
#                                          building. Defaults to empty
#
#   TARGET_KERNEL_EXCLUDE_HOST_HEADERS = Exclude host headers, defaults to false
#
#   KERNEL_TOOLCHAIN_PREFIX            = Overrides TARGET_KERNEL_CROSS_COMPILE_PREFIX,
#                                          Set this var in shell to override
#                                          toolchain specified in BoardConfig.mk
#   KERNEL_TOOLCHAIN                   = Path to toolchain, if unset, assumes
#                                          TARGET_KERNEL_CROSS_COMPILE_PREFIX
#                                          is in PATH
#
#   KERNEL_CC                          = The C Compiler used. This is automatically set based
#                                          on whether the clang version is set, optional.
#
#   KERNEL_CLANG_TRIPLE                = Target triple for clang (e.g. aarch64-linux-gnu-)
#                                          defaults to arm-linux-gnu- for arm
#                                                      aarch64-linux-gnu- for arm64
#                                                      x86_64-linux-gnu- for x86
#   USE_CCACHE                         = Enable ccache (global Android flag)

BUILD_TOP := $(abspath .)

# Set the out dir for the kernel's O= arg
# This needs to be an absolute path, so only set this if the standard out dir isn't used
OUT_DIR_PREFIX := $(shell echo $(OUT_DIR) | sed -e 's|/target/.*$$||g')
KERNEL_BUILD_OUT_PREFIX :=
ifeq ($(OUT_DIR_PREFIX),out)
KERNEL_BUILD_OUT_PREFIX := $(BUILD_TOP)/
endif

# Set the default kernel source
TARGET_AUTO_KDIR := $(shell echo $(TARGET_DEVICE_DIR) | sed -e 's/^device/kernel/g')
TARGET_KERNEL_SOURCE ?= $(TARGET_AUTO_KDIR)
ifneq ($(TARGET_PREBUILT_KERNEL),)
TARGET_KERNEL_SOURCE :=
endif

# Kernel version
KERNEL_VERSION := $(shell grep -s "^VERSION = " $(TARGET_KERNEL_SOURCE)/Makefile | awk '{ print $$3 }')
KERNEL_PATCHLEVEL := $(shell grep -s "^PATCHLEVEL = " $(TARGET_KERNEL_SOURCE)/Makefile | awk '{ print $$3 }')
KERNEL_SUBLEVEL := $(shell grep -s "^SUBLEVEL = " $(TARGET_KERNEL_SOURCE)/Makefile | awk '{ print $$3 }')
TARGET_KERNEL_VERSION ?= $(shell echo $(KERNEL_VERSION)"."$(KERNEL_PATCHLEVEL))

# Architecture
TARGET_KERNEL_ARCH := $(strip $(TARGET_KERNEL_ARCH))
ifeq ($(TARGET_KERNEL_ARCH),)
KERNEL_ARCH := $(TARGET_ARCH)
else
KERNEL_ARCH := $(TARGET_KERNEL_ARCH)
endif

# Device tree
TARGET_KERNEL_DTB ?= dtbs

# Device tree overlay
ifeq ($(filter true, $(TARGET_NEEDS_DTBOIMAGE) $(BOARD_KERNEL_SEPARATED_DTBO)),true)
TARGET_KERNEL_DTBO_PREFIX ?=
TARGET_KERNEL_DTBO ?= dtbo.img
BOARD_PREBUILT_DTBOIMAGE ?= $(TARGET_OUT_INTERMEDIATES)/DTBO_OBJ/arch/$(KERNEL_ARCH)/boot/$(TARGET_KERNEL_DTBO_PREFIX)$(TARGET_KERNEL_DTBO)
endif

# External modules
TARGET_KERNEL_EXT_MODULE_ROOT ?=
TARGET_KERNEL_EXT_MODULES ?=

# Ccache
ifneq ($(USE_CCACHE),)
    ifneq ($(CCACHE_EXEC),)
        # Android 10+ deprecates use of a build ccache. Only system installed ones are now allowed
        CCACHE_BIN := $(CCACHE_EXEC)
    endif
endif

# Compilation tools
ifneq ($(filter 5.10 5.15, $(TARGET_KERNEL_VERSION)),)
    TARGET_KERNEL_LEGACY_COMPILE := false
endif
TARGET_KERNEL_LEGACY_COMPILE ?= true


KERNEL_CROSS_COMPILE := 

ifeq ($(TARGET_KERNEL_LEGACY_COMPILE),true)

# GCC
GCC_PREBUILTS := $(BUILD_TOP)/prebuilts/gcc/$(HOST_PREBUILT_TAG)

# arm64 toolchain
KERNEL_TOOLCHAIN_arm64 := $(GCC_PREBUILTS)/aarch64/aarch64-linux-android-4.9/bin
KERNEL_TOOLCHAIN_PREFIX_arm64 := aarch64-linux-android-
# arm toolchain
KERNEL_TOOLCHAIN_arm := $(GCC_PREBUILTS)/arm/arm-linux-androideabi-4.9/bin
KERNEL_TOOLCHAIN_PREFIX_arm := arm-linux-androidkernel-
# x86 toolchain
KERNEL_TOOLCHAIN_x86 := $(GCC_PREBUILTS)/x86/x86_64-linux-android-4.9/bin
KERNEL_TOOLCHAIN_PREFIX_x86 := x86_64-linux-android-

KERNEL_TOOLCHAIN ?= $(KERNEL_TOOLCHAIN_$(KERNEL_ARCH))
KERNEL_TOOLCHAIN_PREFIX ?= $(KERNEL_TOOLCHAIN_PREFIX_$(KERNEL_ARCH))
KERNEL_TOOLCHAIN_PATH ?= $(KERNEL_TOOLCHAIN)/$(KERNEL_TOOLCHAIN_PREFIX)

KERNEL_CROSS_COMPILE += CROSS_COMPILE="$(KERNEL_TOOLCHAIN_PATH)"
# Needed for CONFIG_COMPAT_VDSO, safe to set for all arm64 builds
ifeq ($(KERNEL_ARCH),arm64)
   KERNEL_CROSS_COMPILE += CROSS_COMPILE_ARM32="$(KERNEL_TOOLCHAIN_arm)/$(KERNEL_TOOLCHAIN_PREFIX_arm)"
   KERNEL_CROSS_COMPILE += CROSS_COMPILE_COMPAT="$(KERNEL_TOOLCHAIN_arm)/$(KERNEL_TOOLCHAIN_PREFIX_arm)"
endif

endif

# LLVM
ifneq ($(filter 5.10 5.15, $(TARGET_KERNEL_VERSION)),)
TARGET_KERNEL_CLANG_VERSION ?= r450784d
else
TARGET_KERNEL_CLANG_VERSION ?= r416183b
endif

ifneq ($(wildcard $(BUILD_TOP)/prebuilts/evervolv-tools/$(HOST_PREBUILT_TAG)/clang-$(TARGET_KERNEL_CLANG_VERSION)/bin/clang),)
TARGET_KERNEL_CLANG_PATH ?= $(BUILD_TOP)/prebuilts/evervolv-tools/$(HOST_PREBUILT_TAG)/clang-$(TARGET_KERNEL_CLANG_VERSION)
else
TARGET_KERNEL_CLANG_PATH ?= $(BUILD_TOP)/prebuilts/clang/host/$(HOST_PREBUILT_TAG)/clang-$(TARGET_KERNEL_CLANG_VERSION)
endif

ifeq ($(TARGET_KERNEL_LEGACY_COMPILE),true)

ifeq ($(KERNEL_ARCH),arm64)
    KERNEL_CLANG_TRIPLE ?= CLANG_TRIPLE=aarch64-linux-gnu-
else ifeq ($(KERNEL_ARCH),arm)
    KERNEL_CLANG_TRIPLE ?= CLANG_TRIPLE=arm-linux-gnu-
else ifeq ($(KERNEL_ARCH),x86)
    KERNEL_CLANG_TRIPLE ?= CLANG_TRIPLE=x86_64-linux-gnu-
endif

KERNEL_CROSS_COMPILE += $(KERNEL_CLANG_TRIPLE)

endif

ifeq ($(KERNEL_CC),)
    KERNEL_CC := CC="$(CCACHE_BIN) clang"
endif

KERNEL_CROSS_COMPILE += $(KERNEL_CC)

# Set paths for prebuilt tools
SYSTEM_TOOLS := $(BUILD_TOP)/prebuilts/build-tools
EXTRA_TOOLS := $(BUILD_TOP)/prebuilts/evervolv-tools

KERNEL_TOOLS := $(EXTRA_TOOLS)/$(HOST_PREBUILT_TAG)/bin:$(TARGET_KERNEL_CLANG_PATH)/bin
KERNEL_LD_LIBRARY := $(EXTRA_TOOLS)/$(HOST_PREBUILT_TAG)/lib:$(TARGET_KERNEL_CLANG_PATH)/lib64

TOOLS_PATH_OVERRIDE := \
    BISON_PKGDATADIR=$(SYSTEM_TOOLS)/common/bison \
    PERL5LIB=$(EXTRA_TOOLS)/common/perl-base \
    PATH=$(KERNEL_TOOLS):$$PATH \
    LD_LIBRARY_PATH=$(KERNEL_LD_LIBRARY):$$LD_LIBRARY_PATH

ifeq ($(TARGET_KERNEL_LEGACY_COMPILE),true)

TOOLS_PATH_OVERRIDE += \
    PATH=$(KERNEL_TOOLCHAIN_$(KERNEL_ARCH)):$$PATH

ifeq ($(KERNEL_ARCH),arm64)
TOOLS_PATH_OVERRIDE += \
    PATH=$(KERNEL_TOOLCHAIN_arm):$$PATH
endif

endif

# Set use the full path to the make command
KERNEL_MAKE_CMD := $(SYSTEM_TOOLS)/$(HOST_PREBUILT_TAG)/bin/make

# Clear this first to prevent accidental poisoning from env
KERNEL_MAKE_FLAGS :=

# Since Linux 4.16, flex and bison are required
KERNEL_MAKE_FLAGS += \
    LEX=$(SYSTEM_TOOLS)/$(HOST_PREBUILT_TAG)/bin/flex \
    YACC=$(SYSTEM_TOOLS)/$(HOST_PREBUILT_TAG)/bin/bison \
    M4=$(SYSTEM_TOOLS)/$(HOST_PREBUILT_TAG)/bin/m4

ifeq ($(TARGET_KERNEL_LEGACY_COMPILE),true)

KERNEL_MAKE_FLAGS += \
    HOSTCC=$(TARGET_KERNEL_CLANG_PATH)/bin/clang \
    HOSTCXX=$(TARGET_KERNEL_CLANG_PATH)/bin/clang++

endif

# Add back threads, ninja cuts this to $(nproc)/2
KERNEL_MAKE_FLAGS += -j$(shell $(EXTRA_TOOLS)/$(HOST_PREBUILT_TAG)/bin/nproc --all)

ifeq ($(TARGET_KERNEL_LEGACY_COMPILE),true)

ifeq ($(HOST_OS),darwin)
  KERNEL_MAKE_FLAGS += HOSTCFLAGS="-I$(BUILD_TOP)/external/elfutils/libelf -I/usr/local/opt/openssl/include" HOSTLDFLAGS="-L/usr/local/opt/openssl/lib -fuse-ld=lld"
else
  KERNEL_MAKE_FLAGS += HOSTLDFLAGS="-L/usr/lib/x86_64-linux-gnu -L/usr/lib64 -fuse-ld=lld"
  ifneq ($(TARGET_KERNEL_EXCLUDE_HOST_HEADERS),true)
    KERNEL_MAKE_FLAGS += CPATH="/usr/include:/usr/include/x86_64-linux-gnu"
  endif
endif

else

KERNEL_MAKE_FLAGS += HOSTCFLAGS="--sysroot=$(BUILD_TOP)/prebuilts/gcc/linux-x86/host/x86_64-linux-glibc2.17-4.8/sysroot -I$(BUILD_TOP)/prebuilts/kernel-build-tools/linux-x86/include"
KERNEL_MAKE_FLAGS += HOSTLDFLAGS="--sysroot=$(BUILD_TOP)/prebuilts/gcc/linux-x86/host/x86_64-linux-glibc2.17-4.8/sysroot -Wl,-rpath,$(BUILD_TOP)/prebuilts/kernel-build-tools/linux-x86/lib64 -L $(BUILD_TOP)/prebuilts/kernel-build-tools/linux-x86/lib64 -fuse-ld=lld --rtlib=compiler-rt"

endif

# Use LLVM's substitutes for GNU binutils if compatible kernel version.
ifeq ($(TARGET_KERNEL_LEGACY_COMPILE),false)
TARGET_KERNEL_LLVM_BINUTILS := true
endif
TARGET_KERNEL_LLVM_BINUTILS ?= false

ifeq ($(TARGET_KERNEL_LLVM_BINUTILS),true)
    KERNEL_MAKE_FLAGS += LLVM=1 LLVM_IAS=1
    ifeq ($(TARGET_KERNEL_LEGACY_COMPILE),true)
        KERNEL_MAKE_FLAGS += AR=$(TARGET_KERNEL_CLANG_PATH)/bin/llvm-ar
        KERNEL_MAKE_FLAGS += LD=$(TARGET_KERNEL_CLANG_PATH)/bin/ld.lld
    endif
endif
