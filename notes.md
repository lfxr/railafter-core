# Notes

## ディレクトリ構成

### AviUtliem

```text
~/.aviutliem/
├── aviutliem.exe         # AviUtliemの実行ファイル
├── aviutliem_updater.exe # アップデータ
├── settings.json         # 設定ファイル
├── aviutliem_cli/        # AviUtliem CLI
│   └── ...
└── ...
```

### AviUtliem CLI

```text
aviutliem_cli/
├── aviutliem_cli.exe         # AviUtliem CLIの実行ファイル
├── aviutliem_cli_updater.exe # アップデータ
├── images/                   # イメージ
│   ├── awesome_image_1/      # とあるイメージ
│   └── ...
├── containers/               # コンテナ
│   ├── awesome_container_1/  # とあるコンテナ
│   │   └── ...
│   └── ...
└── ...
```

### イメージ

```text
awesome_image_1/
├── image.aviutliem.json    # 設定ファイル
└── ...
```

### コンテナ

```text
awesome_container_1/
├── container.aviutliem.json # 設定ファイル
├── aviutl/
│   ├── aviutl.exe           # AviUtlの実行ファイル
│   ├── plugins/             # プラグイン
└── ...
```

## コマンド

```bash
utliem -h
```

```bash
utliem container
```
