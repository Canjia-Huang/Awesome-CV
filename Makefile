.PHONY: all pdf garden vendor-florilegium clean distclean docker docker-build

LATEXMK = latexmk
IMAGE   = awesome-cv
TAG     ?= v2.0.1

# Build build/cv.pdf from cv.tex with the settings in latexmkrc
all: pdf

pdf:
	$(LATEXMK)

# The math-garden variant, build/cv-florilegium.pdf (needs LuaLaTeX, as pdf does)
garden:
	$(LATEXMK) cv-florilegium.tex

# Refresh the vendored florilegium from a GitHub release, e.g.
#   make vendor-florilegium TAG=v2.0.2
vendor-florilegium:
	@./tools/vendor-florilegium.sh "$(TAG)"

# Remove auxiliary files, keep the PDF
clean:
	$(LATEXMK) -c

# Remove auxiliary files and the PDF
distclean:
	$(LATEXMK) -C

# Build inside the pinned TeX Live image (no local TeX installation required)
docker-build:
	docker build --pull --tag $(IMAGE) .

docker:
	docker run --rm --user "$$(id -u):$$(id -g)" \
		--volume "$$PWD:/doc" $(IMAGE) make pdf
