import
  options,
  os,
  sequtils

import
  templates,
  types


const ContainerYamlFileName = "container.yaml"


type Container* = object
  containersDirPath, dirPath, path: string
  tempDirPath, tempSrcDirPath*: string
  id, name: string
  containerYaml: ContainerYaml


# プロトタイプ宣言
proc loadContainerYaml(container: ref Container): Result[void]
func doesExist*(container: ref Container): bool


proc init(container: ref Container) =
  ## Containerオブジェクトのコンストラクタ
  if not container.doesExist: return

  discard container.loadContainerYaml()


proc newContainer*(
    containersDirPath: string,
    id: string,
    name: string = ""
 ): ref Container =
  result = new Container
  result.containersDirPath = containersDirPath
  result.dirPath = containersDirPath / id
  result.path = containersDirPath / id / ContainerYamlFileName
  result.tempDirPath = result.dirPath / "temp"
  result.tempSrcDirPath = result.tempDirPath / "src"
  result.id = id
  result.name = name
  result.init()


proc loadContainerYaml(container: ref Container): Result[void] =
  ## コンテナのYAMLファイルを読み込む
  result = result.typeof()()

  if not fileExists(container.path):
    result.err = option(Error(
      kind: containerDoesNotExistError,
      containerId: container.id,
    ))
    return

  openContainerYamlFile(container.path, saveChanges = false):
    container.containerYaml = containerYaml


func doesExist*(container: ref Container): bool =
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

  discard container.loadContainerYaml()
  

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
  container.containerYaml = ContainerYaml()


proc listPlugins*(container: ref Container): Result[seq[ContainerPlugin]] =
  ## コンテナに含まれるプラグインの一覧を返す
  result = result.typeof()()

  if not container.doesExist:
    result.err = option(Error(
      kind: containerDoesNotExistError,
      containerId: container.id,
    ))
    return

  result.res = container.containerYaml.plugins


func pluginStatus*(
    container: ref Container,
    pluginId: string
): Result[ContainerPlugin] =
  ## コンテナに含まれるプラグインの状態を返す
  result = result.typeof()()

  if not container.doesExist:
    result.err = option(Error(
      kind: containerDoesNotExistError,
      containerId: container.id,
    ))
    return

  let matchedPlugins = container.listPlugins.res.filterIt(it.id == pluginId)
  if matchedPlugins.len == 0:
    result.err = option(Error(
      kind: pluginDoesNotExistInContainerError,
      pdPluginId: pluginId,
      pContainerId: container.id,
    ))
    return

  result.res = matchedPlugins[0]
