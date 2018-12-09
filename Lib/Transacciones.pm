package Trate::Lib::Transacciones;

use Trate::Lib::Constants qw(LOGGER ORCURETRIEVEFILE);
use Trate::Lib::WebServicesClient;
use Trate::Lib::Utilidades;
use Trate::Lib::RemoteExecutor;
use Trate::Lib::ConnectorMariaDB;
use Trate::Lib::Movimiento;
use Trate::Lib::Pase;
use Trate::Lib::Corte;
use Trate::Lib::Mean;
use Try::Catch;
use Data::Dump qw(dump);


# Librerias para tratamiento de archivo XML
use XML::Writer;
use IO::File;
use XML::Twig;

sub new
{
	my $self = {};
	$self->{IDTRANSACCIONES} = undef; 				#id@transactions@BOS/DB/DATA.DB
	$self->{IDPRODUCTOS} = undef;					#product_code@transactions@BOS/DB/DATA.DB
	$self->{IDCORTES} = Trate::Lib::Corte->new();	#shift_id@transactions@BOS/DB/DATA.DB
	$self->{IDVEHICULOS} = undef; 					#mean_id@transactions@BOS/DB/DATA.DB
	$self->{IDDESPACHADORES} = undef; 				#driver_object_id@transactions@BOS/DB/DATA.DB
	$self->{IDTANQUES} = undef; 					#tank_id@transactions@BOS/DB/DATA.DB
	$self->{FECHA} = undef; 						#TIMESTAMP@transactions@BOS/DB/DATA.DB
	$self->{BOMBA} = undef; 						#pump@transactions@BOS/DB/DATA.DB
	$self->{MANGUERA} = undef; 						#nozzle@transactions@BOS/DB/DATA.DB
	$self->{CANTIDAD} = undef; 						#quantity@transactions@BOS/DB/DATA.DB
	$self->{ODOMETRO} = undef; 						#odometer@transactions@BOS/DB/DATA.DB
	$self->{ODOMETROANTERIOR} = undef; 				#previous_odometer@transactions@BOS/DB/DATA.DB
	$self->{HORASMOTOR} = undef; 					#engine_hours@transactions@BOS/DB/DATA.DB
	$self->{HORASMOTORANTERIOR} = undef; 			#previous_engine_hours@transactions@BOS/DB/DATA.DB
	$self->{PLACA} = undef; 						#plate@transactions@BOS/DB/DATA.DB
	$self->{RECIBO} = undef; 						#receipt_id@transactions@BOS/DB/DATA.DB
	$self->{TOTALIZADOR} = undef; 					#totalizer_vol@transactions@BOS/DB/DATA.DB
	$self->{TOTALIZADOR_ANTERIOR} = undef; 			#totalizer_original@transactions@BOS/DB/DATA.DB
	$self->{PPV} = undef; 							#ppv@transactions@BOS/DB/DATA.DB
	$self->{VENTA} = undef; 						#sale@transactions@BOS/DB/DATA.DB
	$self->{GROUP_RULE_ID} = undef;
	$self->{PASE} = Trate::Lib::Pase->new();		#pase se obtiene de las reglas de carga asignada al mean_id de transactions, es el numero previo a la P que integra el nombre de la regla grupal correspondiente
	$self->{LIMIT_RULE_ID} = undef;
	$self->{FUEL_RULE_ID} = undef;
	$self->{VISIT_RULE_ID} = undef;
	$self->{ORCURETRIEVEFILE} = ORCURETRIEVEFILE;
	$self->{LAST_TRANSACTION_ID} = undef; 			#ULTIMA TRANSACCION DESCARGADA
	$self->{LAST_TRANSACTION_TIMESTAMP} = undef;
	$self->{TOTAL_RETRIEVED_TRANSACTIONS} = undef;	#Total de transacciones descargadas desde el dia 1
	bless($self);
	return $self;	
}

sub getLastRetrievedTransactions{
    my $self = shift;
    my $twig= new XML::Twig;
    $twig->parsefile($self->{ORCURETRIEVEFILE});
    my $root = $twig->root;
 #	LOGGER->info(dump($root));
    my @transporter_transaction = $root->descendants('transporter:transaction');
    $self->{LAST_TRANSACTION_ID} = $transporter_transaction[0]->{'att'}->{'id'};
	$self->{LAST_TRANSACTION_TIMESTAMP} = $transporter_transaction[0]->{'att'}->{'TIMESTAMP'};
	$self->{TOTAL_RETRIEVED_TRANSACTIONS} = $transporter_transaction[0]->{'att'}->{'total_retrieved_transactions'};
	
	return $self;
}

sub getLastTransactionsFromORCUDeprecated{
	my $self = shift;
	$self = getLastRetrievedTransactions($self);
	my $remex = Trate::Lib::RemoteExecutor->new();
	my $query = "
				SELECT  
				        t.id,
				        t.product_code,
				        t.shift_id,
				        t.mean_id,
				        t.driver_object_id,
				        t.tank_id,
				        t.TIMESTAMP,
				        t.pump,
				        t.nozzle,
				        t.quantity,
				        t.odometer,
				        t.previous_odometer,
				        t.engine_hours,
				        t.previous_engine_hours,
				        t.plate,
				        t.receipt_id,
				        t.totalizer_vol,
				        t.totalizer_original,
				        t.ppv,
				        t.sale,
				        m.rule AS group_rule_id,
				        m.fleet_id,
				        gr.NAME AS rule_name,
				        gr.NAME AS pase,
				        gr.limits AS limit_rule_id,
				        gr.fuel AS fuel_rule_id,
				        gr.visits AS visit_rule_id
				FROM 
				        transactions as t left join means AS m on t.mean_id=m.id left join group_rules gr on gr.id=m.rule	
				WHERE 
						t.id>" . 
						$self->{LAST_TRANSACTION_ID} . " AND t.TIMESTAMP>'" .
						$self->{LAST_TRANSACTION_TIMESTAMP} . "' limit 1";
	LOGGER->debug($query);
	return $remex->remoteQuery($query);
}

sub getLastTransactionsFromORCU{
	my $self = shift;
	$self = getLastRetrievedTransactions($self);
	my %params = (
		SessionID => "",
		site_code => "",
		ho_role => "1",
		fromID => $self->{LAST_TRANSACTION_ID} + 1,
		toID => $self->{LAST_TRANSACTION_ID} + 5,
		extended_info => "1"
	);
	my $wsc = Trate::Lib::WebServicesClient->new();
	$wsc->callName("SOHOGetTransactionsByRange");
	$wsc->sessionId();
	my $result = $wsc->execute(\%params);	
	LOGGER->info($result->{num_transactions});
	if ($result->{num_transactions} > 0){
		return procesaTransacciones($self,$result->{a_soTransaction}->{soTransaction});
	} else {
		LOGGER->info("NINGUNA TRANSACCION POR DESCARGAR");
		$self->{IDTRANSACCIONES} = $self->{TOTAL_RETRIEVED_TRANSACTIONS} eq 0 ? $self->{LAST_TRANSACTION_ID} + 10 : $self->{LAST_TRANSACTION_ID};
		$self = setLastTransactionRetreived($self);
		return 0;
	}
}

sub procesaTransacciones($){
	my $self = shift;
	my $transaccionesarray = shift;
	my $regla;
	my $return = 0;
	LOGGER->debug("transacciones a procesar [" . @$transaccionesarray . "]");
	my @transacciones = @$transaccionesarray;
	foreach my $row (@transacciones){
		$self->{IDTRANSACCIONES} = $row->{'id'};
		$self->{IDPRODUCTOS} = $row->{'product_code'};
		$self->{IDCORTES} = getCorte($row->{'shift_id'} eq "" ? 0 : $row->{'shift_id'});
		$self->{IDVEHICULOS} = $row->{'mean_name'} eq "" ? "" : $row->{'mean_name'};
		$self->{IDDESPACHADORES} = $row->{'driver_mean_plate'} eq "" ? 0 : $row->{'driver_mean_plate'};
		$self->{FECHA} = $row->{'date'};
		$self->{BOMBA} = $row->{'pump'};
		$self->{MANGUERA} = $row->{'nozzle'};
		$self->{CANTIDAD} = $row->{'quantity'};
		$self->{ODOMETRO} = $row->{'odometer'} eq "" ? 0 : $row->{'odometer'};
		$self->{PLACA} = $row->{'plate'};
		$self->{PPV} = $row->{'ppv'};
		$self->{VENTA} = $row->{'total_price'};
		$self->{PASE} = getPase($row->{'mean_name'},$row->{'date'});
		LOGGER->info("pase " . $self->{PASE}->pase());
		try {
			insertaTransaccion($self);
			insertaMovimiento($self);
			actualizaPase($self);
			limpiaReglaCarga($self);
			$self->{TOTAL_RETRIEVED_TRANSACTIONS} = $self->{TOTAL_RETRIEVED_TRANSACTIONS} + 1;
			$return = 1;
		} catch {
			$return = 0;			
		} finally {
			LOGGER->info(dump($self));
		}
	}
	try {
		$self = setLastTransactionRetreived($self);	
		$return = 1;
	} catch {
		$return = 0;			
	} finally {
		return $return;
	}
}

sub insertaTransaccion{
	my $self = shift;
	my $connector = Trate::Lib::ConnectorMariaDB->new();
	my $preps = "
		INSERT INTO transacciones VALUES('"  .
			$self->{IDTRANSACCIONES} . "','" .
			$self->{IDPRODUCTOS} . "','" .
			$self->{IDCORTES}->folio() . "','" .
			$self->{IDVEHICULOS} . "','" .
			$self->{IDDESPACHADORES} . "','" .
			$self->{IDTANQUES} . "','" .
			$self->{FECHA} . "','" .
			$self->{BOMBA} . "','" .
			$self->{MANGUERA} . "','" .
			$self->{CANTIDAD} . "','" .
			$self->{ODOMETRO} . "','" .
			$self->{ODOMETROANTERIOR} . "','" .
			$self->{HORASMOTOR} . "','" .
			$self->{HORASMOTORANTERIOR} . "','" .
			$self->{PLACA} . "','" .
			$self->{RECIBO} . "','" .
			$self->{TOTALIZADOR} . "','" .
			$self->{TOTALIZADOR_ANTERIOR} . "','" .
			$self->{PPV} . "','" .
			$self->{VENTA} . "','" .
			$self->{PASE}->pase() . "')";
	LOGGER->debug("Ejecutando sql[ ", $preps, " ]");
	my $sth = $connector->dbh->prepare($preps);
	$sth->execute() or die LOGGER->fatal("NO PUDO EJECUTAR EL SIGUIENTE COMANDO en MARIADB:orpak: $preps");
	$sth->finish;
	$connector->destroy();
	return $self;
}

sub insertaMovimiento{
	my $self = shift;
	my $movimiento = Trate::Lib::Movimiento->new();
	$movimiento->{FECHA_HORA} = $self->{FECHA};
	$movimiento->{DISPENSADOR} = $self->{BOMBA};
	$movimiento->{SUPERVISOR} = $self->{IDCORTES}->recibeTurno();
	$movimiento->{DESPACHADOR} = $self->{IDDESPACHADORES};
	$movimiento->{VIAJE} = $self->{PASE}->viaje();
	$movimiento->{CAMION} = $self->{PASE}->camion();
	$movimiento->{CHOFER} = $self->{PASE}->chofer();
	$movimiento->{SELLO} = 'NULL';
	$movimiento->{TIPO_REFERENCIA} = '3';
	$movimiento->{SERIE} = 'NULL';
	$movimiento->{REFERENCIA} = $self->{PASE}->pase();
	$movimiento->{MOVIMIENTO} = '2';
	$movimiento->{LITROS_ESP} = $self->{PASE}->litros();
	$movimiento->{LITROS_REAL} = $self->{CANTIDAD};
	$movimiento->{COSTO_ESP} = '0';
	$movimiento->{COSTO_REAL} = $self->{VENTA};
	$movimiento->{IVA} = '0';
	$movimiento->{IEPS} = '0';
	$movimiento->{STATUS} = '0';
	$movimiento->{PROCESADA} = 'N';
	$movimiento->{TRANSACTION_ID} = $self->{IDTRANSACCIONES};
	$movimiento->inserta();
	return $self;
}

sub actualizaPase{
	my $self = shift;
	LOGGER->info("Datos a procesar [ pase: " . $self->{PASE}->pase() . ", status actual: " . $self->{PASE}->status() . ", litros_real: " . $self->{CANTIDAD} . ", nuevo status: D]");
	$self->{PASE}->status('D');
	$self->{PASE}->supervisor($self->{IDCORTES}->recibeTurno());
	$self->{PASE}->observaciones('');
	$self->{PASE}->litrosReal($self->{CANTIDAD});
	$self->{PASE}->actualiza();
	return $self;
}

sub setLastTransactionRetreived {
	my $self = shift;
	my $twig= XML::Twig->new(
		twig_roots => {
			'transporter:transaction' => sub{ 
				my( $t, $tt)= @_;
				$tt->set_att('id'=>$self->{IDTRANSACCIONES});
				$tt->set_att('TIMESTAMP'=>$self->{FECHA});
				$tt->set_att('timestamp_retrieve'=>Trate::Lib::Utilidades::getCurrentTimestampMariaDB());
				$tt->set_att('total_retrieved_transactions'=>$self->{TOTAL_RETRIEVED_TRANSACTIONS});
				$tt->print;		
		    },
		},
		twig_print_outside_roots => 1,
	);

	$twig->parsefile_inplace($self->{ORCURETRIEVEFILE});
	return $self;
}

sub limpiaReglaCarga{
	my $self = shift;
	my $mean = Trate::Lib::Mean->new();
	$mean->name($self->{IDVEHICULOS});
	my $resultado = $mean->desactivarMean();
	return $self;
}

sub getPase {
	my $camion = shift;
	my $fecha = shift;
	my $pase = Trate::Lib::Pase->new();
	$pase->getFromCamion($camion,$fecha);
	return $pase;
}

sub getCorte {
	my $corteId = shift;
	my $corte = Trate::Lib::Corte->new();
	$corte->getFromId($corteId);
	return $corte;
}

1;
#EOF