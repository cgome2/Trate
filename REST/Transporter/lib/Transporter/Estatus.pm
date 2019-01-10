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

get '/estatusBombas/framelink' => sub {
	if(Trate::Lib::Usuarios->verificaToken(request->headers->{token}) eq 0){
		status 401;
		return {error => "Token de sesion invalido ingrese nuevamente al sistema"};
	} else {
		Trate::Lib::Usuarios->renuevaToken(request->headers->{token});
	}
	my $wsc = Trate::Lib::WebServicesClient->new();
	my %return = ('url'=>ORCUURL . "pump_status.htm?ID=" . $wsc->sessionId);
	return \%return;
};

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
	my @return = $bombas->getBombasEstatus();
	return \@return;	
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

	my $sort = params->{sort};
	my $order = params->{order};
	my $page = params->{page};
	my $limit = params->{limit};
	my $search = params->{search};

	my $transacciones = Trate::Lib::Transacciones->new();
	return $transacciones->getLastNTransactions($sort,$order,$page,$limit,$search);
};

true;

