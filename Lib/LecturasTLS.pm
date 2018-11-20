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
use Trate::Lib::Constants qw(LOGGER);
use Trate::Lib::RemoteExecutor;
use Trate::Lib::ConnectorMariaDB;

# Librerias para tratamiento de archivo XML
use XML::Writer;
use IO::File;
use XML::Twig;

sub new
{
	my $self = {};
	$self->{RECEPTION_UNIQUE_ID} = undef; 
	$self->{TANK_ID} = undef; 
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
	$self->{START_WATER} = undef; 
	$self->{END_WATER} = undef; 
	$self->{START_TEMP} = undef; 
	$self->{STN_ID} = undef; 
	$self->{SENT_TO_FHO} = undef; 
	$self->{SENT_TO_DHO} = undef; 
	$self->{SENT_TO_FILE} = undef; 
	$self->{USED_FOR_DELIVERY} = undef; 
	$self->{SALES_VOLUME_ADJUSTMENT} = undef; 
	$self->{RECEIVED_TIMESTAMP} = undef; 
	$self->{QUANTITY_MATCH} = undef; 
	$self->{START_DENSITY} = undef; 
	$self->{END_DENSITY} = undef; 
	$self->{START_TC_DENSITY} = undef; 
	$self->{END_TC_DENSITY} = undef; 
	$self->{START_TOTAL_TC_DENSITY_OFFSET} = undef;
	$self->{END_TOTAL_TC_DENSITY_OFFSET} = undef;
	$self->{QUANTITY_TRAN} = undef;
	$self->{QUANTITY_TLS} = undef;
	$self->{NET_VOLUME_DURING_DECANT} = undef;

	$self->{ORCURETREIVEFILE} = "/usr/local/orpak/perl/Trate/orcuretreive.xml";
	$self->{LAST_TLS_READING_ID} = undef; #ULTIMA RECEPCION DESCARGADA
	$self->{LAST_TLS_READING_TIMESTAMP} = undef;
	bless($self);
	return $self;	
}

sub getLastRetrievedLecturasTLS{
    my $self = shift;
    my $twig= new XML::Twig;
    $twig->parsefile($self->{ORCURETREIVEFILE});
    my $root = $twig->root;
    my @transporter_tls_reading = $root->descendants('transporter:tls_reading');
    $self->{LAST_TLS_READING_ID} = $transporter_tls_reading[0]->{'att'}->{'reception_unique_id'};
	$self->{LAST_TLS_READING_TIMESTAMP} = $transporter_tls_reading[0]->{'att'}->{'received_timestamp'};
	
	return $self;
}

sub getLastLecturasTLSFromORCU{
	my $self = shift;
	$self = getLastRetrievedLecturasTLS($self);
	my $remex = Trate::Lib::RemoteExecutor->new();
	my $query = "SELECT reception_unique_id,
						tank_id,
						start_volume,
						end_volume,
						end_temp,
						start_delivery_timestamp,
						end_delivery_timestamp,
						rui,
						status,
						start_tc_volume,
						end_tc_volume,
						start_height,
						end_height,
						start_water,
						end_water,
						start_temp,
						stn_id,
						sent_to_fho,
						sent_to_dho,
						sent_to_file,
						used_for_delivery,
						sales_volume_adjustment,
						received_timestamp,
						quantity_match,
						start_density,
						start_tc_density,
						end_tc_density,
						start_total_tc_density_offset,
						end_total_tc_density_offset,
						quantity_tran,
						quantity_tls,
						net_volume_during_decant
				FROM tank_delivery_readings_t 
				WHERE reception_unique_id>" . 
						$self->{LAST_TLS_READING_ID} . " AND END_DELIVERY_TIMESTAMP>'" .
						$self->{LAST_TLS_READING_TIMESTAMP} . "' ";
	LOGGER->debug($query);
	#return $remex->remoteQuery($query);
	return $remex->remoteQueryDevelopment($query);
}

sub insertaLecturaTLS{
	my $self = shift;
	my $connector = Trate::Lib::ConnectorMariaDB->new();
	my $preps = "
		INSERT INTO tank_delivery_readings_t VALUES('"  .
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
			$self->{START_WATER} . "','" .
			$self->{END_WATER} . "','" .
			$self->{START_TEMP} . "','" .
			$self->{STN_ID} . "','" .
			$self->{SENT_TO_FHO} . "','" .
			$self->{SENT_TO_DHO} . "','" .
			$self->{SENT_TO_FILE} . "','" .
			$self->{USED_FOR_DELIVERY} . "','" .
			$self->{SALES_VOLUME_ADJUSTMENT} . "','" .
			$self->{RECEIVED_TIMESTAMP} . "','" .
			$self->{QUANTITY_MATCH} . "','" .
			$self->{START_DENSITY} . "','" . 
			$self->{END_DENSITY} . "','" .
			$self->{START_TC_DENSITY} . "','" .
			$self->{END_TC_DENSITY} . "','" .
			$self->{START_TOTAL_TC_DENSITY_OFFSET} . "','" .
			$self->{END_TOTAL_TC_DENSITY_OFFSET} . "','" .
			$self->{QUANTITY_TRAN} . "','" .
			$self->{QUANTITY_TLS} . "','" .
			$self->{NET_VOLUME_DURING_DECANT} . "')";
	LOGGER->debug("Ejecutando sql[ ", $preps, " ]");
	my $sth = $connector->dbh->prepare($preps);
    $sth->execute() or die LOGGER->fatal("NO PUDO EJECUTAR EL SIGUIENTE COMANDO en MARIADB:orpak: $preps");
	$connector->destroy();
	return $self;
}

sub procesaLecturasTLS($){
	my $self = shift;
	my $lecturas_tls = shift;
	LOGGER->debug("transacciones a procesar" . @$lecturas_tls);
	foreach my $row (@$lecturas_tls){
			my @fieldsArray = split(/\|/,$row);
			$self->{RECEPTION_UNIQUE_ID} = $fieldsArray[0]; 
			$self->{TANK_ID} = $fieldsArray[1]; 
			$self->{START_VOLUME} = $fieldsArray[2]; 
			$self->{END_VOLUME} = $fieldsArray[3]; 
			$self->{END_TEMP} = $fieldsArray[4]; 
			$self->{START_DELIVERY_TIMESTAMP} = $fieldsArray[5]; 
			$self->{END_DELIVERY_TIMESTAMP} = $fieldsArray[6];
			$self->{RUI} = $fieldsArray[7];
			$self->{STATUS} = $fieldsArray[8]; 
			$self->{START_TC_VOLUME} = $fieldsArray[9]; 
			$self->{END_TC_VOLUME} = $fieldsArray[10]; 
			$self->{START_HEIGHT} = $fieldsArray[11]; 
			$self->{END_HEIGHT} = $fieldsArray[12]; 
			$self->{START_WATER} = $fieldsArray[13]; 
			$self->{END_WATER} = $fieldsArray[14]; 
			$self->{START_TEMP} = $fieldsArray[15]; 
			$self->{STN_ID} = $fieldsArray[16]; 
			$self->{SENT_TO_FHO} = $fieldsArray[17]; 
			$self->{SENT_TO_DHO} = $fieldsArray[18]; 
			$self->{SENT_TO_FILE} = $fieldsArray[19]; 
			$self->{USED_FOR_DELIVERY} = $fieldsArray[20]; 
			$self->{SALES_VOLUME_ADJUSTMENT} = $fieldsArray[21]; 
			$self->{RECEIVED_TIMESTAMP} = $fieldsArray[22]; 
			$self->{QUANTITY_MATCH} = $fieldsArray[23]; 
			$self->{START_DENSITY} = $fieldsArray[24]; 
			$self->{END_DENSITY} = $fieldsArray[25]; 
			$self->{START_TC_DENSITY} = $fieldsArray[26]; 
			$self->{END_TC_DENSITY} = $fieldsArray[27]; 
			$self->{START_TOTAL_TC_DENSITY_OFFSET} = $fieldsArray[28];
			$self->{END_TOTAL_TC_DENSITY_OFFSET} = $fieldsArray[29];
			$self->{QUANTITY_TRAN} = $fieldsArray[30];
			$self->{QUANTITY_TLS} = $fieldsArray[31];
			$self->{NET_VOLUME_DURING_DECANT} = $fieldsArray[32];

			$self = insertaLecturaTLS($self);
	}
	$self = setLastLecturaTLSRetreived($self);	
	return 1;
}

sub setLastLecturaTLSRetreived {
	my $self = shift;
	my $twig= XML::Twig->new(
		twig_roots => {
			'transporter:tls_reading' => sub{ 
				my( $t, $tt)= @_;
				$tt->set_att('reception_unique_id'=>$self->{RECEPTION_UNIQUE_ID});
				$tt->set_att('received_timestamp'=>$self->{END_DELIVERY_TIMESTAMP});
				$tt->set_att('timestamp_retrieve'=>getCurrentTimestamp());
				$tt->print;		
		    },
		},
		twig_print_outside_roots => 1,
	);

	$twig->parsefile_inplace($self->{ORCURETREIVEFILE});
	return $self;
}

sub getCurrentTimestamp {
	my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime(time);
	my $mysqlDate = $year + 1900;
	$mysqlDate .= "-";
	$mysqlDate .= $mon + 1;
	$mysqlDate .= "-";
	$mysqlDate .= $mday;
	$mysqlDate .= " ";
	$mysqlDate .= $hour;
	$mysqlDate .= ":";
	$mysqlDate .= $min;
	$mysqlDate .= ":";
	$mysqlDate .= sprintf("%02d", $sec);
	return $mysqlDate;
}

1;
#EOF