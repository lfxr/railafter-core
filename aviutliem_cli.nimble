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

task format, "Format Nim files":
  exec "nim c --hints:off -r tasks/format.nim"

task lint, "Lint Nim files":
  exec "nim c --hints:off -r tasks/lint.nim"
