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

### image

```bash
utliem image
utliem image ls
utliem image list
utliem image create --name "image_1"
utliem image import "image_1.image.aviutliem.json"
utliem image export "image_1" --path "image_1.image.aviutliem.json"
utliem image delete "image_1"
utliem image update "image_1" --path "image_1_new.image.aviutliem.json"
```

### container

```bash
utliem container
utliem container ls
utliem container list
utliem container create --image "image_1" --name "container_1"
utliem container delete "container_1"
```
