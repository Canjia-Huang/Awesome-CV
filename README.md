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
├── sections/              # CV content, one file per section
│   ├── education.tex
│   ├── experience.tex
│   ├── publications.tex
│   └── presentation.tex
├── assets/                # Optional photo (see below)
├── awesome-cv.cls         # Template class (single source of truth)
├── latexmkrc              # LuaLaTeX + SyncTeX + build/ output directory
├── Makefile               # make / clean / distclean / docker
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

The result is `build/cv.pdf`; logs, `.aux`, `.fls` and `.synctex.gz` stay in
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
extension; the committed workspace settings build with `latexmk` from the root
and put output in `build/`. On Overleaf, upload the repository, keep `cv.tex`
as the main document at the project root, and select LuaLaTeX.

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
