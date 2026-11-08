.PHONY: all pdf clean distclean docker docker-build

LATEXMK = latexmk
IMAGE   = awesome-cv

# Build build/cv.pdf from cv.tex with the settings in latexmkrc
all: pdf

pdf:
	$(LATEXMK)

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
