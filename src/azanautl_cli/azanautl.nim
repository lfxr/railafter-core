import
  os

import
  private/container,
  private/types,
  private/image,
  private/plugin

export
  image.create,
  image.delete,
  image.addPlugin,
  image.removePlugin,
  image.listPlugins,
  container.listPlugins,
  container.downloadPlugin,
  plugin.versionData


type App = object
  dirPath: string
  packagesYamlFilePath: string


func newApp*(dirPath: string, packagesYamlFilePath: string): ref App =
  result = new App
  result.dirPath = dirPath
  result.packagesYamlFilePath = packagesYamlFilePath


func newImage*(app: ref App, imageId: string, imageName: string = ""): ref Image =
  result = newImage(
    imagesDirPath = app.dirPath / "images",
    id = imageId,
    name = imageName
  )


func newContainer*(
    app: ref App,
    containerId: string,
    containerName: string = ""
): ref Container =
  result = newContainer(
    containersDirPath = app.dirPath / "containers",
    id = containerId,
    name = containerName
  )


func newPlugin*(
    app: ref App,
    pluginId: string,
    pluginVersion: string = ""
): ref Plugin =
  result = newPlugin(
    id = pluginId,
    version = pluginVersion,
    packagesYamlFilePath = app.packagesYamlFilePath
  )
