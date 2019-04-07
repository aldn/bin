use File::Copy;

opendir(DIR, ".") || die "can't opendir $some_dir: $!";
$counter =0;
$suffix  =shift;
while (defined($_ = readdir(DIR)))
{
   /^\.+$/ && next;
 #  if (-f $_ )
   {
      $oldname = $_;
      $newname = sprintf "%.2d$suffix\n", $counter++ ;
      print "$oldname $newname\n";
      move( $oldname, $newname) || die "can't renameL $!";
   }
}
closedir DIR;
