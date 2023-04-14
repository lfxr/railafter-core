# Notes > イメージファイル

## イメージファイル (image.azanautl.yaml) の例

```yaml
image_name: image_1

bases:
  aviutl_version: 1.10
  exedit_version: 0.92

plugins:
  - id: hoge
    version: 1.2.0
  - id: fuga
    version: 3.4
```

## スキーマ

```json
{
  "$schema": "http://json-schema.org/draft/2020-12/schema",
  "$ref": "#/$defs/ImageFile",
  "$defs": {
    "ImageFile": {
      "type": "object",
      "properties": {
        "image_name": {
          "type": "string"
        },
        "bases": {
          "type": "object",
          "properties": {
            "aviutl_version": {
              "type": "string"
            },
            "exedit_version": {
              "type": "string"
            }
          },
          "required": [
            "aviutl_version",
            "exedit_version"
          ]
        },
        "plugins": {
          "type": "array",
          "items": {
            "type": "object",
            "properties": {
              "id": {
                "type": "string"
              },
              "version": {
                "type": "string"
              }
            },
            "required": [
              "id",
              "version"
            ]
          }
        }
      },
      "required": [
        "image_name",
        "bases",
        "plugins"
      ]
    }
  }
```
