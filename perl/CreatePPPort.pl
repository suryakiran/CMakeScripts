use Devel::PPPort;
use Getopt::Long;

my $outputFile;

GetOptions (
  'output|o=s' => \$outputFile
);

Devel::PPPort::WriteFile("$outputFile") unless -e $outputFile;
