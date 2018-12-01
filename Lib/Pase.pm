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

sub psInsertarPaseMariaDB {
	my $self = shift;

	my $preps = 	"INSERT INTO ci_pases VALUES(NULL,'" .
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

sub getFromCamion(){
	my $self = shift;
	$self->{CAMION} = shift;
	$self->{FECHA_SOLICITUD} = shift;

	my $id = 0;
	my $connector = Trate::Lib::ConnectorMariaDB->new();
	my $preps = "SELECT * FROM ci_pases WHERE camion = '" . $self->{CAMION} . "' AND fecha_solicitud < '" . $self->{FECHA_SOLICITUD} . "' AND status IN ('A','R') ORDER BY fecha_solicitud DESC LIMIT 1";
	LOGGER->debug("Ejecutando sql[ ", $preps, " ]");
	my $sth = $connector->dbh->prepare($preps);
    $sth->execute() or die LOGGER->fatal("NO PUDO EJECUTAR EL SIGUIENTE COMANDO en MARIADB:orpak: $preps");

	(
	$id,
	$self->{FECHA_SOLICITUD},
	$self->{PASE},
	$self->{VIAJE},
	$self->{CAMION},
	$self->{CHOFER},
	$self->{LITROS},
	$self->{CONTINGENCIA},
	$self->{STATUS},
	$self->{LITROS_REAL},
	$self->{LITROS_ESP},
	$self->{VIAJE_SUST},
	$self->{SUPERVISOR},
	$self->{OBSERVACIONES},
	$self->{ULTIMA_MODIFICACION}
	) = $sth->fetchrow_array;
	$sth->finish;
	$connector->destroy();
	return $self;	
}

sub insertarPaseInformix {
	#PLEASE IMPLEMENT ME 8-)
}

sub actualizaInformix {
	my $self = shift;
	my $return = 0;
	my $connector = Trate::Lib::ConnectorInformix->new();
	my $preps = sprintf "UPDATE ci_pases SET status='%s', supervisor=%d, observaciones='%s', litros_real=CASE WHEN litros_real IS NULL THEN %.4f ELSE litros_real + %.4f END WHERE pase=%d", $self->{STATUS}, $self->{SUPERVISOR}, $self->{OBSERVACIONES}, $self->{LITROS_REAL}, $self->{LITROS_REAL}, $self->{PASE};
	LOGGER->debug("Ejecutando sql[ ", $preps, " ]");
	try {			
		my $sth;
		$sth = $connector->dbh->prepare($preps) or die(LOGGER->fatal("NO SE PUDO CONECTAR A INFORMIX:master"));
	    $sth->execute() or die LOGGER->fatal("NO PUDO EJECUTAR EL SIGUIENTE COMANDO en INFORMIX:orpak: $preps");
	    $sth->finish;
		$connector->destroy();
		$return = 1;		
	} catch {
		$return = 0;
	} finally {
		return $return;
	};
}


sub actualizaMDB{
	my $self = shift;
	my $connector = Trate::Lib::ConnectorMariaDB->new();
	my $preps = sprintf "UPDATE ci_pases SET status='%s', supervisor='%s', observaciones='%s', litros_real=CASE WHEN litros_real IS NULL THEN %.4f ELSE litros_real + %.4f END WHERE pase=%d", $self->{STATUS}, $self->{SUPERVISOR}, $self->{OBSERVACIONES}, $self->{LITROS_REAL}, $self->{LITROS_REAL}, $self->{PASE};
	LOGGER->debug("Ejecutando sql[ ", $preps, " ]");
	my $sth = $connector->dbh->prepare($preps);
    $sth->execute() or die LOGGER->fatal("NO PUDO EJECUTAR EL SIGUIENTE COMANDO en MARIADB:orpak: $preps");
    $sth->finish;
	$connector->destroy();
	return $self;	
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

sub borraPaseMariaDB{
	#PLEASE IMPLEMENT ME
}

sub borraPaseInformix{
	#PLEASE IMPLEMENT ME
}

sub actualiza{
	my $self = shift;
	actualizaMDB($self);
	#actualizaInformix($self); Deprecated now its a trigger from mariadb
}

sub GET{
    my ( $self , $req , $resp ) = @_ ;
    
    $resp->data()->{'pase_message'} = 'Yoadfadsfng user '.$self->paseid() ;
    $resp->data()->{'pase'} = {
        'name' => "\x{111}\x{103}ng t\x{1ea3}i t\x{1ea1}i",
        'id' => '30001' ,
    };
    return Apache2::Const::HTTP_OK ;
}



1;
#EOF