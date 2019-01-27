package Transporter::Pases;

use Dancer ':syntax';
use Trate::Lib::Constants qw(LOGGER);
use Data::Dump qw(dump);
use Trate::Lib::Pase;
use Data::Structure::Util qw( unbless );

our $VERSION = '0.1';

set serializer => 'JSON';

get '/pases/:pase' => sub {
	if(Trate::Lib::Usuarios->verificaToken(request->headers->{token}) eq 0){
		status 401;
		return {error => "Token de sesion invalido ingrese nuevamente al sistema"};
	} else {
		Trate::Lib::Usuarios->renuevaToken(request->headers->{token});
	}
	my $pase = params->{pase};

	my $return = 0;	
	my $PASE = Trate::Lib::Pase->new();
	$PASE->pase($pase);
	$return = $PASE->getPaseByPase();
	if ($return eq 0){
		status 200;
		return {message => "Pase inexistente"};
	} else {
		delete $return->{contingencia};
		return $return;
	}	
};

get '/pases' => sub {
	my $usuario;
	if(Trate::Lib::Usuarios->verificaToken(request->headers->{token}) eq 0){
		status 401;
		return {error => "Token de sesion invalido ingrese nuevamente al sistema"};
	} else {
		Trate::Lib::Usuarios->renuevaToken(request->headers->{token});
		$usuario = Trate::Lib::Usuarios->getUsuarioByToken(request->headers->{token});
	}
	my $pase = params->{pase};
	my $camion = params->{camion};

	my $return = 0;	
	my $PASE = Trate::Lib::Pase->new();
	$PASE->pase($pase);
	$PASE->camion($camion);
	$return = $PASE->getPase();
	if ($return eq 0){
		status 200;
		return {message => "Pase no disponible o inexistente"};
	} else {
		delete $return->{contingencia};
		my @retorno = ();
		push @retorno, $return;
		return \@retorno;
	}
	
};

patch '/pases' => sub {
	my $usuario;
	if(Trate::Lib::Usuarios->verificaToken(request->headers->{token}) eq 0){
		status 401;
		return {error => "Token de sesion invalido ingrese nuevamente al sistema"};
	} else {
		Trate::Lib::Usuarios->renuevaToken(request->headers->{token});
		$usuario = Trate::Lib::Usuarios->getUsuarioByToken(request->headers->{token});
	}
	my $post = from_json( request->body );
	LOGGER->debug(dump($post));
	my $return = 0;	
	my $PASE = Trate::Lib::Pase->new();
	$PASE->pase($post->{pase_id});
	$PASE->camion($post->{camion});
	$PASE->status($post->{status});
	$PASE->observaciones($post->{observaciones});
	$PASE->supervisor($usuario->{numero_empleado});	
	$PASE->meanContingencia($post->{mean_contingencia});

	try {
		$return = $PASE->updatePase();
		LOGGER->debug("el return es: [" . $return . "]");
		if($return eq 0){
			status 500;
			return {message => "NotOkComputer"};
		} else {
			status 200;
			return {message => "OkComputer"};
		}
	} catch {
		$return = 0;
		status 500;
		return ($return eq 1 ?  {message => "OkComputer"} : {message => "NotOkComputer"});
	}
};
