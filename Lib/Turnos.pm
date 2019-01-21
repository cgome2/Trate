package Trate::Lib::Turnos;

use strict;
use Trate::Lib::Constants qw(LOGGER);
use Trate::Lib::BombaTurno;
use Trate::Lib::TanqueTurno;
use Trate::Lib::MeanTurno;
use Data::Dump qw(dump);
use Data::Structure::Util qw( unbless );


sub new
{
	my $self = {};
	$self->{ID_TURNO} = undef;
	$self->{FECHA_ABIERTO} = undef;
	$self->{USUARIO_ABRE} = undef;
	$self->{FECHA_CERRADO} = undef; 
	$self->{USUARIO_CIERRA} = undef; 
	$self->{STATUS} = undef;
	$self->{BOMBAS_TURNO} = [];
	$self->{MEANS_TURNO} = [];
	$self->{TANQUES_TURNO} = [];

	bless($self);
	return $self;	
}

sub idTurno {
        my ($self) = shift;
        if (@_) { $self->{ID_TURNO} = shift }        
        return $self->{ID_TURNO};
}

sub fechaAbierto {
        my ($self) = shift;
        if (@_) { $self->{FECHA_ABIERTO} = shift }        
        return $self->{FECHA_ABIERTO};
}

sub usuarioAbre {
        my ($self) = shift;
        if (@_) { $self->{USUARIO_ABRE} = shift }        
        return $self->{USUARIO_ABRE};
}

sub fechaCerrado {
        my ($self) = shift;
        if (@_) { $self->{FECHA_CERRADO} = shift }        
        return $self->{FECHA_CERRADO};
}

sub usuarioCierra {
        my ($self) = shift;
        if (@_) { $self->{USUARIO_CIERRA} = shift }        
        return $self->{USUARIO_CIERRA};
}

sub status {
        my ($self) = shift;
        if (@_) { $self->{STATUS} = shift }        
        return $self->{STATUS};
}

sub bombasTurno {
    my ($self) = shift;
    if (@_) { $self->{BOMBAS_TURNO} = shift }        
    return @{$self->{BOMBAS_TURNO}};
}

sub meansTurno {
    my ($self) = shift;
    if (@_) { $self->{MEANS_TURNO} = shift }        
    return @{$self->{MEANS_TURNO}};
}

sub tanquesTurno {
    my ($self) = shift;
    if (@_) { $self->{TANQUES_TURNO} = shift }        
    return @{$self->{TANQUES_TURNO}};
}

sub abrirTurno {
	my $self = shift;
	my $connector = Trate::Lib::ConnectorMariaDB->new();
	my $result = 0;
	my $preps = "
		INSERT INTO turnos (fecha_abierto,usuario_abre,status) VALUES ('" . 
			$self->{FECHA_ABIERTO} . "','" .
			$self->{USUARIO_ABRE} . "','" .
			$self->{STATUS} . "')";
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

sub getFromTimestamp($) {
	my $self = shift;
	my $timestamp = pop;
	my $connector = Trate::Lib::ConnectorMariaDB->new();
	
	my $prepsCurrentTurno = "SELECT * FROM turnos WHERE " . 
							"(fecha_cierre IS NULL and status = 2 AND '" . $timestamp . "'>=fecha_abierto) " . 
							"OR (fecha_cierre IS NOT NULL and status=1 AND '" . $timestamp . "'>=fecha_abierto and '" . $timestamp . "'<=fecha_cierre)";
	LOGGER->debug("Ejecutando sql[ ", $prepsCurrentTurno, " ]");
	my $sth = $connector->dbh->prepare($prepsCurrentTurno);
	$sth->execute() or die LOGGER->fatal("NO PUDO EJECUTAR EL SIGUIENTE COMANDO en MARIADB:orpak: $prepsCurrentTurno");
	my $rows = $sth->rows;
	if($rows eq 1){
		my $row = $sth->fetchrow_hashref();
		$self->{ID_TURNO} = $row->{'id_turno'};
		$self->{FECHA_ABIERTO} = $row->{'fecha_abierto'};
		$self->{USUARIO_ABRE} = $row->{'usuario_abre'};
		$self->{FECHA_CERRADO} = $row->{'fecha_cerrado'}; 
		$self->{USUARIO_CIERRA} = $row->{'usuario_cierra'}; 
		$self->{STATUS} = $row->{'status'};
	} elsif ($rows > 1){
		LOGGER->debug("La tabla de turnos contiene más de un turno con ese periodo");
		$self->{ID_TURNO} = 0;
		$self->{FECHA_ABIERTO} = "";
		$self->{USUARIO_ABRE} = 0;
		$self->{FECHA_CERRADO} = ""; 
		$self->{USUARIO_CIERRA} = ""; 
		$self->{STATUS} = 0;
	} else {
		LOGGER->debug("No existe turno que cubra ese periodo");
		$self->{ID_TURNO} = 0;
		$self->{FECHA_ABIERTO} = "";
		$self->{USUARIO_ABRE} = 0;
		$self->{FECHA_CERRADO} = ""; 
		$self->{USUARIO_CIERRA} = ""; 
		$self->{STATUS} = 0;
	}
	LOGGER->debug(dump($self));
	return $self;
}

sub getTurnos {
	my $self = shift;
	
	my $connector = Trate::Lib::ConnectorMariaDB->new();
	my $connectorBombas = Trate::Lib::ConnectorMariaDB->new();
	my $connectorTanques = Trate::Lib::ConnectorMariaDB->new();
	my $connectorMeans = Trate::Lib::ConnectorMariaDB->new();
	my $preps = "SELECT * FROM turnos ORDER BY id_turno DESC LIMIT 50"; 
	my $prepsBombas;
	my $sthBombas;
	my $prepsTanques;
	my $sthTanques;
	my $prepsMeans;
	my $sthMeans;

	LOGGER->debug("Ejecutando sql[ ", $preps, " ]");
	my $sth = $connector->dbh->prepare($preps);
	$sth->execute() or die LOGGER->fatal("NO PUDO EJECUTAR EL SIGUIENTE COMANDO en MARIADB:orpak: $preps");
	my @turnos;
	my $bombaTurno = Trate::Lib::BombaTurno->new();
	my $tanqueTurno = Trate::Lib::TanqueTurno->new();
	my $meanTurno = Trate::Lib::MeanTurno->new();

	while (my $ref = $sth->fetchrow_hashref()) {
		my %turno = ();

		$prepsBombas = "SELECT * FROM turno_bombas WHERE id_turno = '" . $ref->{id_turno} . "'";
		$sthBombas = $connector->dbh->prepare($prepsBombas);
		$sthBombas->execute() or die LOGGER->fatal("NO PUDO EJECUTAR EL SIGUIENTE COMANDO en MARIADB:orpak: $prepsBombas");
		my @bombasTurno = ();
		while (my $b = $sthBombas->fetchrow_hashref()){
			$bombaTurno = Trate::Lib::BombaTurno->new();
			$bombaTurno->idTurno($b->{id_turno});
			$bombaTurno->idBomba($b->{id_bomba});
			$bombaTurno->idManguera($b->{id_manguera});
			$bombaTurno->totalizadorAlAbrir($b->{totalizador_al_abrir});
			$bombaTurno->totalizadorAlCerrar($b->{totalizador_al_cerrar});
			$bombaTurno->timestampAbrir($b->{timestamp_abrir});
			$bombaTurno->timestampCerrar($b->{timestamp_cerrar});
			unbless($bombaTurno);
			push @bombasTurno,$bombaTurno;
		}

		$prepsTanques = "SELECT * FROM turno_tanques WHERE id_turno = '" . $ref->{id_turno} . "'";
		$sthTanques = $connector->dbh->prepare($prepsTanques);
		$sthTanques->execute() or die LOGGER->fatal("NO PUDO EJECUTAR EL SIGUIENTE COMANDO en MARIADB:orpak: $prepsTanques");
		my @tanquesTurno = ();
		while (my $t = $sthTanques->fetchrow_hashref()){
			$tanqueTurno = Trate::Lib::TanqueTurno->new();
			$tanqueTurno->idTurno($t->{id_turno});
			$tanqueTurno->tankId($t->{tank_id});
			$tanqueTurno->volumenInicial($t->{volumen_inicial});
			$tanqueTurno->volumenFinal($t->{volumen_final});
			$tanqueTurno->timestampInicial($t->{timestamp_inicial});
			$tanqueTurno->timestampFinal($t->{timestamp_final});
			unbless($tanqueTurno);			
			push @tanquesTurno,$tanqueTurno;
		}

		$prepsMeans = "SELECT * FROM turno_means WHERE id_turno = '" . $ref->{id_turno} . "'";
		$sthMeans = $connector->dbh->prepare($prepsMeans);
		$sthMeans->execute() or die LOGGER->fatal("NO PUDO EJECUTAR EL SIGUIENTE COMANDO en MARIADB:orpak: $prepsMeans");
		my @meansTurno = ();
		while (my $m = $sthMeans->fetchrow_hashref()){
			$meanTurno = Trate::Lib::MeanTurno->new();
			$meanTurno->idTurno($m->{id_turno});
			$meanTurno->meanId($m->{mean_id});
			$meanTurno->timestampAdd($m->{timestamp_add});
			$meanTurno->timestampRm($m->{timestamp_rm});
			$meanTurno->usuarioAdd($m->{usuario_add});
			$meanTurno->usuarioRm($m->{usuario_rm});
			unbless($meanTurno);
			push @meansTurno,$meanTurno;
		}
		
		%turno = (
			"id_turno" => $ref->{id_turno},
			"fecha_abierto" => $ref->{fecha_abierto},
			"usuario_abre" => $ref->{usuario_abre},
			"fecha_cierre" => $ref->{fecha_cierre},
			"usuario_cierra" => $ref->{usuario_cierra},
			"status" => $ref->{status}
		);
		$turno{BOMBAS_TURNO} = \@bombasTurno;
		$turno{TANQUES_TURNO} = \@tanquesTurno;
		$turno{MEANS_TURNO} = \@meansTurno;
		
    	push @turnos,\%turno;
	}
	$sth->finish;
	$connector->destroy();
	return \@turnos;		
}

sub getTurnoFromId {
	my $self = shift;
	
	my $connector = Trate::Lib::ConnectorMariaDB->new();
	my $connectorBombas = Trate::Lib::ConnectorMariaDB->new();
	my $connectorTanques = Trate::Lib::ConnectorMariaDB->new();
	my $connectorMeans = Trate::Lib::ConnectorMariaDB->new();
	my $preps = "SELECT * FROM turnos WHERE id_turno='" . $self->{ID_TURNO} . "'"; 
	my $prepsBombas;
	my $sthBombas;
	my $prepsTanques;
	my $sthTanques;
	my $prepsMeans;
	my $sthMeans;

	LOGGER->debug("Ejecutando sql[ ", $preps, " ]");
	my $sth = $connector->dbh->prepare($preps);
	$sth->execute() or die LOGGER->fatal("NO PUDO EJECUTAR EL SIGUIENTE COMANDO en MARIADB:orpak: $preps");
	my @turnos;
	my $bombaTurno = Trate::Lib::BombaTurno->new();
	my $tanqueTurno = Trate::Lib::TanqueTurno->new();
	my $meanTurno = Trate::Lib::MeanTurno->new();

	while (my $ref = $sth->fetchrow_hashref()) {
		my %turno = ();

		$prepsBombas = "SELECT * FROM turno_bombas WHERE id_turno = '" . $ref->{id_turno} . "'";
		$sthBombas = $connector->dbh->prepare($prepsBombas);
		$sthBombas->execute() or die LOGGER->fatal("NO PUDO EJECUTAR EL SIGUIENTE COMANDO en MARIADB:orpak: $prepsBombas");
		my @bombasTurno = ();
		while (my $b = $sthBombas->fetchrow_hashref()){
			$bombaTurno = Trate::Lib::BombaTurno->new();
			$bombaTurno->idTurno($b->{id_turno});
			$bombaTurno->idBomba($b->{id_bomba});
			$bombaTurno->idManguera($b->{id_manguera});
			$bombaTurno->totalizadorAlAbrir($b->{totalizador_al_abrir});
			$bombaTurno->totalizadorAlCerrar($b->{totalizador_al_cerrar});
			$bombaTurno->timestampAbrir($b->{timestamp_abrir});
			$bombaTurno->timestampCerrar($b->{timestamp_cerrar});
			unbless($bombaTurno);
			push @bombasTurno,$bombaTurno;
		}

		$prepsTanques = "SELECT * FROM turno_tanques WHERE id_turno = '" . $ref->{id_turno} . "'";
		$sthTanques = $connector->dbh->prepare($prepsTanques);
		$sthTanques->execute() or die LOGGER->fatal("NO PUDO EJECUTAR EL SIGUIENTE COMANDO en MARIADB:orpak: $prepsTanques");
		my @tanquesTurno = ();
		while (my $t = $sthTanques->fetchrow_hashref()){
			$tanqueTurno = Trate::Lib::TanqueTurno->new();
			$tanqueTurno->idTurno($t->{id_turno});
			$tanqueTurno->tankId($t->{tank_id});
			$tanqueTurno->volumenInicial($t->{volumen_inicial});
			$tanqueTurno->volumenFinal($t->{volumen_final});
			$tanqueTurno->timestampInicial($t->{timestamp_inicial});
			$tanqueTurno->timestampFinal($t->{timestamp_final});
			unbless($tanqueTurno);			
			push @tanquesTurno,$tanqueTurno;
		}

		$prepsMeans = "SELECT * FROM turno_means WHERE id_turno = '" . $ref->{id_turno} . "'";
		$sthMeans = $connector->dbh->prepare($prepsMeans);
		$sthMeans->execute() or die LOGGER->fatal("NO PUDO EJECUTAR EL SIGUIENTE COMANDO en MARIADB:orpak: $prepsMeans");
		my @meansTurno = ();
		while (my $m = $sthMeans->fetchrow_hashref()){
			$meanTurno = Trate::Lib::MeanTurno->new();
			$meanTurno->idTurno($m->{id_turno});
			$meanTurno->meanId($m->{mean_id});
			$meanTurno->timestampAdd($m->{timestamp_add});
			$meanTurno->timestampRm($m->{timestamp_rm});
			$meanTurno->usuarioAdd($m->{usuario_add});
			$meanTurno->usuarioRm($m->{usuario_rm});
			unbless($meanTurno);
			push @meansTurno,$meanTurno;
		}
		
		%turno = (
			"id_turno" => $ref->{id_turno},
			"fecha_abierto" => $ref->{fecha_abierto},
			"usuario_abre" => $ref->{usuario_abre},
			"fecha_cierre" => $ref->{fecha_cierre},
			"usuario_cierra" => $ref->{usuario_cierra},
			"status" => $ref->{status}
		);
		$turno{BOMBAS_TURNO} = \@bombasTurno;
		$turno{TANQUES_TURNO} = \@tanquesTurno;
		$turno{MEANS_TURNO} = \@meansTurno;
		
    	push @turnos,\%turno;
	}
	$sth->finish;
	$connector->destroy();
	return \@turnos;	
}

1;
#EOF