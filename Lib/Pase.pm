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

sub new
{
	my $self = {};
	$self->{FECHA_SOLICITUD} = undef;
	$self->{PASE} = '';
	$self->{VIAJE} = undef;
	$self->{CAMION} = undef;
	$self->{CHOFER} = undef;
	$self->{LITROS} = undef;
	$self->{CONTINGENCIA} = undef;
	$self->{STATUS} = undef;
	$self->{LITROS_REAL} = undef;
	$self->{LITROS_ESP} = undef;
	$self->{VIAJE_SUST} = undef;
	$self->{SUPERVISOR} = '';
	$self->{OBSERVACIONES} = '';
	$self->{ULTIMA_MODIFICACION} = undef;
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

sub getFromId(){
	my $self = shift;
	my $pase = shift;

	$self->{PASE} = $pase;
	my $id;
	my $connector = Trate::Lib::ConnectorMariaDB->new();
	my $preps = "SELECT * FROM ci_pases WHERE pase = '" . $self->{PASE} . "'";
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
	my $connector = Trate::Lib::Informix->new();
	my $preps = sprintf "UPDATE ci_pases SET status='%s', supervisor=%d, observaciones='%s', litros_real=CASE WHEN litros_real IS NULL THEN %.4f ELSE litros_real + %.4f END WHERE pase=%d", $self->{STATUS}, $self->{SUPERVISOR}, $self->{OBSERVACIONES}, $self->{LITROS_REAL}, $self->{LITROS_REAL}, $self->{PASE};
	LOGGER->debug("Ejecutando sql[ ", $preps, " ]");
	my $sth = $connector->dbh->prepare($preps);
    $sth->execute() or die LOGGER->fatal("NO PUDO EJECUTAR EL SIGUIENTE COMANDO en MARIADB:orpak: $preps");
    $sth->finish;
	$connector->destroy();
	return $self;
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

sub borraPaseMariaDB{
	#PLEASE IMPLEMENT ME
}

sub borraPaseInformix{
	#PLEASE IMPLEMENT ME
}

sub actualiza{
	my $self = shift;
	actualizaMDB($self);
	#actualizaInformix($self);
}

1;
#EOF