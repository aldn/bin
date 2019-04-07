use warnings;
use strict;
use Audio::Wav;


if ($#ARGV != 2) 
{
    die "usage ".$ARGV[0]." file1.wav file2.wav difference.wav";
}

my $input1 = shift;
my $input2 = shift;
my $output = shift;

my $wav = new Audio::Wav;
my $read1 = $wav -> read($input1);
my $read2 = $wav -> read($input2);
my $write = $wav -> write($output, $read1 -> details() );
print "input1 is ", $read1 -> length_seconds(), " seconds long\n";
print "input2 is ", $read2 -> length_seconds(), " seconds long\n";

print "Writing diff...\n";

while (    ( my @channels1 = $read1 -> read() ) 
        && ( my @channels2 = $read2 -> read() ) 
        )
{
    die unless $#channels1 == $#channels2 && $#channels2 == 1;

    $write -> write(  ( 
      $channels1[0] - $channels2[0],
      $channels1[1] - $channels2[1] 
    ) );
}

$write -> finish();
