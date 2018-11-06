#########################################################
#Corte - Clase Corte									#
#                                                       #
#Autor: Ramses                                          #
#Fecha: Octubre, 2018                                   #
#Revision: 1.0                                          #
#                                                       #
#########################################################

package Trate::Lib::Corte;

use Trate::Lib::ConnectorInformix;
use Trate::Lib::ConnectorMariaDB;
use Trate::Lib::Constants qw(LOGGER);
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

sub fechaHora {
        my ($self) = @_;
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

sub entregaTurno {
        my ($self) = @_;
        return $self->{ENTREGA_TURNO};
}

sub recibeTurno {
        my ($self) = @_;
        return $self->{RECIBE_TURNO};
}

sub fechaHoraRecep {
        my ($self) = @_;
        return $self->{FECHA_HORA_RECEP};
}

sub inventarioRecibidoLts {
        my ($self) = @_;
        return $self->{INVENTARIO_RECIBIDO_LTS};
}

sub movtosTurnoLts {
        my ($self) = @_;
        return $self->{MOVTOS_TURNO_LTS};
}

sub inventarioEntregadoLts {
        my ($self) = @_;
        return $self->{INVENTARIO_ENTREGADO_LTS};
}

sub diferenciaLts {
        my ($self) = @_;
        return $self->{DIFERENCIA_LTS};
}

sub inventarioRecibidoCto {
        my ($self) = @_;
        return $self->{INVENTARIO_RECIBIDO_CTO};
}

sub movtosTurnoCto {
        my ($self) = @_;
        return $self->{MOVTOS_TURNO_CTO};
}

sub inventarioEntregadoCto {
        my ($self) = @_;
        return $self->{INVENTARIO_ENTREGADO_CTO};
}

sub diferenciaCto {
        my ($self) = @_;
        return $self->{DIFERENCIA_CTO};
}

sub autorizoDif {
        my ($self) = @_;
        return $self->{AUTORIZO_DIF};
}

sub contadorInicial {
        my ($self) = @_;
        return $self->{CONTADOR_INICIAL};
}

sub folio {
        my ($self) = @_;
        return $self->{FOLIO};
}

sub contadorFinal {
        my ($self) = @_;
        return $self->{CONTADOR_FINAL};
}


sub vserie {
        my ($self) = @_;
        return $self->{VSERIE};
}

sub procesada {
        my ($self) = @_;
        return $self->{PROCESADA};
}


1;
#EOF