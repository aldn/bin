#!/usr/bin/perl

# Write description block of source file to stdout.
# The sample was taken from kernel source linux/kernel/dma.c
# Following fields were added: $Product, $Notice, $Info
#
# By default selecting C type


sub usage {
    print "
Synopsis:
    $0 [options]

Options:
    --file=FILENAME         source file name
    --project=STRING        project name
    --abst=STRING           very short description
    --defsym=STRING         symbol to use in #ifndef..#define..#endif block in .h-file

"
}

for $arg (@ARGV)
{
    SWITCH: for($arg)
	{
		s/--file=//   and $file=$arg, last SWITCH;
		s/--project=//   and $project=$arg, last SWITCH;
		s/--abst=//   and $abst=$arg, last SWITCH;
		s/--defsym=// and $defsym=$arg, last SWITCH;
		s/--help//   && do
		{
	     	usage;
	    	exit 0;
		};
		die "I don\'t know such a switch: $arg\n";
	}
}

$file    eq "" and $file    = qw($<Source>);
$project eq "" and $project = qw($<Project>);
$abst    eq "" and $abst    = qw($<Abstract>);


$fnopath = $file;
# match none, single tilde, tilde and username, relative path
# followed by slash
$fnopath =~ s#(~(\w+|)|\w+|)/##g;

$type = "c";
SWITCH: for ($fnopath)
{
	/\.c$/i  and $type = "c", last SWITCH;
	(/\.cpp$/i or /\.cc$/i or /\.cxx$/i  or /\.C$/ ) and $type = "c++", last SWITCH;
	(/\.h$/i or /\.hpp$/i) and $type = "h", last SWITCH;
	/\.scm$/i and $type = "Scheme", last SWITCH;
	/\.pl$/i and $type = "Perl", last SWITCH;
}


$t = $fnopath; $t =~ tr/[.\-]/_/;
$defsym  eq "" and $defsym  = "__".uc($t )."__";
undef $t;


# define strict date format:
#   YYYY/MM/DD hh:mm:ss
use POSIX qw(strftime);
$date  = strftime "%Y/%m/%d %H:%M:%S", localtime;
$year  = strftime "%Y", localtime;
$today = strftime "%Y/%m/%d", localtime;

@text = (
" <brief>",
" Copyright (C) $year Alexander Dunayevskyy <od\@xyzw.me>",
"",
" This program is free software; you can redistribute it and/or modify",
" it under the terms of the GNU General Public License as published by",
" the Free Software Foundation; either version 2 of the License, or",
" (at your option) any later version.",
"",
" This program is distributed in the hope that it will be useful,",
" but WITHOUT ANY WARRANTY; without even the implied warranty of",
" MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the",
" GNU General Public License for more details.",
"",
" You should have received a copy of the GNU General Public License",
" along with this program; if not, write to the Free Software",
" Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.",
""
);

# we print the same text for all file types but use different comments
$type eq "c" and do {
	print "/*\n";
	print " *".$_."\n" for (@text);
	print " */\n";
};

#$type eq "c++" and print "//".$_."\n" for (@text);
$type eq "c++" and do {
	print "/*\n";
	print " *".$_."\n" for (@text);
	print " */\n";
};

$type eq "Scheme" and print ";;".$_."\n" for (@text);
$type eq "Perl" and print "#".$_."\n" for (@text);

$type eq "h" and print
"#ifndef $defsym
#define $defsym

/* put declarations here */

#endif /* ! $defsym */
";

