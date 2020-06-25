package Trate::Lib::LecturasPump;

#########################################################
# LecturasPump - Clase LecturasPump                 	#
#                                                       #
# Autor: Ramses                                         #
# Fecha: Mayo, 2020                                     #
# Revision: 1.0                                         #
#                                                       #
#########################################################

use strict;
use Trate::Lib::Constants qw(LOGGER ORCURETRIEVEFILE HO_ROLE);
use Trate::Lib::Utilidades;
use Trate::Lib::RemoteExecutor;
use Trate::Lib::ConnectorMariaDB;
use Trate::Lib::Tanques;
use Data::Dump qw(dump);

# Librerias para tratamiento de archivo XML
use XML::Writer;
use IO::File;
use XML::Twig;

sub new
{
	my $self = {};
	$self->{TANK_ID} = undef;
	$self->{ID_TANK_DELIVERY_READING} = undef;
	$self->{RECEPTION_UNIQUE_ID} = undef;
	$self->{START_VOLUME} = undef;
	$self->{END_VOLUME} = undef; 
	$self->{END_TEMP} = undef; 
	$self->{START_DELIVERY_TIMESTAMP} = undef;
	$self->{END_DELIVERY_TIMESTAMP} = undef;
	$self->{RUI} = undef;
	$self->{STATUS} = undef;
	$self->{START_TC_VOLUME} = undef;
	$self->{END_TC_VOLUME} = undef;
	$self->{START_HEIGHT} = undef;
	$self->{END_HEIGHT} = undef;
	$self->{START_TEMP} = undef;
	$self->{START_WATER} = undef;
	$self->{END_WATER} = undef;
	$self->{TANK_NAME} = undef;
	$self->{TANK_NUMBER} = undef;
	$self->{QUANTITY_TLS} = undef;
	$self->{QUANTITY_TRAN} = undef;
	$self->{CI_MOVIMIENTOS} = undef;
	$self->{ORIGEN_REGISTRO} = "PUMP";
	
	bless($self);
	return $self;	
}

sub idTankDeliveryReading {
	my $self = shift;
    if (@_) { $self->{ID_TANK_DELIVERY_READING} = shift }        
    return $self->{ID_TANK_DELIVERY_READING};
}

sub receptionUniqueId {
        my ($self) = shift;
        if (@_) { $self->{RECEPTION_UNIQUE_ID} = shift }        
        return $self->{RECEPTION_UNIQUE_ID};
}

sub status {
        my ($self) = shift;
        if (@_) { $self->{STATUS} = shift }        
        return $self->{STATUS};
}

sub ciMovimientos {
        my ($self) = shift;
        if (@_) { $self->{CI_MOVIMIENTOS} = shift }        
        return $self->{CI_MOVIMIENTOS};
}

sub origenRegistro {
	my ($self) = shift;
	if (@_) { $self->{ORIGEN_REGISTRO} = shift }
	return $self->{ORIGEN_REGISTRO};
}

sub procesaLecturaPump($) {
	my $self = shift;
	my $transaccion = shift;
	if($transaccion->{'quantity'} > 0){	
		my $tankes = Trate::Lib::Tanques->new();
		my $tanque = $tankes->getTanqueByName($transaccion->{'tank_name'});
		$self->{RECEPTION_UNIQUE_ID} = $transaccion->{'id'}; 
		$self->{TANK_ID} = $tanque->{ID};
		$self->{END_VOLUME} = $transaccion->{'quantity'} + $self->{START_VOLUME}; 
		$self->{START_DELIVERY_TIMESTAMP} = $transaccion->{'start_flow'};
		$self->{END_DELIVERY_TIMESTAMP} = $transaccion->{'timestamp'};
		$self->{RUI} = $transaccion->{'id'};
		$self->{STATUS} = 0;
		$self->{TANK_NAME} = $transaccion->{'tank_name'};
		$self->{TANK_NUMBER} = $tanque->{NUMBER};
		$self->{QUANTITY_TLS} = $transaccion->{'quantity'};
		$self->{QUANTITY_TRAN} = 0;	
		$self->{ORIGEN_REGISTRO} = "PUMP";
		LOGGER->debug(dump($self));
		insertaLecturaPump($self);
	}
	return 1;
}

sub insertaLecturaPump {
	my $self = shift;
	my $connector = Trate::Lib::ConnectorMariaDB->new();
	my $preps = "
		INSERT INTO tank_delivery_readings_t VALUES(" . 
			"NULL,'"  .
		 	$self->{RECEPTION_UNIQUE_ID} . "','" .
			$self->{TANK_ID} . "','" .
			$self->{START_VOLUME} . "','" .
			$self->{END_VOLUME} . "','" .
			$self->{END_TEMP} . "','" .
			$self->{START_DELIVERY_TIMESTAMP} . "','" .
			$self->{END_DELIVERY_TIMESTAMP} . "','" .
			$self->{RUI} . "','" .
			$self->{STATUS} . "','" .
			$self->{START_TC_VOLUME} . "','" .
			$self->{END_TC_VOLUME} . "','" .
			$self->{START_HEIGHT} . "','" . 
			$self->{END_HEIGHT} . "','" .
			$self->{START_TEMP} . "','" .
			$self->{START_WATER} . "','" .
			$self->{END_WATER} . "','" .
			$self->{TANK_NAME} . "','" .
			$self->{TANK_NUMBER} . "','" .
			$self->{QUANTITY_TLS} . "','" .
			$self->{QUANTITY_TRAN} . "'," .
			"NULL,'" . 
			$self->{ORIGEN_REGISTRO} . "'," .
			"NULL, " .
			"NULL)";
	LOGGER->debug("Ejecutando sql[ ", $preps, " ]");
    try {
	my $sth = $connector->dbh->prepare($preps);
	$sth->execute() or die LOGGER->fatal("NO PUDO EJECUTAR EL SIGUIENTE COMANDO en MARIADB:orpak: $preps");
	$sth->finish;
	$connector->destroy();
	LOGGER->debug("ramses inserta correctamente la lectura");
	return 1;
    } catch {
	LOGGER->debug("ramses no inserto correctamente la lectura");
	return 0;				    
    }
	
}


1;
#EOF