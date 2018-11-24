#!/usr/bin/perl
##########################################################################
# Name: 
# Description: 
# Author: 
# Adapted by: 
# Date : 
# Version: 
##########################################################################
#use strict;
use warnings;
use POSIX qw(strftime);
use Orpak::LIB;
use Orpak::Constants;
use DBI;
use Orpak::DbLib;
use Socket;
use File::Copy;
use Orpak::Trate::Trate_functions;

my ($fecha_fin, $estacion, $dispensador, $supervisor, $despachador, $viaje, $camion, $fecha_finmy);
my ($chofer, $referencia, $litros_esp, $litros_real, $costo_esp, $costo_real, $iva, $ieps, $transaction_id);
my ($tipo_producto, $ppv, $status, $id_vehiculo, $litros_limit, $tipo_cmd, $shift_id, $poid, $observaciones);
my $nom_cmd;
my $APLICA_CONTING=0;
my ($dbmy, $dbin);
my ($status_old, $status_new);

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

    return $EXITO;
}

sub calcula_fecha_fin_manual {
    $fecha_finmy = $fecha_fin;
    $fecha_fin = substr($fecha_finmy, 0, 16);

    return $EXITO;
}

sub toma_datos_ci_pases {
    my ($log_arc) = @_;
    my ($sth, $sql, $row_hash);

    $sql = sprintf "SELECT litros_limit FROM ins_litros_lim WHERE pump_object_id=%s AND status=1", $poid;
    $sth = $dbmy->prepare($sql);
    $sth->execute() or &wr_log($log_arc, "NO PUDO EJECUTAR EL SIGUIENTE COMANDO en MYSQL:orpak: $sql", 1);
    $row_hash = $sth->fetchrow_hashref;
    $litros_limit=$row_hash->{litros_limit};
    $sth->finish;

    $sql = sprintf "UPDATE ins_litros_lim SET status=0 WHERE pump_object_id=%s AND status=1 AND litros_limit=%.4f", $poid, $litros_limit;
    $dbmy->do($sql) or &inserta_error_log($log_arc, $dbmy, $IDMYSQL, "Mysql:Orpak", $sql);

    $sql = sprintf "SELECT pase, viaje, chofer, litros FROM ci_pases WHERE camion=%d AND status=\'%s\'", $camion, $status_old;
    $sth = $dbmy->prepare($sql);
    $sth->execute() or &wr_log($log_arc, "NO PUDO EJECUTAR EL SIGUIENTE COMANDO en MYSQL:orpak: $sql", 1);
    $row_hash = $sth->fetchrow_hashref;
    $referencia=$row_hash->{pase};
    $viaje=$row_hash->{viaje};
    $chofer=$row_hash->{chofer};
    $litros_esp=$row_hash->{litros};
    $sth->finish;

    return $EXITO;
}

sub verifica_contingencia_pases {
  my ($log_arc) = @_;
  my ($sth, $sql, $si_contingencia);
  
  $sql = sprintf "select object_id from object_dependency_matrix where object_parent_id=(select object_id as object_id from objects_t where field4=\'%s\' AND status_code=2 AND objtyp_code=8)", $camion;
  $sth = $dbmy->prepare($sql);
  $sth->execute() or &wr_log($log_arc, "NO PUDO EJECUTAR EL SIGUIENTE COMANDO en MYSQL:orpak: $sql", 1);
  $id_vehiculo = $sth->fetchrow_array;
  $sth->finish;

  $sql = sprintf "select object_desc from object_language_matrix where object_id=%s and language_code=\'es\'", $id_vehiculo;
  $sth = $dbmy->prepare($sql);
  $sth->execute() or &wr_log($log_arc, "NO PUDO EJECUTAR EL SIGUIENTE COMANDO en MYSQL:orpak: $sql", 1);
  $camion = $sth->fetchrow_array;
  $sth->finish;
  

  $sql = sprintf "SELECT COUNT(*) FROM objects_t OT WHERE OT.objtyp_code=11 AND OT.status_code=2 AND OT.field6 IS NOT NULL AND OT.field12 IS NOT NULL AND OT.field13=0 AND OT.field3=2 AND OT.object_id=%s", $id_vehiculo;
  $sth = $dbmy->prepare($sql);
  $sth->execute() or &wr_log($log_arc, "NO PUDO EJECUTAR EL SIGUIENTE COMANDO en MYSQL:orpak: $sql", 1);
  $si_contingencia = $sth->fetchrow_array;
  $sth->finish;
  
  if ($si_contingencia > 0) {
    $APLICA_CONTING = $TRUE;
  }
  return $EXITO;
}

sub toma_despachador {
  my ($log_arc) = @_;
  my ($sth, $sql);
  
  $sql = sprintf "SELECT  b.object_desc AS tag_desc  FROM   history_log_t a  LEFT JOIN object_language_matrix b ON b.object_id = a.field2 AND b.language_code =\'es\'  LEFT JOIN object_language_matrix c ON c.object_id = a.field3 AND c.language_code =\'es\'  LEFT JOIN tbl t ON t.tbl = \'SFTGST\' AND t.language_code = \'es\' AND t.code = a.field4  WHERE a.histyp_code=\'3\' AND t.name=\'ENTRO\'  AND a.field1=%s", $shift_id;
  $sth = $dbmy->prepare($sql);
  $sth->execute() or &wr_log($log_arc, "NO PUDO EJECUTAR EL SIGUIENTE COMANDO en MYSQL:orpak: $sql", 0);
  $despachador = $sth->fetchrow_array;
  $sth->finish;
  
  return $EXITO;
}

sub dame_id_vehiculo {
    my ($log_arc) = @_;
    my ($sth, $sql);

    $sql = "SELECT ot.object_id FROM object_language_matrix olm LEFT JOIN objects_t ot ON olm.object_id=ot.object_id WHERE object_desc=\'%s\' AND language_code=\'es\' AND ot.status_code=2 AND ot.objtyp_code=11", $camion;
    $sth = $dbmy->prepare($sql);
    $sth->execute() or &wr_log($log_arc, "NO PUDO EJECUTAR EL SIGUIENTE COMANDO en MYSQL:orpak: $sql", 0);
    $id_vehiculo = $sth->fetchrow_array;
    $sth->finish;

    $id_vehiculo = (defined($id_vehiculo) && $id_vehiculo =~ /\d+$/ ) ? $id_vehiculo : 0;
    return $EXITO;
}

sub toma_ppv_manual {
    my ($log_arc) = @_;
    my $sth;

    my $sql = sprintf "select if(\'%s\'>timestamp,new_price,price) from object_product_matrix where product_id=%s", $fecha_fin, $tipo_producto;
    $sth = $dbmy->prepare($sql);
    $sth->execute() or &wr_log($log_arc, "NO PUDO EJECUTAR EL SIGUIENTE COMANDO en MYSQL:orpak: $sql", 0);
    $ppv = $sth->fetchrow_array;
    $sth->finish;

    return $EXITO;
}

sub toma_numero_iva_ieps {
    my ($log_arc) = @_;
    my $sth;
    my ($ieps_tmp, $iva_tmp);

    my $sql = sprintf "select product_ieps, product_iva from produc_ieps where product_id=%s and status=1", $tipo_producto;
    $sth = $dbmy->prepare($sql);
    $sth->execute() or &wr_log($log_arc, "NO PUDO EJECUTAR EL SIGUIENTE COMANDO en MYSQL:orpak: $sql", 1);
    ($ieps_tmp, $iva_tmp) = $sth->fetchrow_array;
    $iva = ((($ppv - $ieps_tmp) / (1 + $iva_tmp))) * $iva_tmp * $litros_real;
    $ieps = $ieps_tmp * $litros_real;
    $sth->finish;

    return $EXITO;
}

sub inserta_movimientos_siteomat {
	my ($log_arc) = @_;
	my $sql;
  
	$transaction_id = ($transaction_id == "NULL") ? 0 : $transaction_id;

	$sql = sprintf
	"INSERT ci_movimientos (fecha_hora, 
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
	VALUES (\'%s\',%.4d,%d,%d,%d,%d,%d,%d,NULL,3,NULL,%d,2,%.4f,%.4f,%.4f,%.4f,%.4f,%.4f,%d,'N',%s)",
				$fecha_finmy, 
				$estacion, 
				$dispensador, 
				$supervisor, 
				$despachador, 
				$viaje, 
				$camion, 
				$chofer, 
				$referencia, 
				$litros_esp, 
				$litros_real, 
				$costo_esp, 
				$costo_real, 
				$iva, 
				$ieps, 
				$status, 
				$transaction_id;
	$dbmy->do($sql) or &inserta_error_log($log_arc, $dbmy, $IDMYSQL, "Mysql:Orpak", $sql);
	return $EXITO;
}

sub inserta_movimientos_trate {
	my ($log_arc) = @_;
	my ($sql, $sth, $camion_trate);

	$transaction_id = ($transaction_id == "NULL") ? 0 : $transaction_id;
  
	$sql = sprintf "SELECT camion FROM ci_pases WHERE pase=%d", $referencia;
	$sth = $dbin->prepare($sql);
	$sth->execute() or &wr_log($log_arc, "NO PUDO EJECUTAR EL SIGUIENTE COMANDO en INFORMIX:Trate: $sql", 0);
	$camion_trate = $sth->fetchrow_array;
	$sth->finish;

	$sql = sprintf
	"INSERT INTO ci_movimientos    (fecha_hora, 
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
	VALUES (\'%s\',%.4d,%d,%d,%d,%d,%d,%d,NULL,3,NULL,%d,2,%.4f,%.4f,%.4f,%.4f,%.4f,%.4f,%d,'N',%s)",
					$fecha_fin, 
					$estacion, 
					$dispensador, 
					$supervisor, 
					$despachador, 
					$viaje, 
					$camion_trate, 
					$chofer, 
					$referencia, 
					$litros_esp, 
					$litros_real, 
					$costo_esp, 
					$costo_real, 
					$iva, 
					$ieps, 
					$status,
					$transaction_id;
	$dbin->do($sql) or &inserta_error_log($log_arc, $dbmy, $IDINFMX, "Informix:trate", $sql);
	system("echo jotingas >> /tmp/ramses");
	return $EXITO;
}

sub actualiza_pases_siteomat {
  my ($log_arc) = @_;
  my $sql;
  
  if ($status_old eq "T") {
    $sql = sprintf "UPDATE ci_pases SET status='%s', supervisor=%d, litros_real=CASE WHEN litros_real IS NULL THEN %.4f ELSE litros_real + %.4f END WHERE pase=%d", $status_new, $supervisor, $litros_real, $litros_real, $referencia;
  }
  elsif ($status_old eq "A") {
    $sql = sprintf "UPDATE ci_pases SET status='%s', supervisor=%d, observaciones='%s', litros_real=CASE WHEN litros_real IS NULL THEN %.4f ELSE litros_real + %.4f END WHERE pase=%d", $status_new, $supervisor, $observaciones, $litros_real, $litros_real, $referencia;
  }
  else {
    $sql = sprintf "UPDATE ci_pases SET status='%s', litros_real=CASE WHEN litros_real IS NULL THEN %.4f ELSE litros_real + %.4f END WHERE pase=%d", $status_new, $litros_real, $litros_real, $referencia;
  }
#  $sql = sprintf "UPDATE ci_pases SET status='%s', litros_real=CASE WHEN litros_real IS NULL THEN %.4f ELSE litros_real + %.4f END WHERE camion=%d AND status='%s' AND litros=%.4f AND pase=%d", $status_new, $litros_real, $litros_real, $camion, $status_old, $litros_esp, $referencia;
  $dbmy->do($sql) or &inserta_error_log($log_arc, $dbmy, $IDMYSQL, "Mysql:Orpak", $sql);
  return $EXITO;
}

sub actualiza_pases_trate {
  my ($log_arc) = @_;
  my $sql;
  
  if ($status_old eq "T") {
    $sql = sprintf "UPDATE ci_pases SET status='%s', supervisor=%d, litros_real=CASE WHEN litros_real IS NULL THEN %.4f ELSE litros_real + %.4f END WHERE pase=%d", $status_new, $supervisor, $litros_real, $litros_real, $referencia;
  }
  elsif ($status_old eq "A") {
    $sql = sprintf "UPDATE ci_pases SET status='%s', supervisor=%d, observaciones='%s', litros_real=CASE WHEN litros_real IS NULL THEN %.4f ELSE litros_real + %.4f END WHERE pase=%d", $status_new, $supervisor, $observaciones, $litros_real, $litros_real, $referencia;
  }
  else {
    $sql = sprintf "UPDATE ci_pases SET status='%s', litros_real=CASE WHEN litros_real IS NULL THEN %.4f ELSE litros_real + %.4f END WHERE pase=%d", $status_new, $litros_real, $litros_real, $referencia;
  }
#  $sql = sprintf "UPDATE ci_pases SET status='%s', litros_real=CASE WHEN litros_real IS NULL THEN %.4f ELSE litros_real + %.4f END WHERE camion=%d AND status='%s' AND litros=%.4f AND pase=%d", $status_new, $litros_real, $litros_real, $camion, $status_old, $litros_esp, $referencia;
  $dbin->do($sql) or &inserta_error_log($log_arc, $dbmy, $IDINFMX, "Informix:trate", $sql);
  return $EXITO;
}

sub actualiza_saldo_vehiculo {
  my ($log_arc) = @_;
  my $sql;
  
  $sql = sprintf "UPDATE objects_t SET field17=0 WHERE objtyp_code=11 AND object_id=%s", $id_vehiculo;
  $dbmy->do($sql) or &inserta_error_log($log_arc, $dbmy, $IDMYSQL, "Mysql:Orpak", $sql);

#  $sql = sprintf "UPDATE objects_t SET field17=field17+(SELECT SUM(total_price) FROM transactions_t WHERE mean_object_id=%s) WHERE object_id=%s", $id_vehiculo, $id_vehiculo;
#  $dbmy->do($sql) or &inserta_error_log($log_arc, $dbmy, $IDMYSQL, "Mysql:Orpak", $sql);

  return $EXITO;
}

sub inserta_transaccion_transactions_t {
        my $site_code = Orpak::Generic::StationNumber();
        my $site_object_id = Orpak::Generic::GetParam('object_id');
	my $transactionid;
	my $sth;

	my $sql = "SELECT val FROM indexes_t where indexx_code='TRNSCT'";
	#$sth = $dbmy->prepare($sql);
	#$sth->execute() or &wr_log($log_arc, "NO PUDO EJECUTAR EL SIGUIENTE COMANDO en MYSQL:orpak: $sql", 1);
	#$transactionid = $sth->fetchrow_array;

	system "echo \"Sitio $site_code $site_object_id transaction_id <= $sql \" >> /tmp/windows";
}

sub main {
  
  $dbmy=Orpak::DbLib::Connect() or &wr_log(*ARC_LOG, "NO SE PUDO CONECTAR AL SERVIDOR MYSQL", 1);
  &begin_commit_rollback_trans_trate(*ARC_LOG, $dbmy, $BEGINTRAN);
  $dbin = Connect_Informix_trate(*ARC_LOG, $dbmy);
  &begin_commit_rollback_trans_trate(*ARC_LOG, $dbin, $BEGINTRAN);
  
	if ( $tipo_cmd==2 ) { # Es manual la captura
		$status_old="A";
		$status_new="C";
		$status=2;
    
		&actualiza_pases_siteomat(*ARC_LOG);
		&actualiza_pases_trate(*ARC_LOG);
		&toma_ppv_manual(*ARC_LOG);
		$litros_esp = (defined($litros_esp)) ? $litros_esp : 0;
		$costo_esp = ($litros_esp == 9999) ? 0 : $litros_esp * $ppv;
		$costo_real = $litros_real * $ppv;
		&dame_id_vehiculo(*ARC_LOG);
		$despachador = (defined($despachador) && $despachador =~ /\d+$/ ) ? $despachador : 0;
		&calcula_fecha_fin_manual();
		&inserta_transaccion_transactions_t();
	}
	else {
		verifica_contingencia_pases(*ARC_LOG);
		if ( $APLICA_CONTING == $TRUE ) {
			$status_old="T";
			$status_new="M";
			$status=1;
		}
		else {
			$status_old="P";
			$status_new="D";
			$status=0;
		}
    
		&toma_datos_ci_pases(*ARC_LOG);
    
		&calcula_fecha_fin(*ARC_LOG);
		$supervisor=&toma_numero_supervisor(*ARC_LOG, $dbmy);
		$supervisor = (defined($supervisor) && $supervisor =~ /\d+$/ ) ? $supervisor : 0;
    
		&toma_despachador(*ARC_LOG);
    		$despachador = (defined($despachador) && $despachador =~ /\d+$/ ) ? $despachador : 0;
    		$litros_esp = (defined($litros_esp)) ? $litros_esp : 0;
    		$costo_esp = ($litros_esp == 9999) ? 0 : $litros_esp * $ppv;
    		&actualiza_pases_siteomat(*ARC_LOG);
    		&actualiza_pases_trate(*ARC_LOG);
  	}
  
  $estacion=&toma_numero_estacion(*ARC_LOG, $dbmy);
  &toma_numero_iva_ieps(*ARC_LOG);
  &inserta_movimientos_siteomat(*ARC_LOG);
  &inserta_movimientos_trate(*ARC_LOG);
  &actualiza_saldo_vehiculo(*ARC_LOG);

  if ($ERRDB == $FALSE) {
    &begin_commit_rollback_trans_trate(*ARC_LOG, $dbmy, $COMITTRAN);
    &begin_commit_rollback_trans_trate(*ARC_LOG, $dbin, $COMITTRAN);
  }
  else {
    &begin_commit_rollback_trans_trate(*ARC_LOG, $dbmy, $ROLLBTRAN);
    &begin_commit_rollback_trans_trate(*ARC_LOG, $dbin, $ROLLBTRAN);
  }

  $dbin->disconnect;
  $dbmy->disconnect();
}

open(ARC_LOG, ">> $ARC_LOG") or die "NO PUDE CREAR EL ARCHIVO $ARC_LOG: $!";

select ARC_LOG;
$| = 1;  # Flush la salida 
select STDOUT;

# CASO3: perl 2 $fecha_fin $dispensador $supervisor $despachador $viaje $camion $chofer 
#                         $referencia $litros_esp $litros_real "NULL" $tipo_producto "NULL" "NULL" "NULL" "NULL" $observaciones "NULL"
# CASO1 y 2: perl 0 "NULL" $obj_ext_code "NULL" "NULL" "NULL" $vehicle_plate "NULL" "NULL" "NULL" 
#                         $quantity $price $prod $ppv $vehicle_id $shift_object_id $poid "NULL" $recnum

($tipo_cmd, $fecha_fin, $dispensador, $supervisor, $despachador, $viaje, $camion, $chofer, $referencia, $litros_esp, 
 $litros_real, $costo_real, $tipo_producto, $ppv, $id_vehiculo, $shift_id, $poid, $observaciones, $transaction_id) = @ARGV;

&wr_log(*ARC_LOG, "==== INICIALIZANDO ==== |Programa $0 en EJECUCION", 0);

$nom_cmd = ($tipo_cmd == 2) ? "MANUAL" : "AUTOMATICA";

$mensaje_log = "DATOS PROCESAR: \nACTIVIDAD A REALIZAR: $nom_cmd\nFECHA FIN: $fecha_fin\nDISPENSADOR: $dispensador\nSUPERVISOR: $supervisor\nDESPACHADOR: $despachador\nVIAJE: $viaje\nCAMION: $camion\nCHOFER: $chofer\nREFERENCIA: $referencia\nLITROS ESPERADOS: $litros_esp\nLITROS REALES: $litros_real\nCOSTO REAL: $costo_real\nTIPO PRODUCTO: $tipo_producto\nPPV: $ppv\nID_VEHICULO: $id_vehiculo\nID_TURNO: $shift_id\nPUMPID: $poid\nOBSERVACIONES: $observaciones\nID TRANSACCION: $transaction_id";
&wr_log(*ARC_LOG, $mensaje_log, 0);

if ($#ARGV < 17 ) {
  &wr_log(*ARC_LOG, "Numero de Argumentos Invalido. Faltan Datos", 0);
  exit 1;
}

&main();
close(ARC_LOG);

exit $EXITO;
