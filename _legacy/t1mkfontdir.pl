#!/usr/bin/perl

# -----------------------------------------------------------------------------
# 
# t1mkfontdir.pl
# (c) 2002 Alexander Dunayevskyy
# MIT License
#
# -----------------------------------------------------------------------------
# Basically this Perl script tries to duplicate the functionality of
# ttmkfdir, but for case of Type1 fonts. First it loops through all
# font files in given directory. Then script parses a Type1 font
# binary file (.pfb) and determines its characteristics, which are
# written to stdout in following order:
# 	1) file_name
#	2) creation_date
#	3) raw data (may contain Adobe-specific things, if any)
# T1 "main" textual header things (begin with 0x0D byte
# end with " [readonly ]def"):
# 	4) version
#	5) Notice
#	6) FullName
#	7) FamilyName
#	8) Weight
#	9) ItalicAngle (doubtfully one needs this item and the following)
#	10) isFixedPitch
#	11) UnderlinePosition
#	12) UnderlineThickness
#	13) FontName
#	14) Encoding
#	15) PaintType
#	16) FontType (actually should be "1" ;-)
#	17) UniqueID
# After that, script creates "fonts.scale" file with all fonts listed.
# User should type in 'mkfontdir' to create "fonts.dir" and so on.
#

# globals
$out_filename="fonts.scale";
$tmp="${out_filename}~";

# not actually needed but seems to look nice.
# ($0 by default contains working directory. Remove it)
split('/', $0); $program=@_[$#_];

$fdir=@ARGV[0] eq "" ? "./" : @ARGV[0]; # this is the directory full of .pfb's

opendir(DIR, "$fdir") or die "$program: Error: Invalid input directory $fdir\n";
@files= grep { /$.pfb/i } readdir(DIR);
closedir DIR;

$#files > 0 or die "$program: Warning: no .pfb in this dir!\n";

if( -e $out_filename ) {
    print "$program: Warning: fonts.dir already exists Overwrite? (Y,N) ";
    my $yn = <STDIN>;
    $yn !~ /y/i &&  exit; # type anything other than 'y' or 'Y' to abort
}
open(TMP, "+> $tmp") or die "$program: Error: I can't create output file!\n";

$num_of_lines=0; # num_of_lines (needs to be in the very beginning of fonts.scale)

for (@files) {
    $curfont=$_; # save $_ now because we'll potentially clobber it
    open (PFB, "< $fdir/$curfont") or die "$program: Error: open($curfont)\n";
    binmode PFB;

    # read the stuff

    # reset $raw when dealing with new font because it ACCUMULATES raw data
    $raw="";
    # I hope 1kB for header would be enough (FIXME: truncation?)
    while(read(PFB,$z,1024)) {
	# specifiers are separated by 0x0D byte (AFAIK)
	split("\x0D", $z);
	# -----------------------------------------------------------
	# ----------deal with specifiers we're interested in---------
	for (@_) {
	    # find and delete specifiers, get trailing strings
	    
	    # delete stuff at end (really no idea why it is there ??)
	    s/(| readonly) def//;

	    s/^\%\%CreationDate: //i	? $creation_date=$_	:
	    s/^\%\%\s//i		? $raw= $raw.$_		:
	    s#^/version ##i		? $version=$_		:
	    s#^/Notice ##i		? $notice=$_		:
	    s#^/FullName ##i		? $fullname=$_		:
	    s#^/FamilyName ##i		? $familyname=$_	:
	    s#^/Weight ##i		? $weight=$_		:
	    s#^/ItalicAngle ##i		? $italic_angle=$_	:
	    s#^/isFixedPitch ##i	? $is_fixed_pitch=$_	:
	    s#^/UnderlinePosition ##i	? $uline_pos=$_		:
	    s#^/UnderlineThickness ##i	? $uline_thickness=$_	:
	    s#^/FontName ##i		? $fontname=$_		:
	    s#^/Encoding ##i		? $enc=$_		:
	    s#^/PaintType ##i		? $paint_type=$_	:
	    s#^/FontType ##i		? $font_type=$_		:
	    s#/UniqueID ##i		? $id=$_		:
	    # Decide where to stop splitting, as we might be
	    # reading font glyph data. IMHO we should stop
	    # after encountering /currentfile eexec/ (???)
	    m/^currentfile eexec/	? last			: next;
	}
	# -----------------------------------------------------------
    }
    print "
Source:              $curfont
Creation date:       $creation_date
Raw data:            $raw
Version:             $version
Notice:              $notice
Full Name:           $fullname
Family:              $familyname
Weight:              $weight
ItalicAngle:         $italic_angle
Fixed Pitch:         $is_fixed_pitch
Underline Position:  $uline_pos
Underline Thickness: $uline_thickness
Font Name:           $fontname
Encoding:            $enc
Paint Type:          $paint_type
Font Type:           $font_type
UniqueID:            $id
----------------------------------------------------------------------

";
    close PFB;


    # Whatever we need is stored in $fullname,
    # $family and $fontname (less); $weight may be absent at all.
    
    # Manufacturer field typically stored in $notice, maybe in $raw too.
    # There's no any simple way to get it :-(
    if ($notice ne "") { $mft_var=$notice; }	# seek in $notice
    else { $mft_var=$raw; }			# seek in $raw
    SWITCH: for ($mft_var) {
	/Monotype/i and $mft="monotype", last SWITCH;
	(/International Typeface Corporation/i || /ITC/i) and $mft="ITC", last SWITCH;
	/Microsoft/i and $mft="microsoft", last SWITCH;
	/Linotype(| AG)/i and $mft="linotype", last SWITCH;
	/H.\sBerthold AG/i and $mft="berthold", last SWITCH;
	/URW/i and $mft="URW", last SWITCH;
	/Visual Graphics Corporation/i and $mft="Visual Graphics", last SWITCH;
	# actually Adobe edits and publishes above companies' fonts ;-)
	/Adobe/i and $mft="adobe", last SWITCH;
	# TODO: add more manufacturers
	$mft="misc";
    }

    # name is TYPICALLY, accordingly to Adobe's style, stored
    # in $fontname in form "/<name>-<weightspec>"
    split('-', $fontname);
    $fontname = @_[0];
    $fontname =~ s#^/##; # remove slash
    # determine weight
    SWITCH: for(@_[1]) {
	/black/i and $weight="Black", last SWITCH;
	/bold/i and $weight="Bold", last SWITCH;
	/book/i and $weight="Book", last SWITCH;
	/demi/i and $weight="Demi Bold", last SWITCH;
	/light/i and $weight="Light", last SWITCH;
	/medium/i and $weight="Medium", last SWITCH;
	/regular/i and $weight="Regular", last SWITCH;
	/semi/i and $weight="Semi Bold", last SWITCH;
	# exotic ones
	/heavy/i and $weight="Heavy", last SWITCH;
	/ultra/i and $weight="Ultra", last SWITCH;
	# default
	$weight="Regular";
    }
    # italic, oblique or regular
    SWITCH: for(@_[1]) {
	/italic/i and $slant="i", last SWITCH;
	/oblique/i and $slant="o", last SWITCH;
	# default
	$slant="r";
    }
    # width
    SWITCH: for(@_[1]) {
	/cond/i and $width="condensed", last SWITCH;
	/semicond/i and $width="semicondensed", last SWITCH;
	# default
	$width="normal";
    }

    # encodings
    SWITCH: for($enc) {
	/Standard/i and @encoding = ("iso8859-1", "iso8859-2"), last SWITCH;
	# TODO: one who knows Adobe encoders' style: add more circumstances
	@encoding = ("iso8859-1");
    }

    # print font line for each encoding
    for (@encoding) {
	print TMP "$curfont -$mft-$fontname-$weight-$slant-$width--0-0-0-0-p-0-$_\n";
	$num_of_lines++;
    }
}

open(OUT, "+> $out_filename") or die "$program: Error: I can't create output file!\n";
seek(TMP, 0, SEEK_SET);		    # rewind temporary file
print OUT "$num_of_lines\n";	    # DEST <= number of font lines (first line)
while(<TMP>) { print OUT "$_"; }    # DEST <= TEMP (line by line)
close TMP;			    # clos'em
close OUT;
system ("rm -f $tmp");		    # remove temporary file

# This is DONE!

