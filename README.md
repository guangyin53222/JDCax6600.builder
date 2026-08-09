<div align="center">
<h1>OpenWrt — 云编译</h1>

## 特别提示

- **本人不对任何人因使用本固件所遭受的任何理论或实际的损失承担责任！**
- **本固件禁止用于任何商业用途，请务必严格遵守国家互联网使用相关法律规定！**

## 项目说明

- 默认管理地址：**`192.168.88.1`**
- 默认用户：**`root`**
- 默认密码：**`none`**（空密码）
- 上游仓库：[Lang-Ke/OpenWrt-CI](https://github.com/Lang-Ke/OpenWrt-CI)（通过 GitHub **Sync fork** 保持更新）
- 固件源码：[LiBwrt/LibWrt](https://github.com/LiBwrt/LibWrt)（`25.12-nss` 分支，支持 NSS 硬件加速）
- 云编译参考：[haiibo/OpenWrt](https://github.com/haiibo/OpenWrt) · [视频教程](https://www.youtube.com/watch?v=6j4ofS0GT38&t=507s)

## 目录说明

| 路径 | 说明 |
|------|------|
| `configs/General.config` | 通用插件与编译优化（所有机型共用） |
| `configs/IPQ60XX.config` | IPQ60xx 机型选择（如 ZN M2） |
| `configs/*.config` | 其他机型专用配置 |
| `scripts/Roc-script.sh` | 自定义脚本（默认 IP、主题、PassWall/OpenClash 等源码） |
| `.github/workflows/*.yml` | GitHub Actions 云编译工作流 |

## 可用工作流

| Workflow | 适用机型 / 场景 |
|----------|----------------|
| **IPQ60XX-LibWrt** | IPQ60xx（ZN M2、京东云等），NSS 加速 |
| **IPQ60XX-NOWIFI-LibWrt** | IPQ60xx 无 WiFi 版 |
| **IPQ807X-LibWrt** | IPQ807x 平台 |
| **Arthur&Athena&Taiyi-ImmortalWrt** | 京东云亚瑟 / 雅典娜 / 太乙 |
| **RAX3000M-ImmortalWrt** | 移动 RAX3000M |
| **K2P-ImmortalWrt** | 斐讯 K2P |
| **x86-64-ImmortalWrt** | x86-64 软路由 |
| **Trigger-All-Workflows** | 一键触发上述全部编译 |

## 定制固件

1. 登录 GitHub，Fork 本仓库到你自己的账号。
2. 修改 `configs` 目录下对应配置文件：
   - 添加或删除插件：把 `y` 改成 `n`（仅加 `#` 无效）。
   - 插件说明可参考：[OpenWrt 软件包全量解释](https://www.right.com.cn/FORUM/forum.php?mod=viewthread&tid=8384897)。
3. 修改默认 IP、hostname、插件源码等：编辑 `scripts/Roc-script.sh`。
4. 推送代码后，进入 **Actions**，选择对应 **workflow** 手动运行。
5. 编译约需 1～2 小时，完成后在仓库 **[Releases](https://github.com/1987zcc/OpenWrt-CI/releases)** 对应 Tag 下载固件。

### ZN M2 推荐流程

1. 保持 `configs/IPQ60XX.config` 中 `zn_m2=y`，其余机型 `=n`。
2. 按需修改 `configs/General.config` 插件。
3. 运行 **IPQ60XX-LibWrt** workflow。
4. 刷机后访问 `http://192.168.88.1`。

## 保持与上游同步

本仓库 Fork 自 [Lang-Ke/OpenWrt-CI](https://github.com/Lang-Ke/OpenWrt-CI)。

- **网页**：仓库页点击 **Sync fork** → **Update branch**。
- **命令行**：
  ```bash
  git remote add upstream https://github.com/Lang-Ke/OpenWrt-CI.git   # 首次
  git fetch upstream && git merge upstream/master && git push
  ```

你在 `configs`、`Roc-script.sh` 中的自定义修改，同步时若有冲突需手动解决。

## 致谢

- 云编译框架：[haiibo/OpenWrt](https://github.com/haiibo/OpenWrt)
- 参考项目：[laipeng668/openwrt-ci-roc](https://github.com/laipeng668/openwrt-ci-roc)
- LibWrt / NSS：[LiBwrt/LibWrt](https://github.com/LiBwrt/LibWrt)

![Overview](Overview.png)
![Global](Global.png)
