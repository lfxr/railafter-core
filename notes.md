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
utliem images create "image_1"
utliem images import "image_1.image.aviutliem.json"
utliem images export "image_1" --path "image_1.image.aviutliem.json"
utliem images delete "image_1"
utliem image "image_1" base
utliem image "image_1" plugins add "hoge:1.2.0"
utliem image "image_1" plugins ls
utliem image "image_1" plugins list
utliem image "image_1" plugins delete "hoge"
```

### container

```bash
utliem container
utliem container ls
utliem container list
utliem container create --image "image_1" --name "container_1"
utliem container delete "container_1"
```

## UtliemCliオブジェクト

```nim
let uc = newUtliemCli()
echo uc.image.list()
uc.image.create("image_1")
```

## イメージファイル (image.aviutliem.yaml) の中身の例

```yaml
image_name: image_1

base:
  aviutl_version: 1.10
  exedit_version: 0.92

plugins:
  - id: hoge
    version: 1.2.0
  - id: fuga
    version: 3.4

scripts:
  - id: piyo
    version: 0.1.7
  - id: hogera
    version: 6.12.9
```

## キラー

- 環境の使い分けが可能&容易になる
  - 文字PV用, 茶番用, 実験用という風に分けられる
  - トリミングなどの軽めの編集だけなら, 動作が軽い, 最低限のプラグインしか入っていないイメージ/コンテナを使用する

- 配布しやすい
  - イメージファイルを共有してそれを読み込んでもらえば, ほぼ同じ環境が再現できる
