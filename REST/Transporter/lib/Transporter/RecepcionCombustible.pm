package Transporter::RecepcionCombustible;

use Dancer ':syntax';
use Trate::Lib::Constants qw(LOGGER);
use Trate::Lib::LecturasTLS;
use Trate::Lib::RecepcionCombustible;
use Trate::Lib::Factura;
use Trate::Lib::ProveedoresTrate;
use Trate::Lib::Usuarios;

use Try::Catch;
use Data::Dump qw(dump);
use Data::Structure::Util qw( unbless );

our $VERSION = '0.1';

set serializer => 'JSON';

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
		status 200;
		my @array = ();
		LOGGER->info("No existen recepciones de combustible en el sistema");
		return \@array;
	} else {
		return $return;
	}		
};

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
	LOGGER->debug(dump($post));
    my $FACTURA = Trate::Lib::Factura->new();
    $FACTURA->fecha($post->{fecha_documento});
    $FACTURA->factura($post->{folio_documento});
    $FACTURA->fserie($post->{serie_documento});
    $FACTURA->proveedor($post->{numero_proveedor});
	LOGGER->debug(dump($FACTURA));
    if($FACTURA->existeFactura() eq 0){
	    status 400;
	    LOGGER->info("La factura " . $FACTURA->factura() . " no existe en informix");
	    return {message => "Factura no existente en informix."};
    }
	
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
	LOGGER->debug($respuesta);
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

    	my $FACTURA = Trate::Lib::Factura->new();
    	$FACTURA->fecha($post->{fecha_documento});
    	$FACTURA->factura($post->{folio_documento});
    	$FACTURA->fserie($post->{serie_documento});
    	$FACTURA->proveedor($post->{numero_proveedor});
   	#if($FACTURA->existeFactura() eq 0){
	#    status 400;
	#    return {message => "Factura no existente en informix."};
    	#}

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
		if ($respuesta eq 1){
			return {message => "OKComputer"};
		} else {
			status 401;
			return {error => "NOTOKComputer"};
		}
	} elsif ($post->{status} eq 2){
		my $respuesta = $RECEPCION_COMBUSTIBLE->actualizarRecepcionCombustible();
		if ($respuesta ne 1){
			status 401;
			return {message => "NOTOKComputer"};
		} else {
			my @lecturas_por_asignar = @{$post->{lecturas_combustible}};		
			LOGGER->debug("el valor para la recepcion {" . $RECEPCION_COMBUSTIBLE->idRecepcion() . "}");
			my $existenciaFinal = 0;
			my $existenciaInicial = 0;
			my $ruibubble = 0;
			my $dateInicial;
			my $insertamovimiento;
			LOGGER->debug("las lecturas por asignar : " . dump(\@lecturas_por_asignar));
			foreach (@lecturas_por_asignar){
				$ruibubble = ($ruibubble le $_->{rui} && $ruibubble ne 0) ? $ruibubble : $_->{rui} ;
				$dateInicial = $ruibubble eq $_->{rui} ? $_->{start_delivery_timestamp} : $dateInicial; 
				$existenciaFinal = $_->{end_volume} ge $existenciaFinal ? $_->{end_volume} : $existenciaFinal;
				$existenciaInicial = $_->{start_volume} ge $existenciaInicial ? $_->{start_volume} : $existenciaInicial;
				LOGGER->debug($_->{id_tank_delivery_reading});
	
				# Agregar movimiento documental
				$RECEPCION_COMBUSTIBLE->{MOVIMIENTO_RECEPCION}->fechaHora($RECEPCION_COMBUSTIBLE->fechaDocumento($_->{end_delivery_timestamp}));
				$RECEPCION_COMBUSTIBLE->{MOVIMIENTO_RECEPCION}->dispensador(0);
				$RECEPCION_COMBUSTIBLE->{MOVIMIENTO_RECEPCION}->supervisor($usuario->{numero_empleado});
				$RECEPCION_COMBUSTIBLE->{MOVIMIENTO_RECEPCION}->despachador($post->{numero_proveedor});
				$RECEPCION_COMBUSTIBLE->{MOVIMIENTO_RECEPCION}->viaje('');
				$RECEPCION_COMBUSTIBLE->{MOVIMIENTO_RECEPCION}->camion('');
				$RECEPCION_COMBUSTIBLE->{MOVIMIENTO_RECEPCION}->chofer('');
				$RECEPCION_COMBUSTIBLE->{MOVIMIENTO_RECEPCION}->sello($post->{sello_pemex});
				$RECEPCION_COMBUSTIBLE->{MOVIMIENTO_RECEPCION}->tipoReferencia(2);
				$RECEPCION_COMBUSTIBLE->{MOVIMIENTO_RECEPCION}->serie($post->{serie_documento});
				$RECEPCION_COMBUSTIBLE->{MOVIMIENTO_RECEPCION}->referencia($post->{folio_documento});
				$RECEPCION_COMBUSTIBLE->{MOVIMIENTO_RECEPCION}->movimiento(1);
				$RECEPCION_COMBUSTIBLE->{MOVIMIENTO_RECEPCION}->litrosEsp($post->{litros_documento});
				$RECEPCION_COMBUSTIBLE->{MOVIMIENTO_RECEPCION}->litrosReal($_->{quantity_tls});
				$RECEPCION_COMBUSTIBLE->{MOVIMIENTO_RECEPCION}->costoEsp($post->{importe_documento});
				$RECEPCION_COMBUSTIBLE->{MOVIMIENTO_RECEPCION}->costoReal(1);
				$RECEPCION_COMBUSTIBLE->{MOVIMIENTO_RECEPCION}->iva(1);
				$RECEPCION_COMBUSTIBLE->{MOVIMIENTO_RECEPCION}->ieps(1);
				$RECEPCION_COMBUSTIBLE->{MOVIMIENTO_RECEPCION}->status(0);
				$RECEPCION_COMBUSTIBLE->{MOVIMIENTO_RECEPCION}->procesada('N');
				$RECEPCION_COMBUSTIBLE->{MOVIMIENTO_RECEPCION}->idRecepcion($RECEPCION_COMBUSTIBLE->idRecepcion());
			
				LOGGER->debug("Se inserta movimiento tipo 1 : " . dump($RECEPCION_COMBUSTIBLE->{MOVIMIENTO_RECEPCION}));
				$insertamovimiento = $RECEPCION_COMBUSTIBLE->{MOVIMIENTO_RECEPCION}->inserta();
				#$insertamovimiento = 1;
				if($insertamovimiento eq 0){
					status 401;
					return {message => "Error al insertar el movimiento recepcion se ejecuta un rollback"};
				} else {
					LOGGER->debug(Trate::Lib::LecturasTLS->quemarLectura($_->{id_tank_delivery_reading},$RECEPCION_COMBUSTIBLE->idRecepcion()));
				}
			}

			# Agregar movimiento tipo 0 correspondiente al inventario inicial	
			$RECEPCION_COMBUSTIBLE->{MOVIMIENTO_INVENTARIO}->fechaHora($dateInicial);
			$RECEPCION_COMBUSTIBLE->{MOVIMIENTO_INVENTARIO}->dispensador('');
			$RECEPCION_COMBUSTIBLE->{MOVIMIENTO_INVENTARIO}->supervisor($usuario->{numero_empleado});
			$RECEPCION_COMBUSTIBLE->{MOVIMIENTO_INVENTARIO}->despachador($post->{numero_proveedor});
			$RECEPCION_COMBUSTIBLE->{MOVIMIENTO_INVENTARIO}->viaje('');
			$RECEPCION_COMBUSTIBLE->{MOVIMIENTO_INVENTARIO}->camion('');
			$RECEPCION_COMBUSTIBLE->{MOVIMIENTO_INVENTARIO}->chofer('');
			$RECEPCION_COMBUSTIBLE->{MOVIMIENTO_INVENTARIO}->sello('');
			$RECEPCION_COMBUSTIBLE->{MOVIMIENTO_INVENTARIO}->tipoReferencia('');
			$RECEPCION_COMBUSTIBLE->{MOVIMIENTO_INVENTARIO}->serie('');
			$RECEPCION_COMBUSTIBLE->{MOVIMIENTO_INVENTARIO}->referencia('');
			$RECEPCION_COMBUSTIBLE->{MOVIMIENTO_INVENTARIO}->movimiento(0);
			$RECEPCION_COMBUSTIBLE->{MOVIMIENTO_INVENTARIO}->litrosEsp('');
			$RECEPCION_COMBUSTIBLE->{MOVIMIENTO_INVENTARIO}->litrosReal($existenciaInicial);	
			$RECEPCION_COMBUSTIBLE->{MOVIMIENTO_INVENTARIO}->costoEsp('0');
			$RECEPCION_COMBUSTIBLE->{MOVIMIENTO_INVENTARIO}->costoReal(1);
			$RECEPCION_COMBUSTIBLE->{MOVIMIENTO_INVENTARIO}->iva(1);
			$RECEPCION_COMBUSTIBLE->{MOVIMIENTO_INVENTARIO}->ieps(1);
			$RECEPCION_COMBUSTIBLE->{MOVIMIENTO_INVENTARIO}->status(0);
			$RECEPCION_COMBUSTIBLE->{MOVIMIENTO_INVENTARIO}->procesada('N');
			$RECEPCION_COMBUSTIBLE->{MOVIMIENTO_INVENTARIO}->idRecepcion($RECEPCION_COMBUSTIBLE->idRecepcion());

			$insertamovimiento = $RECEPCION_COMBUSTIBLE->{MOVIMIENTO_INVENTARIO}->inserta();
			#$insertamovimiento = 1;
			if($insertamovimiento eq 0){
				status 401;
				return {message => "Error al insertar el movimiento inventario se ejecuta un rollback"};
			} else {
				return {message => "Se proceso recepcion de TLS"};
			}
		}

	} else {
		status 401;
		return {message => "Error en la estructura del JSON no se encuentra el nodal status"};
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
		LOGGER->debug(dump(\%rc));
		my @array = ();
		push @array, \%rc;
		return \@array;
	} else {
		status 404;
		return {message => "No existe la recepción solicitada"};
	}
};

get '/recepciones_combustible/verificarFactura/:fecha/:factura/:serie' => sub {
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
	my $proveedores = Trate::Lib::ProveedoresTrate->new();
	my $prov = $proveedores->getProveedoresTrate();
	if($prov eq 0){
		status 404;
		return {error => "No existen proveedores"};
	} else {
		status 200;
		LOGGER->debug(dump($prov));
		return $prov;
	}
};

true;
