import
  strutils,
  strformat

import
  private/types


func message*(err: Error): string =
  case err.kind:
  of imageAlreadyExistsError:
    fmt"イメージ'{err.imageId}'は既に存在します"
  of imageDoesNotExistError:
    fmt"イメージ'{err.imageId}'は存在しません"
  of containerAlreadyExistsError:
    fmt"コンテナ'{err.containerId}'は既に存在します"
  of containerDoesNotExistError:
    fmt"コンテナ'{err.containerId}'は存在しません"
  of invalidZipFileHashValueError:
    fmt"ZIPファイル'{err.zipFilePath}'のハッシュ値が不正です;" & '\n' &
    fmt"予期されているハッシュ値: '{err.expectedHashValue}'" & '\n' &
    fmt"実際のハッシュ値: '{err.actualHashValue}'"
  of dependencyNotSatisfiedError:
    fmt"依存関係'{err.dependencyName}'が満たされていません;" & '\n' &
    & "予期されているバージョン: '{err.expectedVersions.join(\",\")}'" &
    '\n' & fmt"実際のバージョン: '{err.actualVersion}'"
  of githubApiRateLimitExceededError:
    "GitHub APIのレート制限に達しました:\n" &
    fmt"制限リセット日時: {err.rateLimitResetDateTime}"
  of httpRequestError:
    "HTTPリクエストエラー:\n" &
    fmt"URL: {err.url}" & '\n' &
    fmt"ステータスメッセージ: {err.statusMessage}"
  of connectionTimedOutError:
    "接続がタイムアウトしました:\n" &
    fmt"URL: {err.url}" & '\n' &
    fmt"ステータスメッセージ: {err.statusMessage}"
  of fileWritingError:
    fmt"ファイル'{err.filePath}'の書き込みに失敗しました"
  of fileDoesNotExistError:
    fmt"ファイル'{err.filePath}'は存在しません"
