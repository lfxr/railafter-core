import
  options,
  os,
  unittest

import
  ../../src/azanautl_cli/private/github_api,
  ../../src/azanautl_cli/private/types


proc main =
  const
    CooldownTimeMilliseconds = 2 * 1000
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
      ).asset(110174731).download("hoge.zip")
    check res.err.isNone

  sleep CooldownTimeMilliseconds

  # httpRequestError
  block:
    let res = ghApi.repository(
      (owner: "lafixier", repo: "release-test")
    ).asset(-1).download("hoge.zip")
    check res.err.isSome
    let err = res.err.get()
    check err.kind == httpRequestError
    check err.url == GitHubApiTestRepoUrl & "releases/assets/-1"
    check err.statusMessage == StatusMessages.notFound

  sleep CooldownTimeMilliseconds

  # httpRequestError
  block:
    let res = ghApi.repository(
      (owner: "lafixier", repo: "_")
    ).asset(110174731).download("hoge.zip")
    check res.err.isSome
    let err = res.err.get()
    check err.kind == httpRequestError
    check err.url == "https://api.github.com/repos/lafixier/_/releases/assets/110174731"
    check err.statusMessage == StatusMessages.notFound

  sleep CooldownTimeMilliseconds

  # httpRequestError
  block:
    let res = ghApi.repository(
      (owner: "lafixier", repo: "あ")
    ).asset(110174731).download("hoge.zip")
    check res.err.isSome
    let err = res.err.get()
    check err.kind == httpRequestError
    check err.url == "https://api.github.com/repos/lafixier/あ/releases/assets/110174731"
    check err.statusMessage == StatusMessages.badRequest

  sleep CooldownTimeMilliseconds

  block:
    let res = ghApi.repository(
      (owner: "lafixier", repo: "release-test")
    ).asset(110174731).download("hoge.zip")
    check res.err.isNone

  sleep CooldownTimeMilliseconds

  # fileWritingError
  block:
    let res = ghApi.repository(
      (owner: "lafixier", repo: "release-test")
    ).asset(110174731).download("")
    check res.err.isSome
    let err = res.err.get()
    check err.kind == fileWritingError
    check err.filePath == ""


when isMainModule: main()
