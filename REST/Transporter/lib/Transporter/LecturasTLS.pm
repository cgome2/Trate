package Transporter::LecturasTLS;

use Dancer ':syntax';
use Trate::Lib::Constants qw(LOGGER);
use Trate::Lib::LecturasTLS;
use Trate::Lib::RecepcionCombustible;
use Trate::Lib::Factura;
use Data::Dump qw(dump);


our $VERSION = '0.1';

set serializer => 'JSON';

get '/lecturas_tls' => sub {
	my $LECTURAS_TLS = Trate::Lib::LecturasTLS->new();
	if($LECTURAS_TLS->getLastLecturasTlsFromOrcu() eq 1){
		my $lecturasTls = $LECTURAS_TLS->getLecturasTls;	
		return $lecturasTls;
	} else {
	    return {error_message => "please implement me properly"};
	}
};

get '/lecturas_tls/:rui' => sub {
    my $rui = params->{rui};
	my $LECTURAS_TLS = Trate::Lib::LecturasTLS->new();
    $LECTURAS_TLS->receptionUniqueId($rui);
    $LECTURAS_TLS = $LECTURAS_TLS->getLecturasTlsFromId();
    LOGGER->info(dump($LECTURAS_TLS));
    return {data => $LECTURAS_TLS};
};

put '/lecturas_tls' => sub {
	return {transporter_says => "please implement me soon..."};
};

patch '/lecturas_tls' => sub {
	my $request = Dancer::Request->new(env => \%ENV);
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
	my $id_ci_movimiento = 0;
	#actualizar tank_delivery_readings indicando el id@ci_movimientos
	$RECEPCION_COMBUSTIBLE->lecturaTls->status(1);
	$RECEPCION_COMBUSTIBLE->lecturaTls->ciMovimientos($id_ci_movimiento);
	
	$RECEPCION_COMBUSTIBLE->movimientoInventario($RECEPCION_COMBUSTIBLE->movimientoInventario->inserta());
	$RECEPCION_COMBUSTIBLE->movimientoRecepcion($RECEPCION_COMBUSTIBLE->movimientoRecepcion->inserta());	
	$RECEPCION_COMBUSTIBLE->lecturaTls->ciMovimientos($RECEPCION_COMBUSTIBLE->movimientoRecepcion->{ID});

	LOGGER->info(dump($RECEPCION_COMBUSTIBLE));
	$RECEPCION_COMBUSTIBLE->lecturaTls->updateLecturasTlsMariaDb();	
	
	return 1;
};

del '/lecturas_tls' => sub {
	my $request = Dancer::Request->new(env => \%ENV);
	my $post = from_json( request->body );
	my $LECTURAS_TLS = Trate::Lib::LecturasTLS->new();
    $LECTURAS_TLS->receptionUniqueId($post->{reception_unique_id});
	$LECTURAS_TLS->deleteLecturasTlsMariaDb();	

	return 1;
};

get '/facturas/:fecha/:factura/:proveedor/:serie' => sub {
    my $fecha = params->{fecha};
    my $factura = params->{factura};
    my $proveedor = params->{proveedor};
    my $fserie = params->{serie};
    my $FACTURA = Trate::Lib::Factura->new();
    $FACTURA->fecha($fecha);
    $FACTURA->factura($factura);
    $FACTURA->proveedor($proveedor);
    $FACTURA->fserie($fserie);
    return {data => $FACTURA->existeFactura()};	
};

true;
