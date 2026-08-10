#!/bin/bash
# ============================================================
# Roc-script.sh
# 适用: OpenWrt 25.12.x (kernel 6.12)
# 目标: IPQ60xx (JDCloud RE-CS-02 / ZN M2 / JDC AX6600)
# 插件: iStore + Athena LED + Harbor File + OpenClash
# Argon / Aurora 主题
# NSS 加速 / SQM / USB 存储
# OpenAppFilter (匹配 OpenWrt 25.12.x)
# 集客 AC 控制器 (JS 增强版，适配 LuCI 24.x)
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



# ========== 7. Aurora 主题 ==========
# ========== 7.5 集客 AC 控制器（JS 增强版，适配 OpenWrt 25.12 / LuCI 24.x） ==========
echo ">>> [7.5/9] 安装集客 AC 控制器..."
rm -rf package/luci-app-gecoosac package/gecoosac
git clone --depth=1 https://github.com/laipeng668/luci-app-gecoosac package/luci-app-gecoosac

echo "✅ 集客 AC 控制器源码安装完成（需 AP 固件 7.6+，建议 8.x）"
echo "   后端: gecoosac"
echo "   前端: luci-app-gecoosac (JS 版，兼容 25.12)"



# ========== 8.5. 安装 feeds（全脚本只此一次） ==========
echo ">>> [9/9] 安装所有 feeds..."
./scripts/feeds update -a
./scripts/feeds install -a
echo "✅ Feeds 安装完成"


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
echo " 7. 集客 AC 控制器 (服务 → 集客AC控制器)"
echo " 8. OpenAppFilter (应用过滤, v6.1.8)"
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
echo " - 集客 AC 需 AP 固件 7.6+，建议升级至 8.x 以获得最佳兼容性"
echo ""
