import
  options,
  unittest

import
  ../../src/azanautl_cli/private/image,
  ../../src/azanautl_cli/private/types


proc main =
  const ImagesDirPath = "testdata/image/delete"

  block:
    let image = newImage(ImagesDirPath, "exist-image-1")

    check not image.delete.err.isSome

  block:
    let image = newImage(ImagesDirPath, "exist-image-2", "Exist Image 2")

    check not image.delete.err.isSome

  block:
    const ImageId = "unexist-image"
    let
      image = newImage(ImagesDirPath, ImageId)
      res = image.delete()
      err = res.err.get()

    check res.err.isSome
    check err.kind == imageDoesNotExistError
    check err.imageId == ImageId


when isMainModule: main()
