# -*- mode: python ; coding: utf-8 -*-
# macOS 打包配置文件

import sys
from pathlib import Path

block_cipher = None

a = Analysis(
    ['main.py'],
    pathex=[],
    binaries=[],
    datas=[
        ('src', 'src'),
        ('icon.ico', '.'),
    ],
    hiddenimports=[
        'PyQt6.QtCore',
        'PyQt6.QtGui',
        'PyQt6.QtWidgets',
        'lark_oapi',
        'lark_oapi.api.docx',
        'lark_oapi.api.docx.v1',
        'lark_oapi.api.drive.v1',
    ],
    hookspath=[],
    hooksconfig={},
    runtime_hooks=[],
    excludes=[],
    noarchive=False,
)

pyz = PYZ(a.pure, cipher=block_cipher)

exe = EXE(
    pyz,
    a.scripts,
    [],
    exclude_binaries=True,
    name='Lark2MD',
    debug=False,
    bootloader_ignore_signals=False,
    strip=False,
    upx=True,
    console=False,
    disable_windowed_traceback=False,
    argv_emulation=True,  # macOS 需要启用
    target_arch=None,
    codesign_identity=None,
    entitlements_file=None,
)

coll = COLLECT(
    exe,
    a.binaries,
    a.datas,
    strip=False,
    upx=True,
    upx_exclude=[],
    name='Lark2MD',
)

# macOS .app bundle
app = BUNDLE(
    coll,
    name='Lark2MD.app',
    icon='icon.icns' if Path('icon.icns').exists() else None,
    bundle_identifier='com.feishu2md.lark2md',
    info_plist={
        'CFBundleName': 'Lark2MD',
        'CFBundleDisplayName': '飞书文档转Markdown',
        'CFBundleVersion': '1.0.0',
        'CFBundleShortVersionString': '1.0.0',
        'NSHighResolutionCapable': True,
        'NSRequiresAquaSystemAppearance': False,  # 支持深色模式
        'LSMinimumSystemVersion': '10.15',
    },
)
