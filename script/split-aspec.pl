#!/usr/bin/perl

use strict;
use utf8;
use FileHandle;
use Getopt::Long;
use List::Util qw(sum min max shuffle);
binmode STDIN, ":utf8";
binmode STDOUT, ":utf8";
binmode STDERR, ":utf8";

if(@ARGV < 4) {
    print STDERR "Usage: $0 ID_OUT SRC_OUT TRG_OUT TYPE CONF < IN\n";
    exit 1;
}

$ARGV[3] =~ /^(entrain|en|zh)$/ or die "Bad type $ARGV[3]\n";

open FILE0, ">:utf8", $ARGV[0] or die "Couldn't open $ARGV[0]";
open FILE1, ">:utf8", $ARGV[1] or die "Couldn't open $ARGV[1]";
open FILE2, ">:utf8", $ARGV[2] or die "Couldn't open $ARGV[2]";

my ($src, $trg, @ids);
if($ARGV[3] eq "entrain") {
    ($src, $trg, @ids) = (3, 4, 1, 2);
} elsif($ARGV[3] eq "en") {
    ($src, $trg, @ids) = (2, 3, 0, 1);
} else {
    ($src, $trg, @ids) = (1, 2, 0);
}
my $conf = $ARGV[4];

while(<STDIN>) {
    chomp;
    my @arr = split(/ \|\|\| /);
    if($conf and ($arr[0] < $conf)) {
        exit;
    }
    if($ARGV[3] =~ /^en/) {
        $arr[$trg] =~ s/([,\):;])([a-zA-Z])/$1 $2/g;
        $arr[$trg] =~ s/‐/-/g;
    }
    print FILE0 join(" ||| ", map { $arr[$_] } @ids)."\n";
    print FILE1 "$arr[$src]\n";
    print FILE2 "$arr[$trg]\n";
}
