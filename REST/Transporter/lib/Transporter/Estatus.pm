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

	my $sort = params->{sort};
	my $order = params->{order};
	my $page = params->{page};
	my $limit = params->{limit};
	my $search = params->{search};

	my $transacciones = Trate::Lib::Transacciones->new();
	return $transacciones->getLastNTransactions($sort,$order,$page,$limit,$search);
};

put '/cambiar_precio' => sub {
	if(Trate::Lib::Usuarios->verificaToken(request->headers->{token}) eq 0){
		status 401;
		return {error => "Token de sesion invalido ingrese nuevamente al sistema"};
	} else {
		Trate::Lib::Usuarios->renuevaToken(request->headers->{token});
	}

#	Agregar cambio de precio se tendrá una tabla con los productos de forma local, listaremos el producto
#	Se pondra el nuevo precio y la fecha a partir de la cual aplicará
#	Durante el cron que se ejecuta cada minuto, se verificará si se debe realizar un cambio de precio, en caso afirmativo se procederá ejecutando el servicio web
#	
#	<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:sit="http://orpak.com/SiteOmatServices/">
#	   <soapenv:Header/>
#	   <soapenv:Body>
#	      <sit:SOUpdatePrice>
#	         <!--Optional:-->
#	         <sit:SessionID>JSknLvNHOErpoWNPNncxixuaAIGWFda/B4jQzm2AD51DG8HfUd2g</sit:SessionID>
#	         <sit:site_code>5</sit:site_code>
#	         <sit:product_code>1</sit:product_code>
#	         <sit:new_price>15.00</sit:new_price>
#	         <!--Optional:-->
#	         <sit:timestamp>2019-01-13 18:00:00</sit:timestamp>
#	         <!--Optional:-->
#	         <sit:username>Admin</sit:username>
#	      </sit:SOUpdatePrice>
#	   </soapenv:Body>
#	</soapenv:Envelope>
			
};

true;

