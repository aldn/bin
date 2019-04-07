use strict;
use warnings;

my $metafileFilename= "metafile-temporary";
foreach(@ARGV) 
{
   /\.mkv/ && do
   {
   
      my $inputFilename  = $_;
      my $outputFilename = $inputFilename;
      $outputFilename =~ s/\.mkv/\.ts/;
      #print $outputFilename ."\n" ; sleep 10; die;
      open metafileHandle, ">$metafileFilename" or die;

      print metafileHandle << "EOF";
MUXOPT --no-pcr-on-video-pid --new-audio-pes --vbr  --vbv-len=500
V_MPEG4/ISO/AVC, "$_", insertSEI, contSPS, track=1, lang=rus
A_AC3, "$_", track=2, lang=rus
A_AC3, "$_", track=3, lang=eng
EOF
      close metafileHandle;
         
      print "tsmuxer  $metafileFilename \"$outputFilename\"\n";
      system("tsmuxer  $metafileFilename \"$outputFilename\"");
   }
}


unlink $metafileFilename;

sleep(10);
