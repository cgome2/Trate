package Trate::Lib::Turnos;

use strict;
use Trate::Lib::Constants qw(LOGGER DEFAULT_FLEET_ID DEFAULT_FLEET_NAME HO_ROLE DEFAULT_RULE);
use Trate::Lib::Bombas;
use Trate::Lib::Tanques;
use Trate::Lib::BombaTurno;
use Trate::Lib::TanqueTurno;
use Trate::Lib::MeanTurno;
use Data::Dump qw(dump);
use Data::Structure::Util qw( unbless );
use Trate::Lib::Utilidades;
use Trate::Lib::Corte;


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

# Obtiene un objeto de turno a partir de una fecha hora
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

# Obtiene un listado de los turnos por fecha con parametros de paginacion
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

# obtiene un objeto de tipo turno en blanco
sub getNew {
	my $self = shift;
	my %return;
	my $allmeans = Trate::Lib::Mean->getDespachadores();
	my @despachadores = @{$allmeans};
	my @means_turno;
	foreach my $despachador (@despachadores){
		my $omean = ();
		$omean->{id_turno} = "";
		$omean->{mean_id} = $despachador->{id};
		$omean->{despachador} = $despachador->{NAME};
		$omean->{timestamp_add} = "";
		$omean->{timestamp_rm} = "";
		$omean->{id_usuario_add} = "";
		$omean->{id_usuario_rm} = "";
		$omean->{status_mean_turno} = 0;
		push @means_turno,$omean;
	}
	$self->{MEANS_TURNO} = \@means_turno;

	my $now = Trate::Lib::Utilidades->getCurrentTimestampMariaDB();
	unbless($self);
	$return{id_turno} = $self->{ID_TURNO};
	$return{id_usuario_abre} = $self->{ID_USUARIO_ABRE};
	$return{id_usuario_cierra} = $self->{ID_USUARIO_CIERRA};
	$return{usuario_abre} = $self->{USUARIO_ABRE};
	$return{usuario_cierra} = $self->{USUARIO_CIERRA};
	$return{status} = $self->{STATUS};
	$return{fecha_abierto} = $self->{FECHA_ABIERTO};
	$return{fecha_cerrado} = $self->{FECHA_CERRADO};
	$return{MEANS_TURNO} = $self->{MEANS_TURNO};
	return \%return;
}

# obtiene un objeto turno por id o el último
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

	LOGGER->debug("RAMSES 1");
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

	LOGGER->debug("RAMSES 2");

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

	$prepsMeans = "SELECT tm.*,m.NAME AS despachador,u.numero_empleado AS usuario_add,u2.numero_empleado AS usuario_rm,CASE tm.status_mean_turno WHEN 2 THEN 1 ELSE 0 END AS activo " .
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

# Al abrir inserta totalizadores de cada bomba en la tabla turno_bombas
sub insertOpenTotalizerReadings{
	my $self = shift;
	my $connector = Trate::Lib::ConnectorMariaDB->new();
	my $result = 0;
	my $bombas = Trate::Lib::Bombas->new();
	my $obombas = $bombas->getBombas();
	my @pumps = @{$obombas};
	#LOGGER->debug(dump(\@pumps));
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

# al abrir inserta las lecturas de los tanque en la tabla turno_tanques
sub insertOpenTankReadings{
	my $self = shift;
	my $connector = Trate::Lib::ConnectorMariaDB->new();
	my $result = 0;
	my $tanques = Trate::Lib::Tanques->new();
	my @tanks = $tanques->getTanquesEstatus();
	my %tankhash;
	my $now = Trate::Lib::Utilidades->getCurrentTimestampMariaDB();
	foreach my $tank (@tanks){
		%tankhash = ();
		my $preps = "INSERT INTO turno_tanques (id_turno,tank_id,tank_name,volumen_inicial,timestamp_inicial) " .
			" VALUES ('" .
				$self->{ID_TURNO} . "','" .
				$tank->{tank_id} . "','" .
				$tank->{name} . "','" .
				$tank->{fuel_volume} . "','" .
				$now . "')";
		LOGGER->debug("Ejecutando sql[ ", $preps, " ]");
		my $sth = $connector->dbh->prepare($preps);
		$sth->execute() or die LOGGER->fatal("NO PUDO EJECUTAR EL SIGUIENTE COMANDO en MARIADB:orpak: $preps");
		$sth->finish;
		$connector->destroy();
		$tankhash{timestamp_final} = undef;
		$tankhash{volumen_inicial} = $tank->{fuel_volume};
		$tankhash{volumen_final} = undef;
		$tankhash{id_turno} = $self->{ID_TURNO};
		$tankhash{tank_name} = $tank->{name};
		$tankhash{timestamp_inicial} = $now;
		$tankhash{tank_id} = $tank->{tank_id};
		push @{$self->{TANQUES_TURNO}},\%tankhash;
	}
}

sub fillBombasTurno {
	my $self = shift;
	my $connector = Trate::Lib::ConnectorMariaDB->new();
	my $bombaTurno = Trate::Lib::BombaTurno->new();

	my $prepsBombas = "SELECT * FROM turno_bombas WHERE id_turno=" . $self->{ID_TURNO};
	my $sthBombas = $connector->dbh->prepare($prepsBombas);
	$sthBombas->execute() or die LOGGER->fatal("NO PUDO EJECUTAR EL SIGUIENTE COMANDO en MARIADB:orpak: $prepsBombas");
	my @bombasTurno = ();

	while (my $b = $sthBombas->fetchrow_hashref()){
		push @bombasTurno, $b;
	}
	$self->{BOMBAS_TURNO} = \@bombasTurno;
	return $self;
}

sub fillTanquesTurno {
	my $self = shift;
	my $connector = Trate::Lib::ConnectorMariaDB->new();
	my $preps = "SELECT * FROM turno_tanques WHERE id_turno=" . $self->{ID_TURNO};
	my $sth = $connector->dbh->prepare($preps);
	$sth->execute() or die LOGGER->fatal("NO PUDO EJECUTAR EL SIGUIENTE COMANDO en MARIADB:orpak: $preps");
	my @tanquesTurno = ();
	while (my $t = $sth->fetchrow_hashref()){
		push @tanquesTurno,$t;
	}

	$self->{TANQUES_TURNO} = \@tanquesTurno;
	return $self;
}

# activa o desactiva la flota principal en el orcu
sub cambiarEstatusFlota($){
	my $self = shift;
	my $estatus = shift;
	my $status;
	if($estatus eq "ACTIVA"){
		$status = 2;
	} elsif ($estatus eq "INACTIVA"){
		$status = 1;
	} else {
		return 0;
	}

	my %paramsheader = (
		SessionID => "",
		site_code => "",
		num_fleets => "1"
	);

	my %soFleet = ();
	$soFleet{id} = DEFAULT_FLEET_ID;
	$soFleet{name} = DEFAULT_FLEET_NAME;
	$soFleet{status} = $status;
	$soFleet{code} = 1;
	$soFleet{default_rule} = DEFAULT_RULE;
	$soFleet{acctyp} = 0;
	$soFleet{available_amount} = 0;

	my %soFleets;
	$soFleets{soFleet} = \%soFleet;
	my %paramsbody;
	$paramsbody{a_soFleet} = \%soFleets;
	my $wsc = Trate::Lib::WebServicesClient->new();
	$wsc->callName("SOUpdateFleets");
	$wsc->sessionId();
	my $result = $wsc->executehb(\%paramsheader,\%paramsbody);
	return $result->{rc};
}

# verifica que sii existen jarreos sin devolución en el turno a fin de garantizar que no haya cierres inconsistentes
sub verificarJarreosAbiertos{
	my $self = shift;
	my $connector = Trate::Lib::ConnectorMariaDB->new();
	my $preps = "SELECT count(*) AS jarreos FROM jarreos_t WHERE status_code = 2 AND transaction_timestamp>='" . $self->{FECHA_ABIERTO} . "'";
	LOGGER->debug("Ejecutando sql[ ", $preps, " ]");
	my $sth = $connector->dbh->prepare($preps);
	$sth->execute() or die LOGGER->fatal("NO PUDO EJECUTAR EL SIGUIENTE COMANDO en MARIADB:orpak: $preps");
	my $row = $sth->fetchrow_hashref();
	$sth->finish;
	$connector->destroy();
	if($row->{jarreos} gt 0){
		return 1;
	} else {
		return 0;
	}
}

# verifica que todas las bombas tengan un estado 55 o 49 es decir IDLE o FUERA DE LINEA para poder realizar el corte
sub verificarEstadosBombaIdle{
	my $self = shift;
	my $bombas = Trate::Lib::Bombas->new();
	my @pumps = @{$bombas->getBombasEstatus()};
	foreach my $pump (@pumps){
		if($pump->{status} ne 55 && $pump->{status} ne 49){
			return 1;
		}
	}
	return 0;
}

# verifica que no existan lecturas de recepción de combustible que no hayan sido asigadas a un documento a fin de permitir el cierre de un corte
sub verificarRecepcionesDocumentos{
	my $self = shift;
	my $connector = Trate::Lib::ConnectorMariaDB->new();
	my $preps = "SELECT count(*) AS recepciones FROM tank_delivery_readings_t WHERE status = 0 AND end_delivery_timestamp>='" . $self->{FECHA_ABIERTO} . "'";
	LOGGER->debug("Ejecutando sql[ ", $preps, " ]");
	my $sth = $connector->dbh->prepare($preps);
	$sth->execute() or die LOGGER->fatal("NO PUDO EJECUTAR EL SIGUIENTE COMANDO en MARIADB:orpak: $preps");
	my $row = $sth->fetchrow_hashref();
	$sth->finish;
	$connector->destroy();
	if($row->{recepciones} gt 0){
		return 1;
	} else {
		return 0;
	}
}

# bloquea los means de los despachadores
sub bloquearMeansDespachador{
	my $self = shift;
	my @despachadores = @{$self->{MEANS_TURNO}};
	foreach my $despachador (@despachadores){
		my $md = Trate::Lib::Mean->new();
		$md->id($despachador->{mean_id});
		$md->fillMeanFromId();
		LOGGER->debug(dump($md));
		if($despachador->{status_mean_turno} eq 2){
			$md->desactivarMean();
		}
	}
}

# inseta lecturas de totalizadores por cada bomba al cierre del turno
sub insertCloseTankReadings{
	my $self = shift;
	my $connector = Trate::Lib::ConnectorMariaDB->new();
	my $result = 0;
	my $tanques = Trate::Lib::Tanques->new();
	my @tanks = $tanques->getTanquesEstatus();
	my $now = Trate::Lib::Utilidades->getCurrentTimestampMariaDB();
	my $sth;
	foreach my $tank (@tanks){
		my $preps = "UPDATE turno_tanques SET " .
			" volumen_final='" . $tank->{fuel_volume} . "'," .
			" timestamp_final = NOW() " . 
			" WHERE id_turno='" . $self->{ID_TURNO} . "' AND tank_id=" . $tank->{tank_id};
		LOGGER->debug("Ejecutando sql[ ", $preps, " ]");
		$sth = $connector->dbh->prepare($preps);
		$sth->execute() or die LOGGER->fatal("NO PUDO EJECUTAR EL SIGUIENTE COMANDO en MARIADB:orpak: $preps");
	}
	$sth->finish;
	$connector->destroy();
}

# inserta lectura de existencia en tanques al cierre del turno
sub insertCloseTotalizerReadings{
	my $self = shift;
	my $connector = Trate::Lib::ConnectorMariaDB->new();
	my $result = 0;
	my $bombas = Trate::Lib::Bombas->new();
	my $obombas = $bombas->getBombas();
	my @pumps = @{$obombas};
	my $now = Trate::Lib::Utilidades->getCurrentTimestampMariaDB();
	my $sth;
	foreach my $pump (@pumps){
		my $preps = "UPDATE turno_bombas SET " .
			" totalizador_al_cerrar='" . $pump->{TOTALIZADOR} . "'," .
			" timestamp_cerrar = NOW() " . 
			" WHERE id_turno='" . $self->{ID_TURNO} . "' AND id_bomba=" . $pump->{ID};
		LOGGER->debug("Ejecutando sql[ ", $preps, " ]");
		$sth = $connector->dbh->prepare($preps);
		$sth->execute() or die LOGGER->fatal("NO PUDO EJECUTAR EL SIGUIENTE COMANDO en MARIADB:orpak: $preps");
	}
	$sth->finish;
	$connector->destroy();
}

# Cambia el estado de un turno a cerrado
sub cerrarTurno {
	my $self = shift;
	my $connector = Trate::Lib::ConnectorMariaDB->new();
	$self->{FECHA_CERRADO} = Trate::Lib::Utilidades->getCurrentTimestampMariaDB();
	my $preps = "UPDATE turnos SET " .
		" fecha_cierre='" . $self->{FECHA_CERRADO} . "'," .
		" id_usuario_cierra='" . $self->{ID_USUARIO_CIERRA} . "'," .
		" status = 1 " . 
		" WHERE id_turno='" . $self->{ID_TURNO} . "'";
	LOGGER->debug("Ejecutando sql[ ", $preps, " ]");
	my $sth = $connector->dbh->prepare($preps);
	$sth->execute() or die LOGGER->fatal("NO PUDO EJECUTAR EL SIGUIENTE COMANDO en MARIADB:orpak: $preps");
	$sth->finish;
	$connector->destroy();
	return $self;
}

# obtiene los listros despachados en el turno
sub getLitrosTurno {
	my $self = shift;
	my $connector = Trate::Lib::ConnectorMariaDB->new();
	my $preps = "SELECT sum(cantidad) AS litros FROM transacciones WHERE idcortes=" . $self->{ID_TURNO};
	my $sth = $connector->dbh->prepare($preps);
	$sth->execute() or die LOGGER->fatal("NO PUDO EJECUTAR EL SIGUIENTE COMANDO en MARIADB:orpak: $preps");
	my $row = $sth->fetchrow_hashref();
	$sth->finish;
	$connector->destroy();
	return length($row->{litros}) gt 0 ? $row->{litros} : 0;
}

# obtiene los litros despachados por bomba en el turno
sub getLitrosTurnoByPump($) {
	my $self = shift;
	my $pump = pop;
	my $connector = Trate::Lib::ConnectorMariaDB->new();
	my $preps = "SELECT sum(cantidad) AS litros FROM transacciones WHERE idcortes=" . $self->{ID_TURNO} . " AND bomba=" . $pump;
	LOGGER->debug("Ejecutando sql[ ", $preps, " ]");
	my $sth = $connector->dbh->prepare($preps);
	$sth->execute() or die LOGGER->fatal("NO PUDO EJECUTAR EL SIGUIENTE COMANDO en MARIADB:orpak: $preps");
	my $row = $sth->fetchrow_hashref();
	$sth->finish;
	$connector->destroy();
	
	return length($row->{litros}) gt 0 ? $row->{litros} : 0;
}

# obtiene los litros recibidos por un proveedor en el turno
sub getLitrosRecibidos {
	my $self = shift;
	my $connector = Trate::Lib::ConnectorMariaDB->new();
	my $preps = "SELECT sum(start_volume - end_volume) AS litros FROM tank_delivery_readings_t WHERE end_delivery_timestamp >='" . $self->{FECHA_ABIERTO} . "' AND end_delivery_timestamp <= '" . $self->{FECHA_CERRADO} . "'";
	my $sth = $connector->dbh->prepare($preps);
	$sth->execute() or die LOGGER->fatal("NO PUDO EJECUTAR EL SIGUIENTE COMANDO en MARIADB:orpak: $preps");
	my $row = $sth->fetchrow_hashref();
	$sth->finish;
	$connector->destroy();
	return length($row->{litros}) gt 0 ? $row->{litros} : 0;
}

# envia el corte al servidor de trate
sub enviarTurnoTrate {
	my $self = shift;
	fillTanquesTurno($self);
	#inserta movimiento con tanques
	my @tt = @{$self->{TANQUES_TURNO}};
	my $corte = Trate::Lib::Corte->new();
	$corte->fechaHora($self->{FECHA_CERRADO});
	$corte->dispensador(0);
	$corte->entregaTurno($self->{USUARIO_ABRE});
	$corte->recibeTurno($self->{USUARIO_CIERRA});
	$corte->fechaHoraRecep($self->{FECHA_ABIERTO});
	$corte->inventarioRecibidoLts(@tt[0]->{volumen_inicial});
	$corte->movtosTurnoLts(&getLitrosRecibidos($self) - &getLitrosTurno($self));
	$corte->inventarioEntregadoLts(@tt[0]->{volumen_final});
	$corte->diferenciaLts($corte->inventarioRecibidoLts() + &getLitrosRecibidos($self) - $corte->inventarioEntregadoLts()  - $corte->movtosTurnoLts());
	$corte->inventarioRecibidoCto(0);
	$corte->movtosTurnoCto(0);
	$corte->inventarioEntregadoCto(0);
	$corte->diferenciaCto(0);
	$corte->autorizoDif(0);
	$corte->contadorInicial(0);
	$corte->contadorFinal(0);
	$corte->vserie("");
	$corte->procesada("");
	$corte->folio("");
	$corte->inserta();

	fillBombasTurno($self);
	my @bombas_turno = @{$self->{BOMBAS_TURNO}};
	foreach my $bomba (@bombas_turno){
		$corte = Trate::Lib::Corte->new();
		$corte->folio("");
		$corte->fechaHora($self->{FECHA_CERRADO});
		$corte->dispensador($bomba->{bomba});
		$corte->entregaTurno($self->{USUARIO_ABRE});
		$corte->recibeTurno($self->{USUARIO_CIERRA});
		$corte->fechaHoraRecep($self->{FECHA_ABIERTO});
		$corte->inventarioRecibidoLts($bomba->{totalizador_al_abrir});
		$corte->movtosTurnoLts( &getLitrosTurnoByPump( $self, $bomba->{bomba} ) );
		$corte->inventarioEntregadoLts($bomba->{totalizador_al_cerrar});
		$corte->inventarioRecibidoCto(0);
		$corte->movtosTurnoCto(0);
		$corte->inventarioEntregadoCto(0);
		$corte->diferenciaCto(0);
		$corte->autorizoDif(0);
		$corte->contadorInicial("");
		$corte->contadorFinal("");
		$corte->diferenciaLts($corte->movtosTurnoLts() - $corte->contadorFinal() + $corte->contadorInicial());
		$corte->vserie("");
		$corte->procesada("");
		$corte->folio("");
		$corte->inserta();
	}
}

sub actualizaMeansTurno() {
	my $self = shift;
	my @means_turno = @{$self->{MEANS_TURNO}};
	my $omean = Trate::Lib::Mean->new();
	my $mean_turno;
	foreach my $mt (@means_turno){
		$mean_turno = Trate::Lib::MeanTurno->new();
		$mean_turno->{ID_TURNO} = $mt->{id_turno};
		$mean_turno->{MEAN_ID} = $mt->{mean_id};
		if(($mt->{status_mean_turno} eq 0 || $mt->{status_mean_turno} eq 1) && $mt->{activo} eq 1)
		{
			$mean_turno->{ID_USUARIO_ADD} = $self->{ID_USUARIO_CIERRA};
			$mean_turno->{TIMESTAMP_ADD} = Trate::Lib::Utilidades->getCurrentTimestampMariaDB();
			$mean_turno->{STATUS_MEAN_TURNO} = 2;
			$mean_turno->actualizar();
			$omean->id($mean_turno->{MEAN_ID});
			$omean->fillMeanFromId();
			$omean->activarMean();
		}
		if($mt->{status_mean_turno} eq 2 && $mt->{activo} eq 0)
		{
			$mean_turno->{ID_USUARIO_ADD} = $self->{ID_USUARIO_CIERRA};
			$mean_turno->{TIMESTAMP_ADD} = Trate::Lib::Utilidades->getCurrentTimestampMariaDB();
			$mean_turno->{ID_USUARIO_RM} = $self->{ID_USUARIO_CIERRA};
			$mean_turno->{TIMESTAMP_RM} = Trate::Lib::Utilidades->getCurrentTimestampMariaDB();
			$mean_turno->{STATUS_MEAN_TURNO} = 1;
			$mean_turno->actualizar();
			$omean->id($mean_turno->{MEAN_ID});
			$omean->fillMeanFromId();
			$omean->desactivarMean();
		}
		LOGGER->debug(dump($mean_turno));
	}
}

sub existeUnTurnoAbierto {
	my $connector = Trate::Lib::ConnectorMariaDB->new();
	my $preps = "SELECT count(*) turnos_abiertos FROM turnos WHERE status = 2";
	my $sth = $connector->dbh->prepare($preps);
	$sth->execute() or die LOGGER->fatal("NO PUDO EJECUTAR EL SIGUIENTE COMANDO en MARIADB:orpak: $preps");
	my $row = $sth->fetchrow_hashref();
	$sth->finish;
	$connector->destroy();
	LOGGER->info("Se verificó si hay turnos abiertos encontrando [" . $row->{turnos_abiertos} . "] como resultado");
	return ($row->{turnos_abiertos} gt 0 ? 1 : 0);
}

1;
#EOF
