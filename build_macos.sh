#!/bin/bash
# macOS 打包脚本

set -e

echo "=== Lark2MD macOS 打包脚本 ==="

# 检查 Python 环境
if ! command -v python3 &> /dev/null; then
    echo "错误: 未找到 python3"
    exit 1
fi

# 检查 uv 或 pip
if command -v uv &> /dev/null; then
    PKG_MGR="uv"
    echo "使用 uv 作为包管理器"
else
    PKG_MGR="pip"
    echo "使用 pip 作为包管理器"
fi

# 安装依赖
echo ""
echo ">>> 安装项目依赖..."
if [ "$PKG_MGR" = "uv" ]; then
    uv sync
else
    pip install -e .
fi

# 安装 PyInstaller
echo ""
echo ">>> 安装 PyInstaller..."
if [ "$PKG_MGR" = "uv" ]; then
    uv pip install pyinstaller
else
    pip install pyinstaller
fi

# 生成 icns 图标（如果不存在）
if [ ! -f "icon.icns" ] && [ -f "icon.ico" ]; then
    echo ""
    echo ">>> 生成 macOS 图标..."

    # 创建临时 iconset 目录
    mkdir -p icon.iconset

    # 使用 sips 转换图标（macOS 自带工具）
    if command -v sips &> /dev/null; then
        # 从 ico 提取或使用 img 目录中的图标
        if [ -f "img/256x256.ico" ]; then
            sips -s format png "img/256x256.ico" --out icon.iconset/icon_256x256.png 2>/dev/null || true
        fi

        # 尝试从 icon.ico 生成各尺寸
        for size in 16 32 48 128 256 512; do
            sips -z $size $size icon.iconset/icon_256x256.png --out icon.iconset/icon_${size}x${size}.png 2>/dev/null || true
        done

        # 生成 @2x 版本
        for size in 16 32 128 256; do
            size2=$((size * 2))
            cp icon.iconset/icon_${size2}x${size2}.png icon.iconset/icon_${size}x${size}@2x.png 2>/dev/null || true
        done

        # 生成 icns
        iconutil -c icns icon.iconset -o icon.icns 2>/dev/null || echo "警告: 无法生成 icns，将使用默认图标"

        # 清理临时文件
        rm -rf icon.iconset
    else
        echo "警告: sips 不可用，跳过图标转换"
    fi
fi

# 清理旧的构建
echo ""
echo ">>> 清理旧构建..."
rm -rf build dist

# 执行打包
echo ""
echo ">>> 开始打包..."
if [ "$PKG_MGR" = "uv" ]; then
    uv run pyinstaller Lark2MD_macOS.spec --noconfirm
else
    pyinstaller Lark2MD_macOS.spec --noconfirm
fi

# 检查结果
if [ -d "dist/Lark2MD.app" ]; then
    echo ""
    echo "=== 打包成功 ==="
    echo "应用位置: $(pwd)/dist/Lark2MD.app"
    echo ""
    echo "你可以:"
    echo "  1. 双击 dist/Lark2MD.app 运行"
    echo "  2. 将 Lark2MD.app 拖到 /Applications 目录安装"
    echo ""

    # 显示应用大小
    du -sh dist/Lark2MD.app
else
    echo ""
    echo "=== 打包失败 ==="
    exit 1
fi
