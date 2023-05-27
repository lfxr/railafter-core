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
  try:
    discard imageYamlFile.load()
  except AssertionDefect:
    discard imageYamlFile.update(ImageYaml())

  var imageYaml {.inject.} = imageYamlFile.load()
  try: body
  finally:
    if mode == fmWrite: discard imageYamlFile.update(imageYaml)


template openContainerYamlFile*(path: string, mode: FileMode, body: untyped) =
  let containerYamlFile = ContainerYamlFile(filePath: path)
  try:
    discard containerYamlFile.load()
  except AssertionDefect:
    discard containerYamlFile.update(ContainerYaml())

  var containerYaml {.inject.} = containerYamlFile.load()
  try: body
  finally:
    if mode == fmWrite: discard containerYamlFile.update(containerYaml)

