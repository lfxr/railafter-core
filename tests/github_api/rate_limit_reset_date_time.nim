import
  nre,
  options,
  unittest

import
  ../../src/azanautl_cli/private/github_api {.all.},
  ../../src/azanautl_cli/private/types


proc main =
  let ghApi = newGithubApi()

  block:
    let resetDateTime = ghApi.rateLimitResetDateTime
    check resetDateTime.err.isNone
    check resetDateTime.res.match(
      re"^\d{4}(-\d{2}){2}T\d{2}(:\d{2}){2}(Z|[+-]\d{2}:\d{2})?$"
    ).isSome


when isMainModule: main()
