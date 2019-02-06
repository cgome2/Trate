#!/usr/bin/perl -w
##########################################################################
# Name: 
# Description: 
# Author: 
# Adapted by: 
# Date : 
# Version: 
##########################################################################
use Trate::Lib::Factura;
use Try::Catch;
use Trate::Lib::Constants qw(LOGGER INFORMIX_SERVER);
use strict;

$ENV{INFORMIXSERVER} = INFORMIX_SERVER; 

LOGGER->info(`echo \$INFORMIXSERVER`);

my $return = 0;
# (1) salir a menos que envien los 3 argumentos
my $num_args = $#ARGV + 1;
if ($num_args != 3) {
	LOGGER->fatal("Uso: valida_factura_trate.pl fecha factura serie");
	print("Uso: valida_factura_trate.pl fecha factura serie\n");
    exit $return;
}

my ($invoiceid, $invoicedate, $serie) = @ARGV;

my $factura = Trate::Lib::Factura->new();
$factura->fecha($invoicedate);
$factura->factura($invoiceid);
$factura->fserie($serie);
LOGGER->info("Executing with $num_args arguments fecha: $invoicedate factura: $invoiceid serie: $serie");
try {
	$return = $factura->existeFactura or die(LOGGER->fatal("IMPOSIBLE VALIDAR LA FACTURA EN MASTER"));
} catch {
	LOGGER->warn("IMPOSIBLE VALIDAR LA FACTURA EN MASTER");
	$return = 0;
} finally {
	LOGGER->info("SE DEVOLVIO EL RESULTADO $return");
	print "$return\n";
	exit $return;
};
