#!/usr/bin/perl

# extracts package description from RPM .spec files
# and prints it in slack-desc format
$in_desc =0;
while (<STDIN>) {
SWITCH:
	for ($_) {
		chomp;
		/Name/ && do { s/Name:\s*//; $name = $_; last SWITCH; };
		/Summary/ && do  { s/Summary:\s*//; $summary = $_; last SWITCH; };
		/\%description/ && do { $in_desc = 1; last SWITCH; };
		/^\%/ && do { $in_desc =0; last SWITCH; };
		@desc = (@desc, $_ ) if($in_desc && $_ ne "");
	}
}

print "$name: $name ($summary)\n";
print "$name:\n";
foreach (@desc) {
	print "$name: $_\n";
}
print "$name:\n";

