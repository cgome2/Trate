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
	$RECEPCION_COMBUSTIBLE->numeroProveedor($post->{numero_proveedor});
	$RECEPCION_COMBUSTIBLE->empleadoCaptura($usuario->{numero_empleado});
	$RECEPCION_COMBUSTIBLE->litrosDocumento($post->{litros_documento});
	$RECEPCION_COMBUSTIBLE->ppvDocumento($post->{ppv_documento});
	$RECEPCION_COMBUSTIBLE->importeDocumento($post->{importe_documento});
	$RECEPCION_COMBUSTIBLE->ivaDocumento($post->{iva_documento});
	$RECEPCION_COMBUSTIBLE->iepsDocumento($post->{ieps_documento});
	$RECEPCION_COMBUSTIBLE->status(1);	


	my $respuesta = $RECEPCION_COMBUSTIBLE->insertarRecepcionCombustible();
	LOGGER->info($respuesta);
	if ($respuesta eq 1){
		return {message => "OKComputer"};
	} else {
		status 401;
		return {error => "NOTOKComputer"};
	}
};

patch '/recepciones_combustible' => sub {
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

	$RECEPCION_COMBUSTIBLE->idRecepcion($post->{id_recepcion});
	$RECEPCION_COMBUSTIBLE->fechaRecepcion($post->{fecha_recepcion});
	$RECEPCION_COMBUSTIBLE->fechaDocumento($post->{fecha_documento});
	$RECEPCION_COMBUSTIBLE->terminalEmbarque($post->{terminal_embarque});
	$RECEPCION_COMBUSTIBLE->selloPemex($post->{sello_pemex});
	$RECEPCION_COMBUSTIBLE->folioDocumento($post->{folio_documento});
	$RECEPCION_COMBUSTIBLE->tipoDocumento($post->{tipo_documento});
	$RECEPCION_COMBUSTIBLE->serieDocumento($post->{serie_documento});
	$RECEPCION_COMBUSTIBLE->numeroProveedor($post->{numero_proveedor});
	$RECEPCION_COMBUSTIBLE->empleadoCaptura($usuario->{numero_empleado});
	$RECEPCION_COMBUSTIBLE->litrosDocumento($post->{litros_documento});
	$RECEPCION_COMBUSTIBLE->ppvDocumento($post->{ppv_documento});
	$RECEPCION_COMBUSTIBLE->importeDocumento($post->{importe_documento});
	$RECEPCION_COMBUSTIBLE->ivaDocumento($post->{iva_documento});
	$RECEPCION_COMBUSTIBLE->iepsDocumento($post->{ieps_documento});
	$RECEPCION_COMBUSTIBLE->status($post->{status});	
	
	if($post->{status} eq 1){
		my $respuesta = $RECEPCION_COMBUSTIBLE->actualizarRecepcionCombustible();
		LOGGER->info($respuesta);
		if ($respuesta eq 1){
			return {message => "OKComputer"};
		} else {
			status 401;
			return {error => "NOTOKComputer"};
		}
	} elsif ($post->{status} eq 2){
		return {message => "Recepcion con TLS procesada"};
	} else {
		status 401;
		return {message => "Error en la estructura del JSON no se encuentra el nodal status"};
	}
};

patch '/recepciones_combustible_old/:id' => sub {
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
	if ($respuesta eq 1){
		return {message => "OKComputer"};
	} else {
		status 401;
		return {error => "NOTOKComputer"};
	}
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

get '/recepciones_combustible/:id' => sub {
	if(Trate::Lib::Usuarios->verificaToken(request->headers->{token}) eq 0){
		status 401;
		return {error => "Token de sesion invalido ingrese nuevamente al sistema"};
	} else {
		Trate::Lib::Usuarios->renuevaToken(request->headers->{token});
	}

	my $id = params->{id};
	my $RECEPCION_COMBUSTIBLE = Trate::Lib::RecepcionCombustible->new();
	my $recepcion_combustible = $RECEPCION_COMBUSTIBLE->getFromId($id);
	if ($recepcion_combustible ne 0){
		status 200;
		my %rc = %$recepcion_combustible;
		my $lecturas_combustible = $RECEPCION_COMBUSTIBLE->lecturaTls()->getLecturasTls();
		my @lc = @{$lecturas_combustible};
		$rc{'lecturas_combustible'} = $lecturas_combustible;
		LOGGER->info($recepcion_combustible);
		return \%rc;	
	} else {
		status 404;
		return {message => "No existe la recepción solicitada"};
	}
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

get '/proveedores' => sub {
	if(Trate::Lib::Usuarios->verificaToken(request->headers->{token}) eq 0){
		status 401;
		return {error => "Token de sesion invalido ingrese nuevamente al sistema"};
	} else {
		Trate::Lib::Usuarios->renuevaToken(request->headers->{token});
	}
	my $lists = Trate::Lib::Lists->new();
	my $result = $lists->getProveedoresTrate();
	if($result eq 0){
		status 404;
		return {error => "No existen proveedores"};
	} else {
		status 200;
		return $result;
	}
};

true;
