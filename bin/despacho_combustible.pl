#!/usr/bin/perl
##########################################################################
# Name: 
# Description: 
# Author: 
# Adapted by: 
# Date : 
# Version: 
##########################################################################
use strict;
use Trate::Lib::ConnectorInformix;
use Trate::Lib::ConnectorMariaDB;
use Trate::Lib::RemoteExecutor;
use Trate::Lib::Constants qw(LOGGER TRUE FALSE);

#use experimental qw( switch );
use Switch;

my ($fecha_fin, $estacion, $dispensador, $supervisor, $despachador, $viaje, $camion, $fecha_finmy, $movimiento);
my ($chofer, $tipo_referencia, $referencia, $litros_esp, $litros_real, $costo_esp, $costo_real, $iva, $ieps, $transaction_id);
my ($tipo_producto, $ppv, $status, $id_vehiculo, $litros_limit, $tipo_cmd, $shift_id, $poid, $observaciones);
my $nom_cmd;
my $APLICA_CONTING=0;
my ($dbmy, $dbin);
my ($status_old, $status_new);
my ( $IDMYSQL, $IDINFMX, $BEGINTRAN, $ERRDB, $COMITTRAN, $ROLLBTRAN);
my $mensaje_log;

sub calcula_fecha_fin {
    my ($log_arc) = @_;
    my ($sth, $fecha_tmp);
    my $sql = "SELECT NOW()";
    $sth = $dbmy->prepare($sql);
    $sth->execute() or &wr_log($log_arc, "NO PUDO EJECUTAR EL SIGUIENTE COMANDO en MYSQL:orpak: $sql", 1);
    $fecha_tmp = $sth->fetchrow_array;
    $sth->finish;
    $fecha_finmy = $fecha_tmp;
    $fecha_fin = substr($fecha_tmp, 0, 16);
    return TRUE;
}

sub toma_despachador {
	my ($log_arc) = @_;
	my ($sth, $sql);
  
	$sql = sprintf 
	"SELECT 
		b.object_desc AS tag_desc 
	FROM 
		history_log_t a 
		LEFT JOIN object_language_matrix b ON b.object_id = a.field2 AND b.language_code =\'es\' 
		LEFT JOIN object_language_matrix c ON c.object_id = a.field3 AND c.language_code =\'es\'  
		LEFT JOIN tbl t ON t.tbl = \'SFTGST\' AND t.language_code = \'es\' AND t.code = a.field4  
	WHERE 
		a.histyp_code=\'3\' AND t.name=\'ENTRO\' AND a.field1=%s LIMIT 1", $shift_id;
	$sth = $dbmy->prepare($sql);
	$sth->execute() or &wr_log($log_arc, "NO PUDO EJECUTAR EL SIGUIENTE COMANDO en MYSQL:orpak: $sql", 0);
	$despachador = $sth->fetchrow_array;
	$sth->finish;
	return TRUE;
}

sub toma_numero_iva_ieps {
	my ($log_arc) = @_;
	my $sth;
	my ($ieps_tmp, $iva_tmp);
	my $sql = sprintf 
	"SELECT 
		ROUND(product_ieps * %.4f,4),
		ROUND(((%.4f - product_ieps)/(1 + product_iva))*product_iva*%.4f,4) 
	 FROM 
		produc_ieps 
	 WHERE 
		product_id=%s 
	 AND 
		status=1", 
		$litros_real, 
		$ppv, 
		$litros_real, 
		$tipo_producto;
	$sth = $dbmy->prepare($sql);
	$sth->execute() or &wr_log($log_arc, "NO PUDO EJECUTAR EL SIGUIENTE COMANDO en MYSQL:orpak: $sql", 1);
	($ieps,$iva) = $sth->fetchrow_array;
	$sth->finish;
	return TRUE;
}

sub inserta_movimientos_siteomat {
	my ($log_arc) = @_;
	my $sql;
  
	$transaction_id = ($transaction_id == "NULL") ? 0 : $transaction_id;
	$tipo_referencia = (defined($tipo_referencia) && $tipo_referencia>0) ? $tipo_referencia : 3;
	
	$sql = sprintf
	"INSERT INTO ci_movimientos	(fecha_hora,
					 estacion, 
					 dispensador, 
					 supervisor, 
					 despachador, 
					 viaje, 
					 camion, 
					 chofer, 
					 sello, 
					 tipo_referencia, 
					 serie,
					 referencia,
					 movimiento,
					 litros_esp,
					 litros_real,
					 costo_esp,
					 costo_real,
					 iva,
					 ieps,
					 status,
					 procesada,
					 transaction_id)
				VALUES  (\'%s\',%.4d,%d,%d,%d,%d,%d,%d,NULL,%d,NULL,%d,%d,%.4f,%.4f,%.4f,%.4f,%.4f,%.4f,%d,'N',%s)",
					 $fecha_finmy,
					 $estacion,
					 $dispensador,
					 $supervisor,
					 $despachador,
					 $viaje,
					 $camion,
					 $chofer,
					 $tipo_referencia,
					 $referencia,
					 $movimiento,
					 $litros_esp,
					 $litros_real,
					 $costo_esp,
					 $costo_real,
					 $iva,
					 $ieps,
					 $status,
					 $transaction_id;
	$dbmy->do($sql) or &inserta_error_log($log_arc, $dbmy, $IDMYSQL, "Mysql:Orpak", $sql);
	return TRUE;
}

sub inserta_movimientos_trate {
	my ($log_arc) = @_;
	my ($sql, $sth, $camion_trate);
        $transaction_id = ($transaction_id == "NULL") ? 0 : $transaction_id;
	$tipo_referencia = (defined($tipo_referencia) && $tipo_referencia>0) ? $tipo_referencia : 3;
	$sql = sprintf "SELECT camion FROM ci_pases WHERE pase=%d", $referencia;
	$sth = $dbin->prepare($sql);
	$sth->execute() or &wr_log($log_arc, "NO PUDO EJECUTAR EL SIGUIENTE COMANDO en INFORMIX:Trate: $sql", 0);
	$camion_trate = $sth->fetchrow_array;
	$sth->finish;
	$sql = sprintf
	"INSERT INTO ci_movimientos 
					(fecha_hora, 
					 estacion,
					 dispensador,
					 supervisor,
					 despachador,
					 viaje,
					 camion,
					 chofer,
					 sello,
					 tipo_referencia,
					 serie,
					 referencia,
					 movimiento,
					 litros_esp,
					 litros_real,
					 costo_esp,
					 costo_real,
					 iva,
					 ieps,
					 status,
					 procesada,
					 transaction_id) 
				 VALUES (\'%s\',%.4d,%d,%d,%d,%d,%d,%d,NULL,%d,NULL,%d,%d,%.4f,%.4f,%.4f,%.4f,%.4f,%.4f,%d,'N',%s)",
					 $fecha_fin,
					 $estacion,
					 $dispensador,
					 $supervisor,
					 $despachador,
					 $viaje,
					 $camion_trate,
					 $chofer,
					 $tipo_referencia,
					 $referencia,
					 $movimiento,
					 $litros_esp, 
					 $litros_real,
					 $costo_esp,
					 $costo_real,
					 $iva,
					 $ieps,
					 $status,
					 $transaction_id;

	$dbin->do($sql) or &inserta_error_log($log_arc, $dbmy, $IDINFMX, "Informix:trate", $sql);
	return TRUE;
}

sub inserta_jarreos_siteomat {
	my ($log_arc) = @_;
	my $sql;
  
	$transaction_id = ($transaction_id == "NULL") ? 0 : $transaction_id;
	$sql = sprintf
	"INSERT INTO jarreos_t 
				(transaction_id, 
				 transaction_timestamp,
				 transaction_dispensed_quantity,
				 transaction_pump_head_external_code,
				 transaction_total_price,
				 transaction_ppv,
				 transaction_iva,
				 transaction_ieps,
				 status_code) 
			VALUES (\'%s\',\'%s\',%.4f,%d,%.4f,%.4f,%.4f,%.4f,2)",
				 $transaction_id,
				 $fecha_finmy,
				 $litros_real,
				 $dispensador,
				 $costo_real,
				 $ppv,
				 $iva,
				 $ieps;
	$dbmy->do($sql) or &inserta_error_log($log_arc, $dbmy, $IDMYSQL, "Mysql:Orpak", $sql);
	return TRUE;
}

sub main {
	$dbmy=Orpak::DbLib::Connect() or &wr_log(*ARC_LOG, "NO SE PUDO CONECTAR AL SERVIDOR MYSQL", 1);
	&begin_commit_rollback_trans_trate(*ARC_LOG, $dbmy, $BEGINTRAN);
	#$dbin = Connect_Informix_trate(*ARC_LOG, $dbmy);
	$dbin=Orpak::Trate::Trate_functions::Connect_Informix_trate(*ARC_LOG, $dbmy);
	&begin_commit_rollback_trans_trate(*ARC_LOG, $dbin, $BEGINTRAN);
  
	#SI ES JARREO
	if ($tipo_cmd==3 ) { # Es jarreo
		&calcula_fecha_fin(*ARC_LOG);
		
		$estacion = &toma_numero_estacion(*ARC_LOG, $dbmy);
		
		# Dispensador viene en la variable $dispensador 
		
		$supervisor = &toma_numero_supervisor(*ARC_LOG, $dbmy);
		$supervisor = (defined($supervisor) && $supervisor =~ /\d+$/ ) ? $supervisor : 0;
		
		&toma_despachador(*ARC_LOG);
		$despachador = (defined($despachador) && $despachador =~ /\d+$/ ) ? $despachador : 0;
		
		$viaje = 0;
		$camion = 0;
		$chofer = 0;
		
		# Sello viene en la variable $sello como NULL
		$tipo_referencia = 3;
		# Serie viene en la variable $serie como NULL
		
		$referencia = 0;
		$movimiento = 3;
		$litros_esp = 0;
		# litros_real viene en la variable $litros_real
		$costo_esp = 0;
		# costo_real viene en la variable $costo_real
		# ahora obtenemos ieps e iva
		&toma_numero_iva_ieps(*ARC_LOG);
		$status = 0;
		# procesada='N'
		
		&inserta_jarreos_siteomat(*ARC_LOG);
		&inserta_movimientos_siteomat(*ARC_LOG);
		&inserta_movimientos_trate(*ARC_LOG);				#ESTO HAY QUE ACTIVARLO PARA TRATE
		if ($ERRDB == FALSE) {
			&begin_commit_rollback_trans_trate(*ARC_LOG, $dbmy, $COMITTRAN);
			&begin_commit_rollback_trans_trate(*ARC_LOG, $dbin, $COMITTRAN);
		}
		else {
			&begin_commit_rollback_trans_trate(*ARC_LOG, $dbmy, $ROLLBTRAN);
			&begin_commit_rollback_trans_trate(*ARC_LOG, $dbin, $ROLLBTRAN);
		}  
	}
	#SI ES DEVOLUCION DE JARREO
	elsif ($tipo_cmd==4) { # Es devolución de jarreo
		my $utime=time;#unix time
		my @time=localtime $utime;
		my $stime=strftime("%F %T",@time);#time as outputted to string, 'yyyy-mm-dd hh:mm:ss'

		##$fecha_finmy = $fecha_fin;
		$fecha_finmy = $stime;
		$fecha_fin = substr($fecha_finmy, 0, 16);
		$estacion = &toma_numero_estacion(*ARC_LOG, $dbmy);
		# Dispensador viene en la variable $dispensador 
		
		$supervisor = &toma_numero_supervisor(*ARC_LOG, $dbmy);
		$supervisor = (defined($supervisor) && $supervisor =~ /\d+$/ ) ? $supervisor : 0;
		
		&toma_despachador(*ARC_LOG);
		$despachador = (defined($despachador) && $despachador =~ /\d+$/ ) ? $despachador : 0;
		
		$viaje = 0;
		$camion = 0;
		$chofer = 0;
		
		# Sello viene en la variable $sello como NULL
		$tipo_referencia = 4;
		# Serie viene en la variable $serie como NULL
		
		$referencia = 0;
		$movimiento = 4;
		$litros_esp = 0;
		# litros_real viene en la variable $litros_real
		$costo_esp = 0;
		# costo_real viene en la variable $costo_real
		# ahora obtenemos ieps e iva
		&toma_numero_iva_ieps(*ARC_LOG);
		$status = 0; 
		# procesada = 'N'
		
		&inserta_movimientos_siteomat(*ARC_LOG);
		&inserta_movimientos_trate(*ARC_LOG);				#ESTO HAY QUE ACTIVARLO PARA TRATE
		if ($ERRDB == FALSE) {
			&begin_commit_rollback_trans_trate(*ARC_LOG, $dbmy, $COMITTRAN);
			&begin_commit_rollback_trans_trate(*ARC_LOG, $dbin, $COMITTRAN);
		}
		else {
			&begin_commit_rollback_trans_trate(*ARC_LOG, $dbmy, $ROLLBTRAN);
			&begin_commit_rollback_trans_trate(*ARC_LOG, $dbin, $ROLLBTRAN);
		}  
	}
	$dbin->disconnect;
	$dbmy->disconnect();
}


($tipo_cmd, $fecha_fin, $dispensador, $supervisor, $despachador, $viaje, $camion, $chofer, $referencia, $litros_esp, $litros_real, $costo_real, $tipo_producto, $ppv, $id_vehiculo, $shift_id, $poid, $observaciones, $transaction_id) = @ARGV;

LOGGER->info("==== INICIALIZANDO ==== |Programa $0 en EJECUCION");


#given ($tipo_cmd) {
#	when (1) { $nom_cmd = "AUTOMATICO" }
#	when (2) { $nom_cmd = "MANUAL" }
#	when (3) { $nom_cmd = "JARREO" }
#	when (4) { $nom_cmd = "DEVOLUCION_JARREO" }
#	default { $nom_cmd = "AUTOMATICO" }
#}

switch ($tipo_cmd)
{
	case 1 { $nom_cmd = "AUTOMATICO" }
	case 2 { $nom_cmd = "MANUAL" }
	case 3 { $nom_cmd = "JARREO" }
	case 4 { $nom_cmd = "DEVOLUCION_JARREO" }
	else { $nom_cmd = "AUTOMATICO" }
}


$mensaje_log = "DATOS PROCESAR: \n
	ACTIVIDAD A REALIZAR: $nom_cmd
	FECHA FIN: $fecha_fin
	DISPENSADOR: $dispensador
	SUPERVISOR: $supervisor
	DESPACHADOR: $despachador
	VIAJE: $viaje
	CAMION: $camion
	CHOFER: $chofer
	REFERENCIA: $referencia
	LITROS ESPERADOS: $litros_esp
	LITROS REALES: $litros_real
	COSTO REAL: $costo_real
	TIPO PRODUCTO: $tipo_producto
	PPV: $ppv
	ID_VEHICULO: $id_vehiculo
	ID_TURNO: $shift_id
	PUMPID: $poid
	OBSERVACIONES: $observaciones
	ID TRANSACCION: $transaction_id";
print "$mensaje_log\n";
LOGGER->debug($mensaje_log);


if ($#ARGV < 17 ) {
	my $error_message = "
		ERROR EN EL USO DEL COMANDO, ES NECESARIO INGRESAR COMO PARÁMETROS:
		COMANDO (1: AUTOMATICO, 2: MANUAL, 3: JARREO, 4: DEVOLUCION JARREO),
		FECHA FIN,
		DISPENSADOR,
		SUPERVISOR,
		DESPACHADOR,
		VIAJE,
		CAMION,
		CHOFER,
		REFERENCIA,
		LITROS_ESPERADOS,
		LITROS_REALIES,
		COSTO_REAL,
		TIPO PRODUCTO,
		PPV,
		ID_VEHICULO,
		ID_TURNO,
		PUMPID,
		OBSERVACIONES,
		ID_TRANSACCION
	";
	
	print $error_message;
	LOGGER->debug("Numero de Argumentos Invalido. Faltan Datos $error_message");
	exit TRUE;
}

###############################
# INSERCION POR JARREO
# CASO4:	perl 3 "NULL" $obj_ext_code "NULL" "NULL" "NULL" $vehicle_plate "NULL" "NULL" "NULL" $quantity $price $prod $ppv $vehicle_id $shift_object_id $poid "NULL" $recnum
# INSERCION POR DEVOLUCION DE JARREO
# CASO5:	perl 4 $fechajarreo $dispensador "NULL" "NULL" "NULL" "NULL" "NULL" "NULL" "NULL" $litros_real $costo_real $prod $ppv "NULL" $shift_object_id "NULL" "NULL" $recnum
##############################


#&main();

exit TRUE;
