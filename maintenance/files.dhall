let Render = ../package.dhall

let CI = ./dependencies/CI.dhall

let Workflow = CI.Workflow

let Git = CI.Git.Workflow

let Docker = CI.Docker.Workflow

in  { files =
      { maintenance/update =
          Render.SelfInstall.make
            Render.SelfInstall::{ path = "maintenance/files.dhall" }
      , `.gitattributes` = Render.TextFile::{
        , contents =
            ''
            generated/* linguist-generated
            .github/workflows/* linguist-generated
            ''
        }
      , `.github/workflows/ci.yml` = (Render.YAMLFile Workflow.Type)::{
        , install = Render.Install.Write
        , contents = Workflow::{
          , name = "CI"
          , on = Workflow.On.pullRequestOrMain
          , jobs = toMap
              { build = Workflow.Job::{
                , runs-on = Workflow.ubuntu
                , steps =
                  [ Git.checkout Git.Checkout::{=}
                  , Docker.loginToGithub
                  ,     Workflow.Step.bash
                          ( CI.Docker.runInCwd
                              CI.Docker.Run::{
                              , image = CI.Docker.Image::{
                                , name =
                                    "${CI.Docker.Registry.githubPackages}/timbertson/dhall-ci/dhall"
                                , tag = Some "1.37"
                                }
                              }
                              ( CI.Git.requireCleanWorkspaceAfterRunning
                                  [ "make test" ]
                              )
                          )
                    //  { name = Some "Run tests" }
                  ]
                }
              }
          }
        }
      }
    }
