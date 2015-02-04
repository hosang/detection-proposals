function printpng(fname)
%PRINTPDF Prints the current figure into a png document

set(gca, 'LooseInset', get(gca, 'TightInset'));
print('-dpng', '-r200', fname);
