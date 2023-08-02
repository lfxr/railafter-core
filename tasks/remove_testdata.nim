import
  os


proc main =
  removeDir("testdata")
  echo "removed testdata"


when isMainModule: main()
