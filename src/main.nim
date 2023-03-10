import
  strutils

import
  libs/errors,
  libs/commands/containers,
  # libs/commands/images,
  libs/types,
  libs/utliem_cli


let uc = newUtliemCli("app")


proc images(args: seq[string]) =
  echo "images command"
  let
    subcommand = args[0]
    options = args[1..^1]
  case subcommand:
    of "ls", "list":
      # images.list(options)
      const expectedNumberOfArgs: Natural = 0
      if options.len != expectedNumberOfArgs: invalidNumberOfArgs(
          expectedNumberOfArgs, options.len, "images list")
      for image in uc.images.list:
        echo image
    of "create":
      echo "images create"
      const expectedNumberOfArgs: Natural = 1
      if options.len != expectedNumberOfArgs: invalidNumberOfArgs(
          expectedNumberOfArgs, options.len, "images create")
      let imageName = options[0]
      uc.images.create(imageName)
    of "del", "delete":
      echo "images delete"
      const expectedNumberOfArgs: Natural = 1
      if options.len != expectedNumberOfArgs: invalidNumberOfArgs(
          expectedNumberOfArgs, options.len, "images delete")
      let imageName = options[0]
      uc.images.delete(imageName)
    else:
      echo "unknown command"

proc image(args: seq[string]) =
  echo "image command"
  let
    imageName = args[0]
    subcommand = args[1]
    options = args[2..^1]
  case subcommand:
    of "plugins":
      case options[0]:
        of "ls", "list":
          echo "plugins list"
          const expectedNumberOfArgs: Natural = 0
          if options[1..^1].len != expectedNumberOfArgs: invalidNumberOfArgs(
              expectedNumberOfArgs, options[1..^1].len, "plugins list")
          echo uc.image(imageName).plugins.list
        of "add":
          echo "plugins add"
          const expectedNumberOfArgs: Natural = 1
          if options[1..^1].len != expectedNumberOfArgs: invalidNumberOfArgs(
              expectedNumberOfArgs, options[1..^1].len, "plugins add")
          let
            pluginId = options[1].split(":")[0]
            pluginVersion = options[1].split(":")[1]
            plugin = Plugin(
              id: pluginId,
              version: pluginVersion
            )
          uc.image(imageName).plugins.add(plugin)
        of "del", "delete":
          echo "plugins delete"
          const expectedNumberOfArgs: Natural = 1
          if options[1..^1].len != expectedNumberOfArgs: invalidNumberOfArgs(
              expectedNumberOfArgs, options[1..^1].len, "plugins delete")
          let pluginId = options[1]
          uc.image(imageName).plugins.delete(pluginId)
        else:
          echo "unknown command"
    else:
      echo "unknown command"

proc containers(args: seq[string]) =
  echo "containers command"
  let
    subcommand = args[0]
    options = args[1..^1]
  case subcommand:
    of "ls", "list":
      const expectedNumberOfArgs: Natural = 0
      if options.len != expectedNumberOfArgs: invalidNumberOfArgs(
          expectedNumberOfArgs, options.len, "containers list")
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


when isMainModule:
  import cligen
  dispatchMulti(
    [main.images],
    [main.image],
    [main.containers]
  )
