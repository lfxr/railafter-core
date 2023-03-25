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
├── packages.yaml
├── temp/                     # プラグイン・スクリプトのインストール時に使用
├── cache/                    # ダウンロードしたファイルのキャッシュ
│   ├── base/
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
utliem images
utliem images ls
utliem images list
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
utliem containers ls
utliem containers list
utliem containers create "container_1" "image_1"
utliem containers delete "container_1"
utliem container "container_1" plugins download "hoge:1.2.0"
utliem container "container_1" plugins dl "hoge:1.2.0"
utliem container "container_1" plugins install "hoge:1.2.0"
```

### packages

```bash
utliem packages info
utliem packages ls
utliem packages list
utliem packages find "hoge"
utliem packages update
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

## コンテナファイル (container.aviutliem.yaml) の中身の例

```yaml
container_name: container_1

base:
  aviutl_version: 1.10
  exedit_version: 0.92

plugins:
  enabled:
    - id: hoge
      version: 1.2.0
  disabled:
    - id: fuga
      version: 3.4

scripts:
  enabled:
    - id: piyo
      version: 0.1.7
  disabled:
    - id: hogera
      version: 6.12.9
```

## パケージファイル (packages.yaml) の中身の例

```yaml
plugins:
  - id: hoge
    name: ほげ
    description: ほげするプラグイン
    tags: [foo, bar]
    author: fuga
    website: https://fuga.example.com
    versions:
      - version: 1.2.0
        url: https://fuga.example.com/hoge-1.2.0.zip
        hash: abcdef123456abcdef123456abcdef123456abcdef123456abcdef123456
      - version: 1.3.1
        url: https://fuga.example.com/hoge-1.3.1.zip
        hash: 123456abcdef123456abcdef123456abcdef123456abcdef123456abcdef
```

## イメージ/コンテナとは?

### イメージとは

- 例えるなら: レシピ
  - 「レシピ」なので「材料」を追加できる&共有できる

### コンテナとは

- 例えるなら: レシピから作られた料理
  - 料理なので, 後からトッピングしたり材料を取り除いたりする等アレンジできるが共有はできない
  - 共有したいときはレシピの方を共有する
  - アレンジした料理を共有したいときは, 新たなレシピとして書き起こしそれを共有する

## キラー

- 環境の使い分けが可能&容易になる
  - 文字PV用, 茶番用, 実験用という風に分けられる
  - トリミングなどの軽めの編集だけなら, 動作が軽い, 最低限のプラグインしか入っていないイメージ/コンテナを使用する

- 配布しやすい
  - イメージファイルを共有してそれを読み込んでもらえば, ほぼ同じ環境が再現できる

## 環境をイメージとコンテナに分離するメリット

- 配布しやすい?
- 1つのイメージ (テンプレート/ベース, 最低限必要なプラグインを含むイメージ) を作りそのイメージを元に色々なコンテナまたそのコンテナから生成するイメージを作成できる
- 分離しない場合, 環境を残しておくためには, 環境に手を加える前に環境をコピーしてバックアップをする必要がある
- イメージファイルとコンテナを分けられる (そのまま)

## イメージの機能

### プラグイン管理

ファイルのダウンロードは行われない。

- 追加
  - 対象プラグイン情報を`image.aviutliem.yaml`に追加
- 削除
  - 対象プラグイン情報を`image.aviutliem.yaml`から削除

## コンテナの機能

### プラグイン管理_

`インストール`ではファイルのダウンロードが行われる。

- インストール
  - 対象プラグインのファイルをダウンロードして`plugins`ディレクトリに移動
  - 対象プラグイン情報を`container.aviutliem.yaml`の`enabled`フィールドに追加
- アンインストール
  - `plugins`ディレクトリ内のファイルを削除
  - 対象プラグイン情報を`container.aviutliem.yaml`の`enabled`フィールドまたは`disabled`フィールドから削除
- 無効にする
  - remove, 対象プラグインを一時的に`trash`ディレクトリに移動
  - 対象プラグイン情報を`container.aviutliem.yaml`の`enabled`フィールドから`disabled`フィールドに移動
- 有効にする
  - un-remove, 対象プラグインを`trash`ディレクトリから復活
  - 対象プラグイン情報を`container.aviutliem.yaml`の`disabled`フィールドから`enabled`フィールドに移動

## プラグイン・スクリプトのダウンロード・インストール

### コマンド_

`$ utliem container "container_1" plugins get "hoge:1.2.0"`

### 処理内容

1. `packages.yaml`が改竄されていないか電子署名？で検証する
1. `cache`ディレクトリにファイルが存在する場合, ファイルを`temp`ディレクトリにコピーした後`7.`から始める
1. デフォルトブラウザで配布サイトのURLを開く (`start URL`と実行する)
1. エクスプローラーで`temp`ディレクトリを開く
1. ユーザーが, ブラウザ上で配布サイトからファイルをダウンロードする
1. ユーザーが, ダウンロードしたファイルを`temp`ディレクトリに移動もしくはコピーする
1. `temp`ディレクトリ内のファイルのハッシュ値を計算し, ハッシュ値が一致するか確認する
1. ファイルを解凍し, コンテナの`plugins`もしくは`scripts`ディレクトリに移動する
1. キャッシュするオプションが有効かつ`cache`ディレクトリにファイルが存在しない場合, ファイルを`cache`ディレクトリにコピーする
