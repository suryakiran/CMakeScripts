use strict;
use warnings;
use Getopt::Long;
use File::Spec::Functions;
use File::Path qw/make_path/;
use File::Basename;

my (
  $outputFile,
  $namespaces,
  $functions,
  $classes
);

GetOptions (
  'output-file|o=s' => \$outputFile,
  'namespace|n=s@' => \$namespaces,
  'function|f=s@' => \$functions,
  'class|c=s@' => \$classes
);

my $d = dirname($outputFile);
make_path ($d) unless -d $d ;
die ("Cannot create directory $d\n") unless -d $d;

open (FILE, ">$outputFile");

if ($namespaces) {
  foreach (@$namespaces) {
    printf FILE "syn keyword cppNamespace %s\n", $_;
  }
}

if ($classes) {
  foreach (@$classes) {
    printf FILE "\nsyn keyword boostClasses %s", $_;
  }
}

if ($functions) {
  foreach (@$functions) {
    printf FILE "\nsyn keyword boostFunctions %s", $_;
  }
}

close(FILE);
