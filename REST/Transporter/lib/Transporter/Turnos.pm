package Transporter::Turnos;

use Dancer ':syntax';
use Trate::Lib::Constants qw(LOGGER);
use Trate::Lib::Turnos;
use Data::Dump qw(dump);
use List::Util qw(all);
use Trate::Lib::Usuarios;
use Trate::Lib::Utilidades;
use Trate::Lib::Mean;


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
	my $date = length(params->{date}) gt 0 ? params->{date} : "";
	my $sort = length(params->{sort}) gt 0 ? params->{sort} : "";
	my $order = length(params->{order}) gt 0 ? params->{order} : "";


	my $TURNOS = Trate::Lib::Turnos->new();
	$return = $TURNOS->getTurnos($date,$sort,$order);
	LOGGER->info(dump($return));
	if ($return eq 0){
		status 400;
		return {message => "No existen turnos en el sistema"};
	} else {
		return $return;
	}
};

get '/shifts/:id_turno' => sub {
	if(Trate::Lib::Usuarios->verificaToken(request->headers->{token}) eq 0){
		status 401;
		return {error => "Token de sesion invalido ingrese nuevamente al sistema"};
	} else {
		Trate::Lib::Usuarios->renuevaToken(request->headers->{token});
	}

	my $TURNOS = Trate::Lib::Turnos->new();

	my $wstmt;
	if(params->{id_turno} eq "ultimo"){
		$wstmt = " ORDER BY t.fecha_abierto DESC ";
	} else {
		$TURNOS->idTurno(params->{id_turno});
		$wstmt = " WHERE t.id_turno = '" . params->{id_turno} . "' ";
	}
	my $return = 0;	
	$return = $TURNOS->getTurno($wstmt);
	LOGGER->info(dump($return));
	if ($return eq 0){
		status 400;
		return {message => "No existen turnos en el sistema"};
	} else {
		return $return;
	}
};

put '/shifts' => sub {
	my $usuario;
	if(Trate::Lib::Usuarios->verificaToken(request->headers->{token}) eq 0){
		status 401;
		return {error => "Token de sesion invalido ingrese nuevamente al sistema"};
	} else {
		Trate::Lib::Usuarios->renuevaToken(request->headers->{token});
		$usuario = Trate::Lib::Usuarios->getUsuarioByToken(request->headers->{token});
	}	

	my $post = from_json( request->body );

	my $turno = Trate::Lib::Turnos->new();
	my $wstmt = " ORDER BY t.fecha_abierto DESC ";	
	$turno->idTurno($turno->getTurno($wstmt)->{id_turno} + 1);
	$turno->{ID_USUARIO_ABRE} = $usuario->{idusuarios};
	$turno->{STATUS} = 2;
	$turno->abrirTurno();
	my $allmeans = Trate::Lib::Mean->getDespachadores();
	my @despachadores = @{$allmeans};
	LOGGER->info(dump($allmeans));
	my @means = @{$post->{MEANS_TURNO}};
	my $mean_turno;
	my $found = 0;
	foreach my $despachador (@despachadores){
		$found = 0;
		foreach my $mean (@means){
			LOGGER->debug($despachador->{id} . " vs " . $mean->{mean_id});
			if($despachador->{id} eq $mean->{mean_id}) {
				LOGGER->debug($despachador->{id} . " esta en el arreglo del post");
				$mean_turno = Trate::Lib::MeanTurno->new();
				$mean_turno->{ID_TURNO} = $turno->idTurno();
				$mean_turno->{MEAN_ID} = $mean->{mean_id};
				$mean_turno->{ID_USUARIO_ADD} = $usuario->{idusuarios};
				$mean_turno->{STATUS_MEAN_TURNO} = $mean->{status_mean_turno};
				$mean_turno->insertar();
				$found = 1;
				last;
			}
		}
		if ($found eq 0) 
		{
			$mean_turno = Trate::Lib::MeanTurno->new();
			$mean_turno->{ID_TURNO} = $turno->idTurno();
			$mean_turno->{MEAN_ID} = $despachador->{id};
			$mean_turno->{ID_USUARIO_ADD} = undef;
			$mean_turno->{STATUS_MEAN_TURNO} = 0;
			$mean_turno->insertar();
		}
		push @{$turno->{MEANS_TURNO}},$mean_turno;
	}

	$turno->insertOpenTotalizerReadings();
	LOGGER->info(dump($turno));
	
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

patch '/shifts/:id_turno' => sub {
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
true;
