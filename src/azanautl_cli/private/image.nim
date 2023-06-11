import
  options,
  os

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

  openImageYamlFile(image.path, fmWrite):
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
