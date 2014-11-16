
book: perlwebbook.epub

mobi: perlwebbook.mobi

perlwebbook.mobi: perlwebbook.epub
	kindlegen perlwebbook.epub

perlwebbook.epub: chapters/how_the_web_works.md
	pandoc -o perlwebbook.epub title.txt chapters/how_the_web_works.md --epub-metadata=metadata.xml --toc --toc-depth=2
