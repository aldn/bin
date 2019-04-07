#!/usr/bin/perl

die "usage: $0 DIR ARCHIVE_NAME COUNT_LIMIT [TAR_ARGS]\n" if $#ARGV<2;

$userlogin="crow";
$homedir=`echo ~$userlogin`;
$homedir =~ s/\n//;
$homedir =~ /^~/ && die "Not valid user: $userlogin\n";
$backupdir = "$homedir/archive";

(! -d $backupdir) && do
{
	print "Creating nonexistent directory $backupdir.\n";
    mkdir $backupdir;
};

$dir		= $ARGV[0];
$basename	= $ARGV[1];
$limit		= $ARGV[2];
$optargs	= $ARGV[3] if $#ARGV >= 3;

use POSIX qw(strftime);
$date = strftime "%Y%m%d", localtime;

$saveto="$backupdir/$basename-$date.tar.bz2";
$pattern="$backupdir/$basename-*.tar.bz2";


# Check total count of files with given basename
# and in case it exceeds max, delete _a file_

@files=`ls $pattern 2>/dev/null`;
( $#files > $limit-1 ) && do
{
	print "Exceeded count limit on $pattern. Deleting all...\n";
	# get first file in list ( and the one with earlier date)
	# and remove it
	$#files >= 0 &&  system("rm -f $files[0]");
};


# create a today's archive if it is not there

( ! -f $saveto ) && do
{
	print "Creating archive $saveto...\n";
	system("tar $optargs -jcf \"$saveto\" \"$dir\"");
	system("chown crow:crow \"$saveto\"");
	system("chmod 600 \"$saveto\""); # rw by owner only
};
