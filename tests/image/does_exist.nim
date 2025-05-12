import
  unittest

import
  ../../src/azanautl_cli/private/image


proc main =
  const ImagesDirPath = "testdata/image/does_exist"

  block:
    let image = newImage("", "")
    check not image.doesExist
  
  block:
    let image = newImage("", "exist-image")
    check not image.doesExist

  block:
    let image = newImage(ImagesDirPath, "exist-image")
    check image.doesExist

  block:
    let image = newImage(ImagesDirPath, "unexist-image")
    check not image.doesExist

  block:
    let image = newImage(ImagesDirPath, "just-dir")
    check not image.doesExist


when isMainModule: main()
