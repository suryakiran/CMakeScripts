use ExtUtils::ParseXS qw/process_file/;
use ExtUtils::Typemap::STL;
use Getopt::Long;

my ($xsFile, $outFile, $cpp, $typemaps);

GetOptions (
  'xs-file|xs=s' => \$xsFile,
  'output|o=s' => \$outFile,
  'typemap|t=s@' => \$typemaps
);

process_file (
  filename     => $xsFile,
  output       => $outFile,
  'C++'        => 1,
  hiertype     => 1,
  except       => 0,
  prototypes   => 1,
  versioncheck => 1,
  linenumbers  => 1,
  optimize     => 1,
  prototypes   => 1,
  typemap      => $typemaps
);
