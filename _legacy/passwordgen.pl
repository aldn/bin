#!/usr/bin/perl

$max_chars = $ARGV[0] eq "" ? 8 : $ARGV[0];
srand;
while( $max_chars-- )
{
	# get a random ASCII character ordinal value
	# and throw away until an alphanumeric one found
	do {
		$random=int( rand(127) );
	}while( !(
		($random >= ord("A") && $random <= ord("Z") ) ||
		($random >= ord("a") && $random <= ord("z") ) ||
		($random >= ord("0") && $random <= ord("9") )));
	print chr($random);
}
print "\n";
