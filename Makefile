all: bin/dhall-render test

bin/dhall-render:
	maintenance/fix
	maintenance/bootstrap.rb
	maintenance/update

test:
	bin/dhall-render examples/files.dhall
	(cd bootstrap \
		&& echo '(./files.dhall).files.dhall-render.contents' | dhall text | ruby \
		&& ./dhall-render)
	rm -r bootstrap/dhall-render bootstrap/generated


freeze:
	dhall --ascii freeze --inplace self-install.dhall

.PHONY: all bin/dhall-render test

