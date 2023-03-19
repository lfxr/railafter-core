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

func find*(p: ref Packages, query: string): seq[PackagesPlugin] =
  for plugin in p.yaml.plugins:
    if query in plugin.id or
      query in plugin.name or
      query in plugin.description or
      query in plugin.tags or
      query in plugin.author or
      query in plugin.website:
      result.add(plugin)
