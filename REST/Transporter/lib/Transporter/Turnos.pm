package Transporter::Turnos;

use Dancer ':syntax';
use Trate::Lib::Constants qw(LOGGER);
use Trate::Lib::Turnos;
use Data::Dump qw(dump);
use List::Util qw(all);
use Trate::Lib::Usuarios;
use Trate::Lib::Utilidades;
use Trate::Lib::Mean;
use Data::Structure::Util qw( unbless );

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
	if ($return eq 0){
		status 400;
		return {message => "No existen turnos en el sistema"};
	} else {
		return $return;
	}
};

get '/shifts/:id_turno' => sub {
	my $usuario;
	if(Trate::Lib::Usuarios->verificaToken(request->headers->{token}) eq 0){
		status 401;
		return {error => "Token de sesion invalido ingrese nuevamente al sistema"};
	} else {
		Trate::Lib::Usuarios->renuevaToken(request->headers->{token});
		$usuario = Trate::Lib::Usuarios->getUsuarioByToken(request->headers->{token});
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
	if(params->{id_turno} eq "nuevo"){
		$TURNOS->{ID_TURNO} = "";
		$TURNOS->{FECHA_ABIERTO} = Trate::Lib::Utilidades->getCurrentTimestampMariaDB();
		$TURNOS->{ID_USUARIO_ABRE} = $usuario->{idusuarios};
		$TURNOS->{USUARIO_ABRE} = $usuario->{numero_empleado};
		$return = $TURNOS->getNew();
	} else {
		$return = $TURNOS->getTurno($wstmt);
	}

	if ($return eq -1){
		status 400;
		return {message => "No hay lectura con los tanques, no se puede abrir turno"};
	} elsif($return eq 0) {
		status 400;
		return {message => "No existe turno"};
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
	# LOGGER->info(dump($allmeans));
	my @means = @{$post->{MEANS_TURNO}};
	my $mean_turno;
	my $omean = Trate::Lib::Mean->new();
	my $found = 0;
	foreach my $despachador (@despachadores){
		$found = 0;
		foreach my $mean (@means){
			# LOGGER->debug($despachador->{id} . " vs " . $mean->{mean_id});
			if($despachador->{id} eq $mean->{mean_id}) {
				# LOGGER->debug($despachador->{id} . " esta en el arreglo del post");
				$mean_turno = Trate::Lib::MeanTurno->new();
				$mean_turno->{ID_TURNO} = $turno->idTurno();
				$mean_turno->{MEAN_ID} = $mean->{mean_id};
				$mean_turno->{ID_USUARIO_ADD} = $mean->{activo} eq 1 ? $usuario->{idusuarios} : "";
				$mean_turno->{TIMESTAMP_ADD} = $mean->{activo} eq 1 ? 1 : "";
				$mean_turno->{STATUS_MEAN_TURNO} = $mean->{activo} eq 1 ? 2 : 0;
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
			$mean_turno->{ID_USUARIO_ADD} = "";
			$mean_turno->{TIMESTAMP_ADD} = "";
			$mean_turno->{STATUS_MEAN_TURNO} = 0;
			$mean_turno->insertar();
		}
		$omean->id($mean_turno->{MEAN_ID});
		$omean->fillMeanFromId();
		$mean_turno->{STATUS_MEAN_TURNO} eq 2 ? $omean->activarMean() : $omean->desactivarMean();
	}

	$turno->insertOpenTotalizerReadings();
	$turno->insertOpenTankReadings();
	$turno->cambiarEstatusFlota("ACTIVA");

	return $turno->getTurno($wstmt);
};

patch '/shifts' => sub {
	my $usuario;
	if(Trate::Lib::Usuarios->verificaToken(request->headers->{token}) eq 0){
		status 401;
		return {error => "Token de sesion invalido ingrese nuevamente al sistema"};
	} else {
		Trate::Lib::Usuarios->renuevaToken(request->headers->{token});
		$usuario = Trate::Lib::Usuarios->getUsuarioByToken(request->headers->{token});
	}	

	my $post = from_json( request->body );
	if($post->{status} eq 1){
		my $wstmt;
		my $turno = Trate::Lib::Turnos->new();
		$turno->idTurno($post->{id_turno});
		$wstmt = " WHERE t.id_turno = '" . $post->{id_turno} . "' ";

		$turno->{STATUS} = 1;
		$turno->{ID_USUARIO_CIERRA} = $usuario->{idusuarios};
		$turno->{USUARIO_CIERRA} = $usuario->{numero_empleado};
		my $oturno = $turno->getTurno($wstmt);
		$turno->{FECHA_ABIERTO} = $oturno->{fecha_abierto};
		$turno->{ID_USUARIO_ABRE} = $oturno->{id_usuario_abre};
		$turno->{USUARIO_ABRE} = $oturno->{usuario_abre};
		$turno->{MEANS_TURNO} = $oturno->{MEANS_TURNO};
		$turno->{TANQUES_TURNO} = $oturno->{TANQUES_TURNO};
		$turno->{BOMBAS_TURNO} = $oturno->{BOMBAS_TURNO};

		if($turno->verificarJarreosAbiertos()){
			status 400;
			return {message => "Existen jarreos sin devolucion"}; 
		}
		if($turno->verificarEstadosBombaIdle()){
			status 400;
			return {message => "Existen bombas en uso"}; 
		}
		if($turno->verificarRecepcionesDocumentos()){
			status 400;
			return {message => "Existen recepciones de combustible sin documentar"}; 
		}
		if($turno->cambiarEstatusFlota("INACTIVA")){
			status 400;
			return {message => "No se han podido bloquear los dispositivos de operación para el cierre"}; 
		}
		$turno->bloquearMeansDespachador();
		$turno->insertCloseTankReadings();
		$turno->insertCloseTotalizerReadings();
		$turno->cerrarTurno();
		$turno->enviarTurnoTrate();
		status 200;
		return {message=>"Turno cerrado con éxito"};
	} else {
		my $turno = Trate::Lib::Turnos->new();
		$turno->idTurno($post->{id_turno});
		$turno->{ID_USUARIO_CIERRA} = $usuario->{idusuarios};
		$turno->{MEANS_TURNO} = $post->{MEANS_TURNO};
		$turno->actualizaMeansTurno();
		status 200;
		return {message=>"Turno modificado con éxito"};
	}
};
true;
