#########################################################
#Movimiento - Clase Movimiento							#
#                                                       #
#Autor: Ramses                                          #
#Fecha: Octubre, 2018                                   #
#Revision: 1.0                                          #
#                                                       #
#########################################################

package Trate::Lib::Movimiento;

use Trate::Lib::ConnectorInformix;
use Trate::Lib::ConnectorMariaDB;
use strict;

sub new
{
	my $self = {};
	$self->{FECHA_HORA} = undef;
	$self->{ESTACION} = undef;
	$self->{DISPENSADOR} = undef;
	$self->{SUPERVISOR} = undef;
	$self->{DESPACHADOR} = undef;
	$self->{VIAJE} = undef;
	$self->{CAMION} = undef;
	$self->{CHOFER} = undef;
	$self->{SELLO} = undef;
	$self->{TIPO_REFERENCIA} = undef;
	$self->{SERIE} = undef;
	$self->{REFERENCIA} = undef;
	$self->{MOVIMIENTO} = undef;
	$self->{LITROS_ESP} = undef;
	$self->{LITROS_REAL} = undef;
	$self->{COSTO_ESP} = undef;
	$self->{COSTO_REAL} = undef;
	$self->{IVA} = undef;
	$self->{IEPS} = undef;
	$self->{STATUS} = undef;
	$self->{PROCESADA} = undef;
	$self->{TRANSACTION_ID} = undef;
	bless($self);
	return $self;	
}

sub fechaHora {
        my ($self) = @_;
        if (@_) { $self->{FECHA_HORA} = shift }
        return $self->{FECHA_HORA};
}

sub estacion {
        my ($self) = @_;
        if (@_) { $self->{ESTACION} = shift }
        return $self->{ESTACION};
}

sub dispensador {
        my ($self) = @_;
        if (@_) { $self->{DISPENSADOR} = shift }
        return $self->{DISPENSADOR};
}

sub supervisor {
        my ($self) = @_;
        if (@_) { $self->{SUPERVISOR} = shift }
        return $self->{SUPERVISOR};
}

sub despachador {
        my ($self) = @_;
        if (@_) { $self->{DESPACHADOR} = shift }
        return $self->{DESPACHADOR};
}

sub viaje {
        my ($self) = @_;
        if (@_) { $self->{VIAJE} = shift }
        return $self->{VIAJE};
}

sub camion {
        my ($self) = @_;
        if (@_) { $self->{CAMION} = shift }
        return $self->{CAMION};
}

sub chofer {
        my ($self) = @_;
        if (@_) { $self->{CHOFER} = shift }
        return $self->{CHOFER};
}

sub sello {
        my ($self) = @_;
        if (@_) { $self->{SELLO} = shift }
        return $self->{SELLO};
}

sub tipoReferencia {
        my ($self) = @_;
        if (@_) { $self->{TIPO_REFERENCIA} = shift }
        return $self->{TIPO_REFERENCIA};
}

sub serie {
        my ($self) = @_;
        if (@_) { $self->{SERIE} = shift }
        return $self->{SERIE};
}

sub referencia {
        my ($self) = @_;
        if (@_) { $self->{REFERENCIA} = shift }
        return $self->{REFERENCIA};
}

sub movimiento {
        my ($self) = @_;
        if (@_) { $self->{MOVIMIENTO} = shift }
        return $self->{MOVIMIENTO};
}

sub litrosEsp {
        my ($self) = @_;
        if (@_) { $self->{LITROS_ESP} = shift }
        return $self->{LITROS_ESP};
}

sub litrosReal {
        my ($self) = @_;
        if (@_) { $self->{LITROS_REAL} = shift }
        return $self->{LITROS_REAL};
}

sub costoEsp {
        my ($self) = @_;
        if (@_) { $self->{COSTO_ESP} = shift }
        return $self->{COSTO_ESP};
}

sub costoReal {
        my ($self) = @_;
        if (@_) { $self->{COSTO_REAL} = shift }
        return $self->{COSTO_REAL};
}

sub iva {
        my ($self) = @_;
        if (@_) { $self->{IVA} = shift }
        return $self->{IVA};
}

sub ieps {
        my ($self) = @_;
        if (@_) { $self->{IEPS} = shift }
        return $self->{IEPS};
}

sub status {
        my ($self) = @_;
        if (@_) { $self->{STATUS} = shift }
        return $self->{STATUS};
}

sub procesada {
        my ($self) = @_;
        if (@_) { $self->{PROCESADA} = shift }
        return $self->{PROCESADA};
}

sub transaction_id {
        my ($self) = @_;
        if (@_) { $self->{TRANSACTION_ID} = shift }
        return $self->{TRANSACTION_ID};
}

1;
#EOF