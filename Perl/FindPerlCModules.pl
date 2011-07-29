use Config;
use File::Spec::Functions;
use File::Basename;
use Getopt::Long;
use ExtUtils::Mksymlists;

use constant false => 0;
use constant true => 1;

my ($modules, $siteSearch, $outFile);

GetOptions (
  'module|m=s@' => \$modules,
  'outfile|o=s' => \$outFile
 );

my $archDir = $Config{installarchlib};
my $sitePerl = $Config{installsitearch};

my $libExt;

if ($^O =~ /^MSWin32$/) {
  $libExt = 'lib';
} else {
  $libExt = $Config{dlext};
}

my $libNames;

sub findModuleInDir {
  my ($module, $dir) = @_;
  my @modArray = split(/::/, $module);
  my $cmakeName;
  ($cmakeName = $module) =~ s,::,_,g;
  $cmakeName =~ tr/a-z/A-Z/;
  $cmakeName = "PERL_C_MODULE_" . $cmakeName;
  my $libName = catfile ($dir, 'auto');
  foreach my $item (@modArray) {
    $libName = catfile ($libName, $item);
  }

  $libName = catfile (
    $libName, 
    sprintf("%s.%s", $modArray[$#modArray], $libExt
    ));

  $libName =~ s,\\,/,g;

  if (-e $libName) {
    $libNames->{$module}->{CmakeCacheName} = $cmakeName;
    $libNames->{$module}->{CmakeLibName} = sprintf("PerlCModule%s", join('', @modArray));
    printf FH <<eof;
Set(
  $cmakeName
  "$libName"
  CACHE FILEPATH
  "Perl $module C Module"
  )

eof
    return true;
  }

  return false;
}

if ($modules) {

  open FH, ">$outFile";

  foreach (@$modules) {
    if (!findModuleInDir($_, $archDir)) {
      findModuleInDir($_, $sitePerl);
    }
  }

#Set_Property (TARGET PerlCModuleIO PROPERTY IMPORTED_LOCATION ${PERL_C_MODULE_IO})

  printf FH "Mark_As_Advanced (\n";
  foreach (@$modules) {
    printf FH <<eof;
$libNames->{$_}->{CmakeCacheName}
eof
  }
  printf FH ")\n\n";

  foreach (@$modules) {
    printf FH <<eof;
Add_Library (
  $libNames->{$_}->{CmakeLibName}
  SHARED IMPORTED
  )

Set_Property (
  TARGET $libNames->{$_}->{CmakeLibName}
  PROPERTY IMPORTED_LOCATION \${$libNames->{$_}->{CmakeCacheName}}
  )

eof
  }
}

close (FH);
