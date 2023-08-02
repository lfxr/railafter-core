import
  unittest

import
  ../../src/azanautl_cli/private/container


proc main =
  const ContainersDirPath = "testdata/container/does_exist"

  block:
    let container = newContainer("", "")
    check not container.doesExist
  
  block:
    let container = newContainer("", "exist-container")
    check not container.doesExist

  block:
    let container = newContainer(ContainersDirPath, "exist-container")
    check container.doesExist

  block:
    let container = newContainer(ContainersDirPath, "unexist-container")
    check not container.doesExist

  block:
    let container = newContainer(ContainersDirPath, "just-dir")
    check not container.doesExist


when isMainModule: main()
