import
  unittest

import
  ../../src/azanautl_cli/private/utils


proc main =
  check sanitizeFileOrDirName("foo") == "foo"
  check sanitizeFileOrDirName("bar") == "bar"
  check sanitizeFileOrDirName("..") == "-"
  check sanitizeFileOrDirName("/") == "-"
  check sanitizeFileOrDirName("\\") == "-"
  check sanitizeFileOrDirName(":") == "-"
  check sanitizeFileOrDirName("*") == "-"
  check sanitizeFileOrDirName("?") == "-"
  check sanitizeFileOrDirName("\"") == "-"
  check sanitizeFileOrDirName("<") == "-"
  check sanitizeFileOrDirName(">") == "-"
  check sanitizeFileOrDirName("|") == "-"
  check sanitizeFileOrDirName("../foo/bar") == "--foo-bar"


when isMainModule: main()
