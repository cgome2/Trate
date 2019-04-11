#!/usr/bin/perl
use strict;
use warnings;

use Trate::Lib::Mean;
use Trate::Lib::Constants qw(LOGGER);
use Try::Catch;

my $num_args = $#ARGV + 1;

LOGGER->debug("Ejecutando con [ " . $num_args . " ] argumentos, meanName:[ " . $ARGV[0] . " ] status:[ " . $ARGV[1] . "]");
if ($num_args != 2) {
    LOGGER->error("Uso: actualiza_status_mean_orcu.pl meanName status(1: inactivar, 2: activar)");
    print("Uso: actualiza_status_mean_orcu.pl meanName status(1: inactivar, 2: activar)\n");
    exit 0;
}

my ($meanName,$status) = @ARGV;
my $exit = 0;
my $mean = Trate::Lib::Mean->new();
$mean->name($meanName);
try{
	my $resultado = ($status == 1 ? $mean->desactivarMean() : $mean->activarMean());	
	LOGGER->debug($resultado->{rc_desc});
	$exit = ($resultado->{rc} eq 0 ? 1 : 0);
} catch {
	$exit = 0;
} finally {
	$exit = $exit;
};
LOGGER->debug("El resultado del exec para el camion o tag [" . $meanName . "] es: $exit");
print $exit;
