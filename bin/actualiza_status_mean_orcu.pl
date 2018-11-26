#!/usr/bin/perl -w
use strict;

use Trate::Lib::Mean;
use Trate::Lib::Constants qw(LOGGER);

my $num_args = $#ARGV + 1;

LOGGER->info("Ejecutando con [ " . $num_args . " ] argumentos, meanName:[ " . $ARGV[0] . " ] status:[ " . $ARGV[1] . "]");
if ($num_args != 2) {
    LOGGER->error("Uso: actualiza_status_mean_orcu.pl meanName status(1: inactivar, 2: activar)");
    print("Uso: actualiza_status_mean_orcu.pl meanName status(1: inactivar, 2: activar)\n");
    exit 0;
}

my ($meanName,$status) = @ARGV;

my $mean = Trate::Lib::Mean->new();
$mean->name($meanName);
my $resultado = ($status == 1 ? $mean->desactivarMean() : $mean->activarMean());
print $resultado->{rc_desc} . "\n";
($resultado->{rc} == 0 ? exit 1 : exit 0);