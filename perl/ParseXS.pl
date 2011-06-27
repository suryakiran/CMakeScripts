use ExtUtils::ParseXS qw/process_file/;
use ExtUtils::Typemap::STL;
use Getopt::Long;
use File::Spec::Functions qw/rel2abs catfile/;
use File::Basename;
use File::Find::Rule;

my (
  $xsFile,
  $outFile,
  $typemaps,
  $srcDir,
  $binDir
);

GetOptions (
  'source-dir=s' => \$srcDir,
  'binary-dir=s' => \$binDir,
  'xs-file|xs=s' => \$xsFile,
  'output|o=s' => \$outFile,
);

my $cpp_typemap = rel2abs(catfile(dirname(__FILE__), 'cppobject.map'));
my $stl_typemap = rel2abs(catfile($binDir, 'stl.typemap'));

my @other_typemaps = File::Find::Rule->file()->name('*.typemap')->in($srcDir);

foreach (@other_typemaps) {
  push @$typemaps, rel2abs($_);
}

push @$typemaps, $cpp_typemap if -e $cpp_typemap;
push @$typemaps, $stl_typemap if -e $stl_typemap;

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
