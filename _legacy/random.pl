#!/usr/bin/perl

# Get random number from openssl and convert to string of decimal digits
# ARGV[0] = max_digits_in_output
# ARGV[1] = conversion method (hex or decimal, decimal is the default)
#
# Created Fri 28 Jun 2002 01:36:13 PM EEST

(@ARGV[0] ne "") or die "There must be max_digits specifier (\$1)\n";
$max_digits=@ARGV[0];
$dx_conv = @ARGV[1];

# this does not give any numeric string
# (with DIGITS, not ASCII)
# but rather random BYTES
$rand = `openssl rand $max_digits`;

$istart = 0;
for( ; $istart < $max_digits ; $istart++) {
	# <--
	# 1) extract one character [ substr(...) ]
	# 2) get its numeric value [ ord(...) ]
	# 3) raw printf value in either hex or decimal
	$rand_s = $rand_s . (sprintf (( $dx_conv eq "--hex" && $dx_conv ne "") ? "%x" : "%d",
		ord(substr($rand, $istart, 1))));
}

# length of $rand_s will probably be longer
# than requested ($max_digits) so truncate it 
print (substr($rand_s, 0, $max_digits)); print "\n";


