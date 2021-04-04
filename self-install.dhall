let Tree = ./schemas.dhall

let lib = ./lib/dhall_render.rb as Text ++ "\n"

let Options = { beforeRuby : List Text, afterRuby : List Text, path : Text }

let default =
      { beforeRuby = [] : List Text
      , afterRuby = [] : List Text
      , path = "dhall/files.dhall"
      }

let Prelude =
      { List.map
        =
          https://prelude.dhall-lang.org/v16.0.0/List/map sha256:dd845ffb4568d40327f2a817eb42d1c6138b929ca758d50bc33112ef3c885680
      , Text.concatSep
        =
          https://prelude.dhall-lang.org/v16.0.0/Text/concatSep sha256:e4401d69918c61b92a4c0288f7d60a6560ca99726138ed8ebc58dca2cd205e58
      }

let makeExe =
      \(options : Options) ->
        let processPath =
              \(path : Text) ->
                ''
                @default_path = ${Text/show path}
                main''

        in  Tree.Executable::{
            , contents =
                Prelude.Text.concatSep
                  "\n"
                  (   [ lib ]
                    # options.beforeRuby
                    # [ processPath options.path ]
                    # options.afterRuby
                  )
            }

let exe = Tree.Executable::{ contents = lib ++ "main" }

let fix = Tree.Executable::{ contents = ./maintenance/fix as Text }

let bump = Tree.Executable::{ contents = ./maintenance/bump as Text }

let local = Tree.Executable::{ contents = ./maintenance/local as Text }

let documentation =
      [ "## Dhall-based file generation"
      , ""
      , "This project uses [dhall-render](https://github.com/timbertson/dhall-render) to generate a number of files."
      , "Below are common commands to manage these files:"
      , ""
      , " - `dhall/render`: re-render all files defined in dhall/files.dhall"
      , " - `dhall/bump --to someuser/somerepo:branch_or_tag FILES`: bump all `someuser/somerepo` references in FILES to the given branch/tag. Multiple repos and multiple files can be specified at once."
      , " - `dhall/fix [FILES]`: evaluate & format dhall files in the given path (default `.`). Pass `--lint` to lint as well."
      , " - `dhall/local COMMAND`: run COMMAND with all `<name>.dhall.local` files temporarily in place of `<name>.dhall`"
      , ""
      ]

let files =
      \(options : Options) ->
        { dhall/render = makeExe options
        , dhall/fix = fix
        , dhall/bump = bump
        , dhall/local = local
        }

in  { Tree
    , Type = Options
    , default
    , make = makeExe
    , makeExe
    , exe
    , fix
    , bump
    , local
    , files
    , documentation
    }
