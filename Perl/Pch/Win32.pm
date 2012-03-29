package Pch::Win32;
use strict ;
use warnings;
use Win32::Process;
use Data::Dumper;
use Win32::SearchPath;
use File::Which;
use Env qw/@PATH/;

sub _ErrorReport {
  print Win32::FormatMessage (Win32::GetLastError());
}

sub create {
  my ($self) = @_;
  my $args = "/?";
  my $processObj;
  print join("\n", @PATH), "\n";
  Win32::Process::Create (
    $processObj,
    $self->{compiler},
    $args, 0,
    NORMAL_PRIORITY_CLASS, "."
  ) || die _ErrorReport();
  $processObj->Resume();
}

1;
