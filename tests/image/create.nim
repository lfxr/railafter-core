import
  options,
  unittest

import
  ../../src/azanautl_cli/private/image,
  ../../src/azanautl_cli/private/types


proc main =
  const ImagesDirPath = "testdata/image/create"

  block:
    let image = newImage(ImagesDirPath, "unexist-image-1")

    check not image.create.err.isSome

  block:
    let image = newImage(ImagesDirPath, "unexist-image-2", "Unexist Image 2")

    check not image.create.err.isSome

  block:
    const ImageId = "exist-image"
    let
      image = newImage(ImagesDirPath, ImageId)
      res = image.create()
      err = res.err.get()

    check res.err.isSome
    check err.kind == imageAlreadyExistsError
    check err.imageId == ImageId


when isMainModule: main()
