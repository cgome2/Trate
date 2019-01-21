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

get '/means/types/mono' => sub {
	my $meansOptions = 
	[
		{"value" => {"TYPE" => 3,"hardware_type" => "6","auttyp" => 1},"label" => "Fuelopass"},
		{"value" => {"TYPE" => 3,"hardware_type" => "6","auttyp" => 23},"label" => "VIU35 NT"},
		{"value" => {"TYPE" => 3,"hardware_type" => "6","auttyp" => 26},"label" => "DATAPASS"},
		{"value" => {"TYPE" => 2,"hardware_type" => "1","auttyp" => 6},"label" => "Tag de Contingencia"},
		{"value" => {"TYPE" => 2,"hardware_type" => "1","auttyp" => 21},"label" => "Jarreo"},
		{"value" => {"TYPE" => 4,"hardware_type" => "1","auttyp" => 6},"label" => "Despachador"}
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
	
	if(
		($post->{TYPE} eq 3 && $post->{hardware_type} eq 6 && $post->{auttyp} eq 1) ||
		($post->{TYPE} eq 3 && $post->{hardware_type} eq 6 && $post->{auttyp} eq 23) ||
		($post->{TYPE} eq 3 && $post->{hardware_type} eq 6 && $post->{auttyp} eq 26) ||
		($post->{TYPE} eq 4 && $post->{hardware_type} eq 1 && $post->{auttyp} eq 6) ||
		($post->{TYPE} eq 2 && $post->{hardware_type} eq 1 && $post->{auttyp} eq 6) ||
		($post->{TYPE} eq 2 && $post->{hardware_type} eq 1 && $post->{auttyp} eq 21)
	){
		my $MEAN = Trate::Lib::Mean->new();
		LOGGER->debug(dump($MEAN));
		$MEAN->name($post->{NAME});
		$MEAN->string($post->{string});
		$MEAN->type($post->{TYPE});
		$MEAN->hardwareType($post->{hardware_type});
		$MEAN->plate($post->{plate});
		$MEAN->auttyp($post->{auttyp});
		if($MEAN->createMean() eq 1){
			return {message => "OKComputer"};
		} else {
			status 405;
			return {message => "NotOkComputer"};
		}
	} else {
		status 500;
		return {message => "Tipo de dispositivo inexistente"};
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

	if(
		($post->{TYPE} eq 3 && $post->{hardware_type} eq 6 && $post->{auttyp} eq 1) ||
		($post->{TYPE} eq 3 && $post->{hardware_type} eq 6 && $post->{auttyp} eq 23) ||
		($post->{TYPE} eq 3 && $post->{hardware_type} eq 6 && $post->{auttyp} eq 26) ||
		($post->{TYPE} eq 4 && $post->{hardware_type} eq 1 && $post->{auttyp} eq 6) ||
		($post->{TYPE} eq 2 && $post->{hardware_type} eq 1 && $post->{auttyp} eq 6) ||
		($post->{TYPE} eq 2 && $post->{hardware_type} eq 1 && $post->{auttyp} eq 21)
	){
		my $MEAN = Trate::Lib::Mean->new();
		$MEAN->{ID} = $post->{id};
		$MEAN->fillMeanFromId();
		LOGGER->debug(dump($MEAN));
		$MEAN->{NAME} = $post->{NAME};
		$MEAN->{STRING} = $post->{string};
		$MEAN->{TYPE} = $post->{TYPE};
		if($post->{TYPE} eq 2 && $post->{hardware_type} eq 1 && $post->{auttyp} eq 21){
			$MEAN->{STATUS} = $post->{status};	
		}
		$MEAN->{HARDWARE_TYPE} = $post->{hardware_type};
		$MEAN->{PLATE} = $post->{plate};
		$MEAN->{AUTTYP} = $post->{auttyp};
	
		if($MEAN->updateMean() eq 1){
			return {message => "OKComputer"};
		} else {
			status 405;
			return {message => "NotOkComputer"};
		}
	} else {
		status 500;
		return {message => "Tipo de dispositivo inexistente"};
	}	
};

true;
