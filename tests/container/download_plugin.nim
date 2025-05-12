import
  options,
  os,
  unittest

import
  ../../src/azanautl_cli/private/container,
  ../../src/azanautl_cli/private/plugin,
  ../../src/azanautl_cli/private/types,
  ../../src/azanautl_cli/private/utils


proc main =
  const
    ContainersDirPath = "testdata/container/download_plugin"
    PackagesYamlFilePath = "testdata_original/container/packages.yaml"

  block:
    const ContainerId = "unexist-container"
    let
      unexistContainer = newContainer(ContainersDirPath, ContainerId)
      plugin = newPlugin("lafixier/release-test").res
      res = unexistContainer.downloadPlugin(plugin)
      err = res.err.get()

    check res.err.isSome
    check err.kind == containerDoesNotExistError
    check err.containerId == ContainerId

  block:
    const ContainerId = "exist-container-1"
    let
      container = newContainer(ContainersDirPath, ContainerId)
      unexistPlugin = newPlugin(
        "lafixier/unexist-plugin",
        packagesYamlFilePath = PackagesYamlFilePath
      ).res
      res = container.downloadPlugin(unexistPlugin)
      err = res.err.get()

    check res.err.isSome
    check err.kind == pluginDoesNotExistError
    check err.pPluginId == unexistPlugin.id

  block:
    const ContainerId = "exist-container-2"
    let
      container = newContainer(ContainersDirPath, ContainerId)
      pluginUnexistVersion = newPlugin(
        "lafixier/release-test",
        "v-1.0",
        PackagesYamlFilePath
      ).res
      res = container.downloadPlugin(pluginUnexistVersion)
      err = res.err.get()

    check res.err.isSome
    check err.kind == pluginSpecifiedVersionDoesNotExistError
    check err.psPluginId == pluginUnexistVersion.id
    check err.pluginVersion == pluginUnexistVersion.version

  block:
    const ContainerId = "exist-container-3"
    let
      container = newContainer(ContainersDirPath, ContainerId)
      plugin = newPlugin(
        "lafixier/release-test",
        "v1.0",
        PackagesYamlFilePath
      ).res
      res = container.downloadPlugin(plugin)
      assetsFilePath = container.tempSrcDirPath / "assets.zip"
      expectedAssetsFileSha3_512 = plugin.versionData.res.sha3_512_hash

    check res.err.isNone
    check fileExists(assetsFilePath)
    check sha3_512File(assetsFilePath).res == expectedAssetsFileSha3_512


when isMainModule: main()
