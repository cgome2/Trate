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
	if ($result->{num_transactions} gt 1){
		return procesaTransacciones($self,$result->{a_soTransaction}->{soTransaction});
	} elsif ($result->{num_transactions} eq 1){
		my @arregloTransaccionesProcesar;
		push @arregloTransaccionesProcesar, $result->{a_soTransaction}->{soTransaction};
		return procesaTransacciones($self, \@arregloTransaccionesProcesar);
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
		try {
			insertaTransaccion($self);
			insertaMovimiento($self);
			my $meanTransaction = Trate::Lib::Mean->new();
			$meanTransaction->id($row->{mean_id});
			$meanTransaction = Trate::Lib::Mean->getMeanFromId();
			
			if ($meanTransaction->auttyp() ne 21){
				LOGGER->info("Insertar jarreo para el dispositivo <" . $meanTransaction->NAME() . ">");
				actualizaPase($self);
				limpiaReglaCarga($self);
			} else {
				LOGGER->info("Insertar jarreo para el dispositivo <" . $meanTransaction->NAME() . ">");
				insertaJarreo($self);
			}
			
			$self->{TOTAL_RETRIEVED_TRANSACTIONS} = $self->{TOTAL_RETRIEVED_TRANSACTIONS} + 1;
			LOGGER->info(dump($meanTransaction));
			$return = 1;
		} catch {
			$return = 0;			
		} finally {
			LOGGER->info(dump($self));
		};
	}
	try {
		$self = setLastTransactionRetreived($self);	
		$return = 1;
	} catch {
		$return = 0;			
	} finally {
		return $return;
	};
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
	$movimiento->{ID_RECEPCION} = 'NULL';
	$movimiento->inserta();
	return $self;
}

sub insertaJarreo{
	my $self = shift;
	my $jarreo = Trate::Lib::Jarreo->new();
	$jarreo->transactionId($self->{IDTRANSACCIONES});
	$jarreo->transactionTimestamp($self->{FECHA});
	$jarreo->transactionDispensedQuantity($self->{TRANSACTION_DISPENSED_QUANTITY});
	$jarreo->transactionPpv($self->{TRANSACTION_PPV});
	$jarreo->transactionTotalPrice($self->{TRANSACTION_TOTAL_PRICE});
	$jarreo->transactionIva($self->{TRANSACTION_IVA});
	$jarreo->transactionIeps($self->{TRANSACTION_IEPS});
	$jarreo->transactionPumpHeadExternalCode($self->{TRANSACTION_PUMP_HEAD_EXTERNAL_CODE});
	$jarreo->{STATUS_CODE} = 2;
	$jarreo->inserta();	
}

sub actualizaPase{
	my $self = shift;
	LOGGER->info("Datos a procesar [ pase: " . $self->{PASE}->pase() . ", status actual: " . $self->{PASE}->status() . ", litros_real: " . $self->{CANTIDAD} . ", nuevo status: D]");
	$self->{PASE}->status('D');
	#$self->{PASE}->supervisor($self->{IDCORTES}->recibeTurno());
	$self->{PASE}->supervisor(191919);
	$self->{PASE}->observaciones('');
	$self->{PASE}->litrosReal($self->{CANTIDAD});
	$self->{PASE}->updatePase();
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

sub getLastNTransactions{
	my $self = shift;
	my ($sort,$order,$page,$limit,$search) = @_;
	my $connector = Trate::Lib::ConnectorMariaDB->new();
	my $where_stmt = "";
	
	if (length($sort) ge 1){
		$where_stmt .= " ORDER BY " . $sort;
		if (length($order) gt 1){
			$where_stmt .= " " . $order . " ";
		}
	}

	if (length($page) ge 1 && length($limit) ge 1){
		$where_stmt .= " LIMIT " . $page . "," . $limit;
	}	

	my $preps = "SELECT idtransacciones,placa,fecha,bomba,cantidad,sale,pase from transacciones " . $where_stmt ; 
	LOGGER->debug("Ejecutando sql[ ", $preps, " ]");
	my $sth = $connector->dbh->prepare($preps);
	$sth->execute() or die LOGGER->fatal("NO PUDO EJECUTAR EL SIGUIENTE COMANDO en MARIADB:orpak: $preps");
	my @transacciones;
	my $size = 0;
	while (my $ref = $sth->fetchrow_hashref()) {
		$size ++;
    	push @transacciones,$ref;
	}
	$sth->finish;
	$connector->destroy();
	my %return = (
		"data" => \@transacciones,
		"size" => $size
	);
	return \%return;	
}

1;
#EOF