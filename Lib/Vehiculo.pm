package Trate::Lib::Vehiculo;

#########################################################
#Vehiculo - Clase Vehiculo								#
#                                                       #
#Autor: Ramses                                          #
#Fecha: Octubre, 2018                                   #
#Revision: 1.0                                          #
#                                                       #
#########################################################

use strict;

sub new
{
	my $self = {};
	$self->{FECHA_HORA} = undef;
	$self->{ESTACION} = undef;
	$self->{DISPENSADOR} = undef;
	$self->{ENTREGA_TURNO} = undef;
	$self->{RECIBE_TURNO} = undef;
	$self->{FECHA_HORA_RECEP} = undef;
	$self->{INVENTARIO_RECIBIDO_LTS} = undef;
	$self->{MOVTOS_TURNO_LTS} = undef;
	$self->{INVENTARIO_ENTREGADO_LTS} = undef;
	$self->{DIFERENCIA_LTS} = undef;
	$self->{INVENTARIO_RECIBIDO_CTO} = undef;
	$self->{MOVTOS_TURNO_CTO} = undef;
	$self->{INVENTARIO_ENTREGADO_CTO} = undef;
	$self->{DIFERENCIA_CTO} = undef;
	$self->{AUTORIZO_DIF} = undef;
	$self->{CONTADOR_INICIAL} = undef;
	$self->{FOLIO} = undef;
	$self->{CONTADOR_FINAL} = undef;
	$self->{VSERIE} = undef;
	$self->{PROCESADA} = undef;
	bless($self);
	return $self;	
}

1;
#EOF