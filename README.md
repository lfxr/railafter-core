# Railafter Core - Package Manager for AviUtl <!-- omit in toc -->

<!--[![GitHub Repo stars](https://img.shields.io/github/stars/lafixier/railafter-core?style=for-the-badge)](https://github.com/lafixier/railafter-core/stargazers)
[![GitHub](https://img.shields.io/github/license/lafixier/railafter-core?style=for-the-badge)](LICENSE.txt)
![GitHub last commit](https://img.shields.io/github/last-commit/lafixier/railafter-core?style=for-the-badge)
[![GitHub issues](https://img.shields.io/github/issues/lafixier/railafter-core?style=for-the-badge)](https://github.com/lafixier/railafter-core/issues)
[![GitHub pull requests](https://img.shields.io/github/issues-pr-raw/lafixier/railafter-core?style=for-the-badge)](https://github.com/lafixier/railafter-core/pulls)-->

## 目次 <!-- omit in toc -->

- [概要](#概要)
- [機能 (予定)](#機能-予定)
- [インストール](#インストール)
  - [Nimble](#nimble)
- [使い方](#使い方)
  - [ライブラリ](#ライブラリ)
- [開発](#開発)
  - [要件](#要件)
  - [環境構築](#環境構築)
  - [依存外部ライブラリ](#依存外部ライブラリ)
- [依存ライブラリのライセンス](#依存ライブラリのライセンス)
- [ライセンス](#ライセンス)

## 概要

## 機能 (予定)

## インストール

### Nimble

```sh
nimble install railafter
```

## 使い方

### ライブラリ

## 開発

### 要件

- Git
- [Nim](https://nim-lang.org/) (1.6.10 or higher), [Nimble](https://github.com/nim-lang/nimble)
- [typos](https://github.com/crate-ci/typos)
- [ls-lint](https://github.com/loeffel-io/ls-lint)

### 環境構築

```sh
# リポジトリをクローン
git clone git@github.com:lafixier/railafter-core.git

# リポジトリに移動
cd railafter-core

# Git Hooksをインストール
chmod +x scripts/git_hooks/pre-commit
git config --local core.hooksPath scripts/git_hooks

# 依存外部ライブラリをインストール
nimble refresh -l
nimble install -dy
```

### 依存外部ライブラリ

| ライブラリ名 | 用途                                | リポジトリ                               |
| :----------- | :---------------------------------- | :--------------------------------------- |
| cligen       | コマンドライン引数のパース          | <https://github.com/c-blake/cligen>      |
| libcurl      | (Puppy の依存パッケージ)            | <https://github.com/Araq/libcurl>        |
| nimcrypto    | SHA3-512 ハッシュ値の計算           | <https://github.com/cheatfate/nimcrypto> |
| Puppy        | HTTP/HTTPS クライアント             | <https://github.com/treeform/puppy>      |
| Webby        | (Puppy の依存パッケージ)            | <https://github.com/treeform/webby>      |
| NimYAML      | YAML のシリアライズ・デシリアライズ | <https://github.com/flyx/NimYAML>        |
| Zippy        | zip ファイルの解凍                  | <https://github.com/guzba/zippy>         |

## 依存ライブラリのライセンス

[ThirdPartyNotices.md](ThirdPartyNotices.md)を参照してください。

## ライセンス

Copyright (c) 2023 Lafixier Rafinantoka

[MIT ライセンス](LICENSE.txt)でライセンスされています。
