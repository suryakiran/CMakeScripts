use File::Spec::Functions;
use File::Basename;
use Getopt::Long;
use Sys::Hostname;

my $outputFile;

GetOptions (
  'output|o=s' => \$outputFile
);

my $hostName = hostname;
my $userName;

if ($^O =~ /Win32$/) {
  $userName = getlogin();
} else {
  $userName = getpwuid ($<);
}

open (FILE, ">$outputFile");

print FILE <<eof;
Set (
  SYS_INFO_HOST_NAME $hostName
  CACHE STRING "Host Name"
  )

Set (
  SYS_INFO_USER_NAME "$userName"
  CACHE STRING "User Name"
  )
eof

print FILE <<eof;
Mark_As_Advanced (
  SYS_INFO_HOST_NAME
  SYS_INFO_USER_NAME
  )
eof

close (FILE);
