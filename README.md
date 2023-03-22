# AviUtliem CLI - AviUtl統合環境管理CLIツール

[![GitHub Repo stars](https://img.shields.io/github/stars/lafixier/aviutliem-cli?style=for-the-badge)](https://github.com/lafixier/aviutliem-cli/stargazers)
[![GitHub](https://img.shields.io/github/license/lafixier/aviutliem-cli?style=for-the-badge)](https://github.com/lafixier/aviutliem-cli/blob/develop/LICENSE)
![GitHub last commit](https://img.shields.io/github/last-commit/lafixier/aviutliem-cli?style=for-the-badge)
[![GitHub issues](https://img.shields.io/github/issues/lafixier/aviutliem-cli?style=for-the-badge)](https://github.com/lafixier/aviutliem-cli/issues)
[![GitHub pull requests](https://img.shields.io/github/issues-pr-raw/lafixier/aviutliem-cli?style=for-the-badge)](https://github.com/lafixier/aviutliem-cli/pulls)

## 概要

AviUtliem CLIは, AviUtlの環境を統合的に管理するCLIツールです。

## 機能

- AviUtl, 拡張編集Pluginのインストール
- プラグイン, スクリプトのインストール
- AviUtl自体の環境を複数作成・管理・共有

## インストール

### Nimble

```sh
nimble install aviutliem-cli
```

## 開発

### 要件

- Git
- [Nim](https://nim-lang.org/) (1.6.10 or higher), [Nimble](https://github.com/nim-lang/nimble)
- [typos](https://github.com/crate-ci/typos)

### 環境構築

```sh
# リポジトリをクローン
git clone git@github.com:lafixier/aviutliem-cli.git

# リポジトリに移動
cd aviutliem-cli

# Git Hooksをインストール
chmod +x scripts/git_hooks/pre-commit
git config --local core.hooksPath scripts/git_hooks
```
