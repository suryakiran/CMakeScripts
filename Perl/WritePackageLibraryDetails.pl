use strict;
use warnings;
use Getopt::Long;

my ($outputFile, $libraryPrefix);

my $result = GetOptions (
  'output|o=s' => \$outputFile,
  'prefix|p=s' => \$libraryPrefix
);

open (FILE, ">$outputFile");

my $debugLibName = sprintf ("%s_DEBUG_LIBRARY", $libraryPrefix);
my $relLibName = sprintf ("%s_OPTIMIZED_LIBRARY", $libraryPrefix);
my $libsName = sprintf("%s_LIBRARIES", $libraryPrefix);

print FILE <<eof;
If($debugLibName AND $relLibName)
  Set ($libsName
    optimized \${$relLibName}
    debug \${$debugLibName}
    CACHE STRING "$libraryPrefix Libraries"
    )
ElseIf($debugLibName)
  Set ($libsName \${$debugLibName}
    CACHE STRING "$libraryPrefix Libraries"
    )
ElseIf($relLibName)
  Set ($libsName \${$relLibName}
    CACHE STRING "$libraryPrefix Libraries"
    )
EndIf($debugLibName AND $relLibName)

Set (${libraryPrefix}_Debug_LIBRARY \${$debugLibName})
Set (${libraryPrefix}_Release_LIBRARY \${$relLibName})

Mark_As_Advanced (
  $debugLibName
  $relLibName
  $libsName
  )
eof

close(FILE);
