#!perl -w

use Trate::Lib::Mean;
use Data::Dump qw(dump);

my $mean = Trate::Lib::Mean->new();
$mean->{NAME}=8274;
print dump($mean->activarMean());
