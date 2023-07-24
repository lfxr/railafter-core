import
  options,
  unittest

import
  ../../src/azanautl_cli/private/image,
  ../../src/azanautl_cli/private/plugin,
  ../../src/azanautl_cli/private/types


proc main =
  const ImagesDirPath = "testdata/image/does_plugin_exist_in_image"
  let plugin = newPlugin("lafixier/release-test", "1.0").res

  block:
    const ImageId = "unexist-image"
    let
      image = newImage(ImagesDirPath, ImageId)
      res = image.doesPluginExistInImage(plugin)
      err = res.err.get()

    check res.err.isSome
    check err.kind == imageDoesNotExistError
    check err.imageId == ImageId

  block:
    let
      image = newImage(ImagesDirPath, "exist-image")
      pluginWhichExistsInImage = newPlugin("lafixier/release-test", "1.0").res
      res = image.doesPluginExistInImage(pluginWhichExistsInImage)
    
    check not res.err.isSome
    check res.res

  block:
    let
      image = newImage(ImagesDirPath, "exist-image")
      pluginWhichDoesNotExistsInImage = newPlugin(
        "lafixier/release-test",
        "1.1"
      ).res
      res = image.doesPluginExistInImage(pluginWhichDoesNotExistsInImage)

    check not res.err.isSome
    check not res.res


when isMainModule: main()
