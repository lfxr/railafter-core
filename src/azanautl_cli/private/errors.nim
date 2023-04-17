import
  strutils


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

func dependencyNotSatisfied*(dependencyName: string, expectedVersion,
    actualVersion: string) =
  ## 依存関係が満たされていないエラーを吐く
  raiseNewException(
    ValueError,
    "Dependency not satisfied: Dependency '" &
    dependencyName & "' is not satisfied. Expected version is '" &
    expectedVersion & "', but actual version is '" & actualVersion & "'."
  )

func dependencyNotSatisfied*(dependencyName: string, expectedVersions: seq[
    string], actualVersion: string) =
  ## 依存関係が満たされていないエラーを吐く
  raiseNewException(
    ValueError,
    "Dependency not satisfied: Dependency '" &
    dependencyName & "' is not satisfied. Expected version is '" &
    expectedVersions.join(", ") & "', but actual version is '" & actualVersion & "'."
  )
