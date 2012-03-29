package Pch;
use base qw 'Class::Accessor::Fast';
use Data::Dumper;

__PACKAGE__->mk_ro_accessors(qw{
    compiler flags defines
});

my %moduleMap = (
  'MSWin32' => 'Win32'
);

my $module = $moduleMap{$^O} || 'Linux';

require ("Pch/${module}.pm");
our @ISA = ("Pch::${module}");

sub new {
  my ($class, %params) = @_;

  my $self = bless {
  }, $class;

  $self->{compiler} = $params{compiler};
  return $self;
}
