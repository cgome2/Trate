package Transporter::Productos;

use Dancer ':syntax';
use Trate::Lib::Constants qw(LOGGER);
use Trate::Lib::Productos;
use Trate::Lib::Usuarios;

use Try::Catch;
use Data::Dump qw(dump);
use Data::Structure::Util qw( unbless );

our $VERSION = '0.1';

set serializer => 'JSON';

get '/productos' => sub {
	if(Trate::Lib::Usuarios->verificaToken(request->headers->{token}) eq 0){
		status 401;
		return {error => "Token de sesion invalido ingrese nuevamente al sistema"};
	} else {
		Trate::Lib::Usuarios->renuevaToken(request->headers->{token});
	}
	my $productos = Trate::Lib::Productos->new();
	return $productos->getProductos();	
};

get '/productos/:id' => sub {
	if(Trate::Lib::Usuarios->verificaToken(request->headers->{token}) eq 0){
		status 401;
		return {error => "Token de sesion invalido ingrese nuevamente al sistema"};
	} else {
		Trate::Lib::Usuarios->renuevaToken(request->headers->{token});
	}
	
	my $p = params->{id};
	
	my $productos = Trate::Lib::Productos->new();
	$productos->id($p);
	return $productos->getProductoById();
};

patch '/productos/:id' => sub {
	my $usuario;
	if(Trate::Lib::Usuarios->verificaToken(request->headers->{token}) eq 0){
		status 401;
		return {error => "Token de sesion invalido ingrese nuevamente al sistema"};
	} else {
		Trate::Lib::Usuarios->renuevaToken(request->headers->{token});
		$usuario = Trate::Lib::Usuarios->getUsuarioByToken(request->headers->{token});
	}
	
	my $p = params->{id};
	my $post = from_json( request->body );

	my $productos = Trate::Lib::Productos->new();
	$productos->id($p);
	$productos->nextUpdate($post->{next_update});
	$productos->nextPrice($post->{next_price});
	$productos->usuario($usuario->{numero_empleado});
	if($productos->programarCambioPrecio() eq 1){
		status 200;
		return {message => "Cambio de precio programado correctamente"};
	} else {
		status 500;
		return {message => "Error al programar cambio de precio"};
	}
};

true;
