# Package

version       = "0.2.0"
author        = "Lafixier Rafinantoka"
description   = "Core of Railafter, package manager for AviUtl"
license       = "MIT"
srcDir        = "src"


# Dependencies

requires "nim >= 1.6.10"
requires "nimcrypto >= 0.5.4"
requires "yaml >= 1.0.0"
requires "zippy >= 0.10.10"


# Tasks

task precommit, "Pre-commit runs this":
  exec "nimble format"
  exec "nimble lint"
  exec "nimble typos"
  exec "nimble lslint"

task format, "Format Nim files":
  exec "nim c --hints:off -r tasks/format.nim"

task lint, "Lint Nim files":
  exec "nim c --hints:off -r tasks/lint.nim"

task apidocs, "Generate API documentation":
  exec "nim doc --project --index:on --outdir:docs/api src/azanautl_cli/azanautl.nim"

task typos, "Check for typos":
  exec "typos"

task lslint, "Run ls-lint":
  exec "ls-lint"

task preparetestdata, "Prepare test data":
  exec "nim c --hints:off -r tasks/prepare_testdata.nim"

task removetestdata, "Remove test data":
  exec "nim c --hints:off -r tasks/remove_testdata.nim"

task test, "Run tests":
  exec "nimble preparetestdata"
  exec "testament p 'tests/*/*.nim'"
  exec "nimble removetestdata"
