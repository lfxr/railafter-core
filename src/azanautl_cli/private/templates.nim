import
  types,
  yaml_file


type YamlTemplates* = object
  imageYaml*: ImageYaml
  containerYaml*: ContainerYaml


let yamlTemplates* = YamlTemplates()
  ## YAMLのテンプレート


template openImageYamlFile*(filePath: string, mode: FileMode, body: untyped) =
  let imageYamlFile = ImageYamlFile(filePath: filePath)
  var imageYaml {.inject.} = imageYamlFile.load()
  try: body
  finally:
    if mode == fmWrite: discard imageYamlFile.update(imageYaml)

template openContainerYamlFile*(filePath: string, mode: FileMode, body: untyped) =
  let containerYamlFile = ContainerYamlFile(filePath: filePath)
  var containerYaml {.inject.} = containerYamlFile.load()
  try: body
  finally:
    if mode == fmWrite: discard containerYamlFile.update(containerYaml)
