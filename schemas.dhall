let Format = < YAML | JSON | Raw >

let Install = < Symlink | Write | None >

let Options =
      { Type = { destination : Text }, default.destination = "generated" }

let Metadata =
      { format : Format
      , install : Install
      , header : Optional Text
      , executable : Bool
      , path : Optional Text
      }

let defaultMetadata =
      { install = Install.Symlink
      , header = None Text
      , path = None Text
      , executable = False
      }

let File =
    -- base File type with contents of type T
          \(T : Type)
      ->  { Type = Metadata //\\ { contents : T }, default = defaultMetadata }

let withFormat =
    -- File with a specific format
      \(format : Format) -> \(T : Type) -> File T with default.format = format

let TextFile = withFormat Format.Raw Text

let YAMLFile = withFormat Format.YAML

let JSONFile = withFormat Format.JSON

let Executable = withFormat Format.Raw Text with default.executable = True

in  { File
    , Format
    , TextFile
    , Executable
    , YAMLFile
    , JSONFile
    , Install
    , Metadata
    , Options
    }
