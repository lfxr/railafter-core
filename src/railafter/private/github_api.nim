import
  httpclient,
  json,
  options,
  strformat,
  strutils,
  tables,
  times

import
  plugin,
  types


type GitHubApi* = object
  version: string
  responseHeaders: tuple[
    rateLimitReset: string
  ]
  urls: tuple[
    rateLimit: string
  ]


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
  result.responseHeaders = (
    rateLimitReset: "x-ratelimit-reset"
  )
  result.urls = (
    rateLimit: "https://api.github.com/rate_limit"
  )


proc rateLimitResetDateTime(api: ref GitHubApi): Result[string] =
  ## レート制限のリセット日時を取得
  result = result.typeof()()
  var requestResult: Response

  try:
    requestResult = newHttpClient().get(api.urls.rateLimit)
  except OSError as e:
    result.err = option(
      Error(
        kind: connectionTimedOutError,
        url: api.urls.rateLimit,
        statusMessage: e.msg
      )
    )
    return

  let unixTime = (
    $requestResult.headers[api.responseHeaders.rateLimitReset]
  ).parseInt
  result.res = $unixTime.fromUnix


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
    if "rate limit exceeded" in e.msg:
      let
        res = result
        rateLimitResetDateTime = asset.repository.api.rateLimitResetDateTime
      rateLimitResetDateTime.err.map(
        func(err: Error) = res.err = option(err)
      )
      if res.err.isSome: return
      result.err = option(Error(
        kind: githubApiRateLimitExceededError,
        rateLimitResetDateTime: rateLimitResetDateTime.res
      ))
    else:
      result.err = option(Error(
        kind: httpRequestError,
        url: asset.url,
        statusMessage: e.msg
      ))
    return
  except IOError:
    result.err = option(Error(kind: fileWritingError, filePath: filename))
    return
  except OSError as e:
    result.err = option(
      Error(
        kind: connectionTimedOutError,
        url: asset.url,
        statusMessage: e.msg
      )
    )
    return


proc downloadPlugin*(
    api: ref GitHubApi,
    plugin: ref Plugin,
    filePath: string
): Result[void] =
  ## 指定されたファイルパスにプラグインのZIPファイルをダウンロード
  result = result.typeof()()

  let pluginVersionDataResult = plugin.versionData

  if pluginVersionDataResult.err.isSome:
    result.err = pluginVersionDataResult.err
    return

  if not plugin.canBeDownloadedViaGitHubApi.res:
    result.err = option(
      Error(
        kind: pluginSpecifiedVersionCannotBeDownloadedViaGitHubApiError
      )
    )
    return

  let
    githubRepository = plugin.packageInfo.githubRepository
    owner = githubRepository.get.owner
    repo = githubRepository.get.repo
    assetId = pluginVersionDataResult.res.githubAssetId.get

  let res =
    newGitHubApi()
      .repository((owner: owner, repo: repo))
      .asset(assetId)
      .download(filePath)

  if res.err.isSome:
    result.err = res.err
    return
