package Transporter::Usuarios;

use Dancer ':syntax';
use Try::Catch;
use Data::Dump qw(dump);
use Data::Structure::Util qw( unbless );
use Trate::Lib::Constants qw(LOGGER);
use Trate::Lib::Usuarios;
use Trate::Lib::Utilidades;

our $VERSION = '0.1';

set serializer => 'JSON';

post '/login' => sub {
	my $post;
	my $USUARIOS = Trate::Lib::Usuarios->new();
	try {
		$post = from_json(request->body);
		$USUARIOS->usuario($post->{usuario});
		$USUARIOS->password($post->{password});
		if($USUARIOS->login() eq 1){
			delete $USUARIOS->{password};
			return unbless($USUARIOS);
		} else {
			status 404	;
			return {message => "Usuario o password incorrectos"};
		}	
	} catch {
		status 400;
		LOGGER->fatal($@);
		return {message => "Error en la estructura del body"};
	};
};

del '/logout' => sub {
	if(Trate::Lib::Usuarios->verificaToken(request->headers->{token}) eq 0){
		status 401;
		return {error => "Token de sesion invalido ingrese nuevamente al sistema"};
	}
	my $USUARIOS = Trate::Lib::Usuarios->new();
	$USUARIOS->logout(request->headers->{token});
	return {message => "Fin de sesion correcto"};
};

get '/usuarios' => sub {
	my $return = 0;
	if(Trate::Lib::Usuarios->verificaToken(request->headers->{token}) eq 0){
		status 401;
		return {error => "Token de sesion invalido ingrese nuevamente al sistema"};
	} else  {
		Trate::Lib::Usuarios->renuevaToken(request->headers->{token});
	}

	my $USUARIOS = Trate::Lib::Usuarios->new();
	try {
		$return = $USUARIOS->getUsuarios();
		return $return;
	} catch {
		status 401;
		$return = {message => "Error al obtener la lista de usuarios"};
		return $return;
	};
};

get '/usuarios/:idusuarios' => sub {
	if(Trate::Lib::Usuarios->verificaToken(request->headers->{token}) eq 0){
		status 401;
		return {error => "Token de sesion invalido ingrese nuevamente al sistema"};
	} else  {
		Trate::Lib::Usuarios->renuevaToken(request->headers->{token});
	}
	my $return = 0;
	my $USUARIOS = Trate::Lib::Usuarios->new();
	$USUARIOS->idusuarios(params->{idusuarios});
	$return = $USUARIOS->getUsuariosFromId();
	if ($return eq 0){
		status 404;
		return {message => "Usuario no existente"};
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
	$USUARIOS->numeroEmpleado($post->{numero_empleado});
	if($USUARIOS->addUsuarios() eq 1){
		return {message => "Exito"};
	} else {
		status 405;
		return {message => "Falla"};
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
	$USUARIOS->numeroEmpleado($post->{numero_empleado});
	$USUARIOS->password($post->{password});
	if($USUARIOS->updateUsuarios() eq 1){
		return {message => "Exito"};
	} else {
		status 401;
		return {message => "Falla"};
	}
};

put '/usuarios/cambiarpassword' => sub {
	my $usuario;
	if(Trate::Lib::Usuarios->verificaToken(request->headers->{token}) eq 0){
		status 401;
		return {error => "Token de sesion invalido ingrese nuevamente al sistema"};
	} else {
		Trate::Lib::Usuarios->renuevaToken(request->headers->{token});
		$usuario = Trate::Lib::Usuarios->getUsuarioByToken(request->headers->{token});
	}	

	my $post = from_json( request->body );
	if ($usuario->{password} eq Trate::Lib::Utilidades->getSha1($post->{actual})){
	 	$usuario->{password} = $post->{nueva};
	 	LOGGER->info(dump($usuario));
		bless $usuario, "Trate::Lib::Usuarios";
		LOGGER->debug(ref $usuario);
		if($usuario->updateUsuarios() eq 1){
			return {message => "Exito"};
		} else {
			status 401;
			return {message => "Falla"};
		}
		return {message => "Datos incorrectos"};
	}
};

true;
