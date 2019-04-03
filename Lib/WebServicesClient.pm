package Trate::Lib::WebServicesClient;

use Trate::Lib::Constants qw(LOGGER HO_ROLE WSURI WSPROXY WSUSER WSPASSWORD SITE_CODE WSXMLSCHEMA USERHOCOMMUNICATOR PASSHOCUMMUNICATOR);
use SOAP::Lite +trace => 'debug';
#use SOAP::Lite on_fault => sub {my($soap, $res) = @_; die LOGGER->error(ref $res) ? LOGGER->error($res->faultdetail) : LOGGER->info($soap->transport->status),"\n"};
use SOAP::Lite;
use XML::Twig;
use Data::Dump qw(dump);
use Trate::Lib::Utilidades;
use Trate::Lib::ConnectorMariaDB;

sub new 
{
	my $self = {};
	$self->{CALL_NAME} = undef;
	$self->{PARAMS} = undef;
	$self->{SOAP} = SOAP::Lite->uri(WSURI)->proxy(WSPROXY)->xmlschema(WSXMLSCHEMA)->autotype(0);
	$self->{SOAP}->readable(1);
	$self->{SESSIONID} = undef;

	bless($self);
	return $self;
}

sub callName {
    my ($self) = shift;
    if (@_) { $self->{CALL_NAME} = shift }        
    return $self->{CALL_NAME};
}

sub params {
    my ($self) = shift;
    if (@_) { $self->{PARAMS} = shift }        
    return $self->{PARAMS};
}

sub setSessionId {
	my $self = shift;
	my $usuario = shift;
	my $pass = shift;

	my $connector = Trate::Lib::ConnectorMariaDB->new();
	my $preps = "SELECT * FROM orcu_sessions WHERE usuario_orcu='" . $usuario . "' AND until>= NOW() LIMIT 1";
	my $sth = $connector->dbh->prepare($preps);
    $sth->execute() or die LOGGER->fatal("NO PUDO EJECUTAR EL SIGUIENTE COMANDO en MARIADB:orpak: $preps");
	my $row = $sth->fetchrow_hashref();
	$sth->finish;

	if(defined($row)){
		LOGGER->debug("Obeniendo SessionID from DB");
		$self->{SESSIONID} = $row->{session_id};
	} else {
		LOGGER->debug("Obeniendo SessionID from ORCU");
		my %parametros = (
			"user" => $usuario,
			"password" => $pass
		);
		
		my $soap = $self->{SOAP};
		my $method = SOAP::Data->name('ns1:SOLogin')->attr({'xmlns:ns1' => WSURI});
		my @params;	
		for my $parametro (keys %parametros) {
			push @params, SOAP::Data->name($parametro => $parametros{$parametro});
		}
		my $xmlResponse = $soap->call($method => @params)->result;
		$self->{SESSIONID} = $xmlResponse->{SessionID};
		$preps = "DELETE FROM orcu_sessions WHERE usuario_orcu='" . $usuario . "'";
		$sth = $connector->dbh->prepare($preps);
		$sth->execute() or die LOGGER->fatal("NO PUDO EJECUTAR EL SIGUIENTE COMANDO en MARIADB:orpak: $preps");
		$preps = "INSERT INTO orcu_sessions VALUES ('" . $usuario . "','" . $self->{SESSIONID} . "',NOW(),DATE_ADD(NOW(),INTERVAL 1 HOUR))";
		$sth = $connector->dbh->prepare($preps);
		$sth->execute() or die LOGGER->fatal("NO PUDO EJECUTAR EL SIGUIENTE COMANDO en MARIADB:orpak: $preps");
	}
	$connector->destroy();
}

sub sessionId {
	my $self = shift;
	setSessionId($self,WSUSER,WSPASSWORD);
	LOGGER->debug("SessionID: " . $self->{SESSIONID});
	return $self->{SESSIONID};
}

sub sessionIdTransporter {
	my $self = shift;
	setSessionId($self,USERHOCOMMUNICATOR,PASSHOCUMMUNICATOR);
	LOGGER->debug("SessionID: " . $self->{SESSIONID});
	return $self->{SESSIONID};
}

sub execute{
	my $self = shift;
	my %parametros = %{$_[0]};
	$parametros{'SessionID'}=$self->{SESSIONID};
	$parametros{'site_code'}=SITE_CODE;		
	
	my $soap = $self->{SOAP};
	my $method = SOAP::Data->name('ns1:' . $self->{CALL_NAME})->attr({'xmlns:ns1' => WSURI});
	my @params;
	for my $parametro (keys %parametros) {
		LOGGER->debug($parametro . " " . dump($parametros{$parametro}));
		push @params, SOAP::Data->name($parametro => $parametros{$parametro});
	}
	
	return $soap->call($method => @params)->result;	
}

sub executeSOHONotifyTransactionLoaded{
	my $self = shift;
	my %parametros = %{$_[0]};
	my %headerparametros = ();
	$headerparametros{'SessionID'}=$self->{SESSIONID};
	$headerparametros{'site_code'}=SITE_CODE;		
	$headerparametros{'ho_role'}=HO_ROLE;
	$headerparametros{'num_trans'}=1;
	my %bodyparametros = ();
	my $soap = $self->{SOAP};
	my $method = SOAP::Data->name('ns1:' . $self->{CALL_NAME})->attr({'xmlns:ns1' => WSURI});
	my @params;
	for my $headerparametro (keys %headerparametros) {
		push @params, SOAP::Data->name($headerparametro => $headerparametros{$headerparametro});
	}
	for my $parametro (keys %parametros) {
		push @params, SOAP::Data->name($parametro => $parametros{$parametro});
	}
	return $soap->call($method => @params)->result;	
}

sub executehb{
	my $self = shift;
	my %parametrosheader = %{$_[0]};
	my %parametrosbody = %{$_[1]};
	$parametrosheader{'SessionID'}=$self->{SESSIONID};
	$parametrosheader{'site_code'}=SITE_CODE;		
	my $soap = $self->{SOAP};
	my $method = SOAP::Data->name('ns1:' . $self->{CALL_NAME})->attr({'xmlns:ns1' => WSURI});
	my @params;
	for my $parametroheader (keys %parametrosheader) {
		push @params, SOAP::Data->name($parametroheader => $parametrosheader{$parametroheader});
	}
	for my $parametrobody (keys %parametrosbody) {
		push @params, SOAP::Data->name($parametrobody => $parametrosbody{$parametrobody});
	}
	LOGGER->debug(dump(\@params));
	return $soap->call($method => @params)->result;	
}


sub executeSOUpdateMeans{
	my $self = shift;
	my $mean = shift;
	
	$parametros{'SessionID'}=$self->{SESSIONID};
	$parametros{'site_code'}=SITE_CODE;		
	
	my $soap = $self->{SOAP};
	my $method = SOAP::Data->name('ns1:' . $self->{CALL_NAME})->attr({'xmlns:ns1' => WSURI});
	my @params;
	#my $soMeanID = SOAP::Data->name('id' => 1);
	#my @TwoStageList;
	#$TwoStageList[0] = SOAP::Data->name('soMeanID' => \$soMeanID);
	my %soMean;
	#$soMean{TwoStageList} = SOAP::Data->name('TwoStageList' => \$TwoStageList[0]);
	$soMean{id} = $mean->{ID};
	$soMean{rule} = $mean->{RULE};
	$soMean{dept_id} = $mean->{DEPT_ID};
	$soMean{employee_type} = 1;
	$soMean{available_amount} = $mean->{AVAILABLE_AMOUNT};
	$soMean{fleet_id} = $mean->{FLEET_ID};
	$soMean{hardware_type} = $mean->{HARDWARE_TYPE};
	$soMean{auttyp} = $mean->{AUTTYP};
	$soMean{pin_code} = 0;
	$soMean{year} = 0;

	if($mean->{AUTTYP} eq 1 && $mean->{HARDWARE_TYPE} eq 6 && $mean->{TYPE} eq 3){
		$soMean{auth_pin_from} = 2;
		$soMean{is_burned} = 0;
		$soMean{opos_plate_check_type} = 1;
		$soMean{num_of_strings} = $mean->{NUM_OF_STRINGS};
		$soMean{allow_id_replacement} = $mean->{NUM_OF_STRINGS};
		$soMean{update_timestamp} = Trate::Lib::Utilidades->getCurrentTimestampMariaDB();
		$soMean{prompt_always_for_viu} = 1;
	} elsif ($mean->{TYPE} eq 3) {
		$soMean{auth_pin_from} = 2;
		$soMean{is_burned} = 0;
		$soMean{opos_plate_check_type} = 1;
		$soMean{num_of_strings} = 1;
		$soMean{allow_id_replacement} = 0;
		$soMean{update_timestamp} = Trate::Lib::Utilidades->getCurrentTimestampMariaDB();
		$soMean{prompt_always_for_viu} = 1;
	}

	#$soMean{model_id} = $mean->{MODEL_ID};
	$soMean{name} = $mean->{NAME};
	#$soMean{odometer} = 0;
	$soMean{plate} = $mean->{PLATE};
	$soMean{status} = $mean->{STATUS};
	$soMean{string} = $mean->{STRING};
	$soMean{type} = $mean->{TYPE};
	$soMean{driver_required} = 5;
	my @a_soMean;
	$a_soMean[0] = SOAP::Data->name('soMean' => \%soMean);
	$params[3] = SOAP::Data->name('a_soMean' => \$a_soMean[0]);
	$params[2] = SOAP::Data->name('SessionID' => $self->{SESSIONID});
	$params[1] = SOAP::Data->name('site_code' => SITE_CODE);
	$params[0] = SOAP::Data->name('num_of_means' => 1);
	
	LOGGER->debug(dump(\@params));
	
	return $soap->call($method => @params)->result;	
}


1;
#EOF
