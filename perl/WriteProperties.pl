#!/usr/bin/env perl

use warnings;
use strict;
use feature qw/switch/;
use Getopt::Long;

my ($outputFile, $properties);

my $result = GetOptions (
  'Output=s' => \$outputFile,
  'Property=s%' => \$properties
);

open (FILE,  ">$outputFile");

foreach (keys %$properties) {
  printf FILE "Set_Property (DIRECTORY PROPERTY %s %s)\n" ,
              $_, join(' ', split(/,/, $properties->{$_}));
}

close FILE;
