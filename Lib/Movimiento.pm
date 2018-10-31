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
        return $self->{ESTACION};
}

sub dispensador {
        my ($self) = @_;
        return $self->{DISPENSADOR};
}

sub supervisor {
        my ($self) = @_;
        return $self->{SUPERVISOR};
}

sub despachador {
        my ($self) = @_;
        return $self->{DESPACHADOR};
}

sub viaje {
        my ($self) = @_;
        return $self->{VIAJE};
}

sub camion {
        my ($self) = @_;
        return $self->{CAMION};
}

sub chofer {
        my ($self) = @_;
        return $self->{CHOFER};
}

sub sello {
        my ($self) = @_;
        return $self->{SELLO};
}

sub tipoReferencia {
        my ($self) = @_;
        return $self->{TIPO_REFERENCIA};
}

sub serie {
        my ($self) = @_;
        return $self->{SERIE};
}

sub referencia {
        my ($self) = @_;
        return $self->{REFERENCIA};
}

sub movimiento {
        my ($self) = @_;
        return $self->{MOVIMIENTO};
}

sub litrosEsp {
        my ($self) = @_;
        return $self->{LITROS_ESP};
}

sub litrosReal {
        my ($self) = @_;
        return $self->{LITROS_REAL};
}

sub costoEsp {
        my ($self) = @_;
        return $self->{COSTO_ESP};
}

sub costoReal {
        my ($self) = @_;
        return $self->{COSTO_REAL};
}

sub iva {
        my ($self) = @_;
        return $self->{IVA};
}

sub ieps {
        my ($self) = @_;
        return $self->{IEPS};
}

sub status {
        my ($self) = @_;
        return $self->{STATUS};
}

sub procesada {
        my ($self) = @_;
        return $self->{PROCESADA};
}

sub transaction_id {
        my ($self) = @_;
        return $self->{TRANSACTION_ID};
}

1;
#EOF