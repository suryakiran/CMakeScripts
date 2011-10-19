#!/usr/bin/env perl

use warnings;
use strict;
use feature qw/switch/;
use Getopt::Long;

my ($caseConvType, $delimiter, $inputs);

my $result = GetOptions (
  'type|t=s' => \$caseConvType,
  'delimiter|d=s' => \$delimiter,
  'input|i=s@' => \$inputs
);

given ($caseConvType) {
  foreach my $str (@$inputs) {
    when("to_lower") {
    }

    when("break_at_upper_case") {
      $str =~ s/([A-Z])/-lc($1)/ge;
      $str =~ s/-(.*)/$1/;
      print $str . "\n";
    }

    when("camel_case") {
      $str =~ tr/A-Z/a-z/;
      $str =~ s/\b([a-z])/\u$1/g;
      $str =~ s/_([a-z])/\u$1/g;
      print $str . "\n";
    }
  }
};
