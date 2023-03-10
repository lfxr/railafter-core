import
  strformat


func raiseNewException(exception: typedesc, message: string) =
  raise newException(exception, message)

func invalidNumberOfArgs*(expectedNumberOfArgs, actualNumberOfArgs: Natural,
    commandName: string) =
  raiseNewException(
    ValueError,
    "Invalid number of arguments: Command '" &
    commandName & "' expected " & $expectedNumberOfArgs &
    " arguments, but got " & $actualNumberOfArgs & " arguments."
  )
