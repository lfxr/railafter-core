import
  os

import
  private/types,
  private/image,
  private/plugin

export
  image.create,
  image.delete,
  image.addPlugin,
  image.removePlugin,
  image.listPlugins


type App = object
  dirPath: string


func newApp*(dirPath: string): ref App =
  result = new App
  result.dirPath = dirPath


func newImage*(app: ref App, imageId: string, imageName: string = ""): ref Image =
  result = newImage(
    imagesDirPath = app.dirPath / "images",
    id = imageId,
    name = imageName
  )

func newPlugin*(
    app: ref App,
    pluginId: string,
    pluginVersion: string = ""
): ref Plugin =
  result = newPlugin(
    id = pluginId,
    version = pluginVersion
  )
