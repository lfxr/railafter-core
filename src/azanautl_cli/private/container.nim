import
  options,
  os,
  sequtils

import
  plugin,
  templates,
  types


const ContainerYamlFileName = "container.yaml"


type Container* = object
  containersDirPath, dirPath, path: string
  id, name: string


func newContainer*(
    containersDirPath: string,
    id: string,
    name: string = ""
 ): ref Container =
  result = new Container
  result.containersDirPath = containersDirPath
  result.dirPath = containersDirPath / id
  result.path = containersDirPath / id / ContainerYamlFileName
  result.id = id
  result.name = name


func doesExist(container: ref Container): bool =
  ## コンテナが存在するかどうかを返す
  result = fileExists(container.path)


proc create*(container: ref Container): Result[void] =
  ## コンテナを作成する
  result = result.typeof()()

  if container.doesExist:
    result.err = option(Error(
      kind: containerAlreadyExistsError,
      containerId: container.id,
    ))
    return

  createDir container.dirPath

  openContainerYamlFile(container.path, saveChanges = true):
    containerYaml = ContainerYaml(
      containerId: container.id,
      containerName: container.name,
    )
  

proc delete*(container: ref Container): Result[void] =
  ## コンテナを削除する
  result = result.typeof()()

  if not container.doesExist:
    result.err = option(Error(
      kind: containerDoesNotExistError,
      containerId: container.id,
    ))
    return

  removeDir(container.dirPath)


proc listPlugins*(container: ref Container): Result[seq[ContainerPlugin]] =
  ## コンテナに含まれるプラグインの一覧を返す
  result = result.typeof()()

  if not container.doesExist:
    result.err = option(Error(
      kind: containerDoesNotExistError,
      containerId: container.id,
    ))
    return

  openContainerYamlFile(container.path, saveChanges = false):
    result.res = containerYaml.plugins


proc downloadPlugin*(
    container: ref Container,
    plugin: ref Plugin
): Result[void] =
  ## コンテナにプラグインをダウンロードする
  result = result.typeof()()

  if not container.doesExist:
    result.err = option(Error(
      kind: containerDoesNotExistError,
      containerId: container.id,
    ))
    return

