#!/usr/bin/env perl

use strict;
use warnings;
use File::Find::Rule;
use File::Spec::Functions;
use Getopt::Long;
use File::Which qw(which where);
use Env;

my ($printRequires, $printVariables);
my ($cflags, $cflagsOnlyI, $cflagsOnlyOther);
my ($libs, $libsOnlyL, $libsOnlyOther);
my ($modVersion);

my $results = GetOptions (
  'modversion'        => \$modVersion,
  'cflags'            => \$cflags,
  'cflags-only-I'     => \$cflagsOnlyI,
  'cflags-only-other' => \$cflagsOnlyOther,
  'libs'              => \$libs,
  'libs-only-L'       => \$libsOnlyL,
  'libs-only-other'   => \$libsOnlyOther,
  'print-requires'    => \$printRequires,
  'print-variables'   => \$printVariables,
);

my @pkgConfigPath = split(':', $ENV{'PKG_CONFIG_PATH'});

my $dpkg_a = which ('dpkg-architecture');

if (defined $dpkg_a) {
  my $multi_arch = `$dpkg_a -qDEB_HOST_MULTIARCH`; 
  if (not "/usr/lib/$multi_arch/pkgconfig" ~~ @pkgConfigPath) {
    push @pkgConfigPath, '/usr/lib/pkgconfig';
  }
}

if (not '/usr/local/lib/pkgconfig' ~~ @pkgConfigPath) {
  push @pkgConfigPath, '/usr/local/lib/pkgconfig';
}

if (not '/usr/lib/pkgconfig' ~~ @pkgConfigPath) {
  push @pkgConfigPath, '/usr/lib/pkgconfig';
}

foreach my $module (@ARGV) {
  my $pcFile;
  FILE_LOOP : {
    foreach my $pkgDir (@pkgConfigPath) {
      $pcFile = catfile ($pkgDir, $module . '.pc');
      last FILE_LOOP if -e $pcFile;
    }
  }

  print $pcFile . "\n";
}
