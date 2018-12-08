package Trate::Lib::Usuarios;

use Trate::Lib::Constants qw(LOGGER);
use Data::Dump qw(dump);


sub new 
{
	my $self = {};
	$self->{IDUSUARIOS} = undef;
	$self->{USUARIO} = undef;
	$self->{NOMBRE} = undef;
	$self->{PASSWORD} = undef;
	$self->{NIVEL} = undef;
	$self->{ESTATUS} = undef;
	$self->{SESSION_ID} = 0;
	$self->{TOKEN} = undef;
	$self->{CADUCIDAD_TOKEN} = undef;

	bless($self);
	return $self;
}

sub idusuarios {
    my ($self) = shift;
    if (@_) { $self->{IDUSUARIOS} = shift }        
    return $self->{IDUSUARIOS};
}

sub usuario {
    my ($self) = shift;
    if (@_) { $self->{USUARIO} = shift }        
    return $self->{USUARIO};
}

sub password {
    my ($self) = shift;
    if (@_) { $self->{PASSWORD} = shift }        
    return $self->{PASSWORD};	
}

sub caducidadToken {
    my ($self) = shift;
    if (@_) { $self->{CADUCIDAD_TOKEN} = shift }        
    return $self->{CADUCIDAD_TOKEN};	
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
				WHERE usuario = '" . $self->{USUARIO} . "' AND password = '" . $self->{PASSWORD} . "' AND ESTATUS = 1 LIMIT 1";
	LOGGER->debug("Ejecutando sql[ ", $preps, " ]");
	my $sth = $connector->dbh->prepare($preps);
    $sth->execute() or die LOGGER->fatal("NO PUDO EJECUTAR EL SIGUIENTE COMANDO en MARIADB:orpak: $preps");

	(
	$self->{IDUSUARIOS},	
	$self->{NOMBRE},
	$self->{TOKEN},
	$self->{NIVEL},
	$self->{CADUCIDAD_TOKEN},
	$self->{ESTATUS}
	) = $sth->fetchrow_array;
	$sth->finish;
	$connector->destroy();
	$self = setCaducidadToken($self);
	return $self;	
}

sub login {
	my $self = shift;
	$self = token($self);
	if(length($self->{TOKEN}) ge 1){
		return 1;
	} else {
		return "Usuario o password no existentes";
	}
}

sub setCaducidadToken {
	my $self = shift;
	my $connector = Trate::Lib::ConnectorMariaDB->new();
	my $preps = "UPDATE usuarios SET token = '" . $self->{TOKEN} . "',caducidad_token = '" . $self->{CADUCIDAD_TOKEN} . "' WHERE idusuarios = '" . $self->{IDUSUARIOS} . "' LIMIT 1";
	LOGGER->debug("Ejecutando sql[ ", $preps, " ]");
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
	LOGGER->debug("Ejecutando sql[ ", $preps, " ]");
	my $sth = $connector->dbh->prepare($preps);
    $sth->execute() or die LOGGER->fatal("NO PUDO EJECUTAR EL SIGUIENTE COMANDO en MARIADB:orpak: $preps");
	my $rowq = $sth->fetchrow_hashref;
	my $total = $rowq->{'existe'};    
	$sth->finish;
	$connector->destroy();
	return $total;		
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
	LOGGER->debug("Ejecutando sql[ ", $preps, " ]");
	my $sth = $connector->dbh->prepare($preps);
    $sth->execute() or die LOGGER->fatal("NO PUDO EJECUTAR EL SIGUIENTE COMANDO en MARIADB:orpak: $preps");
	$sth->finish;
	$connector->destroy();
	return 1;			
}

1;
#EOF
