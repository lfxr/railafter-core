import
  options,
  os,
  sequtils

import
  plugin,
  templates,
  types


const ImageYamlFileName = "image.yaml"


type Image* = object
  imagesDirPath, dirPath, path: string
  id, name: string
  imageYaml: ImageYaml


# プロトタイプ宣言
proc loadImageYaml(image: ref Image): Result[void]
func doesExist*(image: ref Image): bool


proc init(image: ref Image) =
  ## Imageオブジェクトのコンストラクタ
  if not image.doesExist: return

  discard image.loadImageYaml()


proc newImage*(
    imagesDirPath: string,
    id: string,
    name: string = ""
 ): ref Image =
  result = new Image
  result.imagesDirPath = imagesDirPath
  result.dirPath = imagesDirPath / id
  result.path = imagesDirPath / id / ImageYamlFileName
  result.id = id
  result.name = name
  result.init()


proc loadImageYaml(image: ref Image): Result[void] =
  ## イメージのYAMLファイルを読み込む
  result = result.typeof()()

  if not fileExists(image.path):
    result.err = option(Error(
      kind: imageDoesNotExistError,
      imageId: image.id,
    ))
    return

  openImageYamlFile(image.path, saveChanges = false):
    image.imageYaml = imageYaml


func doesExist*(image: ref Image): bool =
  ## イメージが存在するかどうかを返す
  result = fileExists(image.path)


proc create*(image: ref Image): Result[void] =
  ## イメージを作成する
  result = result.typeof()()

  if image.doesExist:
    result.err = option(Error(
      kind: imageAlreadyExistsError,
      imageId: image.id,
    ))
    return

  createDir image.dirPath

  openImageYamlFile(image.path, saveChanges = true):
    imageYaml = ImageYaml(
      imageId: image.id,
      imageName: image.name,
    )

  discard image.loadImageYaml()
  

proc delete*(image: ref Image): Result[void] =
  ## イメージを削除する
  result = result.typeof()()

  if not image.doesExist:
    result.err = option(Error(
      kind: imageDoesNotExistError,
      imageId: image.id,
    ))
    return

  removeDir(image.dirPath)
  image.imageYaml = ImageYaml()


proc listPlugins*(image: ref Image): Result[seq[Plugin]] =
  ## イメージに含まれるプラグインの一覧を返す
  result = result.typeof()()

  if not image.doesExist:
    result.err = option(Error(
      kind: imageDoesNotExistError,
      imageId: image.id,
    ))
    return

  result.res = image.imageYaml.plugins.mapIt(
    Plugin(id: it.id, version: it.version)
  )


proc doesPluginExistInImage*(
    image: ref Image,
    plugin: ref Plugin
): Result[bool] =
  ## イメージにプラグインが含まれるかどうかを返す
  result = result.typeof()()

  if not image.doesExist:
    result.err = option(Error(
      kind: imageDoesNotExistError,
      imageId: image.id,
    ))
    return

  result.res = image.listPlugins.res.contains(plugin[])


proc doesPluginExistInImage*(
    image: ref Image,
    pluginId: string
): Result[bool] =
  ## イメージにプラグインが含まれるかどうかを返す
  result = result.typeof()()

  if not image.doesExist:
    result.err = option(Error(
      kind: imageDoesNotExistError,
      imageId: image.id,
    ))
    return

  result.res = image.listPlugins.res.filterIt(it.id == pluginId).len != 0


proc addPlugin*(image: ref Image, plugin: ref Plugin): Result[void] =
  ## プラグインをイメージに追加する
  result = result.typeof()()

  if not image.doesExist:
    result.err = option(Error(
      kind: imageDoesNotExistError,
      imageId: image.id,
    ))
    return

  if image.doesPluginExistInImage(plugin.id).res:
    result.err = option(Error(
      kind: pluginAlreadyExistsInImageError,
      pluginId: plugin.id,
      pImageId: image.id,
    ))
    return

  openImageYamlFile(image.path, saveChanges = true):
    imageYaml.plugins.add(
      ImagePlugin(id: plugin.id, version: plugin.version)
    )

  discard image.loadImageYaml()


proc removePlugin*(image: ref Image, pluginId: string): Result[void] =
  ## プラグインをイメージから削除する
  result = result.typeof()()

  if not image.doesExist:
    result.err = option(Error(
      kind: imageDoesNotExistError,
      imageId: image.id,
    ))
    return

  if not image.doesPluginExistInImage(pluginId).res:
    result.err = option(Error(
      kind: pluginDoesNotExistInImageError,
      pluginId: pluginId,
      pImageId: image.id,
    ))
    return

  openImageYamlFile(image.path, saveChanges = true):
    imageYaml.plugins.keepItIf(it.id != pluginId)

  discard image.loadImageYaml()
