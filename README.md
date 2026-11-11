# Canjia Huang — Curriculum Vitae

Personal CV of Canjia Huang, typeset with LuaLaTeX on top of the
[Awesome CV](https://github.com/posquit0/Awesome-CV) class.

This repository is private and contains only the personal CV: the class file,
one main document, its sections, and the build tooling. Templates, résumé and
cover-letter examples, tests, and upstream automation have been removed.

## Layout

```
.
├── cv.tex                 # Main document: personal info, colours, page setup
├── cv-florilegium.tex     # Optional math-garden variant (same content)
├── sections/              # CV content, one file per section
│   ├── education.tex
│   ├── experience.tex
│   ├── publications.tex
│   └── presentation.tex
├── assets/                # Optional photo (see below)
├── vendor/florilegium/    # Vendored florilegium 2.0.1 (MIT) for `make garden`
├── tools/vendor-florilegium.sh  # Refresh that copy from a release
├── awesome-cv.cls         # Template class (single source of truth)
├── latexmkrc              # LuaLaTeX + SyncTeX + build/ output directory
├── Makefile               # make / garden / vendor-florilegium / clean / docker
├── Dockerfile             # Pinned TeX Live + fonts, used by CI
├── luaotfload.conf        # Lets LuaLaTeX find fonts placed in this directory
├── .github/workflows/main.yml
├── .vscode/               # LaTeX Workshop workspace settings
└── LICENCE                # CC BY-SA 4.0, inherited from the template
```

## Requirements

Awesome CV needs **LuaLaTeX with HarfBuzz**, driven by **latexmk**. XeLaTeX and
pdfLaTeX are not supported. Install a current full
[TeX Live](https://tug.org/texlive/) (or [MacTeX](https://tug.org/mactex/)) —
TeX Live 2026 is the tested baseline — plus:

* `lualatex`, `latexmk`, and the `fontawesome6` package
* **Source Sans 3** and **Roboto**, as *static* desktop fonts with Regular,
  Italic, Bold, Bold Italic, Light, and Light Italic faces. A variable-only
  install may not expose the faces the class asks for.
* Run `luaotfload-tool --update` if the fonts are installed but not found.

Alternatively, drop the static font files here at the repository root;
[luaotfload.conf](luaotfload.conf) makes them discoverable, which also works on
Overleaf. Skip this section entirely if you use Docker.

## Build

Run everything from the repository root, where `latexmkrc` and
`awesome-cv.cls` live.

```bash
make              # same as: latexmk
```

The result is `build/cv.pdf`; `make garden` builds the optional math-garden
variant described below. Logs, `.aux`, `.fls` and `.synctex.gz` stay in
`build/` and are git-ignored. To keep rebuilding while you edit:

```bash
latexmk -pvc
```

`make clean` (or `latexmk -c`) removes auxiliary files but keeps the PDF;
`make distclean` (or `latexmk -C`) removes the PDF as well.

### Docker

No local TeX installation required — the image pins TeX Live and both font
families:

```bash
make docker-build   # docker build --pull --tag awesome-cv .
make docker         # compile into build/ on the host
```

The image is pinned to a multi-platform digest with extra packages from a dated
Debian snapshot, so a rebuild resolves the same TeX and font sources. On Apple
Silicon, add `--platform linux/amd64` to reproduce CI's architecture.

### Math garden (optional)

A second PDF, `build/cv-florilegium.pdf`, decorates the CV with florilegium's
`theme=math`: polyhedra, Koch curves, knots, Petersen graphs, equations and
glyphs in the CV's blue and copper. The text is untouched — same A4 page, same
margins, same 18.2 cm column, same page breaks as `build/cv.pdf`.

```bash
make garden         # same as: latexmk cv-florilegium.tex
```

On A4 an 18.2 cm column leaves only 1.4 cm at each side, too narrow for the
theme's glyphs, so the garden goes where the page is genuinely blank:

* **page 1** — the two empty pockets either side of the header get a cluster
  each;
* **page 2** — the free space under the text (`\florilegiumtextend`) fills edge
  to edge.

How it is wired:

* [cv-florilegium.tex](cv-florilegium.tex) defines `\withflorilegium` and inputs
  [cv.tex](cv.tex); the content stays in one place.
* `cv.tex` loads `florilegium` with `grown, theme=math, density=0.9,
  intensity=0.9`, sets its `ink` to the CV's blue, and calls
  `\florilegiumtextend` at the end.
* The class's `red`, `green` and `blue` are reset to pure primaries.
  florilegium 2.0.1 builds a math glyph's colour as
  `text={rgb,255:red,R;green,G;blue,B}`, which xcolor reads as a mix of the
  colours with those names; Awesome CV's pastel versions turn every glyph teal,
  purple or red. Nothing else in this CV uses those names.
* A small Lua patch pins the garden to the blank space: the garden's own margin
  column moves to the paper edge (`colright = 0.3`), its copper head rule goes
  off-page, a page with no free text gets no footer band, and page 1 gets its two
  header pockets as extra regions. Each pocket is listed twice, because the theme
  sizes its fill from the regions' area — twice the area, twice the motifs in the
  same pocket. This touches package internals and is pinned to the vendored
  2.0.1.

Knobs, in the `\ifdefined\withflorilegium` blocks of `cv.tex`:

* `density=0.05…1` — how much grows (`0.9` here); `intensity=0.3…1` — how pale
  it is.
* `theme=geometric` — the other theme in 2.0.1 (flat, straight-edged).
* `\def\florilegiumseed{7}` before `\usepackage` — a different garden for the
  whole document; by default page *n* always grows the same garden.

The runtime files are vendored in `vendor/florilegium/` — `florilegium.sty`, its
Lua modules and the MIT licence, 640 KB in all — and `latexmkrc` puts that
directory on `TEXINPUTS`/`LUAINPUTS`, so builds work offline, from a GitHub ZIP
and on Overleaf, with no `tlmgr install`. [vendor/florilegium/VERSION](vendor/florilegium/VERSION)
records the release, its source URL and the archive's SHA-256. To move to another
release:

```bash
make vendor-florilegium TAG=v2.0.2
```

[the script](tools/vendor-florilegium.sh) downloads that release's
`florilegium.zip`, checks that its `\ProvidesPackage` version matches the tag,
and syncs only the runtime files — a git submodule would pull the whole 69 MB
repository for the same 640 KB.

Caveats. The 1.4 cm side margins stay empty: at that width the math theme can
only place glyphs too large for the strip, and they collide with the text. The
`sections` option patches the standard `\@sect`, which Awesome CV never calls —
`\cvsection` draws its own heading — so flowers beside headings never appear.
Delete `\florilegiumtextend` and the last page is plain again. The vendored copy
is release 2.0.1: the Gothic tracery and shells described in the project's
current README live on its `main` branch and are not in this release.

### CI

[main.yml](.github/workflows/main.yml) builds the image and compiles `cv.pdf`
on every push to `master` that touches the CV sources or the build files
(`cv.tex`, `sections/`, `assets/`, `awesome-cv.cls`, `latexmkrc`,
`luaotfload.conf`, `Dockerfile`, or the workflow itself), then uploads it as the
`cv` artifact. Runs are keyed to the branch, so a new push cancels the previous
build instead of queueing. The workflow can also be started manually from the
Actions tab.

The same run publishes `cv.pdf` to GitHub Pages at
<https://canjia-huang.github.io/Awesome-CV/cv.pdf> — a stable link that always
serves the PDF from the latest successful `master` build. The site root
redirects to it. Pages must be enabled once under **Settings → Pages → Build and
deployment → Source: GitHub Actions**; on Free plans a private repository cannot
publish Pages, and switching the repository to private unpublishes the site.

### Editor

Open the repository root in VS Code with the recommended
[LaTeX Workshop](https://marketplace.visualstudio.com/items?itemName=James-Yu.latex-workshop)
extension. [.vscode/settings.json](.vscode/settings.json) builds the garden by
default: its only recipe runs `latexmk cv-florilegium.tex` from the root, and
`latex-workshop.latex.jobname` is `cv-florilegium`, so Build (Ctrl+Alt+B), View
PDF and auto build on save all read `build/cv-florilegium.pdf` (log, aux and
SyncTeX included). For the plain CV, run `make` in the integrated terminal; to
preview *it* in VS Code instead, set `latex-workshop.latex.jobname` to `cv` and
put `%DOC_EXT%` back in the tool's `args`.

On Overleaf, upload the repository, keep `cv.tex` as the main document at the
project root, and select LuaLaTeX.

## Editing

* Personal information, colours, and page geometry: [`cv.tex`](cv.tex).
* Section content: the matching file under [`sections/`](sections).
* To add a photo, place it at `assets/profile.png` and uncomment the `\photo`
  line in `cv.tex`.
* The footer date uses `\today`; replace it with a literal date for a dated
  application copy.

## Licence and credit

The class, the build configuration, and the overall design come from
[Awesome CV](https://github.com/posquit0/Awesome-CV) by
[Claud D. Park](https://github.com/posquit0), licensed under
[CC BY-SA 4.0](LICENCE). This repository is a derivative work and stays under
the same licence; keep [LICENCE](LICENCE) and the attribution in `cv.tex` and
`awesome-cv.cls` intact.

The CV text and its sections are personal content and are not licensed for
reuse.

The optional math garden uses [florilegium](https://github.com/kevinraymond/florilegium)
2.0.1 by [Kevin Raymond](https://github.com/kevinraymond), MIT licensed; its
licence is kept at [vendor/florilegium/LICENSE](vendor/florilegium/LICENSE).
