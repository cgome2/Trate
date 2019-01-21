package Trate::Lib::Mean;

use strict;
use Trate::Lib::ConnectorMariaDB;
use Trate::Lib::WebServicesClient;
use Data::Dump qw(dump);
use Trate::Lib::Constants qw(DEFAULT_FLEET_ID DEFAULT_DEPT_ID LOGGER DEFAULT_RULE);

sub new
{
	my $self = {};
	$self->{NAME} = undef;
	$self->{STRING} = undef;
	$self->{TYPE} = undef;							#2. Tag tipo vehiculo 3. Dispositivo montado al vehiculo 4. Tag tipo despachador
	$self->{ID} = undef;
	$self->{STATUS} = undef;						# 1. inactivo 2. activo
	$self->{RULE} = DEFAULT_RULE;							# Regla default
	$self->{HARDWARE_TYPE} = undef;					# 6. Montado al Vehiculo 1. Tag
	$self->{PUMP} = 0;							
	$self->{EMPLOYEE_TYPE} = 1;
	$self->{PLATE} = undef;
	$self->{MODEL_ID} = 0;
	$self->{FLEET_ID} = DEFAULT_FLEET_ID;
	$self->{DEPT_ID} = DEFAULT_DEPT_ID;
	$self->{AVAILABLE_AMOUNT} = 0.0;
	$self->{ISSUED_DATE} = undef;
	$self->{LAST_USED} = undef;
	$self->{DISABLE_VIU_TWO_STAGE} = 0;			# 1. Desactivar doble autorizacion 2. Desactivar doble autorizacion
	$self->{PROMPT_ALWAYS_FOR_VIU} = 1;			# 1. Requiere doble autorizacion 2. No requiere doble autorizacion
	$self->{SHIFT_INSTANCE_ID} = 0;
	$self->{NR_2STAGE_ELEMENTS}	= 1;
	bless($self);
	return $self;	
}

sub name {
        my ($self) = shift;
        if (@_) { $self->{NAME} = shift }        
        return $self->{NAME};
}

sub string {
        my ($self) = shift;
        if (@_) { $self->{STRING} = shift }        
        return $self->{STRING};
}

sub type {
        my ($self) = shift;
        if (@_) { $self->{TYPE} = shift }        
        return $self->{TYPE};
}

sub id {
        my ($self) = shift;
        if (@_) { $self->{ID} = shift }        
        return $self->{ID};
}

sub status {
        my ($self) = shift;
        if (@_) { $self->{STATUS} = shift }        
        return $self->{STATUS};
}

sub rule {
        my ($self) = shift;
        if (@_) { $self->{RULE} = shift }        
        return $self->{RULE};
}

sub hardwareType {
        my ($self) = shift;
        if (@_) { $self->{HARDWARE_TYPE} = shift }        
        return $self->{HARDWARE_TYPE};
}

sub plate {
        my ($self) = shift;
        if (@_) { $self->{PLATE} = shift }        
        return $self->{PLATE};
}

sub auttyp {
        my ($self) = shift;
        if (@_) { $self->{AUTTYP} = shift }        
        return $self->{AUTTYP};
}

sub employeeType {
	my ($self) = shift;
	if (@_) {$self->{EMPLOYEE_TYPE} = shift }
	return $self->{EMPLOYEE_TYPE};
}

sub availableAmount {
	my ($self) = shift;
	if (@_) {$self->{AVAILABLE_AMOUNT} = shift }
	return $self->{AVAILABLE_AMOUNT};
}

sub modelId {
	my ($self) = shift;
	if (@_) {$self->{MODEL_ID} = shift }
	return $self->{MODEL_ID};
}

sub fleetId {
	my ($self) = shift;
	if (@_) {$self->{FLEET_ID} = shift }
	return $self->{FLEET_ID};
}

sub deptId {
	my ($self) = shift;
	if (@_) {$self->{DEPT_ID} = shift }
	return $self->{DEPT_ID};
}

sub odometer {
	my ($self) = shift;
	if (@_) {$self->{ODOMETER} = shift }
	return $self->{ODOMETER};
}

sub nr2StageElements {
	my ($self) = shift;
	if (@_) { $self->{NR_2STAGE_ELEMENTS} = shift }
	return $self->{NR_2STAGE_ELEMENTS};
}

sub createMean {
	my $self = shift;
	my $connector = Trate::Lib::ConnectorMariaDB->new();
	my $result = 0;
	my $preps = "
		INSERT INTO means (NAME,string,TYPE,id,status,rule,hardware_type,plate,fleet_id,dept_id,employee_type,auttyp) VALUES ('" . 
			$self->{NAME} . "','" .
			$self->{STRING} . "','" .
			$self->{TYPE} . "'," .
			"NULL,'" .
			1 . "','" .
			$self->{RULE} . "','" .
			$self->{HARDWARE_TYPE} . "','" .
			$self->{PLATE} . "','" .
			$self->{FLEET_ID} . "','" .
			$self->{DEPT_ID} . "','" .
			$self->{EMPLOYEE_TYPE} . "','" .
			$self->{AUTTYP} . "')";
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

sub createMeanOrcu {
	my $self = shift;
	my $wsc = Trate::Lib::WebServicesClient->new();
	$wsc->callName("SOUpdateMeans");
	$wsc->sessionId();
	try {
		my $result = $wsc->executeSOUpdateMeans($self);
		($result->{rc} eq 0 ? return 1 : return 0);
	} catch {
		return 0;
	}
}

sub updateMean {
	my $self = shift;
	my $connector = Trate::Lib::ConnectorMariaDB->new();
	my $preps = " UPDATE means SET " .
		"id = '" . $self->{ID} . "'," .
		"rule = '" . $self->{RULE} . "'," . 
		"dept_id = '" . $self->{DEPT_ID} . "'," .
		"employee_type = '" . $self->{EMPLOYEE_TYPE} . "'," . 
		"available_amount = '" . $self->{AVAILABLE_AMOUNT} . "'," .   
		"fleet_id = '" . $self->{FLEET_ID} . "'," .   
		"hardware_type = '" . $self->{HARDWARE_TYPE} . "'," .   
		"auttyp = '" . $self->{AUTTYP} . "'," .   
		"model_id = '" . $self->{MODEL_ID} . "'," .   
		"name = '" . $self->{NAME} . "'," .   
		"odometer = '" . $self->{ODOMETER} . "'," .   
		"plate = '" . $self->{PLATE} . "'," .   
		"status = " . (length($self->{STATUS}) gt 0 ? $self->{STATUS} : "status") . "," .   
		"string = '" . $self->{STRING} . "'," .   
		"type = '" . $self->{TYPE} . "' WHERE id='" . $self->{ID} . "'";
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

sub activarMean {
	my $self = shift;
	my %params = (
		SessionID => "",
		site_code => "",
		mean_name => $self->{NAME},
		new_state => 2,
	);
	my $wsc = Trate::Lib::WebServicesClient->new();
	$wsc->callName("SOUpdateMeanStatus");
	$wsc->sessionId();
	my $result = $wsc->execute(\%params);
	LOGGER->info(dump($result));
	return $result;
}

sub desactivarMean {
	my $self = shift;
	my %params = (
		SessionID => "",
		site_code => "",
		mean_name => $self->{NAME},
		new_state => 1,
	);
	my $wsc = Trate::Lib::WebServicesClient->new();
	$wsc->callName("SOUpdateMeanStatus");
	$wsc->sessionId();
	my $result = $wsc->execute(\%params);
	LOGGER->info(dump($result));
	return $result;
}

sub getMeans{
	my $self = shift;
	my $connector = Trate::Lib::ConnectorMariaDB->new();
	my $preps = "SELECT NAME,string,TYPE,id,status,rule,hardware_type,plate,fleet_id,dept_id,auttyp FROM means"; 
	LOGGER->debug("Ejecutando sql[ ", $preps, " ]");
	my $sth = $connector->dbh->prepare($preps);
	$sth->execute() or die LOGGER->fatal("NO PUDO EJECUTAR EL SIGUIENTE COMANDO en MARIADB:orpak: $preps");
	my @means;
	my $label;
	while (my $ref = $sth->fetchrow_hashref()) {
		$label = getTypeMeanForView($ref);
		%{$ref} = ( %{$ref}, label => $label);
    	push @means,$ref;
	}
	$sth->finish;
	$connector->destroy();
	return \@means;	
}

sub getMeansFromAuttyp{
	my $self = shift;
	my $connector = Trate::Lib::ConnectorMariaDB->new();
	my $preps = "SELECT NAME,string,TYPE,id,status,rule,hardware_type,plate,fleet_id,dept_id,auttyp FROM means WHERE auttyp=" . $self->{AUTTYP};
	LOGGER->debug("Ejecutando sql[ ", $preps, " ]");
	my $sth = $connector->dbh->prepare($preps);
	$sth->execute() or die LOGGER->fatal("NO PUDO EJECUTAR EL SIGUIENTE COMANDO en MARIADB:orpak: $preps");
	my @means;
	while (my $ref = $sth->fetchrow_hashref()) {
    	push @means,$ref;
	}
	LOGGER->debug({dump(@means)});
	$sth->finish;
	$connector->destroy();
	return \@means;	
}

sub getMeanFromId {
	my $self = shift;
	my $connector = Trate::Lib::ConnectorMariaDB->new();
	my $preps = "SELECT NAME,string,TYPE,id,status,rule,hardware_type,plate,fleet_id,dept_id,auttyp FROM means WHERE id='" . $self->{ID} . "' LIMIT 1"; 
	LOGGER->debug("Ejecutando sql[ ", $preps, " ]");
	my $sth = $connector->dbh->prepare($preps);
	$sth->execute() or die LOGGER->fatal("NO PUDO EJECUTAR EL SIGUIENTE COMANDO en MARIADB:orpak: $preps");
	my $row = $sth->fetchrow_hashref();
	$sth->finish;
	$connector->destroy();
	if($row){
		return $row;
	} else {
		return 0;
	}
}

sub getDespachadores {
	my $self = shift;
	my $connector = Trate::Lib::ConnectorMariaDB->new();
	my $preps = "SELECT NAME,id FROM means " . 
				"WHERE auttyp='" . $self->{AUTTYP} . 
				"AND hardware_type='" . $self->{HARDWARE_TYPE} .
				"AND TYPE='" . $self->{TYPE} . "' LIMIT 1"; 
	LOGGER->debug("Ejecutando sql[ ", $preps, " ]");
	my $sth = $connector->dbh->prepare($preps);
	$sth->execute() or die LOGGER->fatal("NO PUDO EJECUTAR EL SIGUIENTE COMANDO en MARIADB:orpak: $preps");
	my @means;
	while (my $ref = $sth->fetchrow_hashref()) {
    	push @means,$ref;
	}
	LOGGER->debug({dump(@means)});
	$sth->finish;
	$connector->destroy();
	return \@means;	
}


sub fillMeanFromId {
	my $self = shift;
	my $connector = Trate::Lib::ConnectorMariaDB->new();
	my $preps = "SELECT NAME,string,TYPE,id,status,rule,hardware_type,plate,fleet_id,dept_id,auttyp FROM means WHERE id='" . $self->{ID} . "' LIMIT 1"; 
	LOGGER->debug("Ejecutando sql[ ", $preps, " ]");
	my $sth = $connector->dbh->prepare($preps);
	$sth->execute() or die LOGGER->fatal("NO PUDO EJECUTAR EL SIGUIENTE COMANDO en MARIADB:orpak: $preps");
	my $row = $sth->fetchrow_hashref();
	$sth->finish;
	$connector->destroy();
	$self->{NAME}=$row->{NAME};
	$self->{STRING}=$row->{string};
	$self->{TYPE}=$row->{TYPE};
	$self->{STATUS}=$row->{status};
	$self->{RULE}=$row->{rule};
	$self->{HARDWARE_TYPE}=$row->{hardware_type};
	$self->{PLATE}=$row->{plate};
	$self->{FLEET_ID}=$row->{fleet_id};
	$self->{DEPT_ID}=$row->{dept_id};
	$self->{AUTTYP}=$row->{auttyp};
	return $self;
}

sub assignRuleToVehicleOrcu{
	my $self = shift;

	my %params = (

		SessionID => "",
		site_code => "",
        num_of_means => 1,
        #Optional
		#Zero or more repetitions
		soMean => (
					id => $self->{ID},
					rule => $self->{RULE},
					dept_id => $self->{DEPT_ID},
					employee_type => $self->{EMPLOYEE_TYPE},
					available_amount => $self->{AVAILABLE_AMOUNT},
					fleet_id => $self->{FLEET_ID},
					hardware_type => $self->{HARDWARE_TYPE},
					auttyp => $self->{AUTTYP},
					model_id => $self->{MODEL_ID},
					#Optional
					name => $self->{NAME},
					odometer => $self->{ODOMETER},
					#Optional
					plate => $self->{PLATE},
					status => $self->{STATUS},
					#Optional
					string => $self->{STRING},
					type => $self->{TYPE},
					nr_2stage_elements => $self->{NR_2STAGE_ELEMENTS},
					#Optional
					TwoStageList => (
								#Zero or more repetitions
								soMeanID => (
											id => 1,
											),
								),
				),
	);
	my $wsc = Trate::Lib::WebServicesClient->new();
	$wsc->callName("SOUpdateMeans");
	$wsc->sessionId();
	my $result = $wsc->execute(\%params);
	LOGGER->debug(dump($result));
	return $result;	
}

sub getTypeMeanForView ($){
	my $mean = shift;
	my $label = "";
	#my %mean = %{$ref};
	LOGGER->debug(dump($mean));
	if($mean->{auttyp} eq 1 && $mean->{hardware_type} eq 6 && $mean->{TYPE} eq 3){
		$label = "Fuelopass";
	}
	elsif($mean->{auttyp} eq 23 && $mean->{hardware_type} eq 6 && $mean->{TYPE} eq 3){
		$label = "VIU35 NT";
	}
	elsif($mean->{auttyp} eq 26 && $mean->{hardware_type} eq 6 && $mean->{TYPE} eq 3){
		$label = "DATAPASS";
	}
	elsif($mean->{auttyp} eq 6 && $mean->{hardware_type} eq 1 && $mean->{TYPE} eq 4){
		$label = "Despachador";
	}
	elsif($mean->{auttyp} eq 6 && $mean->{hardware_type} eq 1 && $mean->{TYPE} eq 2){
		$label = "Tag de Contingencia";
	}
	elsif($mean->{auttyp} eq 21 && $mean->{hardware_type} eq 1 && $mean->{TYPE} eq 2){
		$label = "Jarreo";
	}
	else {
		$label = "Sistema";
	}
	return $label;
}

1;
#EOF