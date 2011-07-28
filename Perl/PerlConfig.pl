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

my $archDir = $Config{installarchlib};
my $siteArchDir = $Config{installsitearch};
my $prefix = $Config{installprefix};

$archDirSuffix = substr($archDir, length($prefix));
$archDirSuffix =~ s,\\,/,g;
$archDir =~ s,\\,/,g;
$siteArchDir =~ s,\\,/,g;

if (-e catfile ($Config{installarchlib}, 'CORE', 'perl.h')) {
  my $dir = catfile($Config{installarchlib}, 'CORE');
  $dir =~ s,\\,/,g;
  printf FILE <<eof;
Set (
  PERL_INCLUDE_PATH $dir
  CACHE FILEPATH "Perl Include Path"
  )

eof
}

if (-e catfile ($Config{installarchlib}, 'CORE', $Config{libperl})) {
  my $file = catfile($Config{installarchlib}, 'CORE', $Config{libperl});
  $file =~ s,\\,/,g;
  printf FILE <<eof;
Set (
  PERL_LIBRARY $file
  CACHE FILEPATH "Perl Libraries"
  )

eof
}

printf FILE <<eof;
Set (
  PERL_ARCH_DIR_SUFFIX $archDirSuffix 
  CACHE STRING "Perl Arch Lib Directory Suffix"
  )

Set (
  PERL_ARCH_DIR $archDir 
  CACHE STRING "Perl Arch Lib Directory"
  )

Set (
  PERL_SITE_ARCH_DIR $siteArchDir 
  CACHE STRING "Perl Site Arch Lib Directory"
  )

Mark_As_Advanced (
  PERL_INCLUDE_PATH
  PERL_LIBRARY 
  PERL_ARCH_DIR
  PERL_SITE_ARCH_DIR
  PERL_ARCH_DIR_SUFFIX
)
eof

close (FILE);
