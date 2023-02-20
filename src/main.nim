import
  libs/commands/containers,
  libs/commands/images,
  libs/utliem_cli


let uc = newUtliemCli("app")


proc image(args: seq[string]) =
  echo "image command"
  let
    subcommand = args[0]
    options = args[1..^1]
  case subcommand:
    of "ls", "list":
      # images.list(options)
      for image in uc.image.list:
        echo image
    else:
      echo "unknown command"

proc container(args: seq[string]) =
  echo "container command"
  let
    subcommand = args[0]
    options = args[1..^1]
  case subcommand:
    of "ls", "list":
      containers.list options
    else:
      echo "unknown command"


when isMainModule:
  import cligen
  dispatchMulti([main.image], [main.container])
