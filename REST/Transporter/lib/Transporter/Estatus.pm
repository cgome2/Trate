package Transporter::Estatus;

use Dancer ':syntax';
use Trate::Lib::Tanques;
use Trate::Lib::Bombas;
use Trate::Lib::Constants qw(LOGGER ORCUURL);
use Trate::Lib::WebServicesClient;
use Data::Dump qw(dump);
use List::Util qw(all);


our $VERSION = '0.1';

set serializer => 'JSON';

get '/estatusBombas' => sub {
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
	return {tanques => \@return};	
};


get '/estatusBombas1/:id' => sub {
	if(Trate::Lib::Usuarios->verificaToken(request->headers->{token}) eq 0){
		status 401;
		return {error => "Token de sesion invalido ingrese nuevamente al sistema"};
	} else {
		Trate::Lib::Usuarios->renuevaToken(request->headers->{token});
	}
	
	my $bombas = params->{id};
	return {bombas => $bombas};	
};


true;
