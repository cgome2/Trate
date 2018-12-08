package Transporter::Pases;

use Dancer ':syntax';
use Trate::Lib::Constants qw(LOGGER);
use Data::Dump qw(dump);
use Trate::Lib::Pase;
use Data::Structure::Util qw( unbless );

our $VERSION = '0.1';

set serializer => 'JSON';

post '/pases' => sub {
	if(Trate::Lib::Usuarios->verificaToken(request->headers->{token}) eq 0){
		status 401;
		return {error => "Token de sesion invalido ingrese nuevamente al sistema"};
	} else {
		Trate::Lib::Usuarios->renuevaToken(request->headers->{token});
	}
	my $post = from_json( request->body );
	
	my $PASE = Trate::Lib::Pase->new();
	$PASE->pase($post->{pase});
	$PASE->viaje($post->{viaje});
	$PASE->camion($post->{camion});
	$PASE->chofer($post->{chofer});
	$PASE->status($post->{status});
};

true;
