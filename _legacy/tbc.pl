#!/usr/bin/perl
# Termcap_Block_Cursor: seek and replace cursor escape capabilities
# the way to make cursor as tall as possible

$storage_file="./termcap.new";

open(IN, "< /etc/termcap")	or die "$0: Error: terminal database file is unreadable!\n";
open(OUT, "+> $storage_file")	or die "$0: Error: cannot create output file!\n";

$line=1;
while (<IN>) {
    # find vi, ve and vs options and append|replace this escape:
    #	\E[?32c
    # It sets block cursor as documented in kernel-doc/VGA-softcursor.txt

    /^#/ || do {	# don't disturb the things commented out
	my @caps = split(':');	# do separate terminal capabilities
	
	for(@caps) {
	    /^v(i|e|s)=/ && do { # if it's vi, ve or vs
		
		# seek cursor escape & change it
		if(s/((\\E|\\033)\[)\?\d+c/$1?32c/) {
		    print "Escape CHANGED at line $line\n";
		}
		# if not found, just append good escape
		else {
		    $_ .= q/\\E[?32c/;
		    print "Escape APPENDED at line $line\n";
		}
		
	    }; # do
	} # for @caps
	
	$_ = join(':',@caps); # collect changed(?) pieces
    };
    print OUT;
    $line++;
}

print "$0: modified termcap file is saved as $storage_file.\n";
close IN,OUT;

