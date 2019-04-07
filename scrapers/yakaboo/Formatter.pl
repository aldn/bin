
use strict; 
use warnings;
use utf8;
use feature "switch";

# process options
use Getopt::Long;
my $optionHelp;
my $optionInput;
my $optionFilterAspectRatio;
my $optionMinimumTomatoMeter;
my $optionExcludePreorder;
GetOptions ( 
'help'               => \$optionHelp,
'input=s'            => \$optionInput,
'exclude-aspect=s'   => \$optionFilterAspectRatio,
'minimum-tomato=i'   => \$optionMinimumTomatoMeter, 
'exclude-preorder'   => \$optionExcludePreorder 
);

if (defined $optionHelp)
{
   print "List of options:\n";
   print "  --help                       Usage information\n";
   print "  --input=FILENAME             Path to input file. Default: report.txt\n";
   print "  --minimum-tomato=0..100      Include only those which TomatoMeter is >= than that\n";
   print "  --exclude-aspect=STRING      If item's aspect ratio matches STRING (e.g. \"4:3\" the item is excluded\n";
   print "  --exclude-preorder           Exclude items which could be only preordered, not bought now\n";
   exit;
}

$optionInput = "report.txt" unless defined $optionInput;

open fileHandle, "<$optionInput" or die ("Can't open input file $optionInput");
#binmode(fileHandle, ":utf8");
my @movieTableRows = <fileHandle>;
close fileHandle;

# parse rows of json objects
my @movies = ();
foreach (@movieTableRows )
{
   use JSON;
   my $movie = decode_json ($_);
   
   if (!defined $movie->{rating}
       or $movie->{rating} =~ m,n/a,i)
   {
      $movie->{rating} = 0;
   }
   
   # calculate TomatoMeter value based upon IMDB rating
   # if TomatoMeter is not available.
   if ( !defined $movie->{tomatometer}  
        or $movie->{tomatometer} eq "" 
        or $movie->{tomatometer} =~ m,n/a,i)
   {
      $movie->{tomatometer} = $movie->{rating} * 10 ;
   }
      
   if (defined $optionFilterAspectRatio 
       and defined $movie->{aspect_ratio} 
       and $movie->{aspect_ratio} =~ /$optionFilterAspectRatio/)
   {
      # skip
      next;
   }
   
   if (defined $optionMinimumTomatoMeter 
       and $movie->{tomatometer} < $optionMinimumTomatoMeter)
   {
      # skip
      next;
   }
   
   if (defined $optionExcludePreorder 
       and $movie->{buy_or_order} == 2)
   {
      # skip
      next;
   }
   
   push (@movies, $movie);
}
   
# sort by Rotten Tomatoes rating
@movies = sort {$b->{tomatometer} <=> $a->{tomatometer}  } @movies;

my $outputFileName = $optionInput;
#replace filename extension with .html
$outputFileName =~ s/\..+$/\.html/;

open fileHandle, ">$outputFileName" or die("can't create output file $outputFileName") ;
binmode(fileHandle, ":utf8");


print fileHandle   << "TAG";
<html xmlns="http://www.w3.org/1999/xhtml" lang="ru-ru" xml:lang="ru-ru">
<head>
   <meta http-equiv="Content-Type" content="text/html; charset=utf8" />
   <link rel="stylesheet" type="text/css" href="Styles.css" />
</head>
<body>
TAG

foreach my $movie(@movies)
{  
   my $mtitle =    "$movie->{title}<br>";
   $mtitle .=   "<span class=\"title_en\">$movie->{title_en}</span><br>"
      unless not defined $movie->{title_en} ;
   
   my $tomatometerStyle;
   if ( $movie->{tomatometer} <= 30)
   {
      $tomatometerStyle = "rating_low";
   }
   elsif ( $movie->{tomatometer} <= 60)
   {
      $tomatometerStyle = "rating_medium";
   }
   else
   {
      $tomatometerStyle = "rating_high";
   }
   
   my $aspectratioStyle;
   if ( defined $movie->{aspect_ratio} && $movie->{aspect_ratio} =~ /4:3/)
   {
      $aspectratioStyle = "rating_low";
   }
   else
   {
      $aspectratioStyle = "rating_high";
   }
   
   my $moviePic = $movie->{pic};
   my $movieUrl = $movie->{url};
   my $movieYear = defined $movie->{year} ? $movie->{year} : "??";
   my $movieAspectRatio = defined $movie->{aspect_ratio} ? $movie->{aspect_ratio} : "N/A";
   my $movieRating = $movie->{rating};
   my $movieTomatoMeter = $movie->{tomatometer};
   my $moviePrice = defined $movie->{price} ? $movie->{price} : "??";
   
   my $movieBuyOrder;
   given ($movie->{buy_or_order})
   {
   when    (1) { $movieBuyOrder = ""; }
   when    (2) { $movieBuyOrder = "<span class=\"unavailable\">not in stock</span><br>"; }   
   default { $movieBuyOrder = "<span class=\"unavailable\">status unknown</span><br>"; }
   }
   
   
   my $movieImdbLink="";
   if (defined $movie->{imdb_id})
   {
      $movieImdbLink = "<a href=\"http://www.imdb.com/title/$movie->{imdb_id}\">[imdb]</a>";
   }
   
   print fileHandle << "TAG";
   <div class="cell">
      <div class="poster">
         <a href="$movieUrl">
              <img src="$moviePic"><br>
         </a>
         <div class="textbelowposter">
            $movieBuyOrder
            $movieImdbLink
         </div>
       </div>
       <div class="celltext">
         <a href="$movieUrl">
              $mtitle
         </a>
         $movieYear<br>
         aspect ratio: <span class="$aspectratioStyle">$movieAspectRatio</span><br>
         IMDB Rating: $movieRating/10<br>
         TomatoMeter: <span class="$tomatometerStyle">$movieTomatoMeter/100</span><br>
         $moviePrice грн<br>
      </div>
   </div>
TAG

   #print $movie->{imdb_id} . "\n";
}

print fileHandle << "EOF";
</body>
</html>
EOF


close fileHandle;
