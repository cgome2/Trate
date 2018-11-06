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
use Trate::Lib::Constants qw(LOGGER);
use strict;

# (1) salir a menos que envien los 3 argumentos
my $num_args = $#ARGV + 1;
if ($num_args != 3) {
	LOGGER->fatal("Uso: check_invoice_exists_trate.pl fecha factura serie");
    exit 0;
}

my ($invoiceid, $invoicedate, $serie) = @ARGV;

my $factura = Trate::Lib::Factura->new();
$factura->fecha($invoicedate);
$factura->factura($invoiceid);
$factura->factura($serie);
LOGGER->info("Executing with $num_args arguments fecha: $invoicedate factura: $invoiceid serie: $serie");
my $return = $factura->existeFactura;

exit $return;
