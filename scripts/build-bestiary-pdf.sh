#!/bin/bash
# This creates a compiled PDF of all the monster stat blocks in both A4 and Letter formats (including booklets)
scriptdir="/home/yochai/github/cairn/scripts"
sourcedir="/home/yochai/github/cairn/resources/monsters"
tmpdir="/home/yochai/Downloads/tmp"
destdir="/home/yochai/Google Drive/Games/OSR/Into The Odd/hacks/Cairn/Monsters"
currentdate="$(date "+%B %e, %Y")"
mkdir -p $tmpdir/monsters
rsync -av $sourcedir/ $tmpdir/monsters/
sed -i -f prep.sed $tmpdir/monsters/*.md

# Create the PDF
pandoc  -s $tmpdir/monsters/*.md \
        --toc \
   	--template=build.tex \
        --metadata=title:"Cairn Bestiary" \
        --metadata=author:"Yochai Gal" \
        --metadata=lang:"en-US" \
        --metadata=cover-image:"$scriptdir/covers/cairn-bestiary-front-cover.png" \
        -V geometry=letterpaper \
	-V title="Cairn Bestiary" \
        -V subtitle="Compiled on " \
        -V subtitle="$currentdate" \
        -V subtitle=" by Yochai Gal | CC-BY-SA 4.0" \
        -V fontfamily="Alegreya" \
        -V fontsize=12pt \
	-o $tmpdir/cairn-bestiary-letter-tmp.pdf

pandoc  -s $tmpdir/monsters/*.md \
        --toc \
   	--template=build.tex \
        --metadata=title:"Cairn Bestiary" \
        --metadata=author:"Yochai Gal" \
        --metadata=lang:"en-US" \
        --metadata=cover-image:"$scriptdir/covers/cairn-bestiary-front-cover.png" \
        -V geometry=a4paper \
	-V title="Cairn Bestiary" \
        -V subtitle="Compiled on " \
        -V subtitle="$currentdate" \
        -V subtitle=" by Yochai Gal | CC-BY-SA 4.0" \
        -V fontfamily="Alegreya" \
        -V fontsize=12pt \
	-o $tmpdir/cairn-bestiary-a4-tmp.pdf

# Add covers
pdftk "$scriptdir/covers/letter/cairn-bestiary-letter-front-cover.pdf" $tmpdir/cairn-bestiary-letter-tmp.pdf "$scriptdir/covers/letter/cairn-bestiary-letter-back-cover.pdf" cat output "$destdir/cairn-bestiary-letter.pdf"
pdftk "$scriptdir/covers/a4/cairn-bestiary-a4-front-cover.pdf" $tmpdir/cairn-bestiary-a4-tmp.pdf "$scriptdir/covers/a4/cairn-bestiary-a4-back-cover.pdf" cat output "$destdir/cairn-bestiary-a4.pdf"

# Make the booklet
pdfbook2 --paper=letter -s $tmpdir/cairn-bestiary-letter-tmp.pdf
pdfbook2 --paper=a4paper -s $tmpdir/cairn-bestiary-a4-tmp.pdf
pdftk "$scriptdir/covers/letter/cairn-bestiary-letter-covers-landscape.pdf" $tmpdir/cairn-bestiary-letter-tmp-book.pdf cat output "$destdir/cairn-bestiary-letter-booklet.pdf"
pdftk "$scriptdir/covers/a4/cairn-bestiary-a4-covers-landscape.pdf" $tmpdir/cairn-bestiary-a4-tmp-book.pdf cat output "$destdir/cairn-bestiary-a4-booklet.pdf"
rm -rf $tmpdir