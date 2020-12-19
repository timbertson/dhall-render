let Tree = ../package.dhall

in  { files.invalidText
      = (Tree.File {})::{ format = Tree.Format.Raw, contents = {=} }
    }
