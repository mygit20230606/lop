#!/bin/bash
# 检查所有 feeds 是否已同步到远程最新提交
# 用法：在项目根目录执行 ./check_feeds.sh

set -euo pipefail

# 颜色输出
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# 确定 feeds 配置文件
if [ -f "feeds.conf" ]; then
    FEEDS_CONF="feeds.conf"
elif [ -f "feeds.conf.default" ]; then
    FEEDS_CONF="feeds.conf.default"
else
    echo -e "${RED}错误：找不到 feeds.conf 或 feeds.conf.default${NC}"
    exit 1
fi

echo -e "${YELLOW}使用配置文件: $FEEDS_CONF${NC}"

# 检查 feeds 目录是否存在
if [ ! -d "feeds" ]; then
    echo -e "${RED}错误：feeds 目录不存在，请先执行 ./scripts/feeds update -a${NC}"
    exit 1
fi

# 遍历所有 src-git-full 条目
grep '^src-git-full' "$FEEDS_CONF" | while read -r line; do
    # 提取 feed 名称（第二个字段）
    feed_name=$(echo "$line" | awk '{print $2}')
    # 提取分支（分号后的内容），如果没有则用 HEAD
    branch=$(echo "$line" | sed -n 's/.*;//p')
    [ -z "$branch" ] && branch="HEAD"

    feed_dir="feeds/$feed_name"
    echo -e "\n${YELLOW}>>> 检查 feed: $feed_name (分支: $branch)${NC}"

    if [ ! -d "$feed_dir/.git" ]; then
        echo -e "${RED}  ⚠️  $feed_dir 不是有效的 Git 仓库，可能未正确克隆${NC}"
        continue
    fi

    cd "$feed_dir"

    # 获取本地 HEAD hash
    local_hash=$(git rev-parse HEAD 2>/dev/null || true)
    if [ -z "$local_hash" ]; then
        echo -e "${RED}  ❌ 无法获取本地 HEAD 哈希${NC}"
        cd - >/dev/null
        continue
    fi

    # 获取远程对应分支的最新 hash（不下载内容）
    remote_hash=$(git ls-remote origin "$branch" 2>/dev/null | awk '{print $1}' | head -n1)
    if [ -z "$remote_hash" ]; then
        echo -e "${RED}  ❌ 无法获取远程分支 $branch 的最新哈希 (请检查网络或分支名)${NC}"
        cd - >/dev/null
        continue
    fi

    # 比较
    if [ "$local_hash" = "$remote_hash" ]; then
        echo -e "${GREEN}  ✅ 匹配 (本地: $local_hash)${NC}"
    else
        echo -e "${RED}  ❌ 不匹配 (本地: $local_hash, 远程: $remote_hash)${NC}"
        echo -e "${YELLOW}     建议执行: cd $feed_dir && git fetch origin && git reset --hard origin/$branch${NC}"
    fi

    cd - >/dev/null
done

echo -e "\n${GREEN}检查完成！${NC}"