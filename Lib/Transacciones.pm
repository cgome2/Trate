package Trate::Lib::Transacciones;
#########################################################
#Transacciones - Clase Transacciones					#
#                                                       #
#Autor: Ramses                                          #
#Fecha: Noviembre, 2018                                 #
#Revision: 1.0                                          #
#                                                       #
#########################################################

use Trate::Lib::Constants qw(LOGGER ORCURETRIEVEFILE);
use Trate::Lib::WebServicesClient;
use Trate::Lib::Utilidades;
use Trate::Lib::RemoteExecutor;
use Trate::Lib::ConnectorMariaDB;
use Trate::Lib::Movimiento;
use Trate::Lib::Pase;
use Trate::Lib::Mean;
use Trate::Lib::Jarreo;
use Trate::Lib::Turnos;
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
	$self->{IDCORTES} = undef;						#id_turno
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
	$self->{TURNO} = Trate::Lib::Turnos->new();
	bless($self);
	return $self;	
}

# @author CG
# Get last 5 transactions array from orcu and process them
# 1.- Get last retrieved transaction that was processed
# 2.- Pull from ORCU the array with 5 posterior transactions to the retrieved one in previous step
# 3.- Process Transactions
# 4.- Update ORCURETRIEVEFILE with last transaction processed
# @params: No params required
# @return: 1 success 0 failure
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

# @author CG
# Get last transaction retrieved from orcu, it parses the ORCURETRIEVEFILE and get the transaction_id
# @params: No params required
# @return: Current object Trate::Lib::Transacciones with LAST TRANSACTION attributes filled
sub getLastRetrievedTransactions{
    	my $self = shift;
    	my $twig= XML::Twig->new->parsefile(ORCURETRIEVEFILE);
    	my $root = $twig->root;
    	my @transporter_transaction = $root->descendants('transporter:transaction');
	$self->{LAST_TRANSACTION_ID} = $transporter_transaction[0]->{'att'}->{'id'};
	$self->{LAST_TRANSACTION_TIMESTAMP} = $transporter_transaction[0]->{'att'}->{'transaction_timestamp'};
	$self->{TOTAL_RETRIEVED_TRANSACTIONS} = $transporter_transaction[0]->{'att'}->{'total_retrieved_transactions'};
	return $self;
}

# @author CG
# Process transactions array
# 1.- Insert transaction in transacciones@transporter
# 2.- Insert Movimiento in ci_movimientos@transporter
# 3.- If mean device of transaction is type Jarreo Insert Jarreo@transporter
# 4.- Insert Movimiento in ci_movimientos@informix
# @params: Array of transacciones
# @return: 1)success 0)failure
sub procesaTransacciones($){
	my $self = shift;
	my $transaccionesarray = shift;
	my $regla;
	my $return = 0;
	LOGGER->info("transacciones a procesar [" . @$transaccionesarray . "]");
	my @transacciones = @$transaccionesarray;
	foreach my $row (@transacciones){
		LOGGER->debug(dump($row));
		$self->{IDTRANSACCIONES} = $row->{'id'};
		$self->{IDPRODUCTOS} = $row->{'product_code'};
		$self->{TURNO} = getTurno($row->{'date'} . " " . $row->{'time'});
		$self->{IDCORTES} = $self->{TURNO}->idTurno();
		$self->{IDVEHICULOS} = $row->{'mean_id'} eq "" ? "" : $row->{'mean_id'};
		$self->{IDDESPACHADORES} = $row->{'driver_mean_plate'} eq "" ? 0 : $row->{'driver_mean_plate'};
		$self->{FECHA} = $row->{'date'} . " " . $row->{'time'};
		$self->{BOMBA} = $row->{'pump'};
		$self->{MANGUERA} = $row->{'nozzle'};
		$self->{CANTIDAD} = $row->{'quantity'};
		$self->{ODOMETRO} = $row->{'odometer'} eq "" ? 0 : $row->{'odometer'};
		$self->{PLACA} = $row->{'plate'};
		$self->{PPV} = $row->{'ppv'};
		$self->{VENTA} = $row->{'total_price'};
		try {
			insertaTransaccion($self);
			my $meanTransaction = Trate::Lib::Mean->new();
			$meanTransaction->{ID} = $row->{'mean_id'};
			LOGGER->debug(dump($meanTransaction));	
			$meanTransaction->fillMeanFromId();
			if($meanTransaction->auttyp() eq 21 && $meanTransaction->hardwareType() eq 1 && $meanTransaction->type() eq 2){
				LOGGER->info("Transacción es jarreo: " . $meanTransaction->auttyp() . " - " . $meanTransaction->hardwareType() . " - " . $meanTransaction->type());
				insertaMovimientoJarreo($self);
				insertaJarreo($self);
			} else {
				LOGGER->info("Transacción es despacho: " . $meanTransaction->auttyp() . " - " . $meanTransaction->hardwareType() . " - " . $meanTransaction->type());
				$self->{PASE} = getPase($row->{'mean_name'},$row->{'date'} . ' ' . $row->{'time'});
				insertaMovimiento($self);
				actualizaPase($self);
				limpiaReglaCarga($self);
			}
			
			$self->{TOTAL_RETRIEVED_TRANSACTIONS} = $self->{TOTAL_RETRIEVED_TRANSACTIONS} + 1;
			LOGGER->debug(dump($meanTransaction));
			$return = 1;
		} catch {
			$return = 0;			
		} 
		finally {
			LOGGER->debug("Fin de la insercion de la transaccion [" . $self->{IDTRANSACCIONES} . "]");
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

# @author CG
# Insert current object locally at transporter
# @params: No params required
# @return: current object
sub insertaTransaccion{
	my $self = shift;
	my $return = 0;
	my $connector = Trate::Lib::ConnectorMariaDB->new();
	my $preps = "
		INSERT INTO transacciones VALUES('"  .
			$self->{IDTRANSACCIONES} . "','" .
			$self->{IDPRODUCTOS} . "','" .
			$self->{IDCORTES} . "','" .
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
	$return = $self;
}

# @author CG
# Create movimiento object from current transacciones object
# Insert movimiento object locally and remotely at informix
# @params: No params required
# @return: Current object Trate::Lib::Transacciones
sub insertaMovimiento{
	my $self = shift;
	my $movimiento = Trate::Lib::Movimiento->new();
	$movimiento->{FECHA_HORA} = $self->{FECHA};
	$movimiento->{DISPENSADOR} = $self->{BOMBA};
	$movimiento->{SUPERVISOR} = $self->{TURNO}->usuarioAbre();
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
	$movimiento->insertaMDB();
	return $self;
}

# @author CG
# Create movimiento object with jarreo data from current transacciones object
# Insert movimiento object locally and remotely at informix
# @params: No params required
# @return: Current object Trate::Lib::Transacciones
sub insertaMovimientoJarreo{
	my $self = shift;
	my $movimiento = Trate::Lib::Movimiento->new();
	$movimiento->{FECHA_HORA} = $self->{FECHA};
	$movimiento->{DISPENSADOR} = $self->{BOMBA};
	$movimiento->{SUPERVISOR} = $self->{TURNO}->usuarioAbre();
	$movimiento->{DESPACHADOR} = $self->{IDDESPACHADORES};
	$movimiento->{VIAJE} = 0;
	$movimiento->{CAMION} = 0;
	$movimiento->{CHOFER} = 0;
	$movimiento->{SELLO} = 'NULL';
	$movimiento->{TIPO_REFERENCIA} = '3';
	$movimiento->{SERIE} = 'NULL';
	$movimiento->{REFERENCIA} = 0;
	$movimiento->{MOVIMIENTO} = '3';
	$movimiento->{LITROS_ESP} = 0;
	$movimiento->{LITROS_REAL} = $self->{CANTIDAD};
	$movimiento->{COSTO_ESP} = '0';
	$movimiento->{COSTO_REAL} = $self->{VENTA};
	$movimiento->{IVA} = '0';
	$movimiento->{IEPS} = '0';
	$movimiento->{STATUS} = '0';
	$movimiento->{PROCESADA} = 'N';
	$movimiento->{TRANSACTION_ID} = $self->{IDTRANSACCIONES};
	$movimiento->{ID_RECEPCION} = 'NULL';
	LOGGER->info(dump($movimiento));
	$movimiento->insertaMDB();
	return $self;
}

sub insertaMovimientoDevolucionJarreo(){
	my $self = shift;
	my $usuarioDevolucion = pop;
	my $movimiento = Trate::Lib::Movimiento->new();
	$movimiento->{FECHA_HORA} = Trate::Lib::Utilidades->getCurrentTimestampMariaDB();
	$movimiento->{DISPENSADOR} = $self->{BOMBA};
	$movimiento->{SUPERVISOR} = $usuarioDevolucion;
	$movimiento->{DESPACHADOR} = $usuarioDevolucion;
	$movimiento->{VIAJE} = 0;
	$movimiento->{CAMION} = 0;
	$movimiento->{CHOFER} = 0;
	$movimiento->{SELLO} = 'NULL';
	$movimiento->{TIPO_REFERENCIA} = '4';
	$movimiento->{SERIE} = 'NULL';
	$movimiento->{REFERENCIA} = $self->{IDTRANSACCIONES};
	$movimiento->{MOVIMIENTO} = '4';
	$movimiento->{LITROS_ESP} = 0;
	$movimiento->{LITROS_REAL} = $self->{CANTIDAD};
	$movimiento->{COSTO_ESP} = '0';
	$movimiento->{COSTO_REAL} = $self->{VENTA};
	$movimiento->{IVA} = '0';
	$movimiento->{IEPS} = '0';
	$movimiento->{STATUS} = '0';
	$movimiento->{PROCESADA} = 'N';
	$movimiento->{TRANSACTION_ID} = $self->{IDTRANSACCIONES};
	$movimiento->{ID_RECEPCION} = 'NULL';
	LOGGER->info(dump($movimiento));
	$movimiento->insertaMDB();
	return $self;
}

# @author CG
# Create jarreo object from current transacciones object
# Insert jarreo object locally
# @params: No params required
# @return: Current object Trate::Lib::Transacciones
sub insertaJarreo{
	my $self = shift;
	my $jarreo = Trate::Lib::Jarreo->new();
	$jarreo->{TRANSACTION_ID} = $self->{IDTRANSACCIONES};
	$jarreo->{TRANSACTION_TIMESTAMP} = $self->{FECHA};
	$jarreo->{TRANSACTION_DISPENSED_QUANTITY} = $self->{CANTIDAD};
	$jarreo->{TRANSACTION_PPV} = $self->{PPV};
	$jarreo->{TRANSACTION_TOTAL_PRICE} = $self->{VENTA};
	$jarreo->{TRANSACTION_IVA} = 1;
	$jarreo->{TRANSACTION_IEPS} = 1;
	$jarreo->{TRANSACTION_PUMP_HEAD_EXTERNAL_CODE} = $self->{BOMBA};
	$jarreo->{STATUS_CODE} = 2;
	LOGGER->debug(dump($jarreo));
	$jarreo->inserta();	
}

sub actualizaPase{
	my $self = shift;
	LOGGER->info("Datos a procesar [ pase: " . $self->{PASE}->pase() . ", status actual: " . $self->{PASE}->status() . ", litros_real: " . $self->{CANTIDAD});
	if($self->{PASE}->status() eq "T"){
		$self->{PASE}->status('C');	
	} elsif($self->{PASE}->status() eq "R" && length($self->{PASE}->meanContingencia()) gt 0){
		$self->{PASE}->status('C');	
	} else {
		$self->{PASE}->status('D');	
	}
	LOGGER->info("Nuevo status: [" . $self->{PASE}->status() . "]");
	$self->{PASE}->supervisor($self->{TURNO}->usuarioAbre());
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
				$tt->set_att('transaction_timestamp'=>$self->{FECHA});
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
	my $mean = shift;
	my $fecha = shift;
	my $pase = Trate::Lib::Pase->new();
	$pase->getFromMean($mean,$fecha);
	return $pase;
}

sub getTurno {
	my $fechatransaccion = shift;
	my $turno = Trate::Lib::Turnos->new();
	$turno->getFromTimestamp($fechatransaccion);
	return $turno;
}

sub getLastNTransactions{
	my $self = shift;
	my ($sort,$order,$page,$limit,$search) = @_;
	my $connector = Trate::Lib::ConnectorMariaDB->new();
	my $where_stmt = "";
	$order = "DESC";
	$sort = "idtransacciones";
	
	if (length($sort) ge 1){
		$where_stmt .= " ORDER BY " . $sort;
		if (length($order) gt 1){
			$where_stmt .= " " . $order . " ";
		}
	}

	if (length($page) ge 1 && length($limit) ge 1){
		$where_stmt .= " LIMIT " . ($page-1)*$limit . "," . $limit;
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

sub getTransaccionFromId{
	my $self = shift;
	my $id = pop;

	my $connector = Trate::Lib::ConnectorMariaDB->new();
	
	my $preps = "SELECT * from transacciones WHERE idtransacciones =" . $id ; 
	LOGGER->debug("Ejecutando sql[ ", $preps, " ]");
	my $sth = $connector->dbh->prepare($preps);
	$sth->execute() or die LOGGER->fatal("NO PUDO EJECUTAR EL SIGUIENTE COMANDO en MARIADB:orpak: $preps");
	my $row = $sth->fetchrow_hashref();
	$sth->finish;
	$connector->destroy();
	if($row){
		return $row;
	} else {
		return 0;
	}
}

sub fillTransaccionFromId{
	my $self = shift;

	my $connector = Trate::Lib::ConnectorMariaDB->new();
	
	my $preps = "SELECT * from transacciones WHERE idtransacciones =" . $self->{IDTRANSACCIONES} ; 
	LOGGER->debug("Ejecutando sql[ ", $preps, " ]");
	my $sth = $connector->dbh->prepare($preps);
	$sth->execute() or die LOGGER->fatal("NO PUDO EJECUTAR EL SIGUIENTE COMANDO en MARIADB:orpak: $preps");
	my $row = $sth->fetchrow_hashref();
	$sth->finish;
	$connector->destroy();
	if($row){
		$self->{IDTRANSACCIONES} = $row->{idtransacciones}; 				
		$self->{IDPRODUCTOS} = $row->{idproductos};
		$self->{IDCORTES} = $row->{idcortes};
		$self->{IDVEHICULOS} = $row->{idvehiculos};
		$self->{IDDESPACHADORES} = $row->{iddespachadores};
		$self->{IDTANQUES} = $row->{idtanques};
		$self->{FECHA} = $row->{fecha};
		$self->{BOMBA} = $row->{bomba};
		$self->{MANGUERA} = $row->{manguera};
		$self->{CANTIDAD} = $row->{cantidad};
		$self->{ODOMETRO} = $row->{odometro};
		$self->{ODOMETROANTERIOR} = $row->{odometroanterior};
		$self->{HORASMOTOR} = $row->{horasMotor};
		$self->{HORASMOTORANTERIOR} = $row->{horasMotorAnterior};
		$self->{PLACA} = $row->{placa};
		$self->{RECIBO} = $row->{recibo};
		$self->{TOTALIZADOR} = $row->{totalizador};
		$self->{TOTALIZADOR_ANTERIOR} = $row->{totalizador_anterior};
		$self->{PPV} = $row->{ppv};
		$self->{VENTA} = $row->{ppv};
		$self->{PASE} = $row->{pase};
		return $self;
	} else {
		return 0;
	}
}

1;
#EOF
