package Transporter::RecepcionCombustible;

use Dancer ':syntax';
use Trate::Lib::Constants qw(LOGGER);
use Trate::Lib::LecturasTLS;
use Trate::Lib::RecepcionCombustible;
use Trate::Lib::Factura;
use Trate::Lib::Usuarios;

use Try::Catch;
use Data::Dump qw(dump);
use Data::Structure::Util qw( unbless );

our $VERSION = '0.1';

set serializer => 'JSON';

put '/recepciones_combustible' => sub {
	my $usuario;
	if(Trate::Lib::Usuarios->verificaToken(request->headers->{token}) eq 0){
		status 401;
		return {error => "Token de sesion invalido ingrese nuevamente al sistema"};
	} else {
		Trate::Lib::Usuarios->renuevaToken(request->headers->{token});
		$usuario = Trate::Lib::Usuarios->getUsuarioByToken(request->headers->{token});
	}

	my $post = from_json( request->body );
	my $RECEPCION_COMBUSTIBLE = Trate::Lib::RecepcionCombustible->new();

	#insertar ci_movimientos con los datos de la factura
	$RECEPCION_COMBUSTIBLE->fechaRecepcion($post->{fecha_recepcion});
	$RECEPCION_COMBUSTIBLE->fechaDocumento($post->{fecha_documento});
	$RECEPCION_COMBUSTIBLE->terminalEmbarque($post->{terminal_embarque});
	$RECEPCION_COMBUSTIBLE->selloPemex($post->{sello_pemex});
	$RECEPCION_COMBUSTIBLE->folioDocumento($post->{folio_documento});
	$RECEPCION_COMBUSTIBLE->tipoDocumento($post->{tipo_documento});
	$RECEPCION_COMBUSTIBLE->serieDocumento($post->{serie_documento});
	if (length($post->{numero_proveedor}) gt 0) {
		$RECEPCION_COMBUSTIBLE->numeroProveedor($post->{numero_proveedor});
	}
	$RECEPCION_COMBUSTIBLE->empleadoCaptura($usuario->{numero_empleado});
	$RECEPCION_COMBUSTIBLE->litrosDocumento($post->{litros_documento});
	$RECEPCION_COMBUSTIBLE->ppvDocumento($post->{ppv_documento});
	$RECEPCION_COMBUSTIBLE->importeDocumento($post->{importe_documento});
	$RECEPCION_COMBUSTIBLE->ivaDocumento($post->{iva_documento});
	$RECEPCION_COMBUSTIBLE->iepsDocumento($post->{ieps_documento});
	$RECEPCION_COMBUSTIBLE->status(1);	


	my $respuesta = $RECEPCION_COMBUSTIBLE->insertarRecepcionCombustible();
	LOGGER->info($respuesta);
	#if ($respuesta eq 1){
		return {message => "OKComputer"};
	#} else {
	#	status 401;
	#	return {error => "NOTOKComputer"};
	#}
};

get '/recepciones_combustible' => sub{
	my $usuario;
	if(Trate::Lib::Usuarios->verificaToken(request->headers->{token}) eq 0){
		status 401;
		return {error => "Token de sesion invalido ingrese nuevamente al sistema"};
	} else {
		Trate::Lib::Usuarios->renuevaToken(request->headers->{token});
		$usuario = Trate::Lib::Usuarios->getUsuarioByToken(request->headers->{token});
	}

	my $return = 0;	
	my $RECEPCION_COMBUSTIBLE = Trate::Lib::RecepcionCombustible->new();
	$return = $RECEPCION_COMBUSTIBLE->getRecepcionesCombustible();
	if ($return eq 0){
		status 404;
		return {message => "No existen recepciones de combustible en el sistema"};
	} else {
		return $return;
	}
		
};

get '/recepcion_combustible/:id' => sub {
#	if(Trate::Lib::Usuarios->verificaToken(request->headers->{token}) eq 0){
#		status 401;
#		return {error => "Token de sesion invalido ingrese nuevamente al sistema"};
#	} else {
#		Trate::Lib::Usuarios->renuevaToken(request->headers->{token});
#	}
#
#   my $id = params->{id};
#   my $RECEPCION_COMBUSTIBLE = Trate::Lib::Factura->new();
#    $RECEPCION_COMBUSTIBLE->getFromId($id);
#    if($FACTURA->existeFactura() eq 0){
#	    status 404;
#	    return {error => "NotOkComputer"};
#    } else {
#	    status 200;
#	    return {data => "OkComputer"}
#    }
};

get '/recepcionCombustible/verificarFactura/:fecha/:factura/:serie' => sub {
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
	    status 200;
	    return {data => "OkComputer"}
    }
};

true;
