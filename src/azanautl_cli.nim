import
  options,
  strutils

import
  azanautl_cli/private/cli_errors,
  azanautl_cli/private/procs,
  azanautl_cli/private/types,
  azanautl_cli/azanautl,
  azanautl_cli/errors


let auc = newAzanaUtlCli("app")


proc images(args: seq[string]) =
  ## imagesコマンド
  echo "images command"
  let
    subcommand = args[0]
    options = args[1..^1]
  case subcommand:
    of "list", "ls":
      # images.list(options)
      const commandName = "images list"
      const expectedNumberOfArgs: Natural = 0
      if options.len != expectedNumberOfArgs:
        occurFatalError(
          invalidNumberOfArgsError(commandName, expectedNumberOfArgs, options.len)
        )
      for image in auc.images.list:
        echo image
    of "create":
      const commandName = "images create"
      echo commandName
      const expectedNumberOfArgs: Natural = 2
      if options.len != expectedNumberOfArgs:
        occurFatalError(
          invalidNumberOfArgsError(commandName, expectedNumberOfArgs, options.len)
        )
      let 
        imageId = options[0]
        imageName = options[1]
      auc.images.create(imageId, imageName).err.map(
        proc(err: Error) = occurFatalError(err.message)
      )
    of "delete", "del":
      const commandName = "images delete"
      echo commandName
      const expectedNumberOfArgs: Natural = 1
      if options.len != expectedNumberOfArgs:
        occurFatalError(
          invalidNumberOfArgsError(commandName, expectedNumberOfArgs, options.len)
        )
      let imageId = options[0]
      auc.images.delete(imageId).err.map(
        proc(err: Error) = occurFatalError(err.message)
      )
    else:
      echo "unknown command"

proc image(args: seq[string]) =
  ## imageコマンド
  echo "image command"
  let
    imageId = args[0]
    subcommand = args[1]
    options = args[2..^1]
  case subcommand:
    of "plugins":
      case options[0]:
        of "list", "ls":
          const commandName = "plugins list"
          echo commandName
          const expectedNumberOfArgs: Natural = 0
          if options[1..^1].len != expectedNumberOfArgs:
            occurFatalError(
              invalidNumberOfArgsError(
                commandName, expectedNumberOfArgs, options[1..^1].len
              )
            )
          echo auc.image(imageId).plugins.list
        of "add":
          const commandName = "plugins add"
          echo commandName
          const expectedNumberOfArgs: Natural = 1
          if options[1..^1].len != expectedNumberOfArgs:
            occurFatalError(
              invalidNumberOfArgsError(
                commandName, expectedNumberOfArgs, options[1..^1].len
              )
            )
          let plugin = deserializePlugin(options[1])
          auc.image(imageId).plugins.add(plugin)
        of "delete", "del":
          const commandName = "plugins delete"
          echo commandName
          const expectedNumberOfArgs: Natural = 1
          if options[1..^1].len != expectedNumberOfArgs:
            occurFatalError(
              invalidNumberOfArgsError(
                commandName, expectedNumberOfArgs, options[1..^1].len
              )
            )
          let pluginId = options[1]
          auc.image(imageId).plugins.delete(pluginId)
        else:
          echo "unknown command"
    else:
      echo "unknown command"

proc containers(args: seq[string]) =
  ## containersコマンド
  echo "containers command"
  let
    subcommand = args[0]
    options = args[1..^1]
  case subcommand:
    of "list", "ls":
      const commandName = "containers list"
      const expectedNumberOfArgs: Natural = 0
      if options.len != expectedNumberOfArgs:
        occurFatalError(
          invalidNumberOfArgsError(commandName, expectedNumberOfArgs, options.len)
        )
      for container in auc.containers.list:
        echo container
    of "create":
      const commandName = "containers create"
      echo commandName
      const expectedNumberOfArgs: Natural = 3
      if options.len != expectedNumberOfArgs:
        occurFatalError(
          invalidNumberOfArgsError(commandName, expectedNumberOfArgs, options.len)
        )
      let
        containerId = options[0]
        containerName = options[1]
        imageId = options[2]
      auc.containers.create(containerId, containerName, imageId).err.map(
        proc(err: Error) = occurFatalError(err.message)
      )
    of "delete", "del":
      const commandName = "containers delete"
      echo commandName
      const expectedNumberOfArgs: Natural = 1
      if options.len != expectedNumberOfArgs:
        occurFatalError(
          invalidNumberOfArgsError(commandName, expectedNumberOfArgs, options.len)
        )
      let containerId = options[0]
      auc.containers.delete(containerId).err.map(
        proc(err: Error) = occurFatalError(err.message)
      )
    else:
      echo "unknown command"

proc container(useBrowser: bool = false, args: seq[string]) =
  ## containerコマンド
  echo "container command"
  let
    containerId = args[0]
    subcommand = args[1]
    options = args[2..^1]
  case subcommand:
    of "bases":
      case options[0]:
        of "get":
          const commandName = "container bases get"
          echo commandName
          const expectedNumberOfArgs: Natural = 0
          if options[1..^1].len != expectedNumberOfArgs:
            occurFatalError(
              invalidNumberOfArgsError(
                commandName, expectedNumberOfArgs, options[1..^1].len
              )
            )
          auc.container(containerId).bases.get.err.map(
            proc(err: Error) = occurFatalError(err.message)
          )
    of "plugins":
      case options[0]:
        of "download", "dl":
          const commandName = "container plugins download"
          echo commandName
          const expectedNumberOfArgs: Natural = 1
          if options[1..^1].len != expectedNumberOfArgs:
            occurFatalError(
              invalidNumberOfArgsError(
                commandName, expectedNumberOfArgs, options[1..^1].len
              )
            )
          let plugin = deserializePlugin(options[1])
          auc.container(containerId).plugins.download(plugin, useBrowser)
            .err.map(
              proc(err: Error) = occurFatalError(err.message)
            )
        of "install", "i":
          const commandName = "container plugins install"
          echo commandName
          const expectedNumberOfArgs: Natural = 1
          if options[1..^1].len != expectedNumberOfArgs:
            occurFatalError(
              invalidNumberOfArgsError(
                commandName, expectedNumberOfArgs, options[1..^1].len
              )
            )
          let plugin = deserializePlugin(options[1])
          auc.container(containerId).plugins.install(plugin).err.map(
            proc(err: Error) = occurFatalError(err.message)
          )
        of "enable":
          const commandName = "container plugins enable"
          echo commandName
          const expectedNumberOfArgs: Natural = 1
          if options[1..^1].len != expectedNumberOfArgs:
            occurFatalError(
              invalidNumberOfArgsError(
                commandName, expectedNumberOfArgs, options[1..^1].len
              )
            )
          let pluginId = options[1]
          auc.container(containerId).plugins.enable(pluginId)
        of "disable":
          const commandName = "container plugins disable"
          echo commandName
          const expectedNumberOfArgs: Natural = 1
          if options[1..^1].len != expectedNumberOfArgs:
            occurFatalError(
              invalidNumberOfArgsError(
                commandName, expectedNumberOfArgs, options[1..^1].len
              )
            )
          let pluginId = options[1]
          auc.container(containerId).plugins.disable(pluginId)
        else:
          echo "unknown command"
    else:
      echo "unknown command"

proc packages(args: seq[string]) =
  ## packagesコマンド
  echo "packages command"
  let
    subcommand = args[0]
    options = args[1..^1]
  case subcommand:
    of "bases":
      case options[0]:
        of "list", "ls":
          const commandName = "packages bases list"
          echo commandName
          const expectedNumberOfArgs: Natural = 0
          if options[1..^1].len != expectedNumberOfArgs:
            occurFatalError(
              invalidNumberOfArgsError(
                commandName, expectedNumberOfArgs, options[1..^1].len
              )
            )
          for basis in auc.packages.bases.list:
            echo basis
        else:
          echo "unknown command"
    of "plugins":
      case options[0]
        of "list", "ls":
          const commandName = "packages list"
          const expectedNumberOfArgs: Natural = 0
          if options.len != expectedNumberOfArgs:
            occurFatalError(
              invalidNumberOfArgsError(
                commandName, expectedNumberOfArgs, options.len
              )
            )
          echo auc.packages.plugins.list
        of "find":
          const commandName = "packages find"
          echo commandName
          const expectedNumberOfArgs: Natural = 1
          if options.len != expectedNumberOfArgs:
            occurFatalError(
              invalidNumberOfArgsError(
                commandName, expectedNumberOfArgs, options.len
              )
            )
          let query = options[0]
          echo auc.packages.plugins.find(query)
        else:
          echo "unknown command"
    else:
      echo "unknown command"


when isMainModule:
  import cligen
  dispatchMulti(
    [azanautl_cli.images],
    [azanautl_cli.image],
    [azanautl_cli.containers],
    [azanautl_cli.container, short = {"useBrowser": 'b'}],
    [azanautl_cli.packages]
  )
