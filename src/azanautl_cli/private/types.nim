import
  options,
  tables


type
  ImageAlreadyExistsError* = object of CatchableError
  ImageDoesNotExistError* = object of CatchableError
  ContainerAlreadyExistsError* = object of CatchableError
  ContainerDoesNotExistError* = object of CatchableError
  InvalidZipFileHashValueError* = object of CatchableError
  DepencyNotSatisfiedError* = object of CatchableError

type ErrorKind* = enum
  imageAlreadyExistsError,
  imageDoesNotExistError,
  containerAlreadyExistsError,
  containerDoesNotExistError,
  invalidZipFileHashValueError,
  depencyNotSatisfiedError

type Error* = object of CatchableError
  case kind*: ErrorKind
  of imageAlreadyExistsError, imageDoesNotExistError:
    imageId*: string
  of containerAlreadyExistsError, containerDoesNotExistError:
    containerId*: string
  of invalidZipFileHashValueError:
    zipFilePath*: string
    expectedHashValue*: string
    actualHashValue*: string
  of depencyNotSatisfiedError:
    depencyName*: string
    expectedVersions*: seq[string]
    actualVersion*: string

type Result*[S] = ref object
  res*: S
  err*: Option[Error]


type Bases* = object
  aviutl_version*: string
  exedit_version*: string

type Plugin* = object
  id*: string
  version*: string

type Script = object
  id*: string
  version*: string

type ImageYaml* = object
  image_id*, image_name*: string
  bases*: Bases
  plugins*: seq[Plugin]
  scripts*: seq[Script]


type ContainerBases* = object
  aviutl*, exedit*: tuple[version: string, is_installed: bool]

type ContainerPlugin* = object
  id*: string
  version*: string
  is_installed*, is_enabled*: bool
  previously_installed_versions*: seq[string]

type ContainerYaml* = object
  container_id*, container_name*: string
  bases*: ContainerBases
  plugins*: seq[ContainerPlugin]


type GitHubRepository* = tuple
  owner: string
  repo: string

type
  DependenciesBases* = object
    aviutl_versions*, exedit_versions*: Option[seq[string]]

  DependenciesPlugin* = object
    id*: string
    versions*: seq[string]

  Dependencies* = object
    bases*: Option[DependenciesBases]
    plugins*: Option[seq[DependenciesPlugin]]

  PackagesYamlPluginDependencies* = object
    conforming_versions*: seq[string]
    body*: Dependencies

type
  FdType* = enum
    File = "file"
    Dir = "dir"

  MoveTo* {.pure.} = enum
    Root = "root"
    Plugins = "plugins"

  TrackedFilesAndDirs* = object
    path*: string
    fd_type*: FdType
    move_to*: MoveTo
    is_protected*, is_mutable*, is_config*: bool

  PackagesYamlPluginTrackedFilesAndDirs * = object
    conforming_versions*: seq[string]
    body*: seq[TrackedFilesAndDirs]

type
  JobType* = enum
    AfterInstallation = "after_installation"
    AfterUninstallation = "after_uninstallation"

  Command* = enum
    Remove = "remove"
    Run = "run"

  WorkingDir* {.pure.} = enum
    Root = "root"
    Plugins = "plugins"
    DownloadedPlugin = "downloaded_plugin"

  Task* = object
    command*: Command
    working_dir*: WorkingDir
    paths*: seq[string]

  Job* = object
    id*: JobType
    tasks*: seq[Task]

  PackagesYamlPluginJobs* = object
    conforming_versions*: seq[string]
    body*: seq[Job]

type PackagesYamlPluginVersion* = object
  version*: string
  is_latest*: bool
  url*: string
  github_release_tag*: Option[string]
  github_asset_id*: Option[int]
  sha3_512_hash*: string
  released_on*: string
  tracked_file_or_dir_hashes*: Table[string, string]

type PackagesYamlPlugin* = object
  id*: string
  name*: string
  plugin_type*: string
  description*: string
  tags*: seq[string]
  author*: string
  website*: string
  github_repository*: Option[GitHubRepository]
  niconico_commons_id*: Option[string]
  dependencies*: Option[seq[PackagesYamlPluginDependencies]]
  tracked_files_and_dirs*: seq[PackagesYamlPluginTrackedFilesAndDirs]
  jobs*: Option[seq[PackagesYamlPluginJobs]]
  versions*: seq[PackagesYamlPluginVersion]

type PackagesYamlBasisVersion* = object
  version*: string
  url*: string
  sha3_512_hash*: string

type PackagesYamlBasis* = object
  id*: string
  name*: string
  description*: string
  website*: string
  versions*: seq[PackagesYamlBasisVersion]

type PackagesYaml* = object
  bases*: seq[PackagesYamlBasis]
  plugins*: seq[PackagesYamlPlugin]
