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
azanac images list
azanac images ls   # 上と同じ
```

### イメージを作成

```sh
azanac images create <image-name>

# 例: image-1という名前のイメージを作成
azanac images create image-1
```

### イメージを削除

```sh
azanac images delete <image-name>
azanac images del <image-name>

# 例: image-1という名前のイメージを削除
azanac images delete image-1
azanac images del image-1    # 上と同じ
```

## 指定したイメージ

### 指定したイメージのプラグイン

#### 指定したイメージのプラグイン一覧を表示

```sh
azanac image <image-name> plugins list
azanac image <image-name> plugins ls   # 上と同じ

# 例: image-1という名前のイメージのプラグイン一覧を表示
azanac image image-1 plugins list
azanac image image-1 plugins ls   # 上と同じ
```

#### 指定したイメージにプラグインを追加

```sh
azanac image <image-name> plugins add <plugin-name>

# 例: image-1という名前のイメージにplugin-1という名前のプラグインを追加
azanac image image-1 plugins add plugin-1
```

#### 指定したイメージのプラグインを削除

```sh
azanac image <image-name> plugins delete <plugin-name>
azanac image <image-name> plugins del <plugin-name>    # 上と同じ

# 例: image-1という名前のイメージのplugin-1という名前のプラグインを削除
azanac image image-1 plugins delete plugin-1
azanac image image-1 plugins del plugin-1   # 上と同じ
```

## コンテナ

### コンテナの一覧を表示

```sh
azanac containers list
azanac containers ls   # 上と同じ
```

### コンテナを作成

```sh
azanac containers create <container-name> <image-name>
# 引数:
#   - container-name: 作成するコンテナの名前
#   - image-name: 作成するコンテナの基となるイメージの名前

# 例: container-1という名前のコンテナをimage-1という名前のイメージを基に作成
azanac containers create container-1 image-1
```

### コンテナを削除

```sh
azanac containers delete <container-name>
azanac containers del <container-name>    # 上と同じ

# 例: container-1という名前のコンテナを削除
azanac containers delete container-1
azanac containers del container-1   # 上と同じ
```

## 指定したコンテナ

### 指定したコンテナのプラグイン

#### 指定したコンテナにプラグインをダウンロード

```sh
azanac container <container-name> plugins download <plugin-name>
azanac container <container-name> plugins dl <plugin-name>       # 上と同じ

# 例: container-1という名前のコンテナにplugin-1という名前のプラグインをダウンロード
azanac container container-1 plugins download plugin-1
azanac container container-1 plugins dl plugin-1       # 上と同じ
```

#### 指定したコンテナにプラグインをインストール

```sh
azanac container <container-name> plugins install <plugin-name>

# 例: container-1という名前のコンテナにplugin-1という名前のプラグインをインストール
azanac container container-1 plugins install plugin-1
```

## 入手可能なパッケージ

### プラグイン

#### 入手可能なプラグインの一覧を表示

```sh
azanac packages plugins list
azanac packages plugins ls   # 上と同じ
```

#### 入手可能なプラグインを検索

```sh
azanac packages plugins find <keyword>

# 例: キーワードというキーワードでプラグインを検索
azanac packages plugins find キーワード
```
