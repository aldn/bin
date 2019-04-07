#!/usr/bin/perl

# A filter for Subscribe.Ru mailings.
# Strips all commercials and useless headers/footers

$skip= 0;
$napisat_v_list=0;

while (<>) {

	# skip this and all following lines
	# just after '-*-----....'
	/^-\*---/ and $skip=1;

	# print this and all following
	# after '-----...' or '======...'
	(/^-{5}/ or /^={5}/) and $skip=0;

	# these lines are always skipped
	/Информационный канал Subscribe.Ru/	and next;

	#these lines are always printed
	/^Отписать/ and do { 
		print;
		next;
	};
	/^Написать в лист/	and do {
		$napisat_v_list || print;
		$napisat_v_list = 1; # do not want to print this more than once
		next;
	};


	print if!$skip;
}
