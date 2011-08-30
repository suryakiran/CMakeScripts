use Template;

my $tt = Template->new(
  ABSOLUTE => 1
);

$tt->process ("E:/Projects/SourceArea/CodeSamples/CMake/Configure/Vcproj.user.in") ||
#$tt->process ("E:/Projects/SourceArea/CodeSamples/CMake/Configure/test.tt") ||
die $tt->error();
