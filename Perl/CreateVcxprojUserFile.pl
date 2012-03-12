use strict;
use warnings;
use Getopt::Long;
use XML::LibXML;
use File::Spec::Functions;

my (
  $outputFile,
  $workingDirectory,
  $args,
  $xmlFile,
  $exeFile,
  @libPaths,
  @envVar,
);

my $status = GetOptions (
  'output|o=s' => \$outputFile,
  'working-directory|w=s' => \$workingDirectory,
  'args|a=s@' => \$args,
  'xml-file|x=s' => \$xmlFile,
  'exe-file|e=s' => \$exeFile,
  'lib-paths|l=s{,}' => \@libPaths,
  'env-var|v=s{,}' => \@envVar
);

$workingDirectory = $workingDirectory || "\$(ProjectDir)";
$args = $args || [];

my $parser = XML::LibXML->new();
my $cmakeDoc = $parser->parse_file ($xmlFile);
my $boost_lib_dir = canonpath($cmakeDoc->findvalue("//BOOST_LIBRARY_DIR"));
my $qt_bin_dir = canonpath($cmakeDoc->findvalue("//QT_BIN_DIR"));

my $doc = XML::LibXML->createDocument("1.0", "utf-8");

my $root = $doc->createElementNS (
  "http://schemas.microsoft.com/developer/msbuild/2003",
  "Project"
);
my $attr = $doc->createAttribute ("ToolsVersion", "4.0");
$root->setAttributeNode ($attr);
$doc->setDocumentElement($root);

sub _TextNode {
  my ($parent, $name, $value) = @_;
  my $node = $doc->createElement ($name);
  my $text = $doc->createTextNode ($value);
  $node->appendChild ($text);
  $parent->appendChild ($node);
}

sub _CreatePropertyGroupNode {
  my ($conf, $plat) = @_;
  my $conf_u = uc($conf);
  my $path = catfile (
    canonpath($cmakeDoc->findvalue("//CMAKE_RUNTIME_OUTPUT_DIRECTORY_$conf_u")), 
    $exeFile
  );
  my $node = $doc->createElement ("PropertyGroup");
  my $attNode = $doc->createAttribute ( 
    "Condition", 
    "'\$(Configuration)|\$(Platform)' == '$conf|$plat'"
  );
  $node->setAttributeNode ($attNode);
  $root->appendChild ($node);

  foreach (@libPaths) {
    $_ = canonpath($_);
  }

  my @path;
  unshift @path, "%PATH%";
  unshift @path, "$boost_lib_dir";
  unshift @path, "$qt_bin_dir";
  unshift @path, @libPaths;

  _TextNode ($node, "LocalDebuggerSQLDebugging", "false");
  _TextNode ($node, "DebuggerFlavor", "WindowsLocalDebugger");
  _TextNode ($node, "LocalDebuggerAttach", "false");
  _TextNode ($node, "LocalDebuggerCommand", $path);
  _TextNode ($node, "LocalDebuggerCommandArguments", join(' ', @$args));
  _TextNode ($node, "LocalDebuggerWorkingDirectory", $workingDirectory);
  _TextNode ($node, "LocalDebuggerEnvironment", "PATH=".join(';', @path));

  return $node;
}

{
  my $debugNode = _CreatePropertyGroupNode ("Debug", "Win32");
}

{
  my $relNode = _CreatePropertyGroupNode ("Release", "Win32");
}

{
  my $minSizeRelNode = _CreatePropertyGroupNode ("MinSizeRel", "Win32");
}

{
  my $relWithDebInfo = _CreatePropertyGroupNode ("RelWithDebInfo", "Win32");
}

$doc->toFile ($outputFile, 2);
