type Bases* = object
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
  bases*: Bases
  plugins*: seq[Plugin]
  scripts*: seq[Script]


type ContainerPlugins* = object
  enabled*: seq[Plugin]
  disabled*: seq[Plugin]

type ContainerScripts* = object
  enabled*: seq[Script]
  disabled*: seq[Script]

type ContainerYaml* = object
  container_name*: string
  bases*: Bases
  plugins*: ContainerPlugins
  scripts*: ContainerScripts


type PackagesYamlPluginVersion* = object
  version*: string
  url*: string
  sha3_512_hash*: string

type PackagesYamlPlugin* = object
  id*: string
  name*: string
  description*: string
  tags*: seq[string]
  author*: string
  website*: string
  versions*: seq[PackagesYamlPluginVersion]

type PackagesYamlBasisVersion* = object
  version*: string
  url*: string
  sha3_512_hash*: string

type PackagesYamlBasis* = object
  id*: string
  name*: string
  description*: string
  website*: string
  versions*: seq[PackagesYamlBasisVersion]

type PackagesYaml* = object
  bases*: seq[PackagesYamlBasis]
  plugins*: seq[PackagesYamlPlugin]
