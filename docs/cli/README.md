# ドキュメント > CLIツール  <!-- omit in toc -->

## 目次 <!-- omit in toc -->

- [イメージ](#イメージ)
  - [イメージの一覧を表示](#イメージの一覧を表示)
  - [イメージを作成](#イメージを作成)
  - [イメージを削除](#イメージを削除)
- [指定したイメージ](#指定したイメージ)
  - [指定したイメージのプラグイン](#指定したイメージのプラグイン)
    - [指定したイメージのプラグイン一覧を表示](#指定したイメージのプラグイン一覧を表示)
    - [指定したイメージにプラグインを追加](#指定したイメージにプラグインを追加)
    - [指定したイメージのプラグインを削除](#指定したイメージのプラグインを削除)
- [コンテナ](#コンテナ)
  - [コンテナの一覧を表示](#コンテナの一覧を表示)
  - [コンテナを作成](#コンテナを作成)
  - [コンテナを削除](#コンテナを削除)
- [指定したコンテナ](#指定したコンテナ)
  - [指定したコンテナのプラグイン](#指定したコンテナのプラグイン)
    - [指定したコンテナにプラグインをダウンロード](#指定したコンテナにプラグインをダウンロード)
    - [指定したコンテナにプラグインをインストール](#指定したコンテナにプラグインをインストール)
- [入手可能なパッケージ](#入手可能なパッケージ)
  - [プラグイン](#プラグイン)
    - [入手可能なプラグインの一覧を表示](#入手可能なプラグインの一覧を表示)
    - [入手可能なプラグインを検索](#入手可能なプラグインを検索)

## イメージ

### イメージの一覧を表示

```sh
utliem images list
utliem images ls   # 上と同じ
```

### イメージを作成

```sh
utliem images create <image-name>

# 例: image-1という名前のイメージを作成
utliem images create image-1
```

### イメージを削除

```sh
utliem images delete <image-name>
utliem images del <image-name>

# 例: image-1という名前のイメージを削除
utliem images delete image-1
utliem images del image-1    # 上と同じ
```

## 指定したイメージ

### 指定したイメージのプラグイン

#### 指定したイメージのプラグイン一覧を表示

```sh
utliem image <image-name> plugins list
utliem image <image-name> plugins ls   # 上と同じ

# 例: image-1という名前のイメージのプラグイン一覧を表示
utliem image image-1 plugins list
utliem image image-1 plugins ls   # 上と同じ
```

#### 指定したイメージにプラグインを追加

```sh
utliem image <image-name> plugins add <plugin-name>

# 例: image-1という名前のイメージにplugin-1という名前のプラグインを追加
utliem image image-1 plugins add plugin-1
```

#### 指定したイメージのプラグインを削除

```sh
utliem image <image-name> plugins delete <plugin-name>
utliem image <image-name> plugins del <plugin-name>    # 上と同じ

# 例: image-1という名前のイメージのplugin-1という名前のプラグインを削除
utliem image image-1 plugins delete plugin-1
utliem image image-1 plugins del plugin-1   # 上と同じ
```

## コンテナ

### コンテナの一覧を表示

```sh
utliem containers list
utliem containers ls   # 上と同じ
```

### コンテナを作成

```sh
utliem containers create <container-name> <image-name>
# 引数:
#   - container-name: 作成するコンテナの名前
#   - image-name: 作成するコンテナの基となるイメージの名前

# 例: container-1という名前のコンテナをimage-1という名前のイメージを基に作成
utliem containers create container-1 image-1
```

### コンテナを削除

```sh
utliem containers delete <container-name>
utliem containers del <container-name>    # 上と同じ

# 例: container-1という名前のコンテナを削除
utliem containers delete container-1
utliem containers del container-1   # 上と同じ
```

## 指定したコンテナ

### 指定したコンテナのプラグイン

#### 指定したコンテナにプラグインをダウンロード

```sh
utliem container <container-name> plugins download <plugin-name>
utliem container <container-name> plugins dl <plugin-name>       # 上と同じ

# 例: container-1という名前のコンテナにplugin-1という名前のプラグインをダウンロード
utliem container container-1 plugins download plugin-1
utliem container container-1 plugins dl plugin-1       # 上と同じ
```

#### 指定したコンテナにプラグインをインストール

```sh
utliem container <container-name> plugins install <plugin-name>

# 例: container-1という名前のコンテナにplugin-1という名前のプラグインをインストール
utliem container container-1 plugins install plugin-1
```

## 入手可能なパッケージ

### プラグイン

#### 入手可能なプラグインの一覧を表示

```sh
utliem packages plugins list
utliem packages plugins ls   # 上と同じ
```

#### 入手可能なプラグインを検索

```sh
utliem packages plugins find <keyword>

# 例: キーワードというキーワードでプラグインを検索
utliem packages plugins find キーワード
```
