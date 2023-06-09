import
  options,
  unittest

import
  ../../src/azanautl_cli/private/procs,
  ../../src/azanautl_cli/private/types


proc main =
  block:
    let err = sha3_512File("testdata/bar").err.get()
    check err.kind == fileDoesNotExistError
    check err.filePath == "testdata/bar"

  check sha3_512File("testdata/foo.txt").res ==
    "6F1B16155D5F87AF947270B2202C9432B64FF07880E3BD104A50605BC0F949D4E4BF30CDDBB257A7F3A54881429F45EFDB43FBE14371F9F7F5CB16789DB9175D"

  check sha3_512File("testdata/bar/baz.md").res ==
    "AD240AD7B12188628C56099DBDD3B9672E51F03BAAD23250A357602507CFCDA310F3043FC8F4557598F2A0BC4CFE19883DA63F75EB015291C0CE4D5B7C0610F5"

  check sha3_512File("testdata/archive.zip").res ==
    "7C5380F985ED0A1EF418940465D6C06AE631C00079ABF11DEE928FF072DB34CA97D95CAD3B3607E45E91378200C9D0A87E3E0D05E35B41880ADCE7625CAF9A61"


when isMainModule: main()
