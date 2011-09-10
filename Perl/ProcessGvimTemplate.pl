use strict;
use warnings;
use Getopt::Long;
use Template;
use XML::Simple qw(:strict);
use Data::Dumper;

my (
  $tmplFile,
  $outFile,
  $cmakeVarsFile, 
  $cmakeVars, 
  $gvimSearchDirs,
  $projectModules
);

GetOptions (
  'template|t=s' => \$tmplFile,
  'output|o=s' => \$outFile,
  'cmake-vars|x=s' => \$cmakeVarsFile,
  'dirs|d=s@' => \$gvimSearchDirs,
  'project-modules|p=s@' => \$projectModules
);

$cmakeVars = XMLin(
  $cmakeVarsFile,
  ForceArray => 0,
  KeyAttr => []
);

$cmakeVars->{os} = $^O;

if ($gvimSearchDirs) {
  $cmakeVars->{GVIM_SEARCH_DIRS}=$gvimSearchDirs;
}

if ($projectModules) {
  $cmakeVars->{PROJECT_MODULES}=$projectModules;
}

my $template = Template->new(
  INTERPOLATE => 1,
  ABSOLUTE => 1,
  EVAL_PERL => 1
);

$template->process ($tmplFile, $cmakeVars, $outFile);
