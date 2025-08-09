#!/bin/bash

# SPDX-FileCopyrightText: 2024 The LineageOS Project
# SPDX-License-Identifier: Apache-2.0


build_top=../../../../../..

set -u
bash <(sed "s/2048/${2:-2048}/;/Enter password/,+1d" ${build_top}/development/tools/make_key) \
    $1 \
    '/C=US/ST=Illinois/L=Chicago/O=Evervolv/OU=Evervolv/CN=Evervolv/emailAddress=admin@evervolv.com'
