# Notes > パッケージファイル

## パケージファイル (packages.yaml) の例

```yaml
plugins:
  - id: hoge
    name: ほげ
    type: language
    description: AviUtlをほげする
    tags: [fuga]
    author: piyo
    website: https://piyo.example.com/
    git_repository: https://git.example.com/piyo/hoge
    niconico_commons_id: sm0000000
    tracked_files_and_dirs:
      - conforming_versions: [2.0, 2.1]
        body:
          - path: hoge.aul
            type: file
            move_to: plugins
            is_protected: false
            is_mutable: false
            is_config_file_or_dir: false
          - path: hoge.toml
            type: file
            move_to: plugins
            is_protected: true
            is_mutable: true
            is_config_file_or_dir: true
      - conforming_versions: [1.0, 1.1]
        body:
          - path: hoge.aul
            type: file
            move_to: plugins
            is_protected: false
            is_mutable: false
            is_config_file_or_dir: false
          - path: hoge.xml
            type: file
            move_to: plugins
            is_protected: true
            is_mutable: true
            is_config_file_or_dir: true
    jobs:
      - conforming_versions: [1.0, 1.1, 2.0, 2.1]
        body:
          - id: after_installation
            tasks:
              - command: remove
                working_dir: aviutl
                paths: [hoge.exe, hoge.exe.manifest]
              - command: run
                working_dir: downloaded_plugin
                path: create_hoge.exe
          - id: after_uninstallation
            tasks:
              - command: remove
                working_dir: aviutl
                paths: [hoge.exe, hoge.exe.manifest]
    versions:
      - version: 2.1
        sha3_512_hash: kaoeih
        tracked_file_or_dir_hashes:
          hoge.aul: zmlces
          hoge.toml: binmmo
      - version: 2.0
        sha3_512_hash: qlksdf
        tracked_file_or_dir_hashes:
          hoge.aul: pawasv
          hoge.toml: binmmo
      - version: 1.1
        sha3_512_hash: waergn
        tracked_file_or_dir_hashes:
          hoge.aul: oiegkl
          hoge.xml: eqrtgf
      - version: 1.0
        sha3_512_hash: hgerwo
        tracked_file_or_dir_hashes:
          hoge.aul: rwgpoj
          hoge.xml: eqrtgf
```
