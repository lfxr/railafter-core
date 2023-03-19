import
  os,
  osproc


proc main() =
  for file in walkDirRec("."):
    if file.splitFile.ext != ".nim": continue
    discard execProcess(
      "nim",
      args = ["check", file],
      options = {poUsePath}
    )


when isMainModule:
  main()
