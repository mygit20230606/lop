#!/bin/bash
# 上传固件到 GitHub Releases（本地版）
# 依赖: gh CLI (https://cli.github.com/) 并已登录 (gh auth login)
set -e

# 进入脚本所在目录（lop/local），后面的相对路径都以它为准
cd "$(dirname "$0")"

# 检查 lop 仓库是否有未保存的更改
if [ -n "$(git -C .. status --porcelain)" ]; then
  echo "=============================================="
  echo "检测到 lop 仓库存在未保存的更改，请先保存/提交后再运行："
  git -C .. status --short
  echo "=============================================="
  exit 1
fi

# 先推送 lop 仓库到远程，确保远程为最新
git -C .. push origin HEAD

# 复制 .config 到编译输出目录
cp ../../immortalwrt-mt798x/.config ../../immortalwrt-mt798x/bin/targets/mediatek/mt7981/

# 发布信息（发布说明由 RAX3000M-EMMCinit.sh 生成到 Releases.txt）
TAG="$(date +'%Y%m%d%H%M')-rax3000m-hanwckf"

# 进入输出目录后上传固件到 Releases
cd ../../immortalwrt-mt798x/bin/targets/mediatek/mt7981/
gh release create "$TAG" \
  -R mygit20230606/lop \
  .config \
  config.buildinfo \
  feeds.buildinfo \
  immortalwrt-mediatek-mt7981-cmcc_rax3000m-emmc-squashfs-sysupgrade.bin \
  --title "$TAG" \
  --notes-file ../../../../../lop/local/Releases.txt

echo "已上传固件到 Release: mygit20230606/lop @ $TAG"
