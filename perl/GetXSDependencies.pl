#!/usr/bin/env perl

use strict;
use warnings;
use Getopt::Long;
use File::Spec::Functions qw/rel2abs/;

my (
  $input,
  $sourceDir,
);

GetOptions (
  'file|f=s' => \$input,
  'source-dir|s=s' => \$sourceDir,
);

open FH, "< $input";
my @lines = <FH>;
close FH;

my @dependencies;

foreach (@lines) {
  chomp;
  if (/^INCLUDE_COMMAND/) {
    tr/ / /s;
    my @items = split(/ /);
    push @dependencies, rel2abs($items[$#items], $sourceDir);
  }
}

print join(';', @dependencies);
