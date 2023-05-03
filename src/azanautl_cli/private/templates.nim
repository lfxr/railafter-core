import
  types,
  yaml_file


type YamlTemplates* = object
  imageYaml*: ImageYaml
  containerYaml*: ContainerYaml


let yamlTemplates* = YamlTemplates()
  ## YAMLのテンプレート


template openImageYamlFile*(path: string, mode: FileMode, body: untyped) =
  let imageYamlFile = ImageYamlFile(filePath: path)
  var imageYaml {.inject.} = imageYamlFile.load()
  try: body
  finally:
    if mode == fmWrite: discard imageYamlFile.update(imageYaml)

template openContainerYamlFile*(path: string, mode: FileMode, body: untyped) =
  let containerYamlFile = ContainerYamlFile(filePath: path)
  var containerYaml {.inject.} = containerYamlFile.load()
  try: body
  finally:
    if mode == fmWrite: discard containerYamlFile.update(containerYaml)
