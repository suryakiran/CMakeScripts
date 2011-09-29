use strict;
use warnings;
use Getopt::Long;
use Template;
use XML::Simple qw(:strict);
use XML::Parser;
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

foreach (keys %$cmakeVars) {
  my $val = $cmakeVars->{$_};

  if (ref($val) eq 'HASH') {
    if (not scalar keys %$val) {
      delete $cmakeVars->{$_};
    }
  }
}

$cmakeVars->{os} = $^O;

if ($gvimSearchDirs) {
  my %gsd = map {$_ => 1} @$gvimSearchDirs;
  $cmakeVars->{GVIM_SEARCH_DIRS}=[sort (keys %gsd)];
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
