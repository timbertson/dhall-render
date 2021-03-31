let Render =
      https://raw.githubusercontent.com/timbertson/dhall-render/master/package.dhall

in  { files =
            Render.SelfInstall.files Render.SelfInstall::{=}
        /\  { -- Replace this sample entry with your own file definitions:
              dhall/hello = Render.TextFile::{ contents = "world!" }
            }
    }
