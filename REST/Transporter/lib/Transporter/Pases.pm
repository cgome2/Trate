package Transporter::Pases;

use Dancer ':syntax';
use Trate::Lib::Constants qw(LOGGER);
use Data::Dump qw(dump);
use Trate::Lib::Pase;
use Data::Structure::Util qw( unbless );

our $VERSION = '0.1';

set serializer => 'JSON';

get '/pases' => sub {
	if(Trate::Lib::Usuarios->verificaToken(request->headers->{token}) eq 0){
		status 401;
		return {error => "Token de sesion invalido ingrese nuevamente al sistema"};
	} else {
		Trate::Lib::Usuarios->renuevaToken(request->headers->{token});
	}
	my $post = from_json( request->body );
	my $return = 0;	
	my $PASE = Trate::Lib::Pase->new();
	$PASE->pase($post->{pase});
	$PASE->viaje($post->{viaje});
	$PASE->camion($post->{camion});
	$PASE->chofer($post->{chofer});
	$return = $PASE->getPase();
	if ($return eq 0){
		status 401;
		return {data => "Pase no disponible o inexistente"};
	} else {
		return $return;
	}
	
};

patch '/pases' => sub {
	if(Trate::Lib::Usuarios->verificaToken(request->headers->{token}) eq 0){
		status 401;
		return {error => "Token de sesion invalido ingrese nuevamente al sistema"};
	} else {
		Trate::Lib::Usuarios->renuevaToken(request->headers->{token});
	}
	my $post = from_json( request->body );
	my $return = 0;	
	my $PASE = Trate::Lib::Pase->new();
	$PASE->pase($post->{pase});
	$PASE->camion($post->{camion});
	$PASE->status($post->{status});
	$PASE->observaciones($post->{observaciones});
	$PASE->supervisor($post->{supervisor});
	$PASE->meanContingencia($post->{mean_contingencia});
	try {
		$return = $PASE->updatePase();
		return ($return eq 1 ?  {data => "OkComputer"} : {data => "NotOkComputer"});
	} catch {
		$return = 0;
		return ($return eq 1 ?  {data => "OkComputer"} : {data => "NotOkComputer"});
	}
	
};


true;
