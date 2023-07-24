import
  options,
  unittest

import
  ../../src/azanautl_cli/private/image,
  ../../src/azanautl_cli/private/plugin,
  ../../src/azanautl_cli/private/types


proc main =
  const ImagesDirPath = "testdata/image/list_plugins"

  block:
    const ImageId = "unexist-image"
    let
      image = newImage(ImagesDirPath, ImageId)
      res = image.listPlugins()
      err = res.err.get()

    check res.err.isSome
    check err.kind == imageDoesNotExistError
    check err.imageId == ImageId

  block:
    let
      image = newImage(ImagesDirPath, "exist-image-1")
      res = image.listPlugins()
      plugins = res.res

    check not res.err.isSome
    check plugins.len == 0

  block:
    let
      image = newImage(ImagesDirPath, "exist-image-2")
      res = image.listPlugins()
      plugins = res.res

    check not res.err.isSome
    check plugins == @[
      Plugin(id: "lafixier/release-test", version: "1.0"),
      Plugin(id: "lafixier/foo", version: "2.1.0"),
    ]


when isMainModule: main()
