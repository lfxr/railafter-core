import
  os,
  osproc,
  strutils


proc main() =
  for file in walkDirRec("."):
    if file.startsWith("./nimbledeps") or
      file.splitFile.ext != ".nim": continue
    discard execProcess(
      "nim",
      args = ["check", file],
      options = {poUsePath}
    )


when isMainModule:
  main()

