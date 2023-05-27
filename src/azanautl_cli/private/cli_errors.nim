import
  strformat


func invalidNumberOfArgsError*(
    commandName: string,
    expected, acutual: Natural
): string =
  fmt"コマンド'{commandName}'は{expected}個の引数を取りますが、{acutual}個の引数が与えられました"


func unknownCommandError*(commandName: string): string =
  fmt"コマンド'{commandName}'は存在しません"

