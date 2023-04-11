# Notes > コンテナファイル

## コンテナファイル (container.azanautl.yaml) の例

```yaml
container_name: container_1

bases:
  aviutl_version: 1.10
  exedit_version: 0.92

plugins:
  - id: hoge
    version: 1.2.0
    is_enabled: true
    previously_installed_versions: [1.1.0]
  - id: fuga
    version: 3.4
    is_enabled: false
    previously_installed_versions: []
```
