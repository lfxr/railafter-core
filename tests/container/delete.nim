import
  options,
  unittest

import
  ../../src/azanautl_cli/private/container,
  ../../src/azanautl_cli/private/types


proc main =
  const ContainersDirPath = "testdata/container/delete"

  block:
    let container = newContainer(ContainersDirPath, "exist-container-1")

    check not container.delete.err.isSome

  block:
    let container = newContainer(
      ContainersDirPath,
      "exist-container-2",
      "Exist Container 2"
    )

    check not container.delete.err.isSome

  block:
    const ContainerId = "unexist-container"
    let
      container = newContainer(ContainersDirPath, ContainerId)
      res = container.delete()
      err = res.err.get()

    check res.err.isSome
    check err.kind == containerDoesNotExistError
    check err.containerId == ContainerId


when isMainModule: main()
