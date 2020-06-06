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
use Trate::Lib::Constants qw(LOGGER PROVEEDOR INFORMIX_SERVER);

$ENV{INFORMIXSERVER} = INFORMIX_SERVER;

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
	#LOGGER->debug("fecha: " . $self->{FECHA});
	my $fechaInformix = substr($self->{FECHA},2,2) . "-" . substr($self->{FECHA},5,2) . "-" . substr($self->{FECHA},8,2); 
	#LOGGER->debug("fechainformix: " . $fechaInformix);
	my $connector = Trate::Lib::ConnectorInformix->new();
	my $preps = "SELECT COUNT(*) FROM pfacturas WHERE fecha='" . &Trate::Lib::Utilidades::getInformixDate($self->{FECHA}) . "' AND factura='" . $self->{FACTURA} . "' AND proveedor='" . $self->{PROVEEDOR} . "' AND fserie='" . $self->{FSERIE} . "'";
	#my $preps = "SELECT COUNT(*) FROM pfacturas WHERE fecha='" . $fechaInformix . "' AND factura='" . $self->{FACTURA} . "' AND proveedor='" . $self->{PROVEEDOR} . "' AND fserie='" . $self->{FSERIE} . "'";
	LOGGER->debug("Ejecutando sql[ ", $preps, " ]");
	my $sth = $connector->dbh->prepare($preps);
    $sth->execute() or die LOGGER->error("NO PUDO EJECUTAR EL SIGUIENTE COMANDO en INFORMIX:Trate: $preps");
    $conteo = $sth->fetchrow_array;
    $sth->finish;
	LOGGER->debug("Existe: " . $conteo);
	$connector->destroy();
	($conteo gt 0 ? return 1 : return 0);
}

1;
#EOF
