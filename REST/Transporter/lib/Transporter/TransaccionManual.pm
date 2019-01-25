package Transporter::TransaccionManual;

use Dancer ':syntax';
use Trate::Lib::Constants qw(LOGGER);
use Trate::Lib::Lists;
use Trate::Lib::Bombas;
use Trate::Lib::Mean;
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
	my $bombas = Trate::Lib::Bombas->new();
	return $bombas->getBombas();	
};

get '/despachadores' => sub {
	if(Trate::Lib::Usuarios->verificaToken(request->headers->{token}) eq 0){
		status 401;
		return {error => "Token de sesion invalido ingrese nuevamente al sistema"};
	} else {
		Trate::Lib::Usuarios->renuevaToken(request->headers->{token});
	}
	my $MEAN = Trate::Lib::Mean->new();
	return $MEAN->getDespachadores();	
};

true;
