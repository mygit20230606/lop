#!/bin/bash
set -x

cd openwrt

# 下载 vnt 插件
git clone https://github.com/mygit20230606/luci-app-vnt.git package/vnt
# 检出 1.2.16 标签
cd package/vnt && git checkout 1.2.16
# 修改 vnt/Makefile: 把 vnt-dev/vnt 替换为 mygit20230606/vnt_build
sed -i 's#vnt-dev/vnt#mygit20230606/vnt_build#' vnt/Makefile
# 把 1.2.16 替换为 v1.2.16
sed -i 's/1.2.16/v1.2.16/' vnt/Makefile
# 修复日志警告: util -> xml
sed -i 's/util/xml/g' luci-app-vnt/luasrc/model/cbi/vnt.lua

# 修改nfs内核编译报错 这个需要放到feeds更新之后
#sed -i '/-Wno-error=missing-include-dirs/i\		-Wno-error=format-nonliteral \\' feeds/packages/net/nfs-kernel-server/Makefile
