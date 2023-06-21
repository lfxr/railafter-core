import
  types


func newPlugin*(id: string, version: string = ""): ref Plugin =
  result = new Plugin
  result.id = id
  result.version = version
