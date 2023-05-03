import
  options,
  sequtils,
  strutils

import
  types,
  yaml_file


type Packages* = object
  yamlFile: PackagesYamlFile
  yaml: PackagesYaml

type PackagesPlugins* = object
  packages: ref Packages

type PackagesPlugin* = object
  packages: ref Packages
  packagesYamlPlugin: PackagesYamlPlugin

type PackagesBases* = object
  packages: ref Packages

type PackagesBasis* = object
  packages: ref Packages
  packagesYamlBasis: PackagesYamlBasis


proc load(p: ref Packages) =
  p.yaml = p.yamlFile.load()

proc newPackages*(filePath: string): ref Packages =
  result = new Packages
  result.yamlFile = PackagesYamlFile(filePath: filePath)
  result.load()

func plugins*(p: ref Packages): PackagesPlugins =
  ## packagesコマンド
  result.packages = p

func list*(p: PackagesPlugins): seq[PackagesYamlPlugin] =
  ## 入手可能なプラグイン一覧を返す
  p.packages.yaml.plugins

func find*(p: PackagesPlugins, query: string): seq[PackagesYamlPlugin] =
  for plugin in p.list:
    if query in plugin.id or
      query in plugin.name or
      query in plugin.description or
      query in plugin.tags or
      query in plugin.author or
      query in plugin.website:
      result.add(plugin)


func plugin*(p: ref Packages, id: string): PackagesPlugin =
  ## packages.pluginコマンド
  result.packagesYamlPlugin = p.plugins.list.filterIt(it.id == id)[0]

func version*(p: PackagesPlugin, version: string): PackagesYamlPluginVersion =
  ## 指定したバージョンのプラグインを返す
  p.packagesYamlPlugin.versions.filterIt(
    if version == "latest": it.isLatest
    else: it.version == version
  )[0]

func dependencies*(p: PackagesPlugin, version: string): Dependencies =
  ## 指定したバージョンの依存関係を返す
  for dependencies in p.packagesYamlPlugin.dependencies.get(@[]):
    if version in dependencies.conformingVersions:
      return dependencies.body

func githubRepository*(p: PackagesPlugin): GitHubRepository =
  ## 指定したプラグインのGitHubリポジトリを返す
  p.packagesYamlPlugin.githubRepository.get

func trackedFilesAndDirs*(p: PackagesPlugin, version: string): seq[
    TrackedFilesAndDirs] =
  for trackedFilesAndDirs in p.packagesYamlPlugin.trackedFilesAndDirs:
    if version in trackedFilesAndDirs.conformingVersions:
      return trackedFilesAndDirs.body

func jobs*(p: PackagesPlugin, version: string): seq[Job] =
  for jobs in p.packagesYamlPlugin.jobs.get(@[]):
    if version in jobs.conformingVersions:
      return jobs.body


func bases*(p: ref Packages): PackagesBases =
  ## packages.basesコマンド
  result.packages = p

func list*(p: PackagesBases): seq[PackagesYamlBasis] =
  ## ベースパッケージ一覧を返す
  p.packages.yaml.bases


func basis*(p: ref Packages, id: string): PackagesBasis =
  ## packages.basisコマンド
  result.packages = p
  result.packagesYamlBasis = p.bases.list.filterIt(it.id == id)[0]

func version*(p: PackagesBasis, version: string): PackagesYamlBasisVersion =
  ## 指定したバージョンのベースパッケージを返す
  p.packagesYamlBasis.versions.filterIt(it.version == version)[0]
