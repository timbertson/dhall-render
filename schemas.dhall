let Format = < YAML | JSON | Raw >

let Install = < Symlink | Write | None >

let Options =
      { Type = { destination : Text }, default.destination = "generated" }

let Metadata =
      { format : Format
      , install : Install
      , header : Optional Text
      , executable : Bool
      }

let defaultMetadata =
      { format = Format.YAML
      , install = Install.Symlink
      , header = None Text
      , executable = False
      }

let File =
          \(T : Type)
      ->  { Type = Metadata //\\ { contents : T }, default = defaultMetadata }

let TextFile =
      { Type = (File Text).Type
      , default = defaultMetadata // { format = Format.Raw }
      }

let Executable =
      { Type = (File Text).Type
      , default = defaultMetadata // { format = Format.Raw, executable = True }
      }

in  { File, Format, TextFile, Executable, Install, Metadata, Options }
