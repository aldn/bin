#!/usr/bin/perl

use POSIX qw(strftime);

@patterns = (
	"\\*.c",
	"\\*.h",
	"\\*.cpp",
	"\\*.cc",
	"\\*.C" );

for (@patterns)
{
	@files = ( @files, `find  -name $_` );
}


for $curFile (@files)
{
	chomp $curFile;
	# get current file base name
	$baseName = `basename $curFile`;
	chomp $baseName;
	# get modification time
	$mtime = (stat($curFile))[9];
	$mtimeString = strftime "%Y/%m/%d %H:%M:%S", gmtime $mtime;

	system( "cp $curFile $curFile~" );
	open IN, "< $curFile~";
	open OUT, "> $curFile";
	# read input file and check for keyword tags
	# $Id$ or $Id:...$
	for $line (<IN>)
	{
		chomp $line;

		$lineBefore = $line;
		$line =~ s#\$Id(:.*|)\$#\$Id: $baseName     edited $mtimeString \$# && do
		{
			print "$curFile: - $lineBefore\n";
			print "$curFile: + $line\n";
		};
		print OUT "$line\n";

	}
	close IN;
	close OUT;
	system( "rm -f $curFile~" );
	# set modification time as it was before
	utime $mtime, $mtime, $curFile;
	#utime time,time,$curFile;

}
