#!/usr/bin/env perl

use warnings;
use strict;
use Switch 'Perl6';
use Getopt::Long;

my ($caseConvType, $delimiter);

my $result = GetOptions (
  'type=s' => \$caseConvType,
  'delimiter=s' => \$delimiter,
);

given ($caseConvType) {
  foreach my $str (@ARGV) {
    when("to_lower") {
    }

    when("break_at_upper_case") {
      $str =~ s/([A-Z])/-lc($1)/ge;
      $str =~ s/-(.*)/$1/;
      print $str . "\n";
    }
  }
};
