package Trate::Lib::Pase;

#########################################################
#Pase - Clase Pase										#
#                                                       #
#Autor: Ramses                                          #
#Fecha: Octubre, 2018                                   #
#Revision: 1.0                                          #
#                                                       #
#########################################################
use strict;
use Trate::Lib::ConnectorInformix;
use Trate::Lib::ConnectorMariaDB;
use Trate::Lib::Constants qw(LOGGER);
use Try::Catch;
use base qw/Apache2::REST::Handler/;


sub new
{
	my $self = {};
	$self->{FECHA_SOLICITUD} = "";
	$self->{PASE} = 0;
	$self->{VIAJE} = 0;
	$self->{CAMION} = "";
	$self->{CHOFER} = 0;
	$self->{LITROS} = 0;
	$self->{CONTINGENCIA} = 0;
	$self->{STATUS} = "";
	$self->{LITROS_REAL} = 0;
	$self->{LITROS_ESP} = 0;
	$self->{VIAJE_SUST} = 0;
	$self->{SUPERVISOR} = "";
	$self->{OBSERVACIONES} = "";
	$self->{ULTIMA_MODIFICACION} = "";
	$self->{MEAN_CONTINGENCIA} = "";
	bless $self;
	return $self;	
}

sub fechaSolicitud {
        my ($self) = shift;
        if (@_) { $self->{FECHA_SOLICITUD} = shift }        
        return $self->{FECHA_SOLICITUD};
}

sub pase {
        my ($self) = shift;
        if (@_) { $self->{PASE} = shift }        
        return $self->{PASE};
}

sub viaje {
        my ($self) = shift;
        if (@_) { $self->{VIAJE} = shift }        
        return $self->{VIAJE};
}

sub camion {
        my ($self) = shift;
        if (@_) { $self->{CAMION} = shift }        
        return $self->{CAMION};
}

sub chofer {
        my ($self) = shift;
        if (@_) { $self->{CHOFER} = shift }        
        return $self->{CHOFER};
}

sub litros {
        my ($self) = shift;
        if (@_) { $self->{LITROS} = shift }        
        return $self->{LITROS};
}

sub contingencia {
        my ($self) = shift;
        if (@_) { $self->{CONTINGENCIA} = shift }        
        return $self->{CONTINGENCIA};
}

sub status {
        my ($self) = shift;
        if (@_) { $self->{STATUS} = shift }        
        return $self->{STATUS};
}

sub litrosReal {
        my ($self) = shift;
        if (@_) { $self->{LITROS_REAL} = shift }        
        return $self->{LITROS_REAL};
}

sub litrosEsp {
        my ($self) = shift;
        if (@_) { $self->{LITROS_ESP} = shift }        
        return $self->{LITROS_ESP};
}

sub viajeSust {
        my ($self) = shift;
        if (@_) { $self->{VIAJE_SUST} = shift }        
        return $self->{VIAJE_SUST};
}

sub supervisor {
        my ($self) = shift;
        if (@_) { $self->{SUPERVISOR} = shift }        
        return $self->{SUPERVISOR};
}

sub observaciones {
        my ($self) = shift;
        if (@_) { $self->{OBSERVACIONES} = shift }        
        return $self->{OBSERVACIONES};
}

sub ultimaModificacion {
        my ($self) = shift;
        if (@_) { $self->{ULTIMA_MODIFICACION} = shift }        
        return $self->{ULTIMA_MODIFICACION};
}

sub meanContingencia {
        my ($self) = shift;
        if (@_) { $self->{MEAN_CONTINGENCIA} = shift }        
        return $self->{MEAN_CONTINGENCIA};
}

sub psInsertarPaseMariaDB {
	my $self = shift;

	my $preps = 	"INSERT INTO ci_pases (" . 
									"fecha_solicitud," .
									"pase," .
									"viaje," .
									"camion," .
									"chofer," .
									"litros," .
									"contingencia," .
									"status," .
									"litros_real," .
									"litros_esp," .
									"viaje_sust," .
									"supervisor," .
									"observaciones," .
									"ultima_modificacion" .
								") VALUES('" .
									$self->{FECHA_SOLICITUD} . "','" .
									$self->{PASE} . "','" .
									$self->{VIAJE} . "','" .
									$self->{CAMION} . "','" .
									$self->{CHOFER} . "','" .
									$self->{LITROS} . "','" .
									$self->{CONTINGENCIA} . "','" .
									$self->{STATUS} . "','" .
									$self->{LITROS_REAL} . "','" .
									$self->{LITROS_ESP} . "','" .
									$self->{VIAJE_SUST} . "','" .
									$self->{SUPERVISOR} . "','" .
									$self->{OBSERVACIONES} . "'," .
									$self->{ULTIMA_MODIFICACION} .
								")";
	return $preps;
}

sub getFromMean(){
	my $self = shift;
	my $mean = shift;
	$self->{FECHA_SOLICITUD} = shift;

	my $id = 0;
	my $connector = Trate::Lib::ConnectorMariaDB->new();
	my $preps = "SELECT * FROM ci_pases WHERE (camion = '" . $mean . "' OR mean_contingencia = '" . $mean . "') AND status IN ('D','A','R','T','X') ORDER BY fecha_solicitud DESC LIMIT 1";
	LOGGER->debug("Ejecutando sql[ ", $preps, " ]");
	my $sth = $connector->dbh->prepare($preps);
    $sth->execute() or die LOGGER->fatal("NO PUDO EJECUTAR EL SIGUIENTE COMANDO en MARIADB:orpak: $preps");

	my $row = $sth->fetchrow_hashref();
	$sth->finish;
	$connector->destroy();

	$self->{ID}=$row->{id};
	$self->{FECHA_SOLICITUD} = $row->{fecha_solicitud};
	$self->{PASE} = $row->{pase};
	$self->{VIAJE} = $row->{viaje};
	$self->{CAMION} = $row->{camion};
	$self->{CHOFER} = $row->{chofer};
	$self->{LITROS} = $row->{litros};
	$self->{CONTINGENCIA} = $row->{contingencia};
	$self->{STATUS} = $row->{status};
	$self->{LITROS_REAL} = $row->{litros_real};
	$self->{LITROS_ESP} = $row->{litros_esp};
	$self->{VIAJE_SUST} = $row->{viaje_sust};
	$self->{SUPERVISOR} = $row->{supervisor};
	$self->{OBSERVACIONES} = $row->{observaciones};
	$self->{ULTIMA_MODIFICACION} = $row->{ultima_modificacion};
	$self->{MEAN_CONTINGENCIA} = $row->{mean_contingencia};
	return $self;	
}

sub updatePase {
	my $self = shift;
	my $connector = Trate::Lib::ConnectorMariaDB->new();
	my $preps;
	
	if($self->{STATUS} eq "R" || $self->{STATUS} eq "T"){
		$preps = sprintf "UPDATE ci_pases SET status='%s', supervisor='%s', observaciones='%s', mean_contingencia='%s' WHERE pase=%d ", $self->{STATUS}, $self->{SUPERVISOR}, $self->{OBSERVACIONES}, $self->{MEAN_CONTINGENCIA}, $self->{PASE};	
	} else {
		$preps = sprintf "UPDATE ci_pases SET status='%s', supervisor='%s', observaciones='%s', mean_contingencia='%s', litros_real=CASE WHEN litros_real IS NULL THEN %.4f ELSE litros_real + %.4f END WHERE pase=%d ", $self->{STATUS}, $self->{SUPERVISOR}, $self->{OBSERVACIONES}, $self->{MEAN_CONTINGENCIA}, $self->{LITROS_REAL}, $self->{LITROS_REAL}, $self->{PASE};
	}
	LOGGER->debug("Ejecutando sql[ ", $preps, " ]");
	try {
		my $sth = $connector->dbh->prepare($preps);
	    my $rowsaffected = $sth->execute() or die LOGGER->fatal("NO PUDO EJECUTAR EL SIGUIENTE COMANDO en MARIADB:orpak: $preps");
	    $sth->finish;
		$connector->destroy();
		if ($rowsaffected ge 1){
			return 1;			
		} else {
			LOGGER->info("El pase [" . $self->{pase}  . "] no se actualizó en MariaDB");
			return 0;
		}
	} catch {
		return 0;		
	}
}

sub actualizaInformix {
	my $self = shift;
	my $return = 0;
	my $connector = Trate::Lib::ConnectorInformix->new();
	my $preps;
	
	$preps = sprintf "UPDATE ci_pases SET status='%s', supervisor='%s', observaciones='%s', litros_real=%4f " . 
	"WHERE pase=%d ", $self->{STATUS}, $self->{SUPERVISOR}, $self->{OBSERVACIONES}, $self->{LITROS_REAL}, $self->{PASE};	
	LOGGER->debug("Ejecutando sql[ ", $preps, " ]");
	try {			
		my $sth = $connector->dbh->prepare($preps) or die(LOGGER->fatal("NO SE PUDO CONECTAR A INFORMIX:master"));
	    my $rowsaffected = $sth->execute() or die LOGGER->fatal("NO PUDO EJECUTAR EL SIGUIENTE COMANDO en INFORMIX:orpak: $preps");
	    $sth->finish;
		$connector->destroy();
		if ($rowsaffected ge 1){
			return 1;			
		} else {
			LOGGER->info("El pase [" . $self->{PASE} . "] no se actualizó en informix");
			return 0;
		}
		
	} catch {
		return 0;
	}
}

sub getPase {
	my $self = shift;
	my $connector = Trate::Lib::ConnectorMariaDB->new();
	my $preps = "SELECT
					pase as pase_id,
					fecha_solicitud,
					viaje,
					camion,
					chofer,
					litros,
					contingencia,
					status,
					litros_real,
					mean_contingencia
				FROM
					ci_pases
				WHERE
					(pase='" . $self->{PASE} . "' AND status IN ('A','D','R','T','M','C'))
				OR
					(camion='" . $self->{CAMION} . "' AND status IN ('A','D','R','T','M','C'))
				ORDER BY
					fecha_solicitud
				DESC";
	LOGGER->debug("Ejecutando sql[ ", $preps, " ]");
	try {
		my $sth = $connector->dbh->prepare($preps);
		$sth->execute() or die LOGGER->fatal("NO PUDO EJECUTAR EL SIGUIENTE COMANDO en MARIADB:orpak: $preps");
		if ($sth->rows gt 0) {		
			my $row = $sth->fetchrow_hashref();
			$sth->finish;
			$connector->destroy();
			return $row;
		} else {
			$sth->finish;
			$connector->destroy();
			return 0;
		}
	} catch {
		return 0;
	}
}

sub queueMe {
	my $self = shift;
	my $connector = Trate::Lib::ConnectorMariaDB->new();
	my $queue = sprintf "UPDATE ci_pases SET status='%s', supervisor='%s', observaciones='%s', litros_real=CASE WHEN litros_real IS NULL THEN %.4f ELSE litros_real + %.4f END WHERE pase=%d", $self->{STATUS}, $self->{SUPERVISOR}, $self->{OBSERVACIONES}, $self->{LITROS_REAL}, $self->{LITROS_REAL}, $self->{PASE};
	LOGGER->debug("Encolando sql[ ", $queue, " ]");
	my $preps = "INSERT INTO errores_sql_informix VALUES (NULL,\"" . $queue . "\",NOW())";
	LOGGER->debug("Ejecutando sql[ ", $preps, " ]");
	my $sth = $connector->dbh->prepare($preps);
    $sth->execute() or die LOGGER->fatal("NO PUDO EJECUTAR EL SIGUIENTE COMANDO en MARIADB:orpak: $preps");
    $sth->finish;
	$connector->destroy();
	return $self;		
}

sub getPaseByPase {
	my $self = shift;
	my $connector = Trate::Lib::ConnectorMariaDB->new();
	my $preps = "SELECT
					pase as pase_id,
					fecha_solicitud,
					viaje,
					camion,
					chofer,
					litros,
					contingencia,
					status,
					litros_real,
					mean_contingencia
				FROM
					ci_pases
				WHERE
					(pase='" . $self->{PASE} . "')
				ORDER BY
					fecha_solicitud
				DESC";
	LOGGER->debug("Ejecutando sql[ ", $preps, " ]");
	try {
		my $sth = $connector->dbh->prepare($preps);
		$sth->execute() or die LOGGER->fatal("NO PUDO EJECUTAR EL SIGUIENTE COMANDO en MARIADB:orpak: $preps");
		if ($sth->rows gt 0) {		
			my $row = $sth->fetchrow_hashref();
			$sth->finish;
			$connector->destroy();
			return $row;
		} else {
			$sth->finish;
			$connector->destroy();
			return 0;
		}
	} catch {
		return 0;
	}
}

1;
#EOF
