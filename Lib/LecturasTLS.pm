package Trate::Lib::LecturasTLS;

#########################################################
#LecturasTLS - Clase LecturasTLs						#
#                                                       #
#Autor: Ramses                                          #
#Fecha: Noviembre, 2018                                 #
#Revision: 1.0                                          #
#                                                       #
#########################################################

use strict;
use Trate::Lib::Constants qw(LOGGER ORCURETRIEVEFILE HO_ROLE);
use Trate::Lib::Utilidades;
use Trate::Lib::RemoteExecutor;
use Trate::Lib::ConnectorMariaDB;
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
	$self->{ORIGEN_REGISTRO} = undef;
	
	$self->{ORCURETRIEVEFILE} = ORCURETRIEVEFILE;
	$self->{LAST_TLS_READING_ID} = undef; #ULTIMA RECEPCION DESCARGADA
	$self->{LAST_TLS_READING_TIMESTAMP} = undef;
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

# Método para notificar a Orcu que una entrega de combustible ya fue descargada en transporter
# Autor: carlos gomez

sub notificarDescargaLecturasTlsAOrcu {
	my $self = shift;
	my %params = (
		SessionID => "",
		site_code => "",
		ho_role => HO_ROLE,
		num_TankDelivery => "1",
		a_TankDeliveryIDs => {
			soTankDeliveryID => { "id" => $self->{RECEPTION_UNIQUE_ID}}
		}
	);
	LOGGER->debug("los parametros para procesar servicio web" . dump(%params));
	my $wsc = Trate::Lib::WebServicesClient->new();
	$wsc->callName("SOHONotifyTankDeliveryLoaded");
	$wsc->sessionIdTransporter();
	my $result = $wsc->execute(\%params);	
	if ($result->{rc} eq 0){
		LOGGER->info("Se notifico exitosamente al orcu sobre la descarga de la recepcion de combustible");
		return 1;
	} else {
		LOGGER->error('NO se pudo notificar al orcu sobre la descarga de la recepción de combustible');
		return 0;
	}
}

# Método para descargar las últimas lecturas del TLS registradas en el Orcu
# Autor: carlos gomez

sub getLastLecturasTlsFromOrcu {
	my $self = shift;
	#$self = getLastRetrievedLecturasTLS($self);	
	my %params = (
		SessionID => "",
		site_code => "",
		max_size => "5",
		ho_role => HO_ROLE,
	);
	my $wsc = Trate::Lib::WebServicesClient->new();
	$wsc->callName("SOHOGetNewUpdatedTankDelivery");
	$wsc->sessionIdTransporter();
	my $result = $wsc->execute(\%params);	
	LOGGER->info("Cantidad de recepciones [" . $result->{num_TankDelivery} . "]");
	if ($result->{num_TankDelivery} gt 1){
		return procesaLecturasTLS($self,$result->{a_soTankDelivery}->{soTankDelivery});
	} elsif ($result->{num_TankDelivery} eq 1){
		return procesaLecturasTLS($self,[$result->{a_soTankDelivery}->{soTankDelivery}]);
	} else {
		LOGGER->info("Ninguna recepcion por descargar");
		return 1;
	}
}

sub procesaLecturasTLS($){
	my $self = shift;
	my $lecturas_tls_array = shift;
	my @reception_unique_ids_procesados;
	
	LOGGER->debug("El dump para procesar" . dump($lecturas_tls_array));
	my @lecturas_tls = @$lecturas_tls_array;
	foreach my $row (@lecturas_tls){
		$self->{RECEPTION_UNIQUE_ID} = $row->{'reception_unique_id'}; 
		$self->{TANK_ID} = $row->{'tank_id'};
		$self->{START_VOLUME} = $row->{'start_volume'};
		$self->{END_VOLUME} = $row->{'end_volume'}; 
		$self->{END_TEMP} = $row->{'end_temp'}; 
		$self->{START_DELIVERY_TIMESTAMP} = $row->{'start_delivery_timestamp'};
		$self->{END_DELIVERY_TIMESTAMP} = $row->{'end_delivery_timestamp'};
		$self->{RUI} = $row->{'rui'};
		$self->{STATUS} = $row->{'status'};
		$self->{START_TC_VOLUME} = $row->{'start_tc_volume'};
		$self->{END_TC_VOLUME} = $row->{'end_tc_volume'};
		$self->{START_HEIGHT} = $row->{'start_height'};
		$self->{END_HEIGHT} = $row->{'end_height'};
		$self->{START_TEMP} = $row->{'start_temp'};
		$self->{START_WATER} = $row->{'start_water'};
		$self->{END_WATER} = $row->{'end_water'};
		$self->{TANK_NAME} = $row->{'tank_name'};
		$self->{TANK_NUMBER} = $row->{'tank_number'};
		$self->{QUANTITY_TLS} = $row->{'quantity_tls'};
		$self->{QUANTITY_TRAN} = $row->{'quantity_tran'};	
		$self->{ORIGEN_REGISTRO} = "TLS";		
		notificarDescargaLecturasTlsAOrcu($self);
		insertaLecturaTLS($self);
	}
	return 1;
}

sub insertaLecturaTLS {
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

sub setLastLecturaTLSRetreived {
	my $self = shift;
	my $twig= XML::Twig->new(
		twig_roots => {
			'transporter:tls_reading' => sub{ 
				my( $t, $tt)= @_;
				$tt->set_att('reception_unique_id'=>$self->{RECEPTION_UNIQUE_ID});
				$tt->set_att('received_timestamp'=>$self->{END_DELIVERY_TIMESTAMP});
				$tt->set_att('timestamp_retrieve'=>Trate::Lib::Utilidades::getCurrentTimestampMariaDB());
				$tt->print;		
		    },
		},
		twig_print_outside_roots => 1,
	);

	$twig->parsefile_inplace($self->{ORCURETRIEVEFILE});
	return $self;
}


sub getLecturasTls{
	my $self = shift;
	#my ($sort,$order,$page,$limit,$search) = @_;
	my $connector = Trate::Lib::ConnectorMariaDB->new();
	my $where_stmt = "";
	
	#if (length($sort) ge 1){
	#	$where_stmt .= " ORDER BY " . $sort;
	#	if (length($order) gt 1){
	#		$where_stmt .= " " . $order . " ";
	#	}
	#}

	#if (length($page) ge 1 && length($limit) ge 1){
	#	$where_stmt .= " LIMIT " . $page . "," . $limit;
	#}	
	
	my $preps = "SELECT * FROM tank_delivery_readings_t WHERE status=0 AND id_recepcion IS NULL AND ci_movimientos IS NULL " . $where_stmt . " ORDER BY start_delivery_timestamp DESC "; 
	LOGGER->debug("Ejecutando sql[ ", $preps, " ]");
	my $sth = $connector->dbh->prepare($preps);
	$sth->execute() or die LOGGER->fatal("NO PUDO EJECUTAR EL SIGUIENTE COMANDO en MARIADB:orpak: $preps");
	my @tdrs;
	while (my $ref = $sth->fetchrow_hashref()) {
    	push @tdrs,$ref;
	}
	$sth->finish;
	$connector->destroy();
	return \@tdrs;	
}

sub getLecturasTlsFromId {
	my $self = shift;
	my $connector = Trate::Lib::ConnectorMariaDB->new();
	my $preps = "SELECT * FROM tank_delivery_readings_t WHERE id_tank_delivery_reading='" . $self->{ID_TANK_DELIVERY_READING} . "' LIMIT 1"; 
	LOGGER->debug("Ejecutando sql[ ", $preps, " ]");
	my $sth = $connector->dbh->prepare($preps);
	$sth->execute() or die LOGGER->fatal("NO PUDO EJECUTAR EL SIGUIENTE COMANDO en MARIADB:orpak: $preps");
	my $row = $sth->fetchrow_hashref();
	$sth->finish;
	$connector->destroy();
	return $row;	
}

sub updateLecturaTls {
	my $self = shift;
	my $connector = Trate::Lib::ConnectorMariaDB->new();
	my $preps = " UPDATE tank_delivery_readings_t SET " .
		"tank_id='" . $self->{TANK_ID} . "'," .
		"start_volume='" . $self->{START_VOLUME} . "'," .
		"end_volume='" . $self->{END_VOLUME} . "'," .
		"end_temp='" . $self->{END_TEMP} . "'," .
		"start_delivery_timestamp='" . $self->{START_DELIVERY_TIMESTAMP} . "'," .
		"end_delivery_timestamp='" . $self->{END_DELIVERY_TIMESTAMP} . "'," .
		"status='" . $self->{STATUS} . "'," .
		"start_height='" . $self->{START_HEIGHT} . "'," .
		"end_height='" . $self->{END_HEIGHT} . "'," .
		"start_temp='" . $self->{START_TEMP} . "'," .
		"start_water='" . $self->{START_WATER} . "'," .
		"end_water='" . $self->{END_WATER} . "'," .
		"tank_name='" . $self->{TANK_NAME} . "'," .
		"tank_number='" . $self->{TANK_NUMBER} . "'," .
		"origen_registro='" . $self->{ORIGEN_REGISTRO} . "'" .
		" WHERE id_tank_delivery_reading='" . $self->{ID_TANK_DELIVERY_READING} . "'";
	LOGGER->debug("Ejecutando sql[ ", $preps, " ]");
    try {
		my $sth = $connector->dbh->prepare($preps);
	    $sth->execute() or die LOGGER->fatal("NO PUDO EJECUTAR EL SIGUIENTE COMANDO en MARIADB:orpak: $preps");
		$sth->finish;
		$connector->destroy();
		return 1;
    } catch {
		return 0;				    
    }
}

sub deleteLecturaTls {
	my $self = shift;
	my $connector = Trate::Lib::ConnectorMariaDB->new();
	my $preps = " DELETE FROM tank_delivery_readings_t WHERE id_tank_delivery_reading='" . $self->{ID_TANK_DELIVERY_READING} . "' LIMIT 1";
	LOGGER->debug("Ejecutando sql[ ", $preps, " ]");
    try {
		my $sth = $connector->dbh->prepare($preps);
	    $sth->execute() or die LOGGER->fatal("NO PUDO EJECUTAR EL SIGUIENTE COMANDO en MARIADB:orpak: $preps");
		$sth->finish;
		$connector->destroy();
		return 1;
    } catch {
		return 0;				    
    }
}

sub quemarLecturas($$) {
	my $id_recepcion = pop;
	my $lecturas = pop;
	my $in = join(",", @{$lecturas});
	LOGGER->debug(dump($lecturas));
	my $connector = Trate::Lib::ConnectorMariaDB->new();
	my $preps = " UPDATE tank_delivery_readings_t SET " .
		"id_recepcion = '" . $id_recepcion . "'," .
		"status = '" . 1 . "' WHERE id_tank_delivery_reading in(" . $in . ")";
	LOGGER->debug("Ejecutando sql[ ", $preps, " ]");
	my $sth = $connector->dbh->prepare($preps);
	$sth->execute() or die LOGGER->fatal("NO PUDO EJECUTAR EL SIGUIENTE COMANDO en MARIADB:orpak: $preps");
	$sth->finish;
	$connector->destroy();
}

1;
#EOF
