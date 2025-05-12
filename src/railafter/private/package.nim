import
  options,
  tables

import
  types


type PackageType {.pure.} = enum
  Core = "core",
  Plugin = "plugin",
  Script = "script"


type PackageYaml = object
  id*, name*, version*: string
  package_type*: PackageType
  description*: string
  tags*: seq[string]
  author*: string
  websiteUrl*: string
  github_repository*: Option[string]


type PackageYamlVersion = object
  version*: string
  url*: string
  github_asset_id*: Option[int]
  niconico_commons_id*: Option[string]
  sha3_512_hash*: string
  released_on*: Option[string]
  tracked_file_or_dir_hashes: Table[string, string]


type PackageArchive = tuple
  paths: tuple[
    archiveDir: string,
    zipFile: string,
    extractedDir: string,
  ]


type Package = object of RootObj
  packagesYamlFilePath, defaultBrowserDownloadDirPath*: string
  packageType*: PackageType
  archive*: PackageArchive
  yaml*: PackageYaml
  versionData*: PackageYamlVersion


type CorePackage = object of Package


type ExtensionalPackage = object of Package


proc init(package: ref Package): Result[void] =
  ## Packageオブジェクトのコンストラクタ
  result = result.typeof()()


func newPackage*(id, version: string): Result[ref Package] =
  result = result.typeof()()
  result.res = new Package


func newCorePackage*(id, version: string): Result[ref CorePackage] =
  result = result.typeof()()
  result.res = new CorePackage
