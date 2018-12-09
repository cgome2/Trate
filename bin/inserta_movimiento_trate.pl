#!/usr/bin/perl
##########################################################################
# Name: 
# Description: 
# Author: 
# Adapted by: 
# Date : 
# Version: 
##########################################################################
use Trate::Lib::Movimiento;
use Try::Catch;
use Trate::Lib::Constants qw(LOGGER);
use strict;

$ENV{INFORMIXSERVER} = 'prueba';


# (1) salir a menos que envien los 21 argumentos
my $num_args = $#ARGV + 1;
my $return = 0;

if ($num_args != 22) {
	LOGGER->fatal("Uso: movimiento_from_transporter_to_trate.pl fecha_hora estacion dispensador supervisor despachador viaje camion chofer sello tipo_referencia serie referencia movimiento litros_esp litros_real costo_esp costo_real iva ieps status procesada transaction_id");
    exit $return;
}
my ($fecha_hora,$estacion,$dispensador,$supervisor,$despachador,$viaje,$camion,$sello,$chofer,$tipo_referencia,$serie,$referencia,$movimiento,$litros_esp,$litros_real,$costo_esp,$costo_real,$iva,$ieps,$status,$procesada,$transaction_id) = @ARGV;
my $MOVIMIENTO = Trate::Lib::Movimiento->new();
$MOVIMIENTO->fechaHora($fecha_hora);
$MOVIMIENTO->estacion($estacion);
$MOVIMIENTO->dispensador($dispensador);
$MOVIMIENTO->supervisor($supervisor);
$MOVIMIENTO->despachador($despachador);
$MOVIMIENTO->viaje($viaje);
$MOVIMIENTO->camion($camion);
$MOVIMIENTO->sello($sello);
$MOVIMIENTO->chofer($chofer);
$MOVIMIENTO->tipoReferencia($tipo_referencia);
$MOVIMIENTO->serie($serie);
$MOVIMIENTO->referencia($referencia);
$MOVIMIENTO->movimiento($movimiento);
$MOVIMIENTO->litrosEsp($litros_esp);
$MOVIMIENTO->litrosReal($litros_real);
$MOVIMIENTO->costoEsp($costo_esp);
$MOVIMIENTO->costoReal($costo_real);
$MOVIMIENTO->iva($iva);
$MOVIMIENTO->ieps($ieps);
$MOVIMIENTO->status($status);
$MOVIMIENTO->procesada($procesada);
$MOVIMIENTO->transactionId($transaction_id);

try { 
	$return = $MOVIMIENTO->enviarMovimientoInformix() or die(LOGGER->fatal("ERROR AL ENVIAR MOVIMIENTO A INFORMIX"));
} catch {
	$return = 0;
} finally {
	print $return;
};