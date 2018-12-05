package Trate::Lib::RecepcionCombustible;

#########################################################
#LecturasTLS - Clase RecepcionCombustible				#
#                                                       #
#Autor: Ramses                                          #
#Fecha: Noviembre, 2018                                 #
#Revision: 1.0                                          #
#                                                       #
#########################################################

use strict;
use Trate::Lib::Constants qw(LOGGER ORCURETRIEVEFILE HO_ROLE);
use Trate::Lib::Utilidades;
use Trate::Lib::LecturasTLS;
use Trate::Lib::Factura;
use Trate::Lib::Movimiento;
use Data::Dump qw(dump);

sub new
{
	my $self = {};
	$self->{LECTURA_TLS} = Trate::Lib::LecturasTLS->new();
	$self->{FACTURA} = Trate::Lib::Factura->new();
	$self->{MOVIMIENTO_INVENTARIO} = Trate::Lib::Movimiento->new();
	$self->{MOVIMIENTO_RECEPCION} = Trate::Lib::Movimiento->new();
	bless($self);
	return $self;	
}

sub lecturaTls {
        my ($self) = shift;
        if (@_) { $self->{LECTURA_TLS} = shift }        
        return $self->{LECTURA_TLS};
}

sub factura {
        my ($self) = shift;
        if (@_) { $self->{FACTURA} = shift }        
        return $self->{FACTURA};
}

sub movimientoInventario {
        my ($self) = shift;
        if (@_) { $self->{MOVIMIENTO_INVENTARIO} = shift }        
        return $self->{MOVIMIENTO_INVENTARIO};
}

sub movimientoRecepcion {
        my ($self) = shift;
        if (@_) { $self->{MOVIMIENTO_RECEPCION} = shift }        
        return $self->{MOVIMIENTO_RECEPCION};
}

1;
#EOF