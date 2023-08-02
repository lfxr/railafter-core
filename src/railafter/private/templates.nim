import
  types,
  yaml_file


type YamlTemplates* = object
  imageYaml*: ImageYaml
  containerYaml*: ContainerYaml


let yamlTemplates* = YamlTemplates()
  ## YAMLのテンプレート


template openImageYamlFile*(
    path: string,
    saveChanges: bool = false,
    body: untyped
) =
  let imageYamlFile = ImageYamlFile(filePath: path)
  try:
    discard imageYamlFile.load()
  except AssertionDefect:
    discard imageYamlFile.update(ImageYaml())

  var imageYaml {.inject.} = imageYamlFile.load()
  try: body
  finally:
    if saveChanges: discard imageYamlFile.update(imageYaml)


template openContainerYamlFile*(
    path: string,
    saveChanges: bool = false,
    body: untyped
) =
  let containerYamlFile = ContainerYamlFile(filePath: path)
  try:
    discard containerYamlFile.load()
  except AssertionDefect:
    discard containerYamlFile.update(ContainerYaml())

  var containerYaml {.inject.} = containerYamlFile.load()
  try: body
  finally:
    if saveChanges: discard containerYamlFile.update(containerYaml)

