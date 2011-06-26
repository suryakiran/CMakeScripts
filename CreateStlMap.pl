use ExtUtils::Typemap::STL;
use Getopt::Long;

my $outputFile;

GetOptions (
  'output|o=s' => \$outputFile
);

my $stlMap = ExtUtils::Typemap::STL->new;
$stlMap->write(file => $outputFile);
