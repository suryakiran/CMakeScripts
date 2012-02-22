use strict;
use warnings;
use Getopt::Long;
use File::Spec::Functions;
use Template;
use Data::Dumper;

my (
  $tmplFile,
  $outFile,
  $vars, 
);

GetOptions (
  'template|t=s' => \$tmplFile,
  'output|o=s' => \$outFile,
  'var|v=s%' => \$vars,
);

$vars->{os} = $^O;

my $template = Template->new(
  INTERPOLATE => 1,
  ABSOLUTE => 1,
  EVAL_PERL => 1
);

$template->process ($tmplFile, $vars, $outFile);
