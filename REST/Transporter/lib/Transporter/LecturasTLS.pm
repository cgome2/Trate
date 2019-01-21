package Transporter::LecturasTLS;

use Dancer ':syntax';
use Trate::Lib::Constants qw(LOGGER);
use Trate::Lib::LecturasTLS;
use Trate::Lib::RecepcionCombustible;
use Trate::Lib::Factura;
use Trate::Lib::Tanques;
use Try::Catch;
use Data::Dump qw(dump);
use Data::Structure::Util qw( unbless );

$ENV{INFORMIXSERVER} = 'prueba';

our $VERSION = '0.1';

set serializer => 'JSON';

get '/lecturas_tls' => sub {
	if(Trate::Lib::Usuarios->verificaToken(request->headers->{token}) eq 0){
		status 401;
		return {error => "Token de sesion invalido ingrese nuevamente al sistema"};
	} else {
		Trate::Lib::Usuarios->renuevaToken(request->headers->{token});
	}

	my $sort = length(params->{'sort'}) gt 0 ? params->{'sort'} : "";
	my $order = length(params->{order}) gt 0 ? params->{order} : "";
	my $page = length(params->{page}) gt 0 ? params->{page} : "";
	my $limit = length(params->{limit}) gt 0 ? params->{limit} :"";
	my $search = length(params->{'search'}) gt 0 ? params->{'search'} : "";
		
	my $LECTURAS_TLS = Trate::Lib::LecturasTLS->new();	
	$LECTURAS_TLS->getLastLecturasTlsFromOrcu();
	my $lecturasTls = $LECTURAS_TLS->getLecturasTls($sort,$order,$page,$limit,$search);	
	return $lecturasTls;
};

get '/lecturas_tls/:id_tank_delivery_reading' => sub {
	if(Trate::Lib::Usuarios->verificaToken(request->headers->{token}) eq 0){
		status 401;
		return {error => "Token de sesion invalido ingrese nuevamente al sistema"};
	} else {
		Trate::Lib::Usuarios->renuevaToken(request->headers->{token});
	}
    my $id_tank_delivery_reading = params->{id_tank_delivery_reading};
	my $ltls = Trate::Lib::LecturasTLS->new();
	$ltls->idTankDeliveryReading($id_tank_delivery_reading);
	return $ltls->getLecturasTlsFromId();
	return {message=> "exito"};
};

put '/lecturas_tls' => sub {
	if(Trate::Lib::Usuarios->verificaToken(request->headers->{token}) eq 0){
		status 401;
		return {error => "Token de sesion invalido ingrese nuevamente al sistema"};
	} else {
		Trate::Lib::Usuarios->renuevaToken(request->headers->{token});
	}

	my $post = from_json( request->body );
	my $ltls = Trate::Lib::LecturasTLS->new();

	$ltls->{TANK_ID} = $post->{tank}->{ID};
	$ltls->{TANK_NAME} = $post->{tank}->{NAME};
	$ltls->{TANK_NUMBER} = $post->{tank}->{NUMBER};
	$ltls->{START_VOLUME} = $post->{start_volume};
	$ltls->{END_VOLUME} = $post->{end_volume};
	$ltls->{START_TEMP} = $post->{start_temp};
	$ltls->{END_TEMP} = $post->{end_temp};
	$ltls->{START_DELIVERY_TIMESTAMP} = $post->{start_delivery_timestamp};
	$ltls->{END_DELIVERY_TIMESTAMP} = $post->{end_delivery_timestamp};
	$ltls->{STATUS} = 0;
	$ltls->{START_TC_VOLUME} = $post->{start_tc_volume};
	$ltls->{END_TC_VOLUME} = $post->{end_tc_volume};
	$ltls->{START_HEIGHT} = $post->{start_height};
	$ltls->{END_HEIGHT} = $post->{end_height};
	$ltls->{START_WATER} = $post->{start_water};
	$ltls->{END_WATER} = $post->{end_water};
	$ltls->{QUANTITY_TLS} = 0;
	$ltls->{QUANTITY_TRAN} = 0;
	$ltls->{ORIGEN_REGISTRO} = "MANUAL";
	my $resultado = $ltls->insertaLecturaTLS();
	if($resultado eq 0 ){
		status 500;
		return {message => "No pudo ser insertado el registro"};
	} else {
		status 200;
		return {message => "OKComputer"};
	}
	
};

patch '/lecturas_tls' => sub {
	if(Trate::Lib::Usuarios->verificaToken(request->headers->{token}) eq 0){
		status 401;
		return {error => "Token de sesion invalido ingrese nuevamente al sistema"};
	} else {
		Trate::Lib::Usuarios->renuevaToken(request->headers->{token});
	}

	my $post = from_json( request->body );
	my $RECEPCION_COMBUSTIBLE = Trate::Lib::RecepcionCombustible->new();
	
	#insertar nivel de inventario antes de lectura en ci_movimientos
	$RECEPCION_COMBUSTIBLE->lecturaTls->receptionUniqueId($post->{reception_unique_id});
	$RECEPCION_COMBUSTIBLE->movimientoInventario->fechaHora($post->{start_delivery_timestamp});
	$RECEPCION_COMBUSTIBLE->movimientoInventario->supervisor($post->{supervisor});
	$RECEPCION_COMBUSTIBLE->movimientoInventario->movimiento(0);
	$RECEPCION_COMBUSTIBLE->movimientoInventario->litrosReal($post->{start_volume});
	$RECEPCION_COMBUSTIBLE->movimientoInventario->costoReal($post->{ppv}*$post->{start_volume});
	$RECEPCION_COMBUSTIBLE->movimientoInventario->status(0);
	$RECEPCION_COMBUSTIBLE->movimientoInventario->procesada('N');
	

	#insertar ci_movimientos con los datos de la factura
	$RECEPCION_COMBUSTIBLE->movimientoRecepcion->fechaHora($post->{end_delivery_timestamp});
	$RECEPCION_COMBUSTIBLE->movimientoRecepcion->supervisor($post->{supervisor});
	$RECEPCION_COMBUSTIBLE->movimientoRecepcion->sello($post->{sello});
	$RECEPCION_COMBUSTIBLE->movimientoRecepcion->serie($post->{serie});
	$RECEPCION_COMBUSTIBLE->movimientoRecepcion->tipoReferencia(2);
	$RECEPCION_COMBUSTIBLE->movimientoRecepcion->referencia($post->{referencia});
	$RECEPCION_COMBUSTIBLE->movimientoRecepcion->movimiento(1);
	$RECEPCION_COMBUSTIBLE->movimientoRecepcion->litrosEsp($post->{litros_esp});
	$RECEPCION_COMBUSTIBLE->movimientoRecepcion->litrosReal($post->{litros_real});
	$RECEPCION_COMBUSTIBLE->movimientoRecepcion->costoEsp($post->{costo_esp});
	$RECEPCION_COMBUSTIBLE->movimientoRecepcion->costoReal($post->{costo_real});
	$RECEPCION_COMBUSTIBLE->movimientoRecepcion->costoReal($post->{costo_real});
	$RECEPCION_COMBUSTIBLE->movimientoRecepcion->iva($post->{iva});
	$RECEPCION_COMBUSTIBLE->movimientoRecepcion->ieps($post->{ieps});
	$RECEPCION_COMBUSTIBLE->movimientoRecepcion->status($post->{reception_unique_id} eq "" ? 1 : 0); #si no trae rui significa que los datos se cargaron manualmente y no desde tls, por lo tanto el status se envia como 1
	$RECEPCION_COMBUSTIBLE->movimientoRecepcion->procesada('N');
	
	my $respuesta = $RECEPCION_COMBUSTIBLE->movimientoInventario($RECEPCION_COMBUSTIBLE->movimientoInventario->inserta());
	if ($respuesta eq 1){
		$respuesta = $RECEPCION_COMBUSTIBLE->movimientoRecepcion($RECEPCION_COMBUSTIBLE->movimientoRecepcion->inserta());
		if($respuesta eq 1){
			return {message => "OKComputer"};
		} else {
			status 401;
			return {message => "NOTOKComputer"};
		}
	} else {
		status 401;
		return {error => "NOTOKComputer"};
	}
};

del '/lecturas_tls' => sub {
	if(Trate::Lib::Usuarios->verificaToken(request->headers->{token}) eq 0){
		status 401;
		return {error => "Token de sesion invalido ingrese nuevamente al sistema"};
	} else {
		Trate::Lib::Usuarios->renuevaToken(request->headers->{token});
	}

	my $post = from_json( request->body );
	my $LECTURAS_TLS = Trate::Lib::LecturasTLS->new();
    $LECTURAS_TLS->receptionUniqueId($post->{reception_unique_id});
	$LECTURAS_TLS->deleteLecturasTlsMariaDb();	

	return 1;
};

get '/facturas/:fecha/:factura/:serie' => sub {
	if(Trate::Lib::Usuarios->verificaToken(request->headers->{token}) eq 0){
		status 401;
		return {error => "Token de sesion invalido ingrese nuevamente al sistema"};
	} else {
		Trate::Lib::Usuarios->renuevaToken(request->headers->{token});
	}

    my $fecha = params->{fecha};
    my $factura = params->{factura};
    my $fserie = params->{serie};
    my $FACTURA = Trate::Lib::Factura->new();
    $FACTURA->fecha($fecha);
    $FACTURA->factura($factura);
    $FACTURA->fserie($fserie);
    if($FACTURA->existeFactura() eq 0){
	    status 404;
	    return {error => "NotOkComputer"};
    } else {
	    return {data => "OkComputer"}
    }
};

get '/tanques' => sub {
	if(Trate::Lib::Usuarios->verificaToken(request->headers->{token}) eq 0){
		status 401;
		return {error => "Token de sesion invalido ingrese nuevamente al sistema"};
	} else {
		Trate::Lib::Usuarios->renuevaToken(request->headers->{token});
	}
	my $TANQUES = Trate::Lib::Tanques->new();
	my $tanques = $TANQUES->getTanques();
	LOGGER->info(dump($tanques));
	
	return unbless($tanques);
};

true;
