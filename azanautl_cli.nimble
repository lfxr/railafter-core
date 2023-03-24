# Package

version       = "0.1.0"
author        = "lafixier"
description   = "A new awesome nimble package"
license       = "Proprietary"
srcDir        = "src"
installExt    = @["nim"]
bin           = @["azanautl-cli"]


# Dependencies

requires "nim >= 1.6.10"
requires "cligen >= 1.5.39"
requires "nimcrypto >= 0.5.4"
requires "yaml >= 1.0.0"
requires "zippy >= 0.10.7"


# Tasks

task precommit, "Pre-commit runs this":
  exec "nimble format"
  exec "nimble lint"
  exec "nimble typos"

task format, "Format Nim files":
  exec "nim c --hints:off -r tasks/format.nim"

task lint, "Lint Nim files":
  exec "nim c --hints:off -r tasks/lint.nim"

task apidocs, "Generate API documentation":
  exec "nim doc --project --index:on --outdir:docs/api src/azanautl_cli/azanautl_cli.nim"

task typos, "Check for typos":
  exec "typos"
