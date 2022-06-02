let Render = ../package.dhall

let SomeConfigFile = { name : Text, age : Natural }

let List/map =
      https://prelude.dhall-lang.org/v16.0.0/List/map
        sha256:dd845ffb4568d40327f2a817eb42d1c6138b929ca758d50bc33112ef3c885680

let fileList =
    -- file lists are handy if you have a set of files (all the same type)
    -- where the filenames are dynamic (i.e. Text). When using a file list
    -- each must have a `path` property, which is joined with the key to
    -- make the full path.
      let File = Render.YAMLFile SomeConfigFile

      let ages = [ 1, 2, 3 ]

      let makeFile =
            \(age : Natural) ->
              File::{
              , path = Some "${Natural/show age}.yml"
              , contents = { name = "youngling", age }
              }

      in  List/map Natural File.Type makeFile [ 1, 2, 3 ]

in  { options = Render.Options::{ destination = "examples/generated" }
    , files =
      { examples/files/hello = Render.TextFile::{ contents = "Hello!" }
      , `examples/files/hello.sh` = Render.Executable::{
        , contents = "echo 'Hello!'"
        }
      , `examples/files/config.yml` = (Render.YAMLFile SomeConfigFile)::{
        , contents = { name = "tim", age = 100 }
        }
      , `examples/files/config-list.yml` = ( Render.YAMLFile
                                               (List SomeConfigFile)
                                           )::{
        , contents = [ { name = "tim", age = 50 }, { name = "fred", age = 50 } ]
        }
      , `examples/files/config.json` = (Render.JSONFile SomeConfigFile)::{
        , contents = { name = "tim", age = 100 }
        }
      , examples/files/list = fileList
      }
    }
