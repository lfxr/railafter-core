import
  options,
  os

import
  types,
  yaml_file


type PackagesYamlFileReader* = object
  packagesYamlFilePath: string


func newPackagesYamlFileReader*(
    packagesYamlFilePath: string
): ref PackagesYamlFileReader =
  result = new PackagesYamlFileReader
  result.packagesYamlFilePath = packagesYamlFilePath


proc read*(reader: ref PackagesYamlFileReader): Result[PackagesYaml] =
  ## パッケージYAMLを読み込んで返す
  result = result.typeof()()

  let packagesYamlFilePath = reader.packagesYamlFilePath

  if packagesYamlFilePath == "" or not fileExists(packagesYamlFilePath):
    result.err = option(Error(
      kind: packagesYamlFileDoesNotExistError,
      packagesYamlFilePath: packagesYamlFilePath
    ))
    return

  let packagesYamlFile = PackagesYamlFile(filePath: reader.packagesYamlFilePath)
  result.res = packagesYamlFile.load()
