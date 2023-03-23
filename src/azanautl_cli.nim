import
  strutils

import
  azanautl_clipkg/errors,
  azanautl_clipkg/commands/containers,
  # azanautl_clipkg/commands/images,
  azanautl_clipkg/procs,
  azanautl_clipkg/types,
  azanautl_clipkg/azanautl


let uc = newUtliemCli("app")


proc images(args: seq[string]) =
  ## imagesコマンド
  echo "images command"
  let
    subcommand = args[0]
    options = args[1..^1]
  case subcommand:
    of "ls", "list":
      # images.list(options)
      const commandName = "images list"
      const expectedNumberOfArgs: Natural = 0
      if options.len != expectedNumberOfArgs: invalidNumberOfArgs(
          expectedNumberOfArgs, options.len, commandName)
      for image in uc.images.list:
        echo image
    of "create":
      const commandName = "images create"
      echo commandName
      const expectedNumberOfArgs: Natural = 1
      if options.len != expectedNumberOfArgs: invalidNumberOfArgs(
          expectedNumberOfArgs, options.len, commandName)
      let imageName = options[0]
      uc.images.create(imageName)
    of "del", "delete":
      const commandName = "images delete"
      echo commandName
      const expectedNumberOfArgs: Natural = 1
      if options.len != expectedNumberOfArgs: invalidNumberOfArgs(
          expectedNumberOfArgs, options.len, commandName)
      let imageName = options[0]
      uc.images.delete(imageName)
    else:
      echo "unknown command"

proc image(args: seq[string]) =
  ## imageコマンド
  echo "image command"
  let
    imageName = args[0]
    subcommand = args[1]
    options = args[2..^1]
  case subcommand:
    of "plugins":
      case options[0]:
        of "ls", "list":
          const commandName = "plugins list"
          echo commandName
          const expectedNumberOfArgs: Natural = 0
          if options[1..^1].len != expectedNumberOfArgs: invalidNumberOfArgs(
              expectedNumberOfArgs, options[1..^1].len, commandName)
          echo uc.image(imageName).plugins.list
        of "add":
          const commandName = "plugins add"
          echo commandName
          const expectedNumberOfArgs: Natural = 1
          if options[1..^1].len != expectedNumberOfArgs: invalidNumberOfArgs(
              expectedNumberOfArgs, options[1..^1].len, commandName)
          let plugin = deserializePlugin(options[1])
          uc.image(imageName).plugins.add(plugin)
        of "del", "delete":
          const commandName = "plugins delete"
          echo commandName
          const expectedNumberOfArgs: Natural = 1
          if options[1..^1].len != expectedNumberOfArgs: invalidNumberOfArgs(
              expectedNumberOfArgs, options[1..^1].len, commandName)
          let pluginId = options[1]
          uc.image(imageName).plugins.delete(pluginId)
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
    of "ls", "list":
      const commandName = "containers list"
      const expectedNumberOfArgs: Natural = 0
      if options.len != expectedNumberOfArgs: invalidNumberOfArgs(
          expectedNumberOfArgs, options.len, commandName)
      for container in uc.containers.list:
        echo container
    of "create":
      const commandName = "containers create"
      echo commandName
      const expectedNumberOfArgs: Natural = 2
      if options.len != expectedNumberOfArgs: invalidNumberOfArgs(
          expectedNumberOfArgs, options.len, commandName)
      let
        containerName = options[0]
        imageName = options[1]
      uc.containers.create(containerName, imageName)
    of "del", "delete":
      const commandName = "containers delete"
      echo commandName
      const expectedNumberOfArgs: Natural = 1
      if options.len != expectedNumberOfArgs: invalidNumberOfArgs(
          expectedNumberOfArgs, options.len, commandName)
      let containerName = options[0]
      uc.containers.delete(containerName)
    else:
      echo "unknown command"

proc container(args: seq[string]) =
  ## containerコマンド
  echo "container command"
  let
    containerName = args[0]
    subcommand = args[1]
    options = args[2..^1]
  case subcommand:
    of "plugins":
      case options[0]:
        of "dl", "download":
          const commandName = "container plugins download"
          echo commandName
          const expectedNumberOfArgs: Natural = 1
          if options[1..^1].len != expectedNumberOfArgs: invalidNumberOfArgs(
              expectedNumberOfArgs, options[1..^1].len, commandName)
          let plugin = deserializePlugin(options[1])
          uc.container(containerName).plugins.download(plugin)
        of "install":
          const commandName = "container plugins install"
          echo commandName
          const expectedNumberOfArgs: Natural = 1
          if options[1..^1].len != expectedNumberOfArgs: invalidNumberOfArgs(
              expectedNumberOfArgs, options[1..^1].len, commandName)
          let plugin = deserializePlugin(options[1])
          uc.container(containerName).plugins.install(plugin)
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
    of "plugins":
      case options[0]
        of "ls", "list":
          const commandName = "packages list"
          const expectedNumberOfArgs: Natural = 0
          if options.len != expectedNumberOfArgs: invalidNumberOfArgs(
              expectedNumberOfArgs, options.len, commandName)
          echo uc.packages.plugins.list
        of "find":
          const commandName = "packages find"
          echo commandName
          const expectedNumberOfArgs: Natural = 1
          if options.len != expectedNumberOfArgs: invalidNumberOfArgs(
              expectedNumberOfArgs, options.len, commandName)
          let query = options[0]
          echo uc.packages.plugins.find(query)
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
    [azanautl_cli.container],
    [azanautl_cli.packages]
  )
