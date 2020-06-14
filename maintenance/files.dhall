let Tree = ../package.dhall

in  { files =
      { maintenance/update =
          Tree.SelfInstall.make
            Tree.SelfInstall::{ path = "maintenance/files.dhall" }
      , bin/dhall-render =
          Tree.SelfInstall.exe // { install = Tree.Install.Write }
      , `.gitattributes` = Tree.TextFile::{
        , contents = "generated/* linguist-generated"
        }
      }
    }
