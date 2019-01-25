package Trate::Lib::Turnos;

use strict;
use Trate::Lib::Constants qw(LOGGER);
use Trate::Lib::Bombas;
use Trate::Lib::BombaTurno;
use Trate::Lib::TanqueTurno;
use Trate::Lib::MeanTurno;
use Data::Dump qw(dump);
use Data::Structure::Util qw( unbless );
use Trate::Lib::Utilidades;


sub new
{
	my $self = {};
	$self->{ID_TURNO} = undef;
	$self->{FECHA_ABIERTO} = undef;
	$self->{ID_USUARIO_ABRE} = undef;
	$self->{USUARIO_ABRE} = undef;
	$self->{FECHA_CERRADO} = undef; 
	$self->{ID_USUARIO_CIERRA} = undef; 
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

sub idUsuarioAbre {
        my ($self) = shift;
        if (@_) { $self->{ID_USUARIO_ABRE} = shift }        
        return $self->{ID_USUARIO_ABRE};
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

sub idUsuarioCierra {
        my ($self) = shift;
        if (@_) { $self->{ID_USUARIO_CIERRA} = shift }        
        return $self->{ID_USUARIO_CIERRA};
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
		INSERT INTO turnos (id_turno,fecha_abierto,id_usuario_abre,status) VALUES ('" . 
			$self->{ID_TURNO} . "'," .
			"NOW(),'" .
			$self->{ID_USUARIO_ABRE} . "','" .
			$self->{STATUS} . "')";
	LOGGER->debug("Ejecutando sql[ ", $preps, " ]");
	try {
		my $sth = $connector->dbh->prepare($preps);
		$sth->execute() or die LOGGER->fatal("NO PUDO EJECUTAR EL SIGUIENTE COMANDO en MARIADB:orpak: $preps");
		$sth->finish;
		$connector->destroy();
		
	} catch {
		return 0;
	}	
}

sub getFromTimestamp($) {
	my $self = shift;
	my $timestamp = pop;
	my $connector = Trate::Lib::ConnectorMariaDB->new();
	
	my $prepsCurrentTurno = "SELECT t.*,u.numero_empleado AS usuario_abre, u.numero_empleado AS usuario_cierra  " .
							"FROM turnos t LEFT JOIN usuarios u ON t.id_usuario_abre = u.idusuarios " .
							"LEFT JOIN usuarios u2 ON t.id_usuario_cierra = u2.idusuarios " .
							"WHERE (t.fecha_cierre IS NULL and t.status = 2 AND '" . $timestamp . "'>=t.fecha_abierto) " .
							"OR (t.fecha_cierre IS NOT NULL and t.status=1 AND '" . $timestamp . "'>=t.fecha_abierto AND '" . $timestamp . "'<=t.fecha_cierre)";	
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

sub getTurnosById {
	my $self = shift;
	
	my $connector = Trate::Lib::ConnectorMariaDB->new();
	my $connectorBombas = Trate::Lib::ConnectorMariaDB->new();
	my $connectorTanques = Trate::Lib::ConnectorMariaDB->new();
	my $connectorMeans = Trate::Lib::ConnectorMariaDB->new();
	my $preps = " SELECT t.*,ua.nombre as usuario_abre,uc.nombre as usuario_cierra " . 
				" FROM turnos t LEFT JOIN usuarios ua ON t.id_usuario_abre = ua.idusuarios " .
				" LEFT JOIN usuarios uc ON t.id_usuario_cierra=uc.idusuarios" .
				" ORDER BY id_turno DESC LIMIT 50"; 
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
			$bombaTurno->idManguera($b->{bomba});
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
			$tanqueTurno->tankName($t->{tank_name});
			$tanqueTurno->volumenInicial($t->{volumen_inicial});
			$tanqueTurno->volumenFinal($t->{volumen_final});
			$tanqueTurno->timestampInicial($t->{timestamp_inicial});
			$tanqueTurno->timestampFinal($t->{timestamp_final});
			unbless($tanqueTurno);			
			push @tanquesTurno,$tanqueTurno;
		}

		$prepsMeans = "SELECT tm.*,m.NAME AS despachador,u.numero_empleado AS usuario_add,u2.numero_empleado AS usuario_rm " .
						" FROM turno_means tm LEFT JOIN means m ON tm.mean_id=m.id " .
						" LEFT JOIN usuarios u ON tm.id_usuario_add = u.idusuarios " .
						" LEFT JOIN usuarios u2 ON tm.id_usuario_rm = u2.idusuarios " .
						" WHERE tm.id_turno = '" . $ref->{id_turno} . "'";
		$sthMeans = $connector->dbh->prepare($prepsMeans);
		$sthMeans->execute() or die LOGGER->fatal("NO PUDO EJECUTAR EL SIGUIENTE COMANDO en MARIADB:orpak: $prepsMeans");
		my @meansTurno = ();
		while (my $m = $sthMeans->fetchrow_hashref()){
			$meanTurno = Trate::Lib::MeanTurno->new();
			$meanTurno->idTurno($m->{id_turno});
			$meanTurno->meanId($m->{mean_id});
			$meanTurno->timestampAdd($m->{timestamp_add});
			$meanTurno->timestampRm($m->{timestamp_rm});
			$meanTurno->idUsuarioAdd($m->{id_usuario_add});
			$meanTurno->idUsuarioRm($m->{id_usuario_rm});
			unbless($meanTurno);
			$meanTurno->{'despachador'} = $m->{'despachador'};
			$meanTurno->{'usuario_add'} = $m->{'usuario_add'};
			$meanTurno->{'usuario_rm'} = $m->{'usuario_rm'};
			push @meansTurno,$meanTurno;
		}
		
		%turno = (
			"id_turno" => $ref->{id_turno},
			"fecha_abierto" => $ref->{fecha_abierto},
			"id_usuario_abre" => $ref->{id_usuario_abre},
			"usuario_abre" => $ref->{usuario_abre},
			"fecha_cierre" => $ref->{fecha_cierre},
			"id_usuario_cierra" => $ref->{id_usuario_cierra},
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

sub getTurnos {
	my $self = shift;
	my $date = shift;
	my $sort = shift;
	my $order = shift;

	my $where_statement = "";

	if(defined($date) && length($date) gt 1){
		$where_statement .= "WHERE fecha_abierto LIKE '" . $date . "%' OR fecha_cierre LIKE '" . $date . "%'";
	}

	if(length($sort) gt 0 && defined $sort){
		$where_statement .= " ORDER BY $sort " . ((defined($sort) && ($order eq "ASC" || $order eq "DESC")) ? $order : "DESC");
	}
	

	LOGGER->debug("PARAMETROS: " . $date . " " . $sort . " " . $order . " - " . $where_statement);

	my $connector = Trate::Lib::ConnectorMariaDB->new();
	my $preps = " SELECT t.*,ua.nombre as usuario_abre,uc.nombre as usuario_cierra " . 
				" FROM turnos t LEFT JOIN usuarios ua ON t.id_usuario_abre = ua.idusuarios " .
				" LEFT JOIN usuarios uc ON t.id_usuario_cierra=uc.idusuarios " . $where_statement;

	LOGGER->debug("Ejecutando sql[ ", $preps, " ]");
	my $sth = $connector->dbh->prepare($preps);
	$sth->execute() or die LOGGER->fatal("NO PUDO EJECUTAR EL SIGUIENTE COMANDO en MARIADB:orpak: $preps");
	my @turnos;

	while (my $ref = $sth->fetchrow_hashref()) {
		my %turno = ();
		%turno = (
			"id_turno" => $ref->{id_turno},
			"fecha_abierto" => $ref->{fecha_abierto},
			"id_usuario_abre" => $ref->{id_usuario_abre},
			"usuario_abre" => $ref->{usuario_abre},
			"fecha_cierre" => $ref->{fecha_cierre},
			"id_usuario_cierra" => $ref->{id_usuario_cierra},
			"usuario_cierra" => $ref->{usuario_cierra},
			"status" => $ref->{status}
		);
		
    	push @turnos,\%turno;
	}
	$sth->finish;
	$connector->destroy();
	return \@turnos;		
}

sub getTurno {
	my $self = shift;
	my $where_statement = shift;
	
	my $connector = Trate::Lib::ConnectorMariaDB->new();
	my $connectorBombas = Trate::Lib::ConnectorMariaDB->new();
	my $connectorTanques = Trate::Lib::ConnectorMariaDB->new();
	my $connectorMeans = Trate::Lib::ConnectorMariaDB->new();
	my $preps = "SELECT t.*,u.numero_empleado AS usuario_abre,u2.numero_empleado AS usuario_cierra " .
				" FROM turnos t LEFT JOIN usuarios u ON t.id_usuario_abre = u.idusuarios " .
				" LEFT JOIN usuarios u2 ON t.id_usuario_cierra = u2.idusuarios " . $where_statement . " LIMIT 1"; 
	my $prepsBombas;
	my $sthBombas;
	my $prepsTanques;
	my $sthTanques;
	my $prepsMeans;
	my $sthMeans;

	my $sth = $connector->dbh->prepare($preps);
	$sth->execute() or die LOGGER->fatal("NO PUDO EJECUTAR EL SIGUIENTE COMANDO en MARIADB:orpak: $preps");
	my $turno = $sth->fetchrow_hashref();
	if(!$turno){
		return [];
	}
	my @turnos;
	my $bombaTurno = Trate::Lib::BombaTurno->new();
	my $tanqueTurno = Trate::Lib::TanqueTurno->new();
	my $meanTurno = Trate::Lib::MeanTurno->new();

	$prepsBombas = "SELECT * FROM turno_bombas WHERE id_turno=" . $turno->{id_turno};
	$sthBombas = $connector->dbh->prepare($prepsBombas);
	$sthBombas->execute() or die LOGGER->fatal("NO PUDO EJECUTAR EL SIGUIENTE COMANDO en MARIADB:orpak: $prepsBombas");
	my @bombasTurno = ();

	while (my $b = $sthBombas->fetchrow_hashref()){
		push @bombasTurno, $b;
	}

	$turno->{BOMBAS_TURNO} = \@bombasTurno;


	$prepsTanques = "SELECT * FROM turno_tanques WHERE id_turno=" . $turno->{id_turno};
	$sthTanques = $connector->dbh->prepare($prepsTanques);
	$sthTanques->execute() or die LOGGER->fatal("NO PUDO EJECUTAR EL SIGUIENTE COMANDO en MARIADB:orpak: $prepsTanques");
	my @tanquesTurno = ();
	while (my $t = $sthTanques->fetchrow_hashref()){
		push @tanquesTurno,$t;
	}

	$turno->{TANQUES_TURNO} = \@tanquesTurno;

	$prepsMeans = "SELECT tm.*,m.NAME AS despachador,u.numero_empleado AS usuario_add,u2.numero_empleado AS usuario_rm " .
					" FROM turno_means tm LEFT JOIN means m ON tm.mean_id=m.id " .
					" LEFT JOIN usuarios u ON tm.id_usuario_add = u.idusuarios " .
					" LEFT JOIN usuarios u2 ON tm.id_usuario_rm = u2.idusuarios " .
					" WHERE tm.id_turno=" . $turno->{id_turno};
	LOGGER->debug("Ejecutando sql[ ", $prepsMeans, " ]");
	$sthMeans = $connector->dbh->prepare($prepsMeans);
	$sthMeans->execute() or die LOGGER->fatal("NO PUDO EJECUTAR EL SIGUIENTE COMANDO en MARIADB:orpak: $prepsMeans");
	my @meansTurno = ();
	while (my $m = $sthMeans->fetchrow_hashref()){
		push @meansTurno,$m;
	}
		
	$turno->{MEANS_TURNO} = \@meansTurno;
		
	return $turno;
}

sub getLastTankReadings{
	my $self = shift;
	my @tanques = [
		{"tank_id" => 1, "tank_name" => "Magna1", "totalizador_volumen" => 87210.21}
	];
	return \@tanques;
}

sub insertOpenTotalizerReadings{
	my $self = shift;
	my $connector = Trate::Lib::ConnectorMariaDB->new();
	my $result = 0;
	my $bombas = Trate::Lib::Bombas->new();
	my $obombas = $bombas->getBombas();
	my @pumps = @{$obombas};
	LOGGER->debug(dump(\@pumps));
	my %pumphash;
	my $now = Trate::Lib::Utilidades->getCurrentTimestampMariaDB();
	foreach my $pump (@pumps){
		%pumphash = ();
		my $preps = "INSERT INTO turno_bombas (id_turno,id_bomba,bomba,totalizador_al_abrir,timestamp_abrir) " .
			" VALUES ('" .
				$self->{ID_TURNO} . "','" .
				$pump->{ID} . "','" .
				$pump->{PUMP_HEAD} . "','" .
				$pump->{TOTALIZADOR} . "','" .
				$now . "')";
		LOGGER->debug("Ejecutando sql[ ", $preps, " ]");
		my $sth = $connector->dbh->prepare($preps);
		$sth->execute() or die LOGGER->fatal("NO PUDO EJECUTAR EL SIGUIENTE COMANDO en MARIADB:orpak: $preps");
		$sth->finish;
		$connector->destroy();
		$pumphash{id_bomba} = $pump->{ID};
		$pumphash{totalizador_al_abrir} = $pump->{TOTALIZADOR};
		$pumphash{totalizador_al_cerrar} = undef;
		$pumphash{timestamp_al_abrir} = $now;
		$pumphash{timestamp_al_cerrar} = undef;
		$pumphash{bomba} = $pump->{PUMP_HEAD};
		$pumphash{id_turno} = $self->{ID_TURNO};
		push @{$self->{BOMBAS_TURNO}},\%pumphash;
	}
}

sub insertCloseTotalizerReadings{
	my $self = shift;
	my $connector = Trate::Lib::ConnectorMariaDB->new();
	my $result = 0;
	my $bombas = Trate::Lib::Bombas->new();
	my @pumps = $bombas->getBombas();
	foreach my $pump (@pumps){
		my $preps = "UPDATE turno_bombas SET " .
			" totalizador_al_cerrar='" . $pump->{TOTALIZADOR} . "','" .
			" timestamp_cerrar = NOW() " . 
			" WHERE id_turno='" . $self->{ID_TURNO} . "' AND id_bomba";
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
}

1;
#EOF