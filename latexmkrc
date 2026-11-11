# Run latexmk from the repository root so input and image paths are consistent.
$pdf_mode = 4;
$lualatex = 'lualatex -interaction=nonstopmode -halt-on-error -file-line-error -synctex=1 %O %S';
$out_dir = 'build';
@default_files = ('cv.tex');

# florilegium, the optional floral-margin package (cv-florilegium.tex), is
# vendored here so no TeX Live installation is needed.
$ENV{'TEXINPUTS'} = 'vendor/florilegium:' . ($ENV{'TEXINPUTS'} // '');
$ENV{'LUAINPUTS'} = 'vendor/florilegium:' . ($ENV{'LUAINPUTS'} // '');

# Keep luaotfload's font cache inside the ignored build/ directory when the
# default location is not writable (e.g. read-only or sandboxed builds).
$ENV{TEXMFVAR} = 'build/texmf-var' unless defined $ENV{TEXMFVAR} && length $ENV{TEXMFVAR};
