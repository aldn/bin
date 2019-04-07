#### MAIN ####

use strict;
use warnings;
use utf8;
use feature "switch";

# process options
use Getopt::Long;
my $optionHelp;
my $optionSource;
GetOptions ( 
'help'       => \$optionHelp,
'source=s'   => \$optionSource 
);

if (defined $optionHelp)
{
   print "YakabooClient.pl [OPTIONS]\n";
   print "  --source=SOURCE              Part of site to open. SOURCE can be one of:  sale, catalog, toprated, latest, suggest\n";
   exit;
}

die ("Source not defined. See --help") if not defined $optionSource;

my $urlDvdSale = "http://www.yakaboo.ua/ru/sale/catalog/a-z/dvd";
my $urlDvdCatalog = "http://www.yakaboo.ua/ru/catalog/a-z/dvd";
my $urlDvdTopRated = "http://www.yakaboo.ua/ru/catalog/top-rated/dvd";
my $urlDvdLatestReleases = "http://www.yakaboo.ua/ru/catalog/latest-releases/dvd";
my $urlDvdSuggest = "http://www.yakaboo.ua/ru/catalog/suggest/dvd";

my $urlBasename;
my $maxpage = 20;
given ($optionSource)
{
when    (/sale/)      { $urlBasename = $urlDvdSale; $maxpage = 200; }
when    (/catalog/)   { $urlBasename = $urlDvdCatalog; $maxpage = 200; }
when    (/toprated/)  { $urlBasename = $urlDvdTopRated; }
when    (/latest/)    { $urlBasename = $urlDvdLatestReleases; }
when    (/suggest/)   { $urlBasename = $urlDvdSuggest; }
default { $urlBasename = $urlDvdCatalog; }
}

print "Will fetch up to $maxpage pages\n";

clearLogs();
clearReport();

# try all pages
for (1..$maxpage)
{
   my $url_to_fetch = "$urlBasename/page-$_";
   logWarning("page $_\n");
   print "page $_\n";
   my $yakaboo_response = httpFetch($url_to_fetch);
   
   # exit loop if fetch unsuccessful (last page in list?)
   last if not defined $yakaboo_response;
      
   my @listMovies = buildListOfMovies($yakaboo_response);

   $| = 1;
   foreach my $i (@listMovies)
   {
      fetchItemInfoFromYakabooItemPage($i);
      #print "english title: \"$i->{title_en}\"    year: $i->{year}\n";
      
      fetchMovieRating($i);
      #print "rating: \"$i->{rating}\"    tomato: $i->{tomatometer}\n";
      
      if (   !defined $i->{rating}  
          || !defined $i->{tomatometer}
          || $i->{tomatometer} =~ m,n/a,i
          || !defined $i->{title_en}
          || !defined $i->{year}
          || !defined $i->{imdb_id}
          || !defined $i->{plot}
          || !defined $i->{aspect_ratio}
          || !defined $i->{buy_or_order}
          )
      {
         logWarning("\nWARNING: yakaboo item " . $i->{url} . " has some fields missing: \n");
         logWarning("  - rating is 0\n")                 if !defined $i->{rating};
         logWarning("  - tomatoMeter is 0\n")            if !defined $i->{tomatometer};
         logWarning("  - tomatoMeter is N/A\n")          if defined $i->{tomatometer} and $i->{tomatometer} =~ m,n/a,i;
         logWarning("  - english title is empty\n")      if !defined $i->{title_en};
         logWarning("  - year is undefined\n")           if !defined $i->{year};
         logWarning("  - IMDB ID is undefined\n")        if !defined $i->{imdb_id};
         logWarning("  - plot is undefined\n")           if !defined $i->{plot};
         logWarning("  - aspect ratio is undefined\n")   if !defined $i->{aspect_ratio};
         logWarning("  - buy/order availability is undefined\n")   if !defined $i->{buy_or_order};
         logWarning("\n");
      }
      
      appendReport($i);
      
      print "."; 
   }
   $| = 0;
   print "\n";
}

#### MAIN ENDS ####






sub httpFetch
{
   use LWP::Simple;
   my $url = shift;
   #print "fetch: $url\n";
   my $result = get($url);
   #print " (done)\n";
   return $result;
}


sub buildListOfMovies
{
   my @list_movies = ();
   my $tokenSeparator = "<img id=\"film_image_";
   
   # each token is a movie
   my @tokens = split ($tokenSeparator, shift);
   
   # remove first token because it has no useful information
   shift @tokens;
   
   # clean last token as it usually has unnecessary garbage at the end
   $tokens[$#tokens] =~ s/Страница:.+$//;
   
   #open f, ">dump.txt";
   foreach my $t (@tokens)
   {
      my %movie = ();
   
      # prefix with token separator
      $t = $tokenSeparator . $t;
      
      # remove newlines
      $t =~ s/\n//g;
      
      #logWarning("\ntoken:  $t\n\n");
      
      
      #print f "t = $t\n";
      if ($t =~ m/img id="film_image_.*?src="(.+?)"/)
      {
         $movie{pic} = $1;
         #print "movie_pic  = $movie{pic} \n";
      }
      
      if ($t =~ m#<div class="film_view_small_text"><a.*?href="(.+?)".*?>(.+?)</a>#)
      {  
         $movie{url}="http://www.yakaboo.ua$1";
         $movie{title}=$2;
         #print "movie_title = $movie{title} \n";
         #print "movie_url = $movie{url}\n";
      }
      
      if ($t =~ m#<span class="mini_text_orang" >(\d+)# )
      {
         $movie{price} = $1;
         #print "movie_price = $movie{price}\n";
      }
      
      if (defined $movie{pic} 
          and defined $movie{url}
          and defined $movie{title} )
      {
         push  @list_movies, { %movie } ;
      }
      else
      {
         logWarning("error:  item was not parsed correctly. Extracted fields:  pic=$movie{pic} url=$movie{url} title=$movie{title}\n");
      }
   }
   
   #close f;
   
   return @list_movies;
}




# @param: movie hash
sub fetchMovieRating
{
   my $movie = shift;
   my $movie_title = defined $movie->{title_en}  ? $movie->{title_en} : $movie->{title};

   my $request ="t=$movie_title";
   if (defined $movie->{year})
   {
      $request .= "&y=$movie->{year}";
   }
   my $htmlpage = imdbapiCacheGet($request);
   
   use JSON;
   my $imdbapiResult  = from_json $htmlpage;
   
   $movie->{rating}      = $imdbapiResult->{Rating};
   $movie->{tomatometer} = $imdbapiResult->{tomatoMeter};
   $movie->{imdb_id}     = $imdbapiResult->{ID};
}


# @param: movie hash
sub fetchItemInfoFromYakabooItemPage
{
   my $movie = shift;
   
   my $htmlpage = httpFetch($movie->{url});
   #print $movie->{url}. "\n";
   #print $movie_title_rus . "\n";
   
   if (not defined $htmlpage)
   {
      logWarning("error: failed to fetch $movie->{url}\n");
      return;
   }
   
   # remove newlines
   $htmlpage =~ s/\n//g;
   
   
   if ($htmlpage =~ m#<b>\s?$movie->{title}.+?</b>.+?<b>(.+?)</b>#)
   {
      $movie->{title_en} = $1;
      
      $movie->{title_en} =~ s/&nbsp;//;
      $movie->{title_en} =~ s/&amp;/&/;
      
      # If a title matches to a string of digits, then it comes from a russian movie. 
      # In this case set title_en to empty string.
      $movie->{title_en} =~ s/^\d+$//; 
   }
   
   if ($htmlpage =~ m#<b>\s?$movie->{title} \((.+?)\)</b>#)
   {
      $movie->{year} = $1;
      
      # remove spaces in year number string
      $movie->{year} =~ s/\s//g;
   }

   $htmlpage =~ m#Формат изображения:</th> <td >(.+?)</td>#
      and $movie->{aspect_ratio} = $1;
   
   # open test,">test.txt";
   # print test $htmlpage;
   # close test;
   
   # 0 = can't buy or order
   # 1 = can buy
   # 2 = can order

   # this code is generated when user is logged in
   if (  $htmlpage =~ m/onclick="addBuyFilm/ )
   {
      $movie->{buy_or_order} = 1;
   }
   elsif(  $htmlpage =~ m/onclick="addPreorderFilm/ )
   {
      $movie->{buy_or_order} = 2;
   }
   else
   {
      # this code is generated when not logged in
      if ( $htmlpage =~ m/onclick="incBasketGood\(\'(.+?)\'/)
      {
         my $operation = $1;
         ($operation =~ /bu/ or $operation =~ /sale/)         
            and $movie->{buy_or_order} = 1;
         $operation =~ /preorder/  
            and $movie->{buy_or_order} = 2;
      }
   }

   
   
   if ($htmlpage =~ m#<p>О фильме:</p>[\r\n]?<span.+?>(.+?)</span>#)
   {
      $movie->{plot}  .= $1;
   }
   
   if ($htmlpage =~ m#<p>Сюжет:</p>[\r\n]?<span.+?>(.+?)</span>#)
   {
      $movie->{plot}  .= "\n" . $1;
   }
   # remove any occasionally eaten HTML
   $movie->{plot} = stripHtml( $movie->{plot} );
}


sub clearReport
{
   unlink "report.txt";
}

sub clearLogs
{
   unlink "warnings.log";
}


sub appendReport
{
   my $el = shift;
   
   open fileHandle, ">>report.txt";
   
   use JSON;
   my $json_text   = encode_json $el;
   print fileHandle $json_text."\n";
      
   close fileHandle;
}



sub stripHtml
{
   my $val = shift;
   
   $val =~ s/<.+?>//g;
   
   return $val;
}


sub logWarning
{
   my $str = shift;
   open fileHandle, ">>warnings.log";
   print fileHandle $str ;
   close fileHandle;
   
   # also print to stderr
   #print STDERR $str;
}

sub imdbapiCacheGet
{
   my $imdbapiRequest = shift;
   #print "imdbapiRequest = $imdbapiRequest\n";
   # try to load from the cache first
   use DBI;
   my $db = DBI->connect("dbi:SQLite:dbname=imdbapi_cache.db","","",{AutoCommit => 0});
   $db->{sqlite_unicode} = 1;
   $db->do("CREATE TABLE IF NOT EXISTS imdbapi_cache (request, reply);") or die($db->errstr);
   my $query = $db->prepare("SELECT reply FROM imdbapi_cache WHERE (request = ?)");
   $query->execute($imdbapiRequest) or die($db->errstr);
   
   # fetch and return the only result if available
   while ( (my $response) = $query->fetchrow_array())
   {
      # not defined response is invalid. 
      # If imdbapi fails to fetch the info it returns {"Response":"Parse Error"} at least  
      # but never an empty string
      if (defined $response)
      {
         #print ">> returned cached imdbapi string: $response\n";
         $query->finish;
         $db->disconnect;
         return $response;
      }
   }
   
   # No such record in database,  get data from imdbapi.com and cache it.
   my $htmlpage = httpFetch("http://www.imdbapi.com/?$imdbapiRequest&tomatoes=true");
   
   my $sth = $db->prepare("INSERT INTO imdbapi_cache (request, reply) VALUES (?, ?)");
   $sth->execute($imdbapiRequest, $htmlpage)  or die($db->errstr);
   $db->commit;
   
   $sth->finish;
   $db->disconnect;
   
   return $htmlpage;   
}

