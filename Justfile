tmpdir := `mktemp -d`

default: format check test examples docs

vendor:
    http --download --output={{ tmpdir / "roc-svg.tar.br" }} 'https://github.com/Hasnep/roc-svg/releases/download/v0.0.7/vVYSN9mO3igMwoYeu9RtQAnfVFk0Ur2DGWkX9gwHzIE.tar.br'
    brotli --decompress --output={{ tmpdir / "roc-svg.tar" }} {{ tmpdir / "roc-svg.tar.br" }}
    tar xf {{ tmpdir / "roc-svg.tar" }} --directory={{ justfile_directory() / "src" }} Attribute.roc 
    tar xf {{ tmpdir / "roc-svg.tar" }} --directory={{ justfile_directory() / "src" }} Svg.roc

format:
    roc format src/
    roc format examples/

check:
    roc check src/main.roc
    fd --extension roc . examples --exec roc check 

test:
    roc test src/main.roc

examples:
    fd --extension roc . examples --exec roc run --optimize

docs:
    roc docs src/main.roc
