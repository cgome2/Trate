package Trate::Lib::Factura;
#########################################################
#Jarreo - Clase Jarreo									#
#                                                       #
#Autor: Ramses                                          #
#Fecha: Octubre, 2018                                   #
#Revision: 1.0                                          #
#                                                       #
#########################################################

use strict;
use Trate::Lib::ConnectorInformix;
use Trate::Lib::Constants qw(LOGGER);

sub new
{
	my $self = {};
	$self->{FECHA} = undef;
	$self->{FACTURA} = undef;
	$self->{PROVEEDOR} = "15002";
	$self->{FSERIE} = "00";
	bless($self);
	return $self;	
}

sub fecha{
	my ($self) = shift;
	if(@_){ $self->{FECHA} = shift }
	return $self->{FECHA};
}

sub factura {
        my ($self) = shift;
        if (@_) { $self->{FACTURA} = shift }        
        return $self->{FACTURA};
}

sub proveedor {
        my ($self) = shift;
        if (@_) { $self->{PROVEEDOR} = shift }        
        return $self->{PROVEEDOR};
}

sub fserie {
        my ($self) = shift;
        if (@_) { $self->{FSERIE} = shift }        
        return $self->{FSERIE};
}

sub existeFactura {
	my $self = shift;
	my $conteo = 0;
	my $connector = Trate::Lib::ConnectorInformix->new();
	my $preps = "SELECT COUNT(*) FROM pfacturas WHERE fecha='" . $self->{FECHA} . "' AND factura='" . $self->{FACTURA} . "' AND proveedor='" . $self->{PROVEEDOR} . "' AND fserie='" . $self->{FSERIE} . "'";
	LOGGER->info("Ejecutando sql[ ", $preps, " ]");
	my $sth = $connector->dbh->prepare($preps);
    $sth->execute() or die LOGGER->error("NO PUDO EJECUTAR EL SIGUIENTE COMANDO en INFORMIX:Trate: $preps");
    $conteo = $sth->fetchrow_array;
	$connector->destroy();
    return $conteo;
}

1;
#EOF