#!/usr/bin/perl

# Collects version infos of programs and prints to stdout with formatting
#
# (c) 2003 Alexander Dunayevskyy
# MIT License
#



# defaults

$check_everything=0;
$check_kernel=1;
$check_glibc=1;
$check_xfree86=1;
$check_gcc=1;
$check_ld=1;
$check_binutils=1;
# optional
$check_qt=0;
$check_gtk=0;
$check_glib=0;
$check_libpng=0;
$check_opengl=0;
$check_autoconf=0;
$check_automake=0;
$check_libtool=0;
# list of supported locales
$check_locales=0;
# hardware things
$check_cpuinfo=0;
$check_videocard=0;
$check_videodriver=0;
$check_soundcard=0;
$check_sounddriver=0;
$check_usb=0;
$check_chipset=0;


# --------------------------------------------------------------------


sub usage
{
	print <<EOF;

This script collects system configuration info.
Usage:  $0 [WHAT TO CHECK]
  --all=BOOL ..................... check everything (default: $check_everything)
  --kernel=BOOL .................. check kernel version (default: $check_kernel)
  --glibc=BOOL ................... check GLIBC version (default: $check_glibc)
  --xfree86=BOOL ................. check XFree86 version (default: $check_xfree86)
  --gcc=BOOL ..................... check GCC version (default: $check_gcc)
  --ld=BOOL ...................... check ld version (default: $check_ld)
  --binutils=BOOL ................ check gas version (default: $check_binutils)
  --qt=BOOL ...................... check Qt version (default: $check_qt)
  --gtk=BOOL ..................... check GTK+ version (default: $check_gtk)
  --glib=BOOL .................... check GLIB version (default: $check_glib)
  --libpng=BOOL .................. check Libpng version (default: $check_libpng)
  --opengl=BOOL .................. check OpenGL libs (default: $check_opengl)
  --autoconf=BOOL ................ check Autoconf version (default: $check_autoconf)
  --automake=BOOL ................ check Automake version (default: $check_automake)
  --libtool=BOOL ................. check Libtool version (default: $check_libtool)
  --locales=BOOL ................. output supported locales (default: $check_locales)
  --cpuinfo=BOOL ................. output /proc/cpuinfo (default: $check_cpuinfo)
  --videocard=BOOL ............... output video hardware info (default: $check_videocard)
  --videodriver=BOOL ............. check video driver version (default: $check_videodriver)
  --soundcard=BOOL ............... output audio hardware info (default: $check_soundcard)
  --sounddriver=BOOL ............. check sound driver version (default: $check_sounddriver)
  --usb=BOOL ..................... check USB support (default: $check_usb)
  --chipset=BOOL ................. output chipset vendor & id (default: $check_chipset)
EOF
}


sub boolvalue
{
	$res=1;
	( /1/ || /true/ || /yes/ || /on/ )  and $res=1;
	( /0/ || /false/ || /no/ || /off/ ) and $res=0;
	return $res;
}


# parse args

for $i (@ARGV) { SWITCH: for ($i)
{
	s/^--help// && do			{	usage; exit 0; };
	s/^--all// && do			{	$check_everything =boolvalue($_);  last SWITCH; };
	s/^--kernel// && do			{	$check_kernel =boolvalue($_);  last SWITCH; };
	s/^--glibc// && do			{	$check_glibc =boolvalue($_);  last SWITCH; };
	s/^--xfree86// && do		{	$check_xfree86 =boolvalue($_);  last SWITCH; };
	s/^--gcc// && do			{	$check_gcc =boolvalue($_);  last SWITCH; };
	s/^--ld// && do				{	$check_ld =boolvalue($_);  last SWITCH; };
	s/^--binutils// && do		{	$check_binutils =boolvalue($_);  last SWITCH; };
	s/^--qt// && do				{	$check_qt =boolvalue($_);  last SWITCH; };
	s/^--gtk// && do			{	$check_gtk =boolvalue($_);  last SWITCH; };
	s/^--glib// && do			{	$check_glib =boolvalue($_);  last SWITCH; };
	s/^--libpng// && do			{	$check_libpng =boolvalue($_);  last SWITCH; };
	s/^--opengl// && do			{	$check_opengl =boolvalue($_);  last SWITCH; };
	s/^--autoconf// && do		{	$check_autoconf =boolvalue($_);  last SWITCH; };
	s/^--automake// && do		{	$check_automake =boolvalue($_);  last SWITCH; };
	s/^--libtool// && do		{	$check_libtool =boolvalue($_);  last SWITCH; };
	s/^--locales// && do		{	$check_locales =boolvalue($_);  last SWITCH; };
	s/^--cpuinfo// && do		{	$check_cpuinfo =boolvalue($_);  last SWITCH; };
	s/^--videocard// && do		{	$check_videocard =boolvalue($_);  last SWITCH; };
	s/^--videodriver// && do	{	$check_videodriver =boolvalue($_);  last SWITCH; };
	s/^--soundcard// && do		{	$check_soundcard =boolvalue($_);  last SWITCH; };
	s/^--sounddriver// && do	{	$check_sounddriver =boolvalue($_);  last SWITCH; };
	s/^--usb// && do			{	$check_usb =boolvalue($_);  last SWITCH; };
	s/^--chipset//  && do		{	$check_chipset =boolvalue($_);  last SWITCH; };
	die "Unknown option: $_\n";

}
}

$check_everything && do {
	$check_kernel=1;
	$check_glibc=1;
	$check_xfree86=1;
	$check_gcc=1;
	$check_ld=1;
	$check_binutils=1;
	$check_qt=1;
	$check_gtk=1;
	$check_glib=1;
	$check_libpng=1;
	$check_opengl=1;
	$check_autoconf=1;
	$check_automake=1;
	$check_libtool=1;
	$check_locales=1;
	$check_cpuinfo=1;
	$check_videocard=1;
	$check_videodriver=1;
	$check_soundcard=1;
	$check_sounddriver=1;
	$check_usb=1;
	$check_chipset=1;
};


print "------------------ System configuration  ------------------\n";

$check_kernel && do {
	print `uname -a`;
	print "\n";
};


$check_glibc && do {
	print "GNU C libraries:\n";
	print `ls -l /lib/libc[.-]*`;
	print "\n";
};


$check_xfree86 && do {
	$z=`X -version 2>&1`;
	@a=split ('\n', $z);
	for (@a) {
		/Version/ || /Release Date/ || /Build Operating System/ and do {
			print;
			print "\n";
		};
	}
	print "\n";
};


$check_gcc && do {
	print `gcc -v 2>&1 | grep 'gcc version'`;
	print "\n";
};


$check_ld && do {
	print `ld -v`;
	print "\n";
};


$check_binutils && do {
	print `as --version 2>&1 | grep 'GNU assembler'`;
	print "\n";
};


$check_autoconf && do {
	print `autoconf --version 2>&1 | grep 'autoconf (GNU Autoconf)'`;
	print "\n";
};


$check_automake && do {
	print `automake --version 2>&1 | grep 'automake (GNU Automake)'`;
	print "\n";
};


$check_libtool && do {
	print `libtool --version 2>&1 | grep '(GNU libtool)'`;
	print "\n";
};


$check_qt && do {
	print "Qt libraries:\n";
	$z=`find $ENV{QTDIR} -name libqt*.so.* 2>/dev/null`;
	$z=~s#\n# #g;
	print `ls -l $z`;
	print "\n";
};


$check_gtk && do {
	print "GTK+ libraries:\n";
	$z=`find /usr -name libgtk*.so.* 2>/dev/null`;
	$z=~s#\n# #g;
	print `ls -l $z`;
	print `gtk-config --version 2>/dev/null`;
	print "\n";
};


$check_glib && do {
	print "GLIB libraries:\n";
	$z=`find /usr -name libglib*.so.* 2>/dev/null`;
	$z=~s#\n# #g;
	print `ls -l $z`;
	print "\n";
};


$check_libpng && do {
	print "PNG libraries:\n";
	$z=`find /usr -name libpng*.so.* 2>/dev/null`;
	$z=~s#\n# #g;
	print `ls -l $z`;
	print "\n";
};


$check_opengl && do {
	print "OpenGL:\n";
	$z=`find /usr -name libGL*.so.* -or -name libglut*.so.* 2>/dev/null`;
	$z=~s#\n# #g;
	print `ls -l $z`;
	print "\n";
};


$check_locales && do {
	print "Supported locales:\n";
	print `locale -a`;
	print "\n";
};


$check_cpuinfo && do {
	print "\$ cat /proc/cpuinfo\n";
	print `cat /proc/cpuinfo`;
	print "\n";
};


$check_videocard && do {
	print "Video Card:\n";
	print `lspci -vv 2>&1 | grep 'VGA compatible controller'`;
	print "NVIDIA GeForce 2 MX400 64Mb SDRAM\n";
	print "\n";
};


$check_videodriver && do {
	print "Video Driver:\n";
	$z= `dmesg |grep nvidia`;
	$z=~s#\d: nvidia: loading##;
	print $z;
	print "\n";
};


$check_soundcard && do {
	print "Sound Card:\n";
	print `lspci -vv 2>&1 | grep 'Multimedia audio controller'`;
	print "\n";
};


$check_sounddriver && do {
	print "ALSA Sound Driver (checking):\n";
	$z=`alsactl --version 2>/dev/null`;
	$z eq "" and print "not found";
	$z ne "" and print $z;
	print "\n";
};


$check_usb && do {
	print "USB:\n";
	print `lspci -vv 2>&1 | grep USB`;
	print "\n";
};


$check_chipset && do {
	print "Chipset:\n";
	print `lspci -vv 2>&1 | grep -E ^00:00.0`;
	print "\n";
};


print "-----------------------------------------------------------\n";
