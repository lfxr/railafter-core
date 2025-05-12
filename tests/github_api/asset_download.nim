import
  options,
  os,
  unittest

import
  ../../src/azanautl_cli/private/github_api,
  ../../src/azanautl_cli/private/types


proc sleepForCooldownTimeMilliseconds =
  const CooldownTimeMilliseconds = 2 * 1000
  sleep CooldownTimeMilliseconds


proc main =
  const
    AssetsZipFilePath = "testdata/github_api/assets.zip"
    GitHubApiTestRepoUrl =
      "https://api.github.com/repos/lafixier/release-test/"
    StatusMessages = (
      badRequest: "400 Bad request",
      rateLimitExceeded: "403 rate limit exceeded",
      notFound: "404 Not Found"
    )
  let ghApi = newGitHubApi()

  block:
    let
      res = ghApi.repository(
        (owner: "lafixier", repo: "release-test")
      ).asset(110174731).download(AssetsZipFilePath)
    check res.err.isNone

  sleepForCooldownTimeMilliseconds()

  # httpRequestError
  block:
    let res = ghApi.repository(
      (owner: "lafixier", repo: "release-test")
    ).asset(-1).download(AssetsZipFilePath)
    check res.err.isSome
    let err = res.err.get()
    check err.kind == httpRequestError
    check err.url == GitHubApiTestRepoUrl & "releases/assets/-1"
    check err.statusMessage == StatusMessages.notFound

  sleepForCooldownTimeMilliseconds()

  # httpRequestError
  block:
    let res = ghApi.repository(
      (owner: "lafixier", repo: "_")
    ).asset(110174731).download(AssetsZipFilePath)
    check res.err.isSome
    let err = res.err.get()
    check err.kind == httpRequestError
    check err.url == "https://api.github.com/repos/lafixier/_/releases/assets/110174731"
    check err.statusMessage == StatusMessages.notFound

  sleepForCooldownTimeMilliseconds()

  # httpRequestError
  block:
    let res = ghApi.repository(
      (owner: "lafixier", repo: "あ")
    ).asset(110174731).download(AssetsZipFilePath)
    check res.err.isSome
    let err = res.err.get()
    check err.kind == httpRequestError
    check err.url ==
      "https://api.github.com/repos/lafixier/あ/releases/assets/110174731"
    check err.statusMessage == StatusMessages.badRequest

  sleepForCooldownTimeMilliseconds()

  block:
    let res = ghApi.repository(
      (owner: "lafixier", repo: "release-test")
    ).asset(110174731).download(AssetsZipFilePath)
    check res.err.isNone

  sleepForCooldownTimeMilliseconds()

  # fileWritingError
  block:
    let res = ghApi.repository(
      (owner: "lafixier", repo: "release-test")
    ).asset(110174731).download("")
    check res.err.isSome
    let err = res.err.get()
    check err.kind == fileWritingError
    check err.filePath == ""

  check tryRemoveFile(AssetsZipFilePath)


when isMainModule: main()
