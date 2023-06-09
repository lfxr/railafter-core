import
  unittest

import
  ../../src/azanautl_cli/private/procs,
  ../../src/azanautl_cli/private/types


proc main =
  check deserializePlugin("piyo/hoge:v1.0.0") ==
    Plugin(id: "piyo/hoge", version: "v1.0.0")

  check deserializePlugin("piyo/hoge:v12") ==
    Plugin(id: "piyo/hoge", version: "v12")

  check deserializePlugin("piyo/hoge") ==
    Plugin(id: "piyo/hoge", version: "latest")

  check deserializePlugin("hoge") ==
    Plugin(id: "hoge", version: "latest")


when isMainModule: main()
