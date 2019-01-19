package Transporter::Means;

use Dancer ':syntax';
use Trate::Lib::Constants qw(LOGGER);
use Trate::Lib::Mean;
use Data::Dump qw(dump);
use List::Util qw(all);


our $VERSION = '0.1';

set serializer => 'JSON';

get '/' => sub {
    template 'index';
};

get '/means' => sub {
	if(Trate::Lib::Usuarios->verificaToken(request->headers->{token}) eq 0){
		status 401;
		return {error => "Token de sesion invalido ingrese nuevamente al sistema"};
	} else {
		Trate::Lib::Usuarios->renuevaToken(request->headers->{token});
	}
	my $MEAN = Trate::Lib::Mean->new();
	my $means = $MEAN->getMeans();
	return $means;
};

get '/means/types' => sub {
	my $meansOptions = 
	[
		{
		"TYPE" => 3,
		"label" => "Dispositivo montado en vehículo",
		"hardware_types" => 
			[
				{
					"hardware_type" => 6,
					"label" => "Vehículo",
					"auttypes" => [
						{"auttyp" => 1,"label" => "Fuelopass"},
						{"auttyp" => 10,"label" => "TRU"},
						{"auttyp" => 11,"label" => "VIU3"},
						{"auttyp" => 12,"label" => "VIU35 E"},
						{"auttyp" => 13,"label" => "VIU35 NT"},
						{"auttyp" => 14,"label" => "FP HS"},
						{"auttyp" => 15,"label" => "DP only"},
						{"auttyp" => 16,"label" => "VIU 4"},					
						{"auttyp" => 17,"label" => "FP + DP"},					
						{"auttyp" => 18,"label" => "VIU 45"},					
						{"auttyp" => 19,"label" => "FP HS + DP"},					
						{"auttyp" => 20,"label" => "URD"},					
						{"auttyp" => 21,"label" => "URD + DP"},					
						{"auttyp" => 22,"label" => "VIU 35"}
					]
				}
			]
		},
		{
		"TYPE" => 2,
		"label" => "Dispositivo de mano del usuario",
		"hardware_types" =>
			[
				{
					"hardware_type" => 1,
					"label" => "Despacho de combustible",
					"auttypes" => [
						{"auttyp" => 6,"label" => "Tag de Contingencia"},	
						{"auttyp" => 21,"label" => "Jarreo"}
					]
				},
				{
					"hardware_type" => 2,
					"label" => "Despachador",
					"auttypes" => [
						{"auttyp" => 6,"label" => "Despachador"}	
					]
				}
			]
		}
	];
	return $meansOptions;
};

get '/means/:id' => sub {
	if(Trate::Lib::Usuarios->verificaToken(request->headers->{token}) eq 0){
		status 401;
		return {error => "Token de sesion invalido ingrese nuevamente al sistema"};
	} else {
		Trate::Lib::Usuarios->renuevaToken(request->headers->{token});
	}
    my $id = params->{id};
    my $mean = 0;
    my $MEAN = Trate::Lib::Mean->new();
    $MEAN->id($id);
    $mean = $MEAN->getMeanFromId();
	if ($mean eq 0){
		status 404;
		return {message => "Mean no existente"};
	} else {
		return $mean;
	}
};

get '/means/auttyp/:auttyp' => sub {
	if(Trate::Lib::Usuarios->verificaToken(request->headers->{token}) eq 0){
		status 401;
		return {error => "Token de sesion invalido ingrese nuevamente al sistema"};
	} else {
		Trate::Lib::Usuarios->renuevaToken(request->headers->{token});
	}
	my $auttyp = params->{auttyp};
    if(all { $_ ne $auttyp } (20)) {
	    status 405;
		return {message => "Tipo de Mean inválido"};
	}
	my $means;
	my $MEAN = Trate::Lib::Mean->new();
	$MEAN->auttyp($auttyp);
	$means = $MEAN->getMeansFromAuttyp();
	if($means eq 0){
		status 404;
		return {message => "Means inexistentes"};
	} else {
		return $means;
	}
};

put '/means' => sub {
	if(Trate::Lib::Usuarios->verificaToken(request->headers->{token}) eq 0){
		status 401;
		return {error => "Token de sesion invalido ingrese nuevamente al sistema"};
	} else {
		Trate::Lib::Usuarios->renuevaToken(request->headers->{token});
	}
	my $request = Dancer::Request->new(env => \%ENV);
	my $post = from_json( request->body );
	my $MEAN = Trate::Lib::Mean->new();
	$MEAN->name($post->{name});
	$MEAN->string($post->{string});
	$MEAN->type($post->{type});
	$MEAN->id($post->{id});
	$MEAN->status($post->{status});
	$MEAN->rule($post->{rule});
	$MEAN->hardwareType($post->{hardware_type});
	$MEAN->plate($post->{plate});
	$MEAN->fleetId($post->{fleet_id});
	$MEAN->deptId($post->{dept_id});
	$MEAN->auttyp($post->{auttyp});

	if($MEAN->createMean() eq 1){
		return {message => "OKComputer"};
	} else {
		status 405;
		return {message => "NotOkComputer"};
	}
};

patch '/means' => sub {
	if(Trate::Lib::Usuarios->verificaToken(request->headers->{token}) eq 0){
		status 401;
		return {error => "Token de sesion invalido ingrese nuevamente al sistema"};
	} else {
		Trate::Lib::Usuarios->renuevaToken(request->headers->{token});
	}
	my $request = Dancer::Request->new(env => \%ENV);
	my $post = from_json( request->body );

	LOGGER->info(dump($post));


	my $MEAN = Trate::Lib::Mean->new();
	$MEAN->{NAME} = $post->{NAME};
	$MEAN->{STRING} = $post->{string};
	$MEAN->{TYPE} = $post->{TYPE};
	$MEAN->{ID} = $post->{id};
	$MEAN->{STATUS} = $post->{status};
	$MEAN->{RULE} = $post->{rule};
	$MEAN->{HARDWARE_TYPE} = $post->{hardware_type};
	$MEAN->{PLATE} = $post->{plate};
	$MEAN->{FLEET_ID} = $post->{fleet_id};
	$MEAN->{DEPT_ID} = $post->{dept_id};
	$MEAN->{AUTTYP} = $post->{auttyp};
	LOGGER->info(dump($MEAN));

	if($MEAN->updateMean() eq 1){
		return {message => "OKComputer"};
	} else {
		status 405;
		return {message => "NotOkComputer"};
	}
	
};

true;
