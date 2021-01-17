#!/system/bin/sh
# author=HimekoEx

# 变量定义
ROOT_UID="0"
BASE_PATH=$(cd $(dirname $0) && pwd)
ABI=$(getprop ro.product.cpu.abi)

RIRU_PATH="/data/adb/riru"
RIRU_MODULE_ID="%%%RIRU_MODULE_ID%%%"
RIRU_MODULE_PATH="$RIRU_PATH/modules/$RIRU_MODULE_ID"

# used by /data/adb/riru/util_functions.sh
RIRU_MODULE_API_VERSION=%%%RIRU_MODULE_API_VERSION%%%
RIRU_MODULE_MIN_API_VERSION=%%%RIRU_MODULE_MIN_API_VERSION%%%
RIRU_MODULE_MIN_RIRU_VERSION_NAME="%%%RIRU_MODULE_MIN_RIRU_VERSION_NAME%%%"

print() { echo "$1"; }
abort() { echo "$1" && exit 1; }

# check Root
if [ "$(id -u)" -ne "$ROOT_UID" ]; then
  print "**************************************************"
  print "! 请以Root权限执行本脚本"
  abort "**************************************************"
fi

# check architecture
if [ "$ABI" != "armeabi-v7a" ] && [ "$ABI" != "arm64-v8a" ]; then
  abort "! Unsupported platform: $ABI"
else
  print "- Device platform: $ABI"
fi

# check riru version
if [ ! -f "$RIRU_PATH/api_version" ] && [ ! -f "$RIRU_PATH/api_version.new" ]; then
  print "**************************************************"
  print "! Riru $RIRU_MIN_VERSION_NAME or above is required"
  print "! Please install Riru-Shell from https://github.com/HimekoEx/Riru-Shell"
  abort "**************************************************"
fi
local_api_version=$(cat "$RIRU_PATH/api_version") || local_api_version=0
[ "$local_api_version" -eq "$local_api_version" ] || local_api_version=0
print "- Riru API version: $local_api_version"
if [ "$local_api_version" -lt $RIRU_MODULE_MIN_API_VERSION ]; then
  print "**************************************************"
  print "! Riru $RIRU_MIN_VERSION_NAME or above is required"
  print "! Please upgrade Riru-Shell from https://github.com/HimekoEx/Riru-Shell"
  abort "**************************************************"
fi

# Riru files
print "- Extracting extra files"
[ -d "$RIRU_MODULE_PATH" ] || mkdir -p "$RIRU_MODULE_PATH" || abort "! Can't create $RIRU_MODULE_PATH"
chmod 700 "$RIRU_MODULE_PATH"

# Copy module.prop.new
print "- Copy module.prop.new"
rm -f "$RIRU_MODULE_PATH/module.prop.new"
cp -f "$BASE_PATH/riru/module.prop.new" "$RIRU_MODULE_PATH"
chmod 600 "$RIRU_MODULE_PATH/module.prop.new"

# Rename module.prop.new
print "- Rename module.prop.new"
rm -rf "$RIRU_MODULE_PATH/module.prop"
mv "$RIRU_MODULE_PATH/module.prop.new" "$RIRU_MODULE_PATH/module.prop"

# Copy module lib
sys32_PATH="/system/lib/libriru_$RIRU_MODULE_ID.so"
sys64_PATH="/system/lib64/libriru_$RIRU_MODULE_ID.so"
if [ ! -f "$sys32_PATH" ]; then
  print "- Copy libriru_$RIRU_MODULE_ID.so"
  cp -f "$BASE_PATH/$sys32_PATH" "$sys32_PATH" && chmod 777 "$sys32_PATH"
  [ "$ABI" != "armeabi-v7a" ] && cp -f "$BASE_PATH/$sys64_PATH" "$sys64_PATH" && chmod 777 "$sys64_PATH"
fi
