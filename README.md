# AviUtliem CLI - AviUtl統合環境管理CLIツール

## 概要

AviUtliem CLIは, AviUtlの環境を統合的に管理するCLIツールです。

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
