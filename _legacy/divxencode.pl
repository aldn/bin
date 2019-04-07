#!/usr/bin/perl

sub usage
{
	print <<EOF;
$0 [OPTIONS]
  --ffmpeg
  --xvid .............. Select codec
  --out=FILE .......... Output file name (optional)
  --audio=FILE ........ Audio file name (optional)
  --video=FILE ........ Video file name (required)
  --bitrate=NUMBER .... Set bitrate in kBit <4-16000> or
                                       Bit  <16001-24000000>
                                       (warning: 1kBit = 1000 Bits)
                                       (default: 800)
  --keyint=NUMBER ..... specify interval in frames between keyframes
  --append=STRING ..... pass optional string to codec
                        in form 'option1=value:option2=value'
  --cmdline=STRING .... pass option to mencoder
  --2pass ............. use 2-pass encoding
  --3pass ............. use 3-pass encoding
EOF
}

$passes =1;
$codec = "ffmpeg";

for $argvi (@ARGV)
{
	SWITCH: for ($argvi)
	{
		s/^--help// && do		{	usage; exit 0;				};
		s/^--ffmpeg// && do 	{	$codec="ffmpeg"; last SWITCH;	};
		s/^--xvid// && do 		{	$codec="xvid"; last SWITCH;	};
		s/^--out=// && do 		{	$output=$_; last SWITCH;	};
		s/^--audio=// && do		{	$audio=$_; last SWITCH;		};
		s/^--video=// && do		{	$video=$_; last SWITCH;		};
		s/^--bitrate=// && do	{	$bitrate=$_; last SWITCH;	};
		s/^--keyint=// && do	{	$keyint=$_; last SWITCH;	};
		s/^--append=// && do	{	$append=$_; last SWITCH;	};
		s/^--2pass// && do		{	$passes=2; last SWITCH;		};
		s/^--3pass// && do		{	$passes=3; last SWITCH;		};
		s/^--cmdline=// && do	{	$cmdline=$_; last SWITCH;	};
		die "Unknown option: $_\n";
	}
}

print <<EOF;
Output  : $output
Audio   : $audio
Video   : $video
Bitrate : $bitrate
Passes  : $passes
EOF

$output ne "" and $output_str="-o $output";
# assumes audio is plain wav
$audio ne "" and $audio_str="-audiofile $audio -oac mp3lame ";
$video ne "" or die "I can\'t live without video file!\n";

$lavcopts="-lavcopts vcodec=mpeg4";
$bitrate ne "" and $lavcopts .= ":vbitrate=$bitrate";
$keyint ne "" and $lavcopts .= ":keyint=$keyint";
$append ne "" and $lavcopts .= ":$append";

$xvidencopts="-xvidencopts ";
$bitrate ne "" and $xvidencopts .= ":bitrate=$bitrate";
$keyint ne "" and $xvidencopts .= ":max_key_interval=$keyint";
$append ne "" and $xvidencopts .= ":$append";

system("rm -f divx2pass.log frameno.avi");

if ($passes == 1)
{
	print "        ******************************************\n";
	print "        *            1-pass encoding             *\n";
	print "        ******************************************\n";

	$codec eq "ffmpeg" and $s="mencoder $cmdline $video $audio_str $output_str -ovc lavc $lavcopts";
	$codec eq "xvid" and $s="mencoder $cmdline $video $audio_str $output_str -ovc xvid $xvidencopts";
	print ">>>>>> Executing $s\n";
	system($s);
}

if ($passes == 2)
{
	print "        ******************************************\n";
	print "        *            2-pass encoding             *\n";
	print "        ******************************************\n";

	for $i (1..2)
	{
		print "\nPASS $i\n\n";
		$codec eq "ffmpeg" and $s="mencoder $cmdline $video $audio_str $output_str -ovc lavc $lavcopts:vpass=$i";
		$codec eq "xvid" and $s="mencoder $cmdline $video $audio_str $output_str -ovc xvid $xvidencopts:pass=$i";
		print ">>>>>> Executing $s\n";
		system($s);
	}
}

if ($passes == 3)
{
	print "        ******************************************\n";
	print "        *            3-pass encoding             *\n";
	print "        ******************************************\n";

	print "\nPASS 1 (frameno generation)\n\n";
	$codec eq "ffmpeg" and $s="mencoder $cmdline $video $audio_str -ovc frameno -o frameno.avi";
	print ">>>>>> Executing $s\n";
	system($s);

	for $i (1..2)
	{
		print "\nPASS ". $i+1 ."\n\n";
		$codec eq "ffmpeg" and $s="mencoder $cmdline $video $output_str -ovc lavc -oac copy $lavcopts:vpass=$i";
		$codec eq "xvid" and $s="mencoder $cmdline $video $output_str -ovc xvid -oac copy $xvidencopts:pass=$i";
		print ">>>>>> Executing $s\n";
		system($s);
	}

}
