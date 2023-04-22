# AzanaUtl CLI - AviUtl統合環境管理CLIツール <!-- omit in toc -->

[![GitHub Repo stars](https://img.shields.io/github/stars/lafixier/azanautl-cli?style=for-the-badge)](https://github.com/lafixier/azanautl-cli/stargazers)
[![GitHub](https://img.shields.io/github/license/lafixier/azanautl-cli?style=for-the-badge)](LICENSE.txt)
![GitHub last commit](https://img.shields.io/github/last-commit/lafixier/azanautl-cli?style=for-the-badge)
[![GitHub issues](https://img.shields.io/github/issues/lafixier/azanautl-cli?style=for-the-badge)](https://github.com/lafixier/azanautl-cli/issues)
[![GitHub pull requests](https://img.shields.io/github/issues-pr-raw/lafixier/azanautl-cli?style=for-the-badge)](https://github.com/lafixier/azanautl-cli/pulls)

## 目次 <!-- omit in toc -->

- [概要](#概要)
- [機能 (予定)](#機能-予定)
- [インストール](#インストール)
  - [Nimble](#nimble)
- [使い方](#使い方)
  - [CLIツール](#cliツール)
  - [ライブラリ](#ライブラリ)
- [開発](#開発)
  - [要件](#要件)
  - [環境構築](#環境構築)
  - [依存外部ライブラリ](#依存外部ライブラリ)
- [依存ライブラリのライセンス](#依存ライブラリのライセンス)
- [ライセンス](#ライセンス)

## 概要

AzanaUtl CLIは, AviUtlの環境を統合的に管理するCLIツールです。

## 機能 (予定)

- AviUtl, 拡張編集Pluginのインストール
- プラグイン, スクリプトのインストール
- AviUtl自体の環境を複数作成・管理・共有

## インストール

### Nimble

```sh
nimble install azanautl-cli
```

## 使い方

### CLIツール

[docs/cli/README.md](docs/cli/README.md)を参照してください。

### ライブラリ

[docs/api](docs/api/theindex.html)を参照してください。

## 開発

### 要件

- Git
- [Nim](https://nim-lang.org/) (1.6.10 or higher), [Nimble](https://github.com/nim-lang/nimble)
- [typos](https://github.com/crate-ci/typos)

### 環境構築

```sh
# リポジトリをクローン
git clone git@github.com:lafixier/azanautl-cli.git

# リポジトリに移動
cd azanautl-cli

# Git Hooksをインストール
chmod +x scripts/git_hooks/pre-commit
git config --local core.hooksPath scripts/git_hooks

# 依存外部ライブラリをインストール
nimble refresh -l
nimble install -dy
```

### 依存外部ライブラリ

| ライブラリ名 | 用途                               | リポジトリ                               |
| :----------- | :--------------------------------- | :--------------------------------------- |
| cligen       | コマンドライン引数のパース         | <https://github.com/c-blake/cligen>      |
| nimcrypto    | SHA3-512ハッシュ値の計算           | <https://github.com/cheatfate/nimcrypto> |
| NimYAML      | YAMLのシリアライズ・デシリアライズ | <https://github.com/flyx/NimYAML>        |
| Zippy        | zipファイルの解凍                  | <https://github.com/guzba/zippy>         |

## 依存ライブラリのライセンス

[ThirdPartyNotices.md](ThirdPartyNotices.md)を参照してください。

## ライセンス

Copyright (c) 2023 Lafixier Furude

[MITライセンス](LICENSE.txt)でライセンスされています。
