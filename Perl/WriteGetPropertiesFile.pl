#!/usr/bin/env perl

use strict;
use warnings;
use feature qw/switch/;
use Getopt::Long;

my ($outputFile, $props); 

my $result = GetOptions (
  'Output=s' => \$outputFile,
  'Properties=s' => \$props
);

open (FILE, ">$outputFile");

foreach (split(/,/, $props)) {
  printf FILE "Get_Property (%s DIRECTORY PROPERTY %s)\n", $_, $_;
}

close(FILE);
