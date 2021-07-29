let show =
    -- This is a bit arduous, but it is possible to have a local implementation
    -- which is attempted if `DHALL_LOCAL` is set, but required if DHALL_LOCAL_SHOW
    -- is set. It's probably too verbose unless you want maximal flexibility.
        (\(local : Bool) -> ./local-show-impl-not-present.dhall) env:DHALL_LOCAL
      ? ( \(local : Bool) ->
            ./local-show-impl-not-present.dhall ? local "import failed"
        )
          env:DHALL_LOCAL_SHOW
      ? https://prelude.dhall-lang.org/v20.0.0/Natural/show.dhall sha256:684ed560ad86f438efdea229eca122c29e8e14f397ed32ec97148d578ca5aa21

in  show 1
