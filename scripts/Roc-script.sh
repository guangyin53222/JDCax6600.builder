#!/bin/bash
# ============================================================
#  Roc-script.sh
#  适用: OpenWrt (23.05 / 24.10 / master)
#  目标: IPQ60xx (JDCloud RE-CS-02 / ZN M2)
#  插件: iStore + Athena LED + Harbor File + OpenClash
#         Argon / Aurora 主题
#         NSS 加速 / SQM / USB 存储
# ============================================================

set -e

# ========== 0. 基础环境检查 ==========
echo ">>> 检查编译环境..."
if [ ! -f "feeds.conf.default" ]; then
    echo "❌ 错误: 请在 OpenWrt 源码根目录下运行此脚本"
    exit 1
fi

# 确保基本依赖
./scripts/feeds update -a > /dev/null 2>&1 || true

echo ">>> 环境检查完成"

# ========== 1. 替换 Golang 为 sbwml 维护版 ==========
echo ">>> [1/8] 替换 Golang 工具链 (sbwml)..."
rm -rf feeds/packages/lang/golang
git clone --depth=1 https://github.com/sbwml/packages_lang_golang feeds/packages/lang/golang
echo "✅ Golang 替换完成"

# ========== 2. OpenClash ==========
echo ">>> [2/8] 安装 OpenClash..."
rm -rf package/luci-app-openclash
git clone --depth=1 https://github.com/vernesong/OpenClash package/luci-app-openclash
echo "✅ OpenClash 安装完成"

# ========== 3. iStore ==========
echo ">>> [3/8] 安装 iStore..."
rm -rf package/luci-app-store
git clone --depth=1 https://github.com/linkease/istore package/luci-app-store
echo "✅ iStore 安装完成"

# ========== 4. Harbor File ==========
echo ">>> [4/8] 安装 Harbor File..."
rm -rf package/luci-app-harbor-file
git clone --depth=1 https://github.com/destan19/luci-app-harbor-file package/luci-app-harbor-file
echo "✅ Harbor File 安装完成"

# ========== 5. Athena LED Controller (拆包) ==========
echo ">>> [5/8] 安装 Athena LED Controller..."
rm -rf package/athena-led package/luci-app-athena-led
git clone --depth=1 https://github.com/unraveloop/JDC-AX6600-Athena-LED-Controller /tmp/athena-led-controller

cp -r /tmp/athena-led-controller/athena-led package/athena-led
cp -r /tmp/athena-led-controller/luci-app-athena-led package/luci-app-athena-led

rm -rf /tmp/athena-led-controller
echo "✅ Athena LED 安装完成 (athena-led + luci-app-athena-led)"

# ========== 6. Argon 主题 ==========
echo ">>> [6/8] 安装 Argon 主题..."
rm -rf package/luci-theme-argon
git clone --depth=1 https://github.com/jerrykuku/luci-theme-argon package/luci-theme-argon
echo "✅ Argon 主题安装完成"

# ========== 7. Aurora 主题 ==========
echo ">>> [7/8] 安装 Aurora 主题..."
rm -rf package/luci-theme-aurora
git clone --depth=1 https://github.com/ctcgfw/luci-theme-aurora package/luci-theme-aurora
echo "✅ Aurora 主题安装完成"

# ========== 8. 安装 feeds ==========
echo ">>> [8/8] 安装所有 feeds..."
./scripts/feeds update -a
./scripts/feeds install -a
echo "✅ Feeds 安装完成"

# ========== 完成 ==========
echo ""
echo "=============================================="
echo "  ✅ 所有插件安装完成！"
echo "=============================================="
echo ""
echo "📋 已安装的插件:"
echo "   1. OpenClash          (科学上网)"
echo "   2. iStore             (软件中心)"
echo "   3. Harbor File        (文件管理器)"
echo "   4. Athena LED         (京东云 LED 控制)"
echo "   5. Argon 主题         (LuCI 主题)"
echo "   6. Aurora 主题        (LuCI 主题)"
echo ""
echo "📋 接下来请执行:"
echo "   cp configs/IPQ60XX-RECS02 .config"
echo "   make defconfig"
echo "   make menuconfig   (可选,检查配置)"
echo "   make -j\$(nproc)   (开始编译)"
echo ""
echo "⚠️  注意事项:"
echo "   - 确保 .config 中不要重复启用 feeds 版的 luci-app-store"
echo "   - 确保 .config 中不要重复启用 feeds 版的 luci-app-openclash"
echo "   - Athena LED 需要 Rust 工具链 (OpenWrt ≥ 23.05 自带)"
echo "   - iStore 仅支持 x86_64 / arm64 (IPQ60xx 是 arm64 ✅)"
echo ""
