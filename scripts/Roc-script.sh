#!/bin/bash
# ============================================================
# Roc-script.sh
# 适用: OpenWrt 25.12.x (kernel 6.12)
# 目标: IPQ60xx (JDCloud RE-CS-02 / ZN M2 / JDC AX6600)
# 插件: iStore + Athena LED + Harbor File + OpenClash
# Argon / Aurora 主题
# NSS 加速 / SQM / USB 存储
# OpenAppFilter (锁定 v6.1.8 tag，匹配 OpenWrt 25.12.x)
# ============================================================

set -e

# ========== 0. 基础环境检查 ==========
echo ">>> 检查编译环境..."

if [ ! -f "feeds.conf.default" ]; then
    echo "❌ 错误: 请在 OpenWrt 源码根目录下运行此脚本"
    exit 1
fi

for cmd in git curl make; do
    command -v $cmd >/dev/null 2>&1 || {
        echo "❌ 缺少依赖: $cmd"
        exit 1
    }
done

# 确保 feeds.conf 存在（OpenWrt 编译必需）
[ -f "feeds.conf" ] || cp feeds.conf.default feeds.conf

echo "✅ 环境检查完成"

# ========== 1. 替换 Golang 为 sbwml 维护版 ==========
echo ">>> [1/9] 替换 Golang 工具链 (sbwml)..."

if [ -d "feeds/packages/lang/golang/.git" ]; then
    echo "⏭️ Golang 已替换，跳过"
else
    rm -rf feeds/packages/lang/golang
    git clone --depth=1 https://github.com/sbwml/packages_lang_golang feeds/packages/lang/golang
fi

# 校验 Go 版本
GO_VER=$(grep -m1 'PKG_VERSION' feeds/packages/lang/golang/Makefile | cut -d= -f2)
echo "✅ Golang 替换完成 (版本: $GO_VER)"

# ========== 2. OpenClash ==========
echo ">>> [2/9] 安装 OpenClash..."
rm -rf package/luci-app-openclash
git clone --depth=1 https://github.com/vernesong/OpenClash package/luci-app-openclash
echo "✅ OpenClash 安装完成"

# ========== 3. iStore ==========
echo ">>> [3/9] 安装 iStore..."
rm -rf package/luci-app-store
git clone --depth=1 https://github.com/linkease/istore package/luci-app-store
echo "✅ iStore 安装完成"

# ========== 4. Harbor File ==========
echo ">>> [4/9] 安装 Harbor File..."
rm -rf package/luci-app-harbor-file
git clone --depth=1 https://github.com/destan19/luci-app-harbor-file package/luci-app-harbor-file
echo "✅ Harbor File 安装完成"

# ========== 5. Athena LED Controller (拆包) ==========
echo ">>> [5/9] 安装 Athena LED Controller..."
rm -rf package/athena-led package/luci-app-athena-led

TMPDIR=$(mktemp -d)
git clone --depth=1 https://github.com/unraveloop/JDC-AX6600-Athena-LED-Controller "$TMPDIR"

cp -r "$TMPDIR"/athena-led package/athena-led
cp -r "$TMPDIR"/luci-app-athena-led package/luci-app-athena-led

rm -rf "$TMPDIR"
echo "✅ Athena LED 安装完成 (athena-led + luci-app-athena-led)"

# ========== 6. Argon 主题 ==========
echo ">>> [6/9] 安装 Argon 主题..."
rm -rf package/luci-theme-argon
git clone --depth=1 https://github.com/jerrykuku/luci-theme-argon package/luci-theme-argon
echo "✅ Argon 主题安装完成"

# ========== 7. Aurora 主题 ==========
echo ">>> [7/9] 安装 Aurora 主题..."
rm -rf package/luci-theme-aurora
git clone --depth=1 https://github.com/ctcgfw/luci-theme-aurora package/luci-theme-aurora
echo "⚠️ Aurora 主题为非官方维护，如遇编译失败可忽略或移除"
echo "✅ Aurora 主题安装完成"

# ========== 8. 安装 feeds（全脚本只此一次） ==========
echo ">>> [8/9] 安装所有 feeds..."
./scripts/feeds update -a
./scripts/feeds install -a
echo "✅ Feeds 安装完成"

# ========== 9. OpenAppFilter（锁定 v6.1.8 tag，匹配 OpenWrt 25.12.x） ==========
echo ">>> [9/9] 安装 OpenAppFilter..."
rm -rf package/OpenAppFilter
git clone https://github.com/destan19/OpenAppFilter package/OpenAppFilter
cd package/OpenAppFilter

# 强校验：锁定 v6.1.8 tag，不存在则终止编译
git fetch origin --tags
if git checkout v6.1.8; then
    OAF_VER=$(git describe --tags --always)
    echo "✅ OAF 锁定版本 $OAF_VER（匹配 OpenWrt 25.12.x / kernel 6.12）"
else
    echo "❌ OpenAppFilter tag v6.1.8 不存在，终止编译"
    echo "   请检查上游仓库: https://github.com/destan19/OpenAppFilter"
    cd -
    exit 1
fi

cd -
echo "✅ OpenAppFilter 安装完成"

# ========== 完成 ==========
echo ""
echo "=============================================="
echo " ✅ 所有插件安装完成！"
echo "=============================================="
echo ""
echo "📋 已安装的插件:"
echo " 1. OpenClash (科学上网)"
echo " 2. iStore (软件中心)"
echo " 3. Harbor File (文件管理器)"
echo " 4. Athena LED (京东云 LED 控制)"
echo " 5. Argon 主题 (LuCI 主题)"
echo " 6. Aurora 主题 (LuCI 主题)"
echo " 7. OpenAppFilter (应用过滤, v6.1.8)"
echo ""
echo "📋 接下来请执行:"
echo " cp configs/IPQ60XX-RECS02 .config"
echo " make defconfig"
echo " make menuconfig # 可选，检查配置"
echo " make -j\$(nproc) # 开始编译"
echo ""
echo "⚠️ 注意事项:"
echo " - 本脚本仅负责插件拉取，不包含 .config"
echo " - .config 中不要重复启用 feeds 版的 luci-app-store"
echo " - .config 中不要重复启用 feeds 版的 luci-app-openclash"
echo " - Athena LED 需要 Rust 工具链（OpenWrt ≥ 23.05 通过 feeds 自动拉取）"
echo " - iStore 仅支持 x86_64 / arm64 (IPQ60xx 是 arm64 ✅)"
echo " - OAF 已锁定 v6.1.8 tag（匹配 25.12.x / kernel 6.12）"
echo " - Aurora 主题维护停滞，25.12 下可能编译失败，可忽略"
echo " - NSS 加速与 OAF DPI 共存时若异常，先关闭 Turbo ACC 验证"
echo ""
