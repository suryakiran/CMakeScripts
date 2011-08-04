use warnings;
use strict;
use Getopt::Long;

my (
  $modules,
  $output,
  $bootName
);

GetOptions (
  'modules|m=s@' => \$modules,
  'output|o=s' => \$output
);

my $mod;
foreach (@$modules) {
  ($mod = $_) =~ s,:,_,g;
  $bootName->{$_} = "boot_" . $mod;
}

open OUTPUT, ">$output";

printf OUTPUT <<eof;
#include <EXTERN.h>
#include <perl.h>

#include <DllPerlXsi.hxx>

eof

foreach (@$modules) {
  printf OUTPUT <<eof;
EXTERN_C void $bootName->{$_} (pTHX_ CV* cv);
eof
}

printf OUTPUT <<eof;

#ifdef __cplusplus
extern "C" 
{
#endif
void DLLPerlXsi xs_init (pTHX)
{
  char *file = __FILE__;
	dXSUB_SYS;

eof

#newXS("Encode::bootstrap", boot_Encode, file);
foreach (@$modules) {
  printf OUTPUT "\tnewXS(\"%s::bootstrap\", %s, file);\n", $_, $bootName->{$_};
}

printf OUTPUT <<eof;
}
#ifdef __cplusplus
}
#endif
eof
close (OUTPUT)
