#!/usr/bin/perl

@ls = `find -regex '^.* .*'`;
foreach(@ls)
{
	chomp;
	$a=$_;
	$b=$_;
	$b=~s/ /_/g;
	print "$a -> $b\n";
	system ("mv", $a, $b);
}
