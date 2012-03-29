use strict;
use warnings;
use File::Spec::Functions;
use File::Basename;
use XML::LibXML;
use Getopt::Long;

BEGIN {
  unshift @INC, dirname(__FILE__);
}

use Pch;

my (
  $xmlFile,
  $conf,
);

GetOptions (
  'xml-input|x=s' => \$xmlFile,
  'conf|c=s' => \$conf,
);

my $parser = XML::LibXML->new();
my $pchIn = $parser->parse_file ($xmlFile);

my @commonFlags = split(/ /, $pchIn->findvalue("//Flags/Common"));
my @debugFlags = split(/ /, $pchIn->findvalue("//Flags/Debug"));
my @releaseFlags = split(/ /, $pchIn->findvalue("//Flags/Release"));

my @flags = @commonFlags;

if ($conf =~ /Debug/) {
  push @flags, @debugFlags;
} elsif ($conf =~ /Release/) {
  push @flags, @releaseFlags;
}

@flags = grep {/\S/} @flags;
my $pch = Pch->new (
  compiler => 'cl',
  flags => [@flags]
);

$pch->create();
