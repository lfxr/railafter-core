import
  strutils

import
  types


func sanitizeFileOrDirName*(s: string): string =
  result = s
  const replacingTargets = [
    "..", "/", "\\", ":", "*", "?", "\"", "<", ">", "|"
  ]
  for target in replacingTargets:
    result = result.replace(target, "")

func deserializePlugin*(raw: string): Plugin =
  let
    pluginId = raw.split(":")[0]
    pluginVersion = raw.split(":")[1]
  Plugin(
      id: pluginId,
      version: pluginVersion
  )
