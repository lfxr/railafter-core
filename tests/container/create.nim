import
  options,
  unittest

import
  ../../src/azanautl_cli/private/container,
  ../../src/azanautl_cli/private/types


proc main =
  const ContainersDirPath = "testdata/container/create"

  block:
    let container = newContainer(ContainersDirPath, "unexist-container-1")

    check not container.create.err.isSome

  block:
    let container = newContainer(
      ContainersDirPath,
      "unexist-container-2",
      "Unexist Container 2"
    )

    check not container.create.err.isSome

  block:
    const ContainerId = "exist-container"
    let
      container = newContainer(ContainersDirPath, ContainerId)
      res = container.create()
      err = res.err.get()

    check res.err.isSome
    check err.kind == containerAlreadyExistsError
    check err.containerId == ContainerId


when isMainModule: main()
