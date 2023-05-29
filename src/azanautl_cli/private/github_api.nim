import
  httpclient,
  json,
  options,
  strformat,
  strutils,
  tables

import
  types


type GitHubApi* = object
  version: string


type Repository* = object
  api: ref GitHubApi
  owner, repo: string
  url: string


type Asset* = object
  repository: Repository
  id: int
  url: string


func newGitHubApi*(): ref GitHubApi =
  result = new GitHubApi
  result.version = "2022-11-28"


func repository*(api: ref GitHubApi, githubRepository: GitHubRepository): Repository =
  ## 指定したGitHubリポジトリを取得
  result.api = api
  result.owner = githubRepository.owner
  result.repo = githubRepository.repo
  result.url =
    fmt"https://api.github.com/repos/{result.owner}/{result.repo}"


func asset*(repository: Repository, id: int): Asset =
  ## 指定したIDのアセットを取得
  result.repository = repository
  result.id = id
  result.url = fmt"{repository.url}/releases/assets/{id}"


proc download*(asset: Asset, filename: string): Result[void] =
  ## 指定したファイル名でアセットをダウンロード
  result = result.typeof()()
  let
    apiVersion = asset.repository.api.version
    headers = HttpHeaders(
      table: newTable(
        {
          "Accept": @["application/octet-stream"],
          "X-GitHub-Api-Version": @[apiVersion],
        }
      )
    )
  try:
    newHttpClient(headers = headers).downloadFile(asset.url, filename)
  except HttpRequestError as e:
    result.err = option(
      Error(
        kind: httpRequestError,
        url: asset.url,
        statusMessage: e.msg
      )
    )
    return
  except IOError:
    result.err = option(Error(kind: fileWritingError, filePath: filename))
    return
