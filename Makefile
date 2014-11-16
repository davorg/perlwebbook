
chapters = $(shell cat chapters.txt)

book: perlwebbook.epub

mobi: perlwebbook.mobi

perlwebbook.mobi: perlwebbook.epub
	kindlegen -verbose perlwebbook.epub

perlwebbook.epub: $(chapters)
	pandoc -o perlwebbook.epub title.txt $(chapters) --epub-metadata=metadata.xml --toc --toc-depth=2

clean:
	rm perlwebbook.epub perlwebbook.mobi

