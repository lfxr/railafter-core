import
  strutils

import
  types,
  yaml_file


type Packages* = object
  yamlFile: PackagesYamlFile
  yaml: PackagesYaml


proc load(p: ref Packages) =
  p.yaml = p.yamlFile.load()

proc newPackages*(filePath: string): ref Packages =
  result = new Packages
  result.yamlFile = PackagesYamlFile(filePath: filePath)
  result.load()

func list*(p: ref Packages): PackagesYaml =
  p.yaml
