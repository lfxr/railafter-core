# Notes > ディレクトリ構成

## AzanaUtl

```text
~/.azanautl/
├── settings.toml        # 設定ファイル
└── ...
```

## AzanaUtl CLI

```text
~/.azanautl_cli/
├── packages.yaml
├── temp/                     # プラグイン・スクリプトのインストール時に使用
├── cache/                    # ダウンロードしたファイルのキャッシュ
│   ├── bases/
│   ├── plugins/
│   └── scripts/
├── images/                   # イメージ
│   ├── awesome_image_1/      # とあるイメージ
│   └── ...
├── containers/               # コンテナ
│   ├── awesome_container_1/  # とあるコンテナ
│   │   └── ...
│   └── ...
└── ...
```

## イメージ

```text
awesome_image_1/
├── image.azanautl.yaml    # 設定ファイル
└── ...
```

## コンテナ

```text
awesome_container_1/
├── container.azanautl.yaml # 設定ファイル
├── aviutl/
│   ├── aviutl.exe           # AviUtlの実行ファイル
│   ├── plugins/             # プラグイン
│   └── ...
└── ...
```
