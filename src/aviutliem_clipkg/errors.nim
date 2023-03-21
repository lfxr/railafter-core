func raiseNewException(exception: typedesc, message: string) =
  ## 例外を吐く
  raise newException(exception, message)

func invalidNumberOfArgs*(expectedNumberOfArgs, actualNumberOfArgs: Natural,
    commandName: string) =
  ## 引数の数が不正エラーを吐く
  raiseNewException(
    ValueError,
    "Invalid number of arguments: Command '" &
    commandName & "' expected " & $expectedNumberOfArgs & " argument" &
    (if expectedNumberOfArgs > 1: "s" else: "") &
    ", but got " & $actualNumberOfArgs & " argument" &
    (if actualNumberOfArgs > 1: "s" else: "") &
    "."
  )

func invalidZipFileHashValue*(zipFilePath: string) =
  ## zipファイルのハッシュ値が一致しないエラーを吐く
  raiseNewException(
    ValueError,
    "Invalid zip file hash value: The hash value of zip file '" &
    zipFilePath & "' does not match the correct one."
  )
