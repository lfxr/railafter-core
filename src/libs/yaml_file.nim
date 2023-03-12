import
  streams

import
  yaml/serialization

import
  types


type YamlFile = object of RootObj
  filePath*: string

proc load[T](yamlFile: YamlFile, obj: var T): T =
  ## YAMLファイルを読み込んで返す
  let fileStream = newFileStream(yamlFile.filePath)
  fileStream.load(obj)
  fileStream.close()

proc updateY[T](yamlFile: YamlFile, obj: T): T =
  ## YAMLファイルを更新する
  let fileStream = newFileStream(yamlFile.filePath, fmWrite)
  obj.dump(fileStream)
  fileStream.close()

type ImageYamlFile* = object of YamlFile
  discard

proc load*(imageYamlFile: ImageYamlFile): ImageYaml =
  ## イメージファイルを読み込んで返す
  var imageYaml: ImageYaml
  discard imageYamlFile.load(imageYaml)
  return imageYaml

proc update*(imageYamlFile: ImageYamlFile, imageYaml: ImageYaml): ImageYaml =
  ## イメージファイルを更新する
  discard imageYamlFile.updateY(imageYaml)


type ContainerYamlFile* = object of YamlFile
  discard

proc load*(containerYamlFile: ContainerYamlFile): ContainerYaml =
  ## コンテナファイルを読み込んで返す
  var containerYaml: ContainerYaml
  discard containerYamlFile.load(containerYaml)
  return containerYaml

proc update*(containerYamlFile: ContainerYamlFile, containerYaml: ContainerYaml): ContainerYaml =
  ## コンテナファイルを更新する
  discard containerYamlFile.updateY(containerYaml)
