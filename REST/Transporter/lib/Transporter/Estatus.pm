package Transporter::Estatus;

use Dancer ':syntax';
use Trate::Lib::Constants qw(LOGGER URIPUMPOMAT);
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
	my %return = ('url'=>URIPUMPOMAT . $wsc->sessionId);
	return \%return;
};

get '/estatusTanques' => sub {
	if(Trate::Lib::Usuarios->verificaToken(request->headers->{token}) eq 0){
		status 401;
		return {error => "Token de sesion invalido ingrese nuevamente al sistema"};
	} else {
		Trate::Lib::Usuarios->renuevaToken(request->headers->{token});
	}
	return {
	tanques =>[
	{
		name=>'Magna',
		tank_id=>'200000017',
		date=>'01/07/19 23:55:37',
		date_sql=>'2019-01-07 23:55:37',
		fuel_height=>'1543.36',
		fuel_volume=>'52520.660',
		water_height=>'49.21',
		water_volume=>'354.437',
		temperature=>'21.47',
		tc_volume=>'50003.637',
		density=>'0.000',
		density_15=>'0.000',
		tlh_id=>'0',
		user=>'0',
		probe_id=>'200000009',
		shift_id=>'0',
		ullage=>'57479.344'
	},
	{
		name=>'Diesel',
		tank_id=>'200000017',
		date=>'01/07/19 23:55:37',
		date_sql=>'2019-01-07 23:55:37',
		fuel_height=>'1543.36',
		fuel_volume=>'52520.660',
		water_height=>'49.21',
		water_volume=>'354.437',
		temperature=>'21.47',
		tc_volume=>'50003.637',
		density=>'0.000',
		density_15=>'0.000',
		tlh_id=>'0',
		user=>'0',
		probe_id=>'200000009',
		shift_id=>'0',
		ullage=>'57479.344'
	}
	]
	};
	
};

true;
