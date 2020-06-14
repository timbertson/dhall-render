let Tree = ./schemas.dhall

let lib = ./lib/dhall_files.rb as Text ++ "\n"

let Options = { beforeRuby : List Text, afterRuby : List Text, path : Text }

let default = { beforeRuby = [] : List Text, afterRuby = [] : List Text }

let Prelude =
      { List.map =
          https://prelude.dhall-lang.org/v16.0.0/List/map sha256:dd845ffb4568d40327f2a817eb42d1c6138b929ca758d50bc33112ef3c885680
      , Text.concatSep =
          https://prelude.dhall-lang.org/v16.0.0/Text/concatSep sha256:e4401d69918c61b92a4c0288f7d60a6560ca99726138ed8ebc58dca2cd205e58
      }

in  { Tree
    , Type = Options
    , default
    , exe = Tree.Executable::{ contents = lib ++ "main" }
    , make =
            \(options : Options)
        ->  let processPath = \(path : Text) -> "process(${Text/show path})"

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
    }
