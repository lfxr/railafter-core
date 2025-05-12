import
  options,
  os,
  osproc,
  strutils,
  sugar,
  tables,
  terminal,
  times

import
  nimcrypto

import
  types


proc echoWithColors*(
    msg: string,
    foregroundColor: ForegroundColor,
    backgroundColor: BackgroundColor = bgDefault
) =
  ## 色付きでメッセージを出力する
  styledEcho(foregroundColor, backgroundColor, msg)


proc occurFatalError*(msg: string) =
  ## 致命的なエラーを発生させて終了する
  echoWithColors("[致命的なエラー] " & msg, fgWhite, bgRed)
  quit(1)


proc occurNonfatalError*(msg: string) =
  ## 致命的でないエラーを発生させる
  echoWithColors("[エラー] " & msg, fgRed)


proc showInfo*(msg: string) =
  ## 情報を表示する
  echoWithColors("[情報] " & msg, fgCyan)


func sanitizeFileOrDirName*(s: string): string =
  ## ファイル名やディレクトリ名に含まれる使用できない文字をハイフンに置換する
  result = s
  const replacingTargets = [
    "..", "/", "\\", ":", "*", "?", "\"", "<", ">", "|"
  ]
  for target in replacingTargets:
    result = result.replace(target, "-")


proc sha3_512File*(filePath: string): Result[string] =
  ## ファイルのSHA3-512ハッシュ値を計算して返す
  result = result.typeof()()

  if not fileExists(filePath):
    result.err = option(Error(
      kind: fileDoesNotExistError,
      filePath: filePath
    ))
    return

  let
    file = open(filePath, fmRead)
    fileContent = file.readAll()
  defer: file.close()

  result.res = $sha3_512.digest(fileContent)


proc revealDirInExplorer*(dirPath: string) =
  ## ディレクトリをエクスプローラーで開く
  discard execProcess(
    "explorer.exe",
    args = [dirPath],
    options = {poUsePath}
  )


proc processTrackedFds*(
  trackedFds: seq[TrackedFilesAndDirs],
  moveToTuple: tuple[root, plugins: string],
  useMoveTo: tuple[src, dest: bool],
  dirs: tuple[src, dest: string]
) =
  for trackedFd in trackedFds:
    let
      srcFdPath = (
        if useMoveTo.src:
        (case trackedFd.moveTo:
          of MoveTo.Root: moveToTuple.root
          of MoveTo.Plugins: moveToTuple.plugins)
      else: "") / dirs.src / trackedFd.path
      destFdPath = (
        if useMoveTo.dest:
        (case trackedFd.moveTo:
          of MoveTo.Root: moveToTuple.root
          of MoveTo.Plugins: moveToTuple.plugins)
      else: "") / dirs.dest / trackedFd.path
    case trackedFd.fdType:
    of FdType.File:
      moveFile(srcFdPath, destFdPath)
    of FdType.Dir:
      moveDir(srcFdPath, destFdPath)


proc observeDir*(
    path: string,
    extension: string = "",
    sha3_512Hash: string,
    cooldownTimeMilliseconds: int = 1000
): string =
  ## ディレクトリの変更を監視し,
  ## 指定されたハッシュ値と一致するファイルがあればそのパスを返す
  proc walkFiles: seq[string] =
    collect newSeq: (for file in walkFiles(path / "*." & extension): file)

  var fileAndLastWriteTime = newTable[string, Time]()
  for file in walkFiles():
    fileAndLastWriteTime[file] = file.getFileInfo.lastWriteTime

  while true:
    for file in walkFiles():
      let lastWriteTime = file.getFileInfo.lastWriteTime

      if fileAndLastWriteTime.hasKey(file) and
          lastWriteTime != fileAndLastWriteTime[file] or
          not fileAndLastWriteTime.hasKey(file):
        fileAndLastWriteTime[file] = lastWriteTime

        if sha3_512File(file).res == sha3_512Hash:
          return file
    sleep cooldownTimeMilliseconds
