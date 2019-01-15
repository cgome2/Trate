package Trate::Lib::Factura;
#########################################################
#Factura - Clase Factura								#
#                                                       #
#Autor: Ramses                                          #
#Fecha: Diciembre, 2019                                 #
#Revision: 1.0                                          #
#                                                       #
#########################################################

use strict;
use Trate::Lib::ConnectorInformix;
use Trate::Lib::Constants qw(LOGGER PROVEEDOR);

sub new
{
	my $self = {};
	$self->{FECHA} = undef;
	$self->{FACTURA} = undef;
	$self->{PROVEEDOR} = PROVEEDOR;
	$self->{FSERIE} = "RP";
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
	my $preps = "SELECT COUNT(*) FROM pfacturas WHERE fecha='" . &Trate::Lib::Utilidades::getInformixDate($self->{FECHA}) . "' AND factura='" . $self->{FACTURA} . "' AND proveedor='" . $self->{PROVEEDOR} . "' AND fserie='" . $self->{FSERIE} . "'";
	LOGGER->info("Ejecutando sql[ ", $preps, " ]");
	my $sth = $connector->dbh->prepare($preps);
    $sth->execute() or die LOGGER->error("NO PUDO EJECUTAR EL SIGUIENTE COMANDO en INFORMIX:Trate: $preps");
    $conteo = $sth->fetchrow_array;
    $sth->finish;
	$connector->destroy();
	($conteo gt 0 ? return 1 : return 0);
}

1;
#EOF