use strict;
use warnings;
use Getopt::Long;
use File::Basename;
use File::Find::Rule;
use File::Spec;
use diagnostics;

my $file;
my (
  $moduleDir,
  $outputFile,
  $destDirDebug,
  $destDirRelease
);

GetOptions (
  'module-dir|m=s' => \$moduleDir,
  'dest-dir-debug=s' => \$destDirDebug,
  'dest-dir-release=s' => \$destDirRelease,
  'output|o=s' => \$outputFile
);

my @modules = File::Find::Rule->file()->name ('*.pm')->in($moduleDir);

open(FILE, ">$outputFile");

foreach my $module (@modules) {
  my $absModule = File::Spec->rel2abs($module);
  my @arr = split(/-/, basename($module));
  my $fileName = $arr[$#arr];

  my $relPath = $destDirRelease;
  foreach (@arr) {
    $relPath = File::Spec->catfile ($relPath, $_);
  }

  my $debugPath = $destDirDebug;
  foreach (@arr) {
    $debugPath = File::Spec->catfile ($debugPath, $_);
  }

  printf FILE <<eof;
Get_Filename_Component (
  file 
  $absModule 
  ABSOLUTE
  )

Get_Filename_Component (
  destDebug
  $debugPath
  PATH
  )

Get_Filename_Component (
  destRel 
  $relPath 
  PATH
  )

Install (
  FILES  \${file}
  DESTINATION \${destDebug}
  CONFIGURATIONS Debug
  COMPONENT install-perl
  RENAME $fileName
  )
Install (
  FILES  \${file}
  DESTINATION \${destRel}
  CONFIGURATIONS Release
  COMPONENT install-perl
  RENAME $fileName
  )
eof
}

close (FILE);
