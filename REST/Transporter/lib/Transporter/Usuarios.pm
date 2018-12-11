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
		return $return;
	} catch {
		status 401;
		$return = {error_message => "please implement me properly"};
		return $return;
	};
};

get '/usuarios/:idusuarios' => sub {
	if(Trate::Lib::Usuarios->verificaToken(request->headers->{token}) eq 0){
		status 401;
		return {error => "Token de sesion invalido ingrese nuevamente al sistema"};
	} else {
		Trate::Lib::Usuarios->renuevaToken(request->headers->{token});
	}
	my $return = 0;
	my $USUARIOS = Trate::Lib::Usuarios->new();
	$USUARIOS->idusuarios(params->{idusuarios});
	$return = $USUARIOS->getUsuariosFromId();
	if ($return eq 0){
		status 401;
		return {data => "Usuario no existente"};
	} else {
		return $return;
	}
};

put '/usuarios' => sub {
	my $USUARIOS = Trate::Lib::Usuarios->new();
	my $post = from_json( request->body );
	$USUARIOS->usuario($post->{usuario});
	$USUARIOS->nombre($post->{nombre});
	$USUARIOS->nivel($post->{nivel});
	$USUARIOS->estatus($post->{estatus});
	$USUARIOS->password($post->{password});
	if($USUARIOS->addUsuarios() eq 1){
		return {data => "OKComputer"};
	} else {
		status 401;
		return {data => "NotOkComputer"};
	}
};

patch '/usuarios' => sub {
	my $USUARIOS = Trate::Lib::Usuarios->new();
	my $post = from_json( request->body );
	$USUARIOS->idusuarios($post->{idusuarios});
	$USUARIOS->usuario($post->{usuario});	
	$USUARIOS->nombre($post->{nombre});
	$USUARIOS->nivel($post->{nivel});
	$USUARIOS->estatus($post->{estatus});
	$USUARIOS->password($post->{password});
	if($USUARIOS->updateUsuarios() eq 1){
		return {data => "OKComputer"};
	} else {
		status 401;
		return {data => "NotOkComputer"};
	}
};


true;
