#!/usr/bin/env perl

foreach (@ARGV) {
  $_ =~ s/"/'/g;
  printf STDOUT "%s,\n" , $_;
}
