let Render = ../package.dhall

let SomeConfigFile = { name : Text, age : Natural }

let List/map =
      https://prelude.dhall-lang.org/v16.0.0/List/map sha256:dd845ffb4568d40327f2a817eb42d1c6138b929ca758d50bc33112ef3c885680

let headerFormat = Render.Header.ignore

let fileList =
      let File = Render.YAMLFile SomeConfigFile

      let ages = [ 1, 2, 3 ]

      let makeFile =
            \(age : Natural) ->
              File::{
              , path = Some "${Natural/show age}.yml"
              , contents = { name = "youngling", age }
              }

      in  List/map Natural File.Type makeFile [ 1, 2, 3 ]

in  { options = Render.Options::{ destination = "out" }
    , files =
      { hello = Render.TextFile::{ contents = "Hello!", headerFormat }
      , nested/hello = Render.TextFile::{ contents = "Hello!" }
      , `hello.sh` = Render.Executable::{
        , headerFormat
        , contents = "echo 'Hello!'"
        }
      , `hello-shebang.sh` = Render.Executable::{
        , contents =
            ''
            #!/usr/bin/env bash
            echo hello
            ''
        , headerLines = [ "(header)" ]
        }
      , no-symlink = Render.TextFile::{
        , contents =
            ''
            nothin' but content
            ''
        , install = Render.Install.Write
        }
      , `hello.html` = Render.TextFile::{
        , contents = "<h1>Hello</h1>"
        , headerFormat = Render.Header.html
        , headerLines = [ "header1", "header2" ]
        }
      , no-header-lines = Render.TextFile::{
        , contents = "(intentionally empty)"
        , headerLines = [] : List Text
        }
      , fileList
      }
    }
