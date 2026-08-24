#!/bin/bash
# RAX3000M-EMMC 编译初始化脚本（本地版）
# 源码仓库位于 ./immortalwrt-mt798x-6.6
set -e

# 进入源码仓库
cd ../../immortalwrt-mt798x

# 首先记录当前仓库哈希值
SOURCE_HASH=$(git rev-parse HEAD)
echo "SOURCE_HASH=$SOURCE_HASH"
export SOURCE_HASH

# 自定义插件（默认值，用空格分隔）
CUSTOM_PLUGINS='luci-app-dockerman luci-app-ttyd'
export CUSTOM_PLUGINS

# 默认插件
DEFAULT_PLUGINS="luci-theme-argon luci-app-vnt vnt openssh-sftp-server kmod-dm htop curl bash fdisk sshpass hdparm tcpdump-mini lsblk parted rsync kmod-tun iperf3 kmod-fs-ext4 kmod-usb-storage unzip smartmontools"
export DEFAULT_PLUGINS

# 加载默认配置并选择 RAX3000M-EMMC
cp defconfig/mt7981-ax3000.config .config
echo "CONFIG_TARGET_mediatek_mt7981_DEVICE_cmcc_rax3000m-emmc=y" >> .config
echo "# CONFIG_PACKAGE_luci-app-samba4 is not set" >> .config
echo "# CONFIG_PACKAGE_luci-app-filetransfer is not set" >> .config
echo "# CONFIG_PACKAGE_luci-app-usb-printer is not set" >> .config
echo "# CONFIG_PACKAGE_nano is not set" >> .config
sed -i '/CONFIG_PACKAGE_tcpdump=y/d' .config

# 追加上面的插件到 .config
IFS=' ' read -r -a default_plugins <<< "$DEFAULT_PLUGINS"
for plugin in "${default_plugins[@]}"; do
  echo "CONFIG_PACKAGE_${plugin}=y" >> .config
done
echo "已添加默认插件: ${default_plugins[*]}"

IFS=' ' read -r -a plugins <<< "$CUSTOM_PLUGINS"
for plugin in "${plugins[@]}"; do
  echo "CONFIG_PACKAGE_${plugin}=y" >> .config
done
echo "已添加自定义插件: ${plugins[*]}"

cd ../lop/local
# 把参数静态写入发布说明 Releases.txt
cat > "Releases.txt" <<EOF
====================固件信息=======================
本地编译
静态IP:192.168.92.100
自定义插件:$CUSTOM_PLUGINS
默认插件:$DEFAULT_PLUGINS
源码仓库哈希：$SOURCE_HASH
EOF
echo "已生成发布说明: Releases.txt"
