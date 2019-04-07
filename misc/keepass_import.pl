#!/usr/bin/perl

use warnings;
use strict;

use Text::Tabs;
use String::Util ':all';
use Term::ReadKey;
use File::KeePass;
use Data::Dumper qw(Dumper);

# read password from terminal

print "Type master password for kdbx file:";
ReadMode('noecho'); # don't echo
my $master_pass = <STDIN>;
chomp($master_pass);
ReadMode('normal');        # back to normal

# open db
my $db_file  = "1.kdbx";
my $k = File::KeePass->new;
$k->load_db($db_file, $master_pass); # errors die
$k->unlock;


my $group = $k->find_group({title => 'root'});
my $gid = $group->{'id'};

# parse text password file
open(TXTPASS, "<", "/tmp/1");
#my $limit = 3;
for(<TXTPASS>)
{
    #if ($limit == 0)
    #{
    #    last;
    #}
    #--$limit;

    chomp;
    my $line_expanded = expand($_);

    (my $title, my $username, my $password, my $notes) = unpack('a32a40a32a80',$line_expanded);
    $title = trim($title);
    $username = trim($username);
    $password = trim($password);
    $notes = unquote(trim($notes));

    #print "title '$title' username='$username' password='$password' notes='$notes'\n";

    my $e = $k->add_entry({
        title    => $title,
        username => $username,
        password => $password,
        group    => $gid,
        comment  => $notes
    });
}
close(TXTPASS);

# save out a version 2 database
$k->save_db("exported.kdbx", $master_pass);

