import
  options,
  unittest

import
  ../../src/azanautl_cli/private/container,
  ../../src/azanautl_cli/private/types


proc main =
  const ContainersDirPath = "testdata/container/list_plugins"

  block:
    const ContainerId = "unexist-container"
    let
      container = newContainer(ContainersDirPath, ContainerId)
      res = container.listPlugins()
      err = res.err.get()

    check res.err.isSome
    check err.kind == containerDoesNotExistError
    check err.containerId == ContainerId

  block:
    let
      container = newContainer(ContainersDirPath, "exist-container-1")
      res = container.listPlugins()
      plugins = res.res

    check not res.err.isSome
    check plugins.len == 0

  block:
    let
      container = newContainer(ContainersDirPath, "exist-container-2")
      res = container.listPlugins()
      plugins = res.res

    check not res.err.isSome
    check plugins == @[
      ContainerPlugin(
        id: "lafixier/release-test",
        version: "1.0",
        is_installed: true,
        is_enabled: true,
        previously_installed_versions: @[]
      ),
      ContainerPlugin(
        id: "lafixier/foo",
        version: "2.1.0",
        is_installed: true,
        is_enabled: false,
        previously_installed_versions: @[]
      ),
      ContainerPlugin(
        id: "lafixier/bar",
        version: "1.1.0",
        is_installed: false,
        is_enabled: false,
        previously_installed_versions: @[]
      ),
    ]


when isMainModule: main()
