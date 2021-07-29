let show =
        (\(local : Bool) -> ./local-show-impl-not-present.dhall) env:DHALL_LOCAL
      ? https://prelude.dhall-lang.org/v20.0.0/Natural/show.dhall sha256:684ed560ad86f438efdea229eca122c29e8e14f397ed32ec97148d578ca5aa21

in  show 1
