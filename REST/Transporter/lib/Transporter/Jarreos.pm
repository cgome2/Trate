package Transporter::Jarreos;

use Dancer ':syntax';
use Trate::Lib::Constants qw(LOGGER);
use Trate::Lib::Jarreo;
use Trate::Lib::Usuarios;
use Trate::Lib::Transacciones;

use Try::Catch;
use Data::Dump qw(dump);
use Data::Structure::Util qw( unbless );

our $VERSION = '0.1';

set serializer => 'JSON';

get '/jarreos' => sub{
	my $usuario;
	if(Trate::Lib::Usuarios->verificaToken(request->headers->{token}) eq 0){
		status 401;
		return {error => "Token de sesion invalido ingrese nuevamente al sistema"};
	} else {
		Trate::Lib::Usuarios->renuevaToken(request->headers->{token});
		$usuario = Trate::Lib::Usuarios->getUsuarioByToken(request->headers->{token});
	}

	my $return = 0;	
	my $JARREOS = Trate::Lib::Jarreo->new();
	$return = $JARREOS->getJarreos();
	if ($return eq 0){
		status 200;
		LOGGER->info("No existen jarreos de combustible pendientes de devolución");
		my @array = ();
		return \@array;
	} else {
		return $return;
	}

};

get '/jarreos/:id' => sub {
	if(Trate::Lib::Usuarios->verificaToken(request->headers->{token}) eq 0){
		status 401;
		return {error => "Token de sesion invalido ingrese nuevamente al sistema"};
	} else {
		Trate::Lib::Usuarios->renuevaToken(request->headers->{token});
	}

	my $id = params->{id};
	my $JARREO = Trate::Lib::Jarreo->new();
	$JARREO->{TRANSACTION_ID} = $id;
	my $jarreo = $JARREO->getJarreoFromTransactionId();
	if ($jarreo ne 0){
		status 200;
		return $jarreo;
	} else {
		status 404;
		return {message => "No existe el jarreo solicitado"};
	}
};

patch '/jarreos' => sub {
	my $return = 0;
	my $usuario;
	if(Trate::Lib::Usuarios->verificaToken(request->headers->{token}) eq 0){
		status 401;
		return {error => "Token de sesion invalido ingrese nuevamente al sistema"};
	} else {
		Trate::Lib::Usuarios->renuevaToken(request->headers->{token});
		$usuario = Trate::Lib::Usuarios->getUsuarioByToken(request->headers->{token});
	}

	my $post = from_json( request->body );
	my @jarreos = @{$post};
	my $jarreo;
	my $j = Trate::Lib::Jarreo->new();
	my $t = Trate::Lib::Transacciones->new();
	foreach $jarreo (@jarreos){
		try{
			# 	instanciar jarreo por idtransaccion
			$j->{TRANSACTION_ID} = $jarreo->{transaction_id};
			$j->fillJarreoFromTransactionId();
			# 	instanciar transaccion por idtransaccion
			$t->{IDTRANSACCIONES} = $jarreo->{transaction_id};
			$t->fillTransaccionFromId();
			# 	insertar movimiento de jarreo
			$t->insertaMovimientoJarreo($usuario->{numero_empleado});
			# 	actualizar jarreo agregando datos de devolución y cambiando status a 1
			$j->insertaDevolucionJarreo();
			$return = 1;
		} catch {
			$return = 0;
			return {message=> "El jarreo con transacción " . $j->transactionId() . " no fue procesado"};
		}
	}
	if ($return eq 1){
		return {message=>"OkComputer"};	
	} else {
		return {message=>"NotOkComuter"};
	}
};

true;
