import
  strutils

import
  types,
  yaml_file


type Packages* = object
  yamlFile: PackagesYamlFile
  yaml: PackagesYaml

type Plugins* = object
  packages: ref Packages


proc load(p: ref Packages) =
  p.yaml = p.yamlFile.load()

proc newPackages*(filePath: string): ref Packages =
  result = new Packages
  result.yamlFile = PackagesYamlFile(filePath: filePath)
  result.load()

func plugins*(p: ref Packages): Plugins =
  ## packagesコマンド
  result.packages = p

func list*(p: Plugins): seq[PackagesYamlPlugin] =
  ## 入手可能なプラグイン一覧を返す
  p.packages.yaml.plugins

func find*(p: Plugins, query: string): seq[PackagesYamlPlugin] =
  for plugin in p.list:
    if query in plugin.id or
      query in plugin.name or
      query in plugin.description or
      query in plugin.tags or
      query in plugin.author or
      query in plugin.website:
      result.add(plugin)
