# Notes > コマンド

```sh
azanac -h
```

## image

```sh
azanac images
azanac images ls
azanac images list
azanac images create "image_1"
azanac images import "image_1.image.azanautl.json"
azanac images export "image_1" --path "image_1.image.azanautl.json"
azanac images delete "image_1"
azanac image "image_1" base
azanac image "image_1" plugins add "hoge:1.2.0"
azanac image "image_1" plugins ls
azanac image "image_1" plugins list
azanac image "image_1" plugins delete "hoge"
```

## container

```sh
azanac container
azanac containers ls
azanac containers list
azanac containers create "container_1" "image_1"
azanac containers delete "container_1"
azanac container "container_1" plugins download "hoge:1.2.0"
azanac container "container_1" plugins dl "hoge:1.2.0"
azanac container "container_1" plugins install "hoge:1.2.0"
```

## packages

```sh
azanac packages info
azanac packages ls
azanac packages list
azanac packages find "hoge"
azanac packages update
```
