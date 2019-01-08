package Transporter::TransaccionManual;

use Dancer ':syntax';
use Trate::Lib::Constants qw(LOGGER);
use Data::Dump qw(dump);
use List::Util qw(all);


our $VERSION = '0.1';

set serializer => 'JSON';

get '/bombas' => sub {
	if(Trate::Lib::Usuarios->verificaToken(request->headers->{token}) eq 0){
		status 401;
		return {error => "Token de sesion invalido ingrese nuevamente al sistema"};
	} else {
		Trate::Lib::Usuarios->renuevaToken(request->headers->{token});
	}
	my @bombas = ();
	push @bombas, {'id_bomba' => 1, 'bomba' => 'Posicion de carga 1'};
	push @bombas, {'id_bomba' => 2, 'bomba' => 'Posicion de carga 2'};
	return \@bombas;
};

get '/productos' => sub {
	if(Trate::Lib::Usuarios->verificaToken(request->headers->{token}) eq 0){
		status 401;
		return {error => "Token de sesion invalido ingrese nuevamente al sistema"};
	} else {
		Trate::Lib::Usuarios->renuevaToken(request->headers->{token});
	}
	my @productos = ();
	push @productos, {'id_producto' => 1, 'bomba' => 'Diesel'};
	return \@productos;
};

get '/despachadores' => sub {
	if(Trate::Lib::Usuarios->verificaToken(request->headers->{token}) eq 0){
		status 401;
		return {error => "Token de sesion invalido ingrese nuevamente al sistema"};
	} else {
		Trate::Lib::Usuarios->renuevaToken(request->headers->{token});
	}
	my @despachadores = ();
	push @despachadores, {'mean_id' => 1, 'NAME' => 'Despachador 1'};
	push @despachadores, {'mean_id' => 2, 'NAME' => 'Despachador 2'};
	return \@despachadores;
};

true;
