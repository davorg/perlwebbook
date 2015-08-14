
chapters = $(shell cat chapters.txt)

book: perlwebbook.epub

mobi: perlwebbook.mobi

pdf: perlwebbook.pdf

perlwebbook.mobi: perlwebbook.epub
	kindlegen -verbose perlwebbook.epub

perlwebbook.epub: $(chapters)
	pandoc -o perlwebbook.epub title.txt $(chapters) --epub-metadata=metadata.xml --toc --toc-depth=2 --epub-stylesheet=epub.css

perlwebbook.pdf: perlwebbook.epub
	ebook-convert perlwebbook.epub perlwebbook.pdf

clean:
	rm perlwebbook.epub perlwebbook.mobi

