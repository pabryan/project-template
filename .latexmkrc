$pdflatex="pdflatex -interaction=nonstopmode %O %S";
$out_dir = $ENV{'BUILD_DIR'};
$aux_dir = $ENV{'BUILD_DIR'};
$pdf_mode = 1;
$dvi_mode = $postscript_mode = 0;
@default_files = split(':', $ENV{'TEX_SOURCES'});
$ENV{'TEXINPUTS'}='./.texmf//:' . $ENV{'TEXINPUTS'};
$ENV{'BIBINPUTS'}='./.texmf//:' . $ENV{'BIBINPUTS'};
