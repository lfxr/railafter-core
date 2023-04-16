# Notes > パッケージファイル

## パケージファイル (packages.yaml) の例

```yaml
plugins:
  - id: piyo/hoge
    name: ほげ
    plugin_type: language
    description: AviUtlをほげする
    tags: [fuga]
    author: piyo
    website: https://piyo.example.com/
    github_repo?: pi_yo/hoge
    niconico_commons_id?: sm0hoge000000
    dependencies?:
      - conforming_versions: [1.0, 1.1, 2.0, 2.1]
        body:
          bases?:
            - aviutl_versions: [">= v1.00"]
              exedit_versions: [">= v0.92"]
          plugins?:
            - id: piyo/fuga
              versions: [3.1.1, 3.1.2, 3.2.0]
    tracked_files_and_dirs:
      - conforming_versions: [2.0, 2.1]
        body:
          - path: hoge.aul
            fd_type: file
            move_to: plugins
            is_protected: false
            is_mutable: false
            is_config: false
          - path: hoge.toml
            type: file
            move_to: plugins
            is_protected: true
            is_mutable: true
            is_config: true
      - conforming_versions: [1.0, 1.1]
        body:
          - path: hoge.aul
            type: file
            move_to: plugins
            is_protected: false
            is_mutable: false
            is_config: false
          - path: hoge.xml
            type: file
            move_to: plugins
            is_protected: true
            is_mutable: true
            is_config: true
    jobs?:
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
        is_production_release: true
        url: https://git.example.com/piyo/hoge/releases/tag/v2.1
        github_release_tag: v2.1
        sha3_512_hash: kaoeih
        released_on: 2023-03-01
        tracked_file_or_dir_hashes:
          hoge.aul: zmlces
          hoge.toml: binmmo
      - version: 2.0
        is_production_release: true
        url: https://git.example.com/piyo/hoge/releases/tag/v2.0
        github_release_tag: v2.0
        sha3_512_hash: qlksdf
        released_on: 2023-02-20
        tracked_file_or_dir_hashes:
          hoge.aul: pawasv
          hoge.toml: binmmo
      - version: 1.1
        is_production_release: true
        url: https://git.example.com/piyo/hoge/releases/tag/v1.1
        github_release_tag: v1.1
        sha3_512_hash: waergn
        released_on: 2023-01-10
        tracked_file_or_dir_hashes:
          hoge.aul: oiegkl
          hoge.xml: eqrtgf
      - version: 1.0
        is_production_release: true
        url: https://git.example.com/piyo/hoge/releases/tag/v1.0
        github_release_tag: v1.0
        sha3_512_hash: hgerwo
        released_on: 2023-01-01
        tracked_file_or_dir_hashes:
          hoge.aul: rwgpoj
          hoge.xml: eqrtgf
```
