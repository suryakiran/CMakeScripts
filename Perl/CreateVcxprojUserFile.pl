use strict;
use warnings;
use Getopt::Long;
use XML::LibXML;
use File::Spec::Functions;
use File::Basename;
use Data::Dumper;

my (
  $outputFile,
  $workingDirectory,
  $args,
  $kwargs,
  $xmlFile,
  $exeFile,
  $envVars,
  $confDirs,
  $pathEnv,
);

sub handleEnvVars {
  my ($option, $arg) = @_;
  my $conf = 'all';

  if ($arg =~ /^(Debug|Release|MinSizeRel|RelWithDebInfo):?(.*)/) {
    $conf = $1;
    $arg = $2 || undef;
  }

  if (not $arg) {
    return;
  }

  my ($key, $value) = split(/=/, $arg, 2);
  if ($key && $value) {
    push (@{$envVars->{$conf}->{$key}}, $value);
  }
}

sub handleArgs {
  my ($option, $arg) = @_;
  my $conf = 'all';
  my $data = $arg;
  if ($arg =~ /^(Debug|Release|MinSizeRel|RelWithDebInfo):?(.*)/) {
    $conf = $1;
    $data = $2 || undef;
  }

  if (not $data) {
    return;
  }

  my ($key, $value) = split(/=/, $data, 2);
  if ($key && $value) {
    $kwargs->{$conf}->{$key} = $value;
  } else {
    push (@{$args->{$conf}}, $key);
  }
}

sub handleLibDirs {
  my ($option, $value) = @_;
  my $conf = 'all';
  if ($value =~ /^(Debug|Release|MinSizeRel|RelWithDebInfo):(.*)/) {
    $conf = $1;
    $value = $2;
  }
  push (@{$pathEnv->{$conf}}, $value);
} 

my $status = 
GetOptions (
  'output|o=s' => \$outputFile,
  'working-directory|w=s' => \$workingDirectory,
  'xml-file|x=s' => \$xmlFile,
  'exe-file|e=s' => \$exeFile,
  'dir=s@' => sub {
    my ($option, $value) = @_;
    if ($value =~ /^(Debug|Release|MinSizeRel|RelWithDebInfo):(.*)/) {
      $confDirs->{$1} = $2;
    } else {
      $confDirs->{all} = $2;
    }
  },
  'args|a=s@' => \&handleArgs,
  'lib-dir=s@' => \&handleLibDirs,
  'env-var|v=s@' => \&handleEnvVars,
);

$workingDirectory = $workingDirectory || "\$(ProjectDir)";
$args = $args || {};

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

  my $exePath;

  if (exists $confDirs->{$conf}) {
    $exePath = catfile ($confDirs->{$conf}, basename ($exeFile));
  } else {
    $exePath = catfile (
      canonpath($cmakeDoc->findvalue("//CMAKE_RUNTIME_OUTPUT_DIRECTORY_$conf_u")), 
      $exeFile
    );
  }

  my $node = $doc->createElement ("PropertyGroup");
  my $attNode = $doc->createAttribute ( 
    "Condition", 
    "'\$(Configuration)|\$(Platform)' == '$conf|$plat'"
  );
  $node->setAttributeNode ($attNode);
  $root->appendChild ($node);

  foreach (@{$pathEnv->{$conf}}) {
    $_ = canonpath($_);
  }

  foreach (@{$pathEnv->{all}}) {
    $_ = canonpath($_);
  }

  my @envVarsToWrite;

  my @path;
  unshift @path, "%PATH%";
  unshift @path, "$boost_lib_dir";
  unshift @path, "$qt_bin_dir";
  unshift @path, @{$pathEnv->{$conf}};
  unshift @path, @{$pathEnv->{all}};

  push @envVarsToWrite, ("PATH=" . join(';', @path));

  my @argArray;
  
  foreach my $c ($conf, 'all') {
    foreach (keys %{$kwargs->{$c}}) {
      push @argArray, sprintf("--%s=\"%s\"", $_,canonpath($kwargs->{$c}->{$_}));
    }
  }

  my @evars;
  foreach my $c ($conf, 'all') {
    foreach (keys %{$envVars->{$c}}) {
      my @val = @{$envVars->{$c}->{$_}};
      @val = map {canonpath($_)} @val;
      push @envVarsToWrite, ("$_=" . join(';', @val, ("%" . $_ . "%")));
    }
  }

  _TextNode ($node, "LocalDebuggerSQLDebugging", "false");
  _TextNode ($node, "DebuggerFlavor", "WindowsLocalDebugger");
  _TextNode ($node, "LocalDebuggerAttach", "false");
  _TextNode ($node, "LocalDebuggerCommand", $exePath);
  _TextNode ($node, "LocalDebuggerCommandArguments", join(' ', @argArray));
  _TextNode ($node, "LocalDebuggerWorkingDirectory", $workingDirectory);
  _TextNode ($node, "LocalDebuggerEnvironment", join("\n", @envVarsToWrite));

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

$doc->toFile ($outputFile, 1);
