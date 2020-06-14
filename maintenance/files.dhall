let Tree = ../package.dhall

in  { files =
      { maintenance/update =
          Tree.SelfInstall.make
            Tree.SelfInstall::{ path = "maintenance/files.dhall" }
      , bin/dhall-files = Tree.SelfInstall.exe
      , `.gitattributes` = Tree.TextFile::{
        , contents = "generated/* linguist-generated"
        }
      }
    }
