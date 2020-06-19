let Render = ../package.dhall

in  { files =
      { maintenance/update =
          Render.SelfInstall.make
            Render.SelfInstall::{ path = "maintenance/files.dhall" }
      , bin/dhall-render =
          Render.SelfInstall.exe // { install = Render.Install.Write }
      , `.gitattributes` = Render.TextFile::{
        , contents = "generated/* linguist-generated"
        }
      }
    }
