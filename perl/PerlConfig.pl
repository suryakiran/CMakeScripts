#!/usr/bin/env perl

use Config;
use File::Spec::Functions;
use File::Basename;
use Getopt::Long;

my $outputFile;

GetOptions (
  'output|o=s' => \$outputFile
);

open (FILE, ">$outputFile");

if (-e catfile ($Config{installarchlib}, 'CORE', 'perl.h')) {
  printf FILE "Set (PERL_INCLUDE_PATH %s CACHE PATH \"Perl Include Path\")\n", 
    catfile($Config{installarchlib}, 'CORE');
}

if (-e catfile ($Config{installarchlib}, 'CORE', $Config{libperl})) {
  printf FILE "Set (PERL_LIBRARY %s CACHE FILEPATH \"Perl Libraries\")\n", 
    catfile($Config{installarchlib}, 'CORE', $Config{libperl});
}

printf FILE "Mark_As_Advanced (PERL_INCLUDE_PATH PERL_LIBRARY)\n";

close (FILE);
