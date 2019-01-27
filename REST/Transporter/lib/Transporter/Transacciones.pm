package Transporter::Transacciones;

use Dancer ':syntax';
use Trate::Lib::Constants qw(LOGGER);
use Trate::Lib::Bombas;
use Trate::Lib::Mean;
use Trate::Lib::Transacciones;
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

patch '/transacciones' => sub {
	my $usuario;
	if(Trate::Lib::Usuarios->verificaToken(request->headers->{token}) eq 0){
		status 401;
		return {error => "Token de sesion invalido ingrese nuevamente al sistema"};
	} else {
		Trate::Lib::Usuarios->renuevaToken(request->headers->{token});
		$usuario = Trate::Lib::Usuarios->getUsuarioByToken(request->headers->{token});
	}	

	LOGGER->info("El usuario " . $usuario->{idusuarios} . " solicita insertar una transacción");

	my $post = from_json( request->body );
	
	my $transaccion = Trate::Lib::Transacciones->new();
	$transaccion->{IDPRODUCTOS} = $post->{producto};				
	$transaccion->{IDVEHICULOS} = 0;
	$transaccion->{IDDESPACHADORES} = $post->{despachador};
	$transaccion->{FECHA} = substr($post->{fecha_transaccion},0,10) . " " . $post->{hora_transaccion} . ":00";
	$transaccion->{BOMBA} = $post->{bomba};
	$transaccion->{CANTIDAD} = $post->{litros}; 					
	$transaccion->{PLACA} = length($post->{mean_contingencia}) gt 0 ? $post->{mean_contingencia} : $post->{camion};
	$transaccion->{TOTALIZADOR} = $post->{totalizador}; 				
	$transaccion->{VENTA} = $post->{litros}; 					
	$transaccion->{PASE}->{PASE} = $post->{pase_id};	
	$transaccion->{PASE}->{LITROS_REAL} = $post->{litros_real} + $post->{litros};	
	$transaccion->{PASE}->{MEAN_CONTINGENCIA} = length($post->{mean_contingencia}) gt 0 ? $post->{mean_contingencia} : "";
	$transaccion->{PASE}->{STATUS} = "M";
	$transaccion->{PASE}->{VIAJE} = $post->{viaje};
	$transaccion->{PASE}->{CAMION} = $post->{camion};
	$transaccion->{PASE}->{CHOFER} = $post->{chofer};
	$transaccion->{PASE}->{OBSERVACIONES} = $post->{observaciones};

	$transaccion->insertaTransaccionManual();
	return {message=>"Ok"};
};

true;
