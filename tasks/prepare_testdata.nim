import
  os


proc main =
  removeDir("testdata")
  echo "removed testdata"
  copyDir("testdata_original", "testdata")
  echo "copied testdata_original to testdata"


when isMainModule: main()
