# Package

version       = "0.1.0"
author        = "lafixier"
description   = "A new awesome nimble package"
license       = "Proprietary"
srcDir        = "src"
installExt    = @["nim"]
bin           = @["aviutliem_cli"]


# Dependencies

requires "nim >= 1.6.10"


# Tasks

task precommit, "Pre-commit runs this":
  exec "nimble format"
  exec "nimble lint"
  exec "nimble typos"

task format, "Format Nim files":
  exec "nim c --hints:off -r tasks/format.nim"

task lint, "Lint Nim files":
  exec "nim c --hints:off -r tasks/lint.nim"

task htmldocs, "Generate HTML documentation":
  exec "nim doc --project --index:on --outdir:docs/htmldocs src/main.nim"

task typos, "Check for typos":
  exec "typos"
