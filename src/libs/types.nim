import
  streams

import
  yaml/serialization


type Base = object
  aviutl_version*: string
  exedit_version*: string

type Plugin* = object
  id*: string
  version*: string

type Script = object
  id*: string
  version*: string

type ImageYaml* = object
  image_name*: string
  base*: Base
  plugins*: seq[Plugin]
  scripts*: seq[Script]


type YamlFile = object of RootObj
  filePath*: string

proc load[T](yamlFile: YamlFile, obj: var T): T =
  let fileStream = newFileStream(yamlFile.filePath)
  fileStream.load(obj)
  fileStream.close

proc updateY[T](yamlFile: YamlFile, obj: T): T =
  let fileStream = newFileStream(yamlFile.filePath, fmWrite)
  obj.dump(fileStream)
  fileStream.close()

type ImageYamlFile* = object of YamlFile
  discard

proc load*(imageYamlFile: ImageYamlFile): ImageYaml =
  var imageYaml: ImageYaml
  discard imageYamlFile.load(imageYaml)
  return imageYaml

proc update*(imageYamlFile: ImageYamlFile, imageYaml: ImageYaml): ImageYaml =
  discard imageYamlFile.updateY(imageYaml)
