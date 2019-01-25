package Trate::Lib::Usuarios;

use Trate::Lib::Constants qw(LOGGER);
use Data::Dump qw(dump);
use Try::Catch;
use Digest::SHA1 qw(sha1_hex);

sub new 
{
	my $self = {};
	$self->{idusuarios} = undef;
	$self->{usuario} = undef;
	$self->{nombre} = undef;
	$self->{password} = undef;
	$self->{nivel} = undef;
	$self->{estatus} = undef;
	$self->{session_id} = 0;
	$self->{token} = undef;
	$self->{caducidad_token} = undef;
	$self->{numero_empleado} = undef;

	bless($self);
	return $self;
}

sub idusuarios {
    my ($self) = shift;
    if (@_) { $self->{idusuarios} = shift }        
    return $self->{idusuarios};
}

sub usuario {
    my ($self) = shift;
    if (@_) { $self->{usuario} = shift }        
    return $self->{usuario};
}

sub nombre {
    my ($self) = shift;
    if (@_) { $self->{nombre} = shift }        
    return $self->{nombre};
}

sub estatus {
    my ($self) = shift;
    if (@_) { $self->{estatus} = shift }        
    return $self->{estatus};
}

sub password {
    my ($self) = shift;
    if (@_) { $self->{password} = shift }        
    return $self->{password};	
}

sub nivel {
    my ($self) = shift;
    if (@_) { $self->{nivel} = shift }        
    return $self->{nivel};	
}

sub caducidadToken {
    my ($self) = shift;
    if (@_) { $self->{caducidad_token} = shift }        
    return $self->{caducidad_token};	
}

sub numeroEmpleado {
    my ($self) = shift;
    if (@_) { $self->{numero_empleado} = shift }        
    return $self->{numero_empleado};	
}

sub token {
	my $self = shift;
	my $connector = Trate::Lib::ConnectorMariaDB->new();
	my $preps = "SELECT idusuarios,
						nombre,
						sha1(concat(now(),usuario,password)) AS token,
						nivel,
						DATE_ADD(now(), INTERVAL 1 HOUR) AS caducidad_token,
						estatus 
				FROM usuarios 
				WHERE usuario = '" . $self->{usuario} . "' AND password = '" . $self->{password} . "' AND ESTATUS = 1 LIMIT 1";
	LOGGER->debug("Ejecutando sql[ ", $preps, " ]");
	my $sth = $connector->dbh->prepare($preps);
    $sth->execute() or die LOGGER->fatal("NO PUDO EJECUTAR EL SIGUIENTE COMANDO en MARIADB:orpak: $preps");

	(
	$self->{idusuarios},	
	$self->{nombre},
	$self->{token},
	$self->{nivel},
	$self->{caducidad_token},
	$self->{estatus}
	) = $sth->fetchrow_array;
	$sth->finish;
	$connector->destroy();
	$self = setCaducidadToken($self);
	return $self;	
}

sub login {
	my $self = shift;
	$self = token($self);
	if(length($self->{token}) ge 1){
		return 1;
	} else {
		return "Usuario o password no existentes";
	}
}

sub setCaducidadToken {
	my $self = shift;
	my $connector = Trate::Lib::ConnectorMariaDB->new();
	my $preps = "UPDATE usuarios SET token = '" . $self->{token} . "',caducidad_token = '" . $self->{caducidad_token} . "' WHERE idusuarios = '" . $self->{idusuarios} . "' LIMIT 1";
	#LOGGER->debug("Ejecutando sql[ ", $preps, " ]");
	my $sth = $connector->dbh->prepare($preps);
    $sth->execute() or die LOGGER->fatal("NO PUDO EJECUTAR EL SIGUIENTE COMANDO en MARIADB:orpak: $preps");
	$sth->finish;
	$connector->destroy();
	return $self;	
}

sub verificaToken($) {
	my $self = shift;
	my $token = shift;
	my $connector = Trate::Lib::ConnectorMariaDB->new();
	my $preps = "SELECT count(*) AS existe FROM usuarios WHERE token = '" . $token . "' AND caducidad_token>=NOW() LIMIT 1";
	#LOGGER->debug("Ejecutando sql[ ", $preps, " ]");
	my $sth = $connector->dbh->prepare($preps);
    $sth->execute() or die LOGGER->fatal("NO PUDO EJECUTAR EL SIGUIENTE COMANDO en MARIADB:orpak: $preps");
	my $rowq = $sth->fetchrow_hashref;
	my $total = $rowq->{'existe'};    
	$sth->finish;
	$connector->destroy();
	return $total;		
}

sub getUsuarioByToken($) {
	my $self = shift;
	my $token = shift;
	my $connector = Trate::Lib::ConnectorMariaDB->new();
	my $preps = "SELECT * FROM usuarios WHERE token = '" . $token . "' LIMIT 1";
	#LOGGER->debug("Ejecutando sql[ ", $preps, " ]");
	my $sth = $connector->dbh->prepare($preps);
    $sth->execute() or die LOGGER->fatal("NO PUDO EJECUTAR EL SIGUIENTE COMANDO en MARIADB:orpak: $preps");
	my $row = $sth->fetchrow_hashref;
	$sth->finish;
	$connector->destroy();
	return $row;		
}

sub renuevaToken($){
	my $self = shift;
	my $token = shift;
	my $connector = Trate::Lib::ConnectorMariaDB->new();
	my $preps = "UPDATE usuarios SET caducidad_token=DATE_ADD(now(), INTERVAL 1 HOUR) WHERE token = '" . $token . "' LIMIT 1";
	LOGGER->debug("Ejecutando sql[ ", $preps, " ]");
	my $sth = $connector->dbh->prepare($preps);
    $sth->execute() or die LOGGER->fatal("NO PUDO EJECUTAR EL SIGUIENTE COMANDO en MARIADB:orpak: $preps");
	$sth->finish;
	$connector->destroy();
	return $self;
}

sub logout($){
	my $self = shift;
	my $token = shift;
	my $connector = Trate::Lib::ConnectorMariaDB->new();
	my $preps = "UPDATE usuarios SET token = NULL,caducidad_token = NULL WHERE token = '" . $token . "' LIMIT 1";
	#LOGGER->debug("Ejecutando sql[ ", $preps, " ]");
	my $sth = $connector->dbh->prepare($preps);
    $sth->execute() or die LOGGER->fatal("NO PUDO EJECUTAR EL SIGUIENTE COMANDO en MARIADB:orpak: $preps");
	$sth->finish;
	$connector->destroy();
	return 1;			
}

sub getUsuarios {
	my $self = shift;
	my $connector = Trate::Lib::ConnectorMariaDB->new();
	my $preps = "SELECT * FROM usuarios"; 
	#LOGGER->debug("Ejecutando sql[ ", $preps, " ]");
	my $sth = $connector->dbh->prepare($preps);
	$sth->execute() or die LOGGER->fatal("NO PUDO EJECUTAR EL SIGUIENTE COMANDO en MARIADB:orpak: $preps");
	my @usuarios;
	while (my $ref = $sth->fetchrow_hashref()) {
		$ref->{password} = "";
		delete $ref->{session_id};
		delete $ref->{token};
		delete $ref->{caducidad_token};
    	push @usuarios,$ref;
	}
	$sth->finish;
	$connector->destroy();
	return \@usuarios;	
}

sub addUsuarios {
	my $self = shift;
	my $connector = Trate::Lib::ConnectorMariaDB->new();
	my $preps = "INSERT INTO usuarios (idusuarios,usuario,nombre,password,nivel,numero_empleado,estatus) VALUES (NULL,'" .
		$self->{usuario} . "','" .
		$self->{nombre} . "','" .
		sha1_hex($self->{password}) . "','" .
#		$self->{password} . "','" .
		$self->{nivel} . "','" .
		$self->{numero_empleado} . "','" .
		$self->{estatus} . "')";
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

sub updateUsuarios {
	my $self = shift;
	my $connector = Trate::Lib::ConnectorMariaDB->new();
	my $preps = "UPDATE usuarios set nombre='" . $self->{nombre} . "'," ;
	if($self->{password}) {
		$preps = $preps . "password = '" . sha1_hex($self->{password}) . "',";
		}
		$preps = $preps . "numero_empleado = '" . $self->{numero_empleado} . "',";
		$preps = $preps . "estatus = '" . $self->{estatus} . "'," .
		"nivel = '" . $self->{nivel} . "' WHERE idusuarios = '" . $self->{idusuarios} . "' LIMIT 1";
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

sub getUsuariosFromId {
	my $self = shift;
	my $return = 0;
	my $connector = Trate::Lib::ConnectorMariaDB->new();
	my $preps = "SELECT idusuarios,nombre,nivel,password,estatus,usuario,numero_empleado FROM usuarios 
				WHERE idusuarios = '" . $self->{idusuarios} . "' LIMIT 1";
	LOGGER->debug("Ejecutando sql[ ", $preps, " ]");
	try {
		my $sth = $connector->dbh->prepare($preps);
		$sth->execute() or die LOGGER->fatal("NO PUDO EJECUTAR EL SIGUIENTE COMANDO en MARIADB:orpak: $preps");
		my $row = $sth->fetchrow_hashref();
		$sth->finish;
		$connector->destroy();
		if($row){
			$row->{password} = "";
			delete $row->{session_id};
			delete $row->{token};
			delete $row->{caducidad_token};
			return $row;
		} else {
			return 0;
		}
	} catch {
		return 0;
	}
	
}

1;
#EOF
