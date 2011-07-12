use Template;
use Getopt::Long;

my (
  $vars, 
  $output,
  $input
);

GetOptions (
  'vars|v=s%' => \$vars,
  'output|o=s' => \$output,
  'input|i=s' => \$input
);

my $tt = Template->new(
  ABSOLUTE => 1,
  EVAL_PERL => 1
);

print $input, "\n";
$tt->process (
  $input,
  $vars,
  $output
) || die $tt->error();
