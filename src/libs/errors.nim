func raiseNewException(exception: typedesc, message: string) =
  raise newException(exception, message)

func invalidNumberOfArgs*(expectedNumberOfArgs, actualNumberOfArgs: Natural,
    commandName: string) =
  raiseNewException(
    ValueError,
    "Invalid number of arguments: Command '" &
    commandName & "' expected " & $expectedNumberOfArgs & " argument" &
    (if expectedNumberOfArgs > 1: "s" else: "") &
    ", but got " & $actualNumberOfArgs & " argument" &
    (if actualNumberOfArgs > 1: "s" else: "") &
    "."
  )
