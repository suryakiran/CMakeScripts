 use Config;
 use File::Spec::Functions;
 use File::Basename;
 use Getopt::Long;

 use constant false => 0;
 use constant true => 1;

 my ($modules, $siteSearch, $outFile);

 GetOptions (
   'module|m=s@' => \$modules,
   'outfile|o=s' => \$outFile
 );

 my $archDir = $Config{installarchlib};
 my $sitePerl = $Config{installsitearch};
 my $dlExt = $Config{dlext};
 my $cmakeName;
 my @cmakeVars;

 sub findModuleInDir {
   my ($module, $dir) = @_;
   my @modArray = split(/::/, $module);
   ($cmakeName = $module) =~ s,::,_,g;
   $cmakeName =~ tr/a-z/A-Z/;
   $cmakeName = "PERL_C_MODULE_" . $cmakeName;
   my $libName = catfile ($dir, 'auto');
   foreach my $item (@modArray) {
     $libName = catfile ($libName, $item);
   }

   $libName = catfile (
     $libName, 
     sprintf("%s.%s", $modArray[$#modArray], $dlExt
     ));

   $libName =~ s,\\,/,g;

   if (-e $libName) {
     printf FH <<eof;
Set(
  $cmakeName
  "$libName"
  CACHE FILEPATH
  "Perl $cmakeName C Module"
  )

eof

     push @cmakeVars, $cmakeName;
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
 }

 if (@cmakeVars)
 {
   printf FH "Mark_As_Advanced (\n";
   foreach (@cmakeVars) {
     printf FH <<eof;
  $_
eof
   }
   printf FH ")\n";
 }

 close (FH);
