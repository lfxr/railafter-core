import
  options

import
  ../../../src/azanautl_cli/azanautl


proc main = 
  let
    app = newApp("./app")
    image = app.newImage("image-0", "イメージ0")

  echo image.create.err.isSome


when isMainModule: main()
