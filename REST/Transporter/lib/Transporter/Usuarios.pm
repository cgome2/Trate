package Transporter::Usuarios;

use Dancer ':syntax';
use Trate::Lib::Constants qw(LOGGER);
use Data::Dump qw(dump);
use Trate::Lib::Usuarios;
use Data::Structure::Util qw( unbless );

our $VERSION = '0.1';

set serializer => 'JSON';

post '/login' => sub {
	my $USUARIOS = Trate::Lib::Usuarios->new();
	my $post = from_json( request->body );
	$USUARIOS->usuario($post->{usuario});
	$USUARIOS->password($post->{password});
	if($USUARIOS->login() eq 1){
		return unbless($USUARIOS);
	} else {
		status 401;
		return {data => "Usuario o password incorrectos"};
	}
};

del '/logout' => sub {
	if(Trate::Lib::Usuarios->verificaToken(request->headers->{token}) eq 0){
		status 401;
		return {error => "Token de sesion invalido ingrese nuevamente al sistema"};
	}
	my $USUARIOS = Trate::Lib::Usuarios->new();
	return {data => $USUARIOS->logout(request->headers->{token})};
};

get '/usuarios' => sub {
	my $return = 0;
	if(Trate::Lib::Usuarios->verificaToken(request->headers->{token}) eq 0){
		status 401;
		return {error => "Token de sesion invalido ingrese nuevamente al sistema"};
	}
	my $USUARIOS = Trate::Lib::Usuarios->new();
	try {
		$return = $USUARIOS->getUsuarios();
		LOGGER->debug($return);
	} catch {
		status 401;
		$return = {error_message => "please implement me properly"};
	} finally {
		return $return;
	}
};

true;
