import
  strutils

import
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
      for image in uc.images.list:
        echo image
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
          echo uc.image(imageName).plugins.list
        of "add":
          echo "plugins add"
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
          let pluginId = options[1]
          uc.image(imageName).plugins.delete(pluginId)
        else:
          echo "unknown command"
    else:
      echo "unknown command"

proc container(args: seq[string]) =
  echo "container command"
  let
    subcommand = args[0]
    options = args[1..^1]
  case subcommand:
    of "ls", "list":
      containers.list(options)
    else:
      echo "unknown command"


when isMainModule:
  import cligen
  dispatchMulti(
    [main.images],
    [main.image],
    [main.container]
  )
