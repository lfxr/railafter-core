import
  os,
  osproc


proc main() =
  for file in walkDirRec("."):
    if file.splitFile.ext != ".nim": continue
    discard execProcess(
      "nimpretty",
      args = [file],
      options = {poUsePath}
    )


when isMainModule:
  main()
