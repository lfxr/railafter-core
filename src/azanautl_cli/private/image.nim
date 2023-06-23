import
  options,
  os,
  sequtils

import
  templates,
  types


const ImageYamlFileName = "image.yaml"


type Image* = object
  imagesDirPath, dirPath, path: string
  id, name: string


func newImage*(
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


func doesExist(image: ref Image): bool =
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


proc listPlugins*(image: ref Image): Result[seq[Plugin]] =
  ## イメージに含まれるプラグインの一覧を返す
  result = result.typeof()()

  if not image.doesExist:
    result.err = option(Error(
      kind: imageDoesNotExistError,
      imageId: image.id,
    ))
    return

  openImageYamlFile(image.path, saveChanges = false):
    result.res = imageYaml.plugins


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


proc addPlugin*(image: ref Image, plugin: ref Plugin): Result[void] =
  ## プラグインをイメージに追加する
  result = result.typeof()()

  if not image.doesExist:
    result.err = option(Error(
      kind: imageDoesNotExistError,
      imageId: image.id,
    ))
    return

  openImageYamlFile(image.path, saveChanges = true):
    imageYaml.plugins.add(
      Plugin(id: plugin.id, version: plugin.version)
    )


proc removePlugin*(image: ref Image, plugin: ref Plugin): Result[void] =
  ## プラグインをイメージから削除する
  result = result.typeof()()

  if not image.doesExist:
    result.err = option(Error(
      kind: imageDoesNotExistError,
      imageId: image.id,
    ))
    return

  if not image.doesPluginExistInImage(plugin).res:
    result.err = option(Error(
      kind: pluginDoesNotExistInImageError,
      pluginId: plugin.id,
      pImageId: image.id,
    ))
    return

  openImageYamlFile(image.path, saveChanges = true):
    imageYaml.plugins.keepItIf(it.id != plugin.id)
