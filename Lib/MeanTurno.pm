package Trate::Lib::MeanTurno;

use strict;
use Trate::Lib::Constants qw(LOGGER);

sub new
{
	my $self = {};
	$self->{ID_TURNO} = undef;
	$self->{MEAN_ID} = undef;
	$self->{TIMESTAMP_ADD} = undef; 
	$self->{TIMESTAMP_RM} = undef; 
	$self->{ID_USUARIO_ADD} = undef;
	$self->{USUARIO_ADD} = undef;
	$self->{ID_USUARIO_RM} = undef;
	$self->{USUARIO_RM} = undef;
        $self->{STATUS_MEAN_TURNO} = undef;

	bless($self);
	return $self;	
}

sub idTurno {
        my ($self) = shift;
        if (@_) { $self->{ID_TURNO} = shift }        
        return $self->{ID_TURNO};
}

sub meanId {
        my ($self) = shift;
        if (@_) { $self->{MEAN_ID} = shift }        
        return $self->{MEAN_ID};
}

sub timestampAdd {
        my ($self) = shift;
        if (@_) { $self->{TIMESTAMP_ADD} = shift }        
        return $self->{TIMESTAMP_ADD};
}

sub timestampRm {
        my ($self) = shift;
        if (@_) { $self->{TIMESTAMP_RM} = shift }        
        return $self->{TIMESTAMP_RM};
}

sub usuarioAdd {
        my ($self) = shift;
        if (@_) { $self->{USUARIO_ADD} = shift }        
        return $self->{USUARIO_ADD};
}

sub idUsuarioAdd {
        my ($self) = shift;
        if (@_) { $self->{ID_USUARIO_ADD} = shift }        
        return $self->{ID_USUARIO_ADD};
}

sub usuarioRm {
        my ($self) = shift;
        if (@_) { $self->{USUARIO_RM} = shift }        
        return $self->{USUARIO_RM};
}

sub idUsuarioRm {
        my ($self) = shift;
        if (@_) { $self->{ID_USUARIO_RM} = shift }        
        return $self->{ID_USUARIO_RM};
}

sub statusMeanTurno {
        my ($self) = shift;
        if (@_) { $self->{STATUS_MEAN_TURNO} = shift }        
        return $self->{STATUS_MEAN_TURNO};
}

sub insertar {
	my $self = shift;
	my $connector = Trate::Lib::ConnectorMariaDB->new();
	my $result = 0;
	my $preps = "
		INSERT INTO turno_means (id_turno,mean_id,timestamp_add,id_usuario_add,status_mean_turno) VALUES ('" . 
			$self->{ID_TURNO} . "','" .
                        $self->{MEAN_ID} . "'," .
                        "NOW()," .
			(length($self->{ID_USUARIO_ADD}) gt 0 ? ("'" . $self->{ID_USUARIO_ADD} . "'") : "NULL") . ",'" .
			$self->{STATUS_MEAN_TURNO} . "')";
	LOGGER->debug("Ejecutando sql[ ", $preps, " ]");
	my $sth = $connector->dbh->prepare($preps);
	$sth->execute() or die LOGGER->fatal("NO PUDO EJECUTAR EL SIGUIENTE COMANDO en MARIADB:orpak: $preps");
	$sth->finish;
	$connector->destroy();
}


1;
#EOF
