package Transporter::Turnos;

use Dancer ':syntax';
use Trate::Lib::Constants qw(LOGGER);
use Trate::Lib::Turnos;
use Data::Dump qw(dump);
use List::Util qw(all);
use Trate::Lib::Usuarios;


our $VERSION = '0.1';

set serializer => 'JSON';

get '/shifts' => sub {
	if(Trate::Lib::Usuarios->verificaToken(request->headers->{token}) eq 0){
		status 401;
		return {error => "Token de sesion invalido ingrese nuevamente al sistema"};
	} else {
		Trate::Lib::Usuarios->renuevaToken(request->headers->{token});
	}

	my $return = 0;	
	my $TURNOS = Trate::Lib::Turnos->new();
	$return = $TURNOS->getTurnos();
	LOGGER->info(dump($return));
	if ($return eq 0){
		status 404;
		return {message => "No existen turnos en el sistema"};
	} else {
		return $return;
	}
};

get '/turnos/:id' => sub {
	if(Trate::Lib::Usuarios->verificaToken(request->headers->{token}) eq 0){
		status 401;
		return {error => "Token de sesion invalido ingrese nuevamente al sistema"};
	} else {
		Trate::Lib::Usuarios->renuevaToken(request->headers->{token});
	}
	return {message=>"Detalle del turno"};
};

patch '/turnos/cerrar/:id_turno' => sub {
	if(Trate::Lib::Usuarios->verificaToken(request->headers->{token}) eq 0){
		status 401;
		return {error => "Token de sesion invalido ingrese nuevamente al sistema"};
	} else {
		Trate::Lib::Usuarios->renuevaToken(request->headers->{token});
	}
	# Verificar que no haya despacho
	# Verificar que no haya jarreos sin devolución
	# Verificar que no haya recepciones de combustible sin registro
	# Bloquear servicios
	# <sit:SOUpdateFleets>
    #	<!--Optional:-->
    #     <sit:SessionID>WUrN73Cr693nUTSJxZm..jHIGsXD/AXFykmKtYAFB9YNASy78rqQ</sit:SessionID>
    #     <sit:site_code>5</sit:site_code>
    #     <sit:num_fleets>1</sit:num_fleets>
    #     <sit:a_soFleet>
    #        <sit:soFleet>
    #           <sit:id>200000003</sit:id>
    #           <sit:name>Laboratorio</sit:name>
    #           <sit:status>2</sit:status>
    #           <sit:code>1</sit:code>
    #           <sit:default_rule>200000000</sit:default_rule>
    #           <sit:acctyp>0</sit:acctyp>
    #           <sit:available_amount>0</sit:available_amount>
    #        </sit:soFleet>
    #     </sit:a_soFleet>
    #  </sit:SOUpdateFleets>

	# Desactivar tags de despachadores en el turno
	# Obtener totalizadores de bombas
	# Obtener lecturas de tanques
	# Calcular movimiento de entrega de turno
	return {message=>"Cierre de un turno"};
};

put '/turnos/abrir' => sub {
	if(Trate::Lib::Usuarios->verificaToken(request->headers->{token}) eq 0){
		status 401;
		return {error => "Token de sesion invalido ingrese nuevamente al sistema"};
	} else {
		Trate::Lib::Usuarios->renuevaToken(request->headers->{token});
	}
	# Verificar que no haya turno abierto
	# Obtener totalizadores de bombas
	# Obtener lecturas de tanques
	# Listar despachadores
	# Registrar turno abierto con los siguientes datos numero_empleado_recibe_turno,fecha_hora_recepcion,inventario_recibido,inventario_recibido_costo
	# Activar servicios
	# Activar tags de despachadores seleccionados
	return {message=>"Apertura de un turno"};	
};

get '/turnos/despachadores' => sub {
	if(Trate::Lib::Usuarios->verificaToken(request->headers->{token}) eq 0){
		status 401;
		return {error => "Token de sesion invalido ingrese nuevamente al sistema"};
	} else {
		Trate::Lib::Usuarios->renuevaToken(request->headers->{token});
	}
	return {message=>"Regresa listado de despachadores"};		
};

true;
