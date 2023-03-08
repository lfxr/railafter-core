import
  types


type YamlTemplates* = object
  imageYaml*: ImageYaml
  containerYaml*: ContainerYaml


let yamlTemplates* = YamlTemplates()
