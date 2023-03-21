import
  strutils

import
  nimcrypto

import
  types


func sanitizeFileOrDirName*(s: string): string =
  ## ファイル名やディレクトリ名に含まれる使用できない文字を消去する
  result = s
  const replacingTargets = [
    "..", "/", "\\", ":", "*", "?", "\"", "<", ">", "|"
  ]
  for target in replacingTargets:
    result = result.replace(target, "")

func deserializePlugin*(raw: string): Plugin =
  ## プラグインの文字列をパースし, Pluginオブジェクトに変換する
  let
    pluginId = raw.split(":")[0]
    pluginVersion = raw.split(":")[1]
  Plugin(
    id: pluginId,
    version: pluginVersion
  )

proc sha3_512File*(filePath: string): string =
  ## ファイルのSHA3-512ハッシュ値を計算して返す
  let
    file = open(filePath, fmRead)
    fileContent = file.readAll()
  defer: file.close()
  $sha3_512.digest(fileContent)
