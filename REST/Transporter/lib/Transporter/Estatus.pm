package Transporter::Estatus;

use Dancer ':syntax';
use Trate::Lib::Tanques;
use Trate::Lib::Bombas;
use Trate::Lib::Transacciones;
use Trate::Lib::Constants qw(LOGGER ORCUURL);
use Trate::Lib::WebServicesClient;
use Data::Dump qw(dump);
use List::Util qw(all);


our $VERSION = '0.1';

set serializer => 'JSON';

get '/estatusTanques' => sub {
	if(Trate::Lib::Usuarios->verificaToken(request->headers->{token}) eq 0){
		status 401;
		return {error => "Token de sesion invalido ingrese nuevamente al sistema"};
	} else {
		Trate::Lib::Usuarios->renuevaToken(request->headers->{token});
	}
	
	my $tanques = Trate::Lib::Tanques->new();
	my @return = $tanques->getTanquesEstatus();
	return \@return;	
};

get '/estatusBombas' => sub {
	if(Trate::Lib::Usuarios->verificaToken(request->headers->{token}) eq 0){
		status 401;
		return {error => "Token de sesion invalido ingrese nuevamente al sistema"};
	} else {
		Trate::Lib::Usuarios->renuevaToken(request->headers->{token});
	}
	
	my $bombas = Trate::Lib::Bombas->new();
	return $bombas->getBombasEstatus();	
};

get '/estatusBombas/:id' => sub {
	if(Trate::Lib::Usuarios->verificaToken(request->headers->{token}) eq 0){
		status 401;
		return {error => "Token de sesion invalido ingrese nuevamente al sistema"};
	} else {
		Trate::Lib::Usuarios->renuevaToken(request->headers->{token});
	}
	
	my $b = params->{id};
	my $bombas = Trate::Lib::Bombas->new();
	return $bombas->getBombaEstatus($b);

};

get '/last_transactions' => sub {
	if(Trate::Lib::Usuarios->verificaToken(request->headers->{token}) eq 0){
		status 401;
		return {error => "Token de sesion invalido ingrese nuevamente al sistema"};
	} else {
		Trate::Lib::Usuarios->renuevaToken(request->headers->{token});
	}

	my $transacciones = Trate::Lib::Transacciones->new();
	return $transacciones->getLastNTransactions();
};

true;

