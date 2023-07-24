import
  options,
  unittest

import
  ../../src/azanautl_cli/private/image,
  ../../src/azanautl_cli/private/plugin,
  ../../src/azanautl_cli/private/types


proc main =
  const ImagesDirPath = "testdata/image/add_plugin"
  let plugin = newPlugin("lafixier/release-test", "1.0").res

  block:
    const ImageId = "unexist-image"
    let
      image = newImage(ImagesDirPath, ImageId)
      res = image.addPlugin(plugin)
      err = res.err.get()

    check res.err.isSome
    check err.kind == imageDoesNotExistError
    check err.imageId == ImageId

  block:
    let image = newImage(ImagesDirPath, "exist-image-1")

    check not image.addPlugin(plugin).err.isSome

  block:
    const ImageId = "exist-image-2"
    let
      image = newImage(ImagesDirPath, ImageId)
      res = image.addPlugin(plugin)
      err = res.err.get()

    check res.err.isSome
    check err.kind == pluginAlreadyExistsInImageError
    check err.pImageId == ImageId


when isMainModule: main()
