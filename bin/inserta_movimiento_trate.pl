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
use Data::Dump qw(dump);
use Trate::Lib::Constants qw(LOGGER WITHINFORMIX INFORMIX_SERVER);
use strict;

$ENV{INFORMIXSERVER} = INFORMIX_SERVER;


LOGGER->debug("Servidor de informix" . INFORMIX_SERVER);


# (1) salir a menos que envien los 21 argumentos
my $num_args = $#ARGV + 1;
my $return = 0;

if ($num_args != 22) {
	LOGGER->fatal("Uso: movimiento_from_transporter_to_trate.pl fecha_hora estacion dispensador supervisor despachador viaje camion chofer sello tipo_referencia serie referencia movimiento litros_esp litros_real costo_esp costo_real iva ieps status procesada transaction_id");
    exit $return;
}
my ($fecha_hora,$estacion,$dispensador,$supervisor,$despachador,$viaje,$camion,$sello,$chofer,$tipo_referencia,$serie,$referencia,$movimiento,$litros_esp,$litros_real,$costo_esp,$costo_real,$iva,$ieps,$status,$procesada,$transaction_id) = @ARGV;
my $MOVIMIENTO = Trate::Lib::Movimiento->new();
$MOVIMIENTO->{FECHA_HORA} = $fecha_hora;
$MOVIMIENTO->{ESTACION} = $estacion;
$MOVIMIENTO->{DISPENSADOR}= (length($dispensador) gt 0 ? $dispensador : "");
$MOVIMIENTO->{SUPERVISOR} = $supervisor;
$MOVIMIENTO->{DESPACHADOR} = $despachador;
$MOVIMIENTO->{VIAJE} =(length($viaje) gt 0 ? $viaje : "");
$MOVIMIENTO->{CAMION} = (length($camion) gt 0 ? $camion : "");
$MOVIMIENTO->{SELLO} = (length($sello) gt 0 ? $sello : "");
$MOVIMIENTO->{CHOFER} = (length($chofer) gt 0 ? $chofer : "");
$MOVIMIENTO->{TIPO_REFERENCIA} = (length($tipo_referencia) gt 0 ? $tipo_referencia : "");
$MOVIMIENTO->{SERIE} = (length($serie) gt 0 ? $serie : "");
$MOVIMIENTO->{REFERENCIA} = (length($referencia) gt 0 ? $referencia : "");
$MOVIMIENTO->{MOVIMIENTO} = $movimiento;
$MOVIMIENTO->{LITROS_ESP} = (length($litros_esp) gt 0 ? $litros_esp : "");
$MOVIMIENTO->{LITROS_REAL} = $litros_real;
$MOVIMIENTO->{COSTO_ESP} = $costo_esp;
$MOVIMIENTO->{COSTO_REAL} = $costo_real;
$MOVIMIENTO->{IVA} = $iva;
$MOVIMIENTO->{IEPS} = $ieps;
$MOVIMIENTO->{STATUS} = $status;
$MOVIMIENTO->{PROCESADA} = $procesada;
$MOVIMIENTO->{TRANSACTION_ID} = (length($transaction_id) gt 0 ? $transaction_id : "");
LOGGER->debug("El movimiento para informix seria \n" . dump($MOVIMIENTO));
try { 
	if(WITHINFORMIX eq 1){
		$return = $MOVIMIENTO->enviarMovimientoInformix() or die(LOGGER->fatal("ERROR AL ENVIAR MOVIMIENTO A INFORMIX"));
	} else {
		$return = 1;
	}
} catch {
	$return = 0;
} finally {
	print $return;
};
