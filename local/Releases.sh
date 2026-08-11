#!/bin/bash
# 上传固件到 GitHub Releases（本地版）
# 依赖: gh CLI (https://cli.github.com/) 并已登录 (gh auth login)
set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

# 上传目标仓库（lop 自身仓库 https://github.com/mygit20230606/lop）
LOP_REPO="mygit20230606/lop"

# 检查 lop 仓库是否有未保存的更改
LOP_DIR="$SCRIPT_DIR/.."
if [ -n "$(git -C "$LOP_DIR" status --porcelain)" ]; then
  echo "=============================================="
  echo "检测到 lop 仓库存在未保存的更改，请先保存/提交后再运行："
  git -C "$LOP_DIR" status --short
  echo "=============================================="
  exit 1
fi

# 先推送 lop 仓库到远程，确保远程为最新
git -C "$LOP_DIR" push origin HEAD

# 复制 .config 到编译输出目录
cp ../../immortalwrt-mt798x-6.6/.config ../../immortalwrt-mt798x-6.6/bin/targets/*/*/

# 发布信息（发布说明由 RAX3000M-EMMCinit.sh 生成到 Releases.txt）
TAG="$(date +'%Y%m%d%H%M')-rax3000m-emmc"

# 上传固件到 Releases
gh release create "$TAG" \
  -R "$LOP_REPO" \
  .config \
  config.buildinfo \
  feeds.buildinfo \
  immortalwrt-mediatek-filogic-cmcc_rax3000m-emmc-mtk-squashfs-sysupgrade.bin \
  --title "$TAG" \
  --notes-file "$SCRIPT_DIR/Releases.txt"

echo "已上传固件到 Release: $LOP_REPO @ $TAG"
