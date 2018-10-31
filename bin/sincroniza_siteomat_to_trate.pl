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
#use warnings;
use POSIX qw(strftime);
use Orpak::LIB;
use Orpak::Constants;
use DBI;
use Orpak::DbLib;
use Socket;
use File::Copy;
use Orpak::Trate::Trate_functions;

my ($date_from,$date_until);
my ($dbmy, $dbin);

# FUNCION PARA REVISAR Y SINCRONIZAR LAS TABLAS ci_pases@INFORMIX::master CON ci_pases@MYSQL::orpak DADAS DOS FECHAS COMO INTERVALO
# DEVUELVE VALOR ENTERO DE NUMERO DE REGISTROS MODIFICADOS
sub dame_pases_trate {
	my ($log_arc,$fecha_inicio,$fecha_fin) = @_;
	my ($query, $sth);
	my $counter = 0;
	my ($fecha_solicitud, $pase, $viaje, $camion, $chofer, $litros, $contingencia, $status, $litros_real, $litros_esp, $viaje_sust, $supervisor, $observaciones, $ultima_modificacion);
	$query = sprintf "SELECT * FROM ci_pases WHERE fecha_solicitud >= '%s' AND fecha_solicitud <= '%s'",$fecha_inicio,$fecha_fin;
	$sth = $dbin->prepare($query);
    	$sth->execute() or &wr_log($log_arc, "NO PUDO EJECUTAR EL SIGUIENTE COMANDO en INFORMIX:Trate: $query", 0);
	while (($fecha_solicitud, $pase, $viaje, $camion, $chofer, $litros, $contingencia, $status, $litros_real, $litros_esp, $viaje_sust, $supervisor, $observaciones, $ultima_modificacion) = $sth->fetchrow_array()){
		if (&existe_pase_en_siteomat(*ARC_LOG,$pase) == 0) {
			print "\nEL PASE " . $pase . " NO EXISTE EN MYSQL:orpak SE DEBERA AGREGAR\n";
				if ($litros == 0) { $litros=9999; }
			if (&inserta_pase_orpak(*ARC_LOG,$fecha_solicitud, $pase, $viaje, $camion, $chofer, $litros, $contingencia, $status, $litros_real, $litros_esp, $viaje_sust, $supervisor, $observaciones, $ultima_modificacion) == 0) {
				if (&actualiza_saldo_camion(*ARC_LOG,$camion,$litros) == 0) {
					$counter++;
					print "\nEL PASE " . $pase . " FUE INSERTADO CON EXITO Y EL SALDO DEL VEHICULO " . $camion . " FUE MODIFICADO A " . $litros . " LITROS \n";
				}
				else {
					print "\nEXISTIO UN ERROR AL ACTUALIZAR EL SALDO DEL VEHICULO AUNQUE EL PASE FUE INSERTADO EXITOSAMENTE, VALIDAR ANTES DE REALIZAR LA CARGA\n";
				}
			}
		}
		else {
			if(&igual_pase_trate_a_siteomat(*ARC_LOG,$pase,$viaje,$camion,$chofer,$status,$litros_real,$supervisor,$observaciones) == 0){
				print "\nEL PASE " . $pase . " DE INFORMIX:master EXISTE en MYSQL:orpak PERO NO ES IDENTICO EN LOS CAMPOS IMPORTENTES <:-( => SE ACTUALIZARA CONFORME A MYSQL:orpak\n";
				#&actualiza_pase_from_orpak_to_trate(*ARC_LOG,$pase);
				$counter++;
			}
			else {
				print $pase . " >:-D ";
			}
		}
	}
	return $counter;
}


# FUNCION PARA REVISAR SI UN NUMERO DE PASE EXISTE EN ci_pases@MYSQL::orpak
# DEVUELVE EL NUMERO DE REGISTROS EN MYSQL::orpak CON ESE PASE SI ES CERO SIGNIFICA QUE EL PASE NO EXISTE EN ci_pases@MYSQL::orpak
sub existe_pase_en_siteomat {
        my ($sql, $sth);
	my $siono;
	my ($log_arc,$trate_pase) = @_;
	$sql = sprintf "SELECT count(*) FROM ci_pases WHERE pase=%d",$trate_pase;
        $sth = $dbmy->prepare($sql);
	$sth->execute() or &wr_log($log_arc, "LA FUNCION existe_pase_en_siteomat NO PUDO EJECUTAR EL SIGUIENTE COMANDO MYSQL:orpak: $sql",0);
	$siono = $sth->fetchrow();
	return $siono;
}


# FUNCION PARA REVISAR SI UN NUMERO DE PASE CON PARAMETROS pase,viaje,camion,chofer,status,litros_real,supervisor EXISTE EXACTAMENTE IGUAL EN ci_pases@MYSQL::orpak
# DEVUELVE EL NUMERO DE REGISTROS EN MYSQL::orpak CON ESE PASE SI ES CERO SIGNIFICA QUE EL PASE NO EXISTE EN ci_pases@MYSQL::orpak
sub igual_pase_trate_a_siteomat {
        my ($sql, $sth, $siono);
        my ($log_arc,$trate_pase,$trate_viaje,$trate_camion,$trate_chofer,$trate_status,$trate_litros_real,$trate_supervisor,$trate_observaciones) = @_;
	$trate_supervisor = $_[7] or $trate_supervisor = 0;
        
        $sql = sprintf "SELECT count(*) FROM ci_pases WHERE pase=%d AND viaje=%d AND camion=%d AND chofer=%d AND status='%s' AND litros_real=%f AND (supervisor=%d OR supervisor IS NULL)",$trate_pase,$trate_viaje,$trate_camion,$trate_chofer,$trate_status,$trate_litros_real,$trate_supervisor;
	$sth = $dbmy->prepare($sql);
        $sth->execute() or &wr_log($log_arc, "LA FUNCION igual_pase_trate_a_siteomat NO PUDO EJECUTAR EL SIGUIENTE COMANDO MYSQL:orpak: $sql",0);
        $siono = $sth->fetchrow;
	
	return $siono;
}

# FUNCION PARA ACTUALIZAR LOS DATOS DE PASE EN ci_pases@INFORMIX::TRATE CON LA INFORMACION DEL MISMO PASE EN MYSQL::orpak
sub actualiza_pase_from_orpak_to_trate {
        my ($log_arc) = $_[0];
        my $so_pase = $_[1];
        my ($sql,$sth,$ref);

        $sql = sprintf "SELECT * FROM ci_pases WHERE pase=%d LIMIT 1",$so_pase;
        $sth = $dbmy->prepare($sql);
        $sth->execute() or &wr_log($log_arc, "LA FUNCION actualiza_pase_from_orpak_to_trate NO PUDO EJECUTAR EL SIGUIENTE COMANDO EN MYSQL:orpak: $sql",1);
        $ref = $sth->fetchrow_hashref();

        $sql = sprintf "UPDATE ci_pases SET litros_real='%f',status='%s',supervisor='%s',observaciones='%s',ultima_modificacion='%s' WHERE pase=%d", $$ref{'litros_real'},$$ref{'status'},$$ref
{'supervisor'},$$ref{'observaciones'},$$ref{'ultima_modificacion'},$so_pase;
        $dbin->do($sql) or &wr_log($log_arc, "LA FUNCION actualiza_pase_from_orpak_to_trate NO PUDO EJECUTAR EL SIGUIENTE COMANDO EN INFORMIX:master: $sql",1);
        if ($EXITO == 0){
                &wr_log($log_arc, "LA FUNCION actualiza_pase_from_orpak_to_trate EJECUTO EL SIGUIENTE COMANDO EN INFORMIX:master: $sql",0);
        }
}


# FUNCION PARA INSERTAR UN PASE EN MYSQL::orpak
sub inserta_pase_orpak {
        my $sql;
        my ($log_arc,$t_fecha_solicitud,$t_pase,$t_viaje,$t_camion,$t_chofer,$t_litros,$t_contingencia,$t_status,$t_litros_real,$t_litros_esp,$t_viaje_sust,$t_supervisor,$t_observaciones,$t_ultima_modificacion) = @_;

        $sql = sprintf "INSERT INTO ci_pases VALUES ('%s',%d,%d,%d,%d,%f,%f,'%s',%f,%f,%d,%d,'%s','%s')",$t_fecha_solicitud,$t_pase,$t_viaje,$t_camion,$t_chofer,$t_litros,$t_contingencia,$t_status,$t_litros_real,$t_litros_esp,$t_viaje_sust,$t_supervisor,$t_observaciones,$t_ultima_modificacion;
        $dbmy->do($sql) or &inserta_error_log($log_arc, $dbmy, $IDMYSQL, "Mysql:Orpak", $sql);
        return $EXITO;
}

# FUNCION PARA ACTUALIZAR EL SALDO DEL VEHICULO EN MYSQL::orpak CONFORME A LOS LITROS ENVIADOS COMO PARAMETRO
# DEVUELVE EXITO
sub actualiza_saldo_camion {
	my ($sql,$sth,$vehicle_oid);
	my ($log_arc,$saldo,$vehicle) = @_;
	#PRIMERO SE DETECTA EL OBJECT_ID DEL CAMION
	$sql = sprintf "SELECT ot.object_id FROM object_language_matrix olm INNER JOIN objects_t ot ON olm.object_id = ot.object_id WHERE olm.object_desc='%s' AND olm.language_code='es' AND ot.objtyp_code=11 AND ot.status_code=2 LIMIT 1",$vehicle;
	$sth = $dbmy->prepare($sql);
	$sth->execute() or &wr_log($log_arc, "LA FUNCION actualiza_saldo_camion NO PUDO EJECUTAR EL SIGUIENTE COMANDO EN MYSQL::orpak: $sql",1);
	$vehicle_oid = $sth->fetchrow_hashref();
	if ($EXITO == 0){
		#SEGUNDO SE PONE EL SALDO EN CEROS PARA EL CAMION CONFORME AL OBJECT_ID
		$sql = sprintf "UPDATE objects_t SET field17 = ROUND(field17 + (SELECT IF(SUM(total_price) IS NULL,0,SUM(total_price)) FROM transactions_t WHERE mean_object_id='object_id@1a'),2) WHERE object_id='%d' AND status_code=2",$vehicle_oid;
		$sth = $dbmy->prepare($sql);
		$sth->execute() or &wr_log($log_arc, "LA FUNCION actualiza_saldo_camion NO PUDO EJECUTAR EL SIGUIENTE COMANDO EN MYSQL::orpak: $sql",1);
		print "SE VA A ACTUALIZAR EL SALDO DEL CAMION " . $vehicle . "-" . $vehicle_oid . " A " . $saldo . " LITROS\n";

		if ($EXITO == 0) {
			#TERCERO SE ASIGNA EL SALDO EN LITROS CORRESPONDIENTE
			$sql = sprintf "UPDATE objects_t SET field17 = ROUND(field17 + '%d',2) WHERE status_code=2 AND object_id = '%d' AND objtyp_code=11",$saldo,$vehicle_oid;
			$sth->$dbmy->prepare($sql);
			$sth->execute() or &wr_log($log_arc, "LA FUNCION actualiza_saldo_camion NO PUDO EJECUTAR EL SIGUIENTE COMANDO EN MYSQL::orpak: $sql",1);
			print "SE ACTUALIZO EL SALDO DEL CAMION " . $vehicle . "-" . $vehicle_oid . " A " . $saldo . " LITROS\n";
		}
	}
	return $EXITO;
}

# FUNCION PARA REVISAR Y SINCRONIZAR LAS TABLAS ci_movimientos@INFORMIX::master CON ci_movimientos@MYSQL::orpak DADAS DOS FECHAS COMO INTERVALO
# DEVUELVE VALOR ENTERO DE NUMERO DE REGISTROS MODIFICADOS
sub dame_movimientos_siteomat {
        my ($log_arc,$fecha_inicio,$fecha_fin) = @_;
        my ($query, $sth);
        my $counter = 0;
        my ($fecha_hora,$estacion,$dispensador,$supervisor,$despachador,$viaje,$camion,$chofer,$sello,$tipo_referencia,$serie,$referencia,$movimiento,$litros_esp,$litros_real,$costo_esp,$costo_real,$iva,$ieps,$status,$procesada,$transaction_id,$fechahora);

        $query = sprintf "SELECT *,DATE_FORMAT(fecha_hora,'%%Y-%%m-%%d %%H:%%i') as fechahora FROM ci_movimientos WHERE fecha_hora >= '%s' AND fecha_hora <= '%s'",$fecha_inicio,$fecha_fin;
	$sth = $dbmy->prepare($query);
        $sth->execute() or &wr_log($log_arc, "NO PUDO EJECUTAR EL SIGUIENTE COMANDO en INFORMIX:Trate: $query", 0);
        while (($fecha_hora,$estacion,$dispensador,$supervisor,$despachador,$viaje,$camion,$chofer,$sello,$tipo_referencia,$serie,$referencia,$movimiento,$litros_esp,$litros_real,$costo_esp,$costo_real,$iva,$ieps,$status,$procesada,$transaction_id,$fechahora) = $sth->fetchrow_array()){
		if (&existe_movimiento_en_trate(*ARC_LOG,$referencia,$fechahora,$litros_real) == 0) {
                        print "\nEL MOVIMIENTO DEL PASE " . $referencia . " HECHO A LAS " . $fechahora . " NO EXISTE EN INFORMIX::master SE DEBERA AGREGAR\n";
                        #if (&inserta_movimiento_trate(*ARC_LOG,$fechahora,$estacion,$dispensador,$supervisor,$despachador,$viaje,$camion,$chofer,$sello,$tipo_referencia,$referencia,$movimiento,$litros_esp,$litros_real,$costo_esp,$costo_real,$iva,$ieps,$status,$procesada) == 0) {
                        #        $counter++;
                        #}
                }
                else {
			print $referencia . "@" . $fechahora . " >:-D ";
                }
        }
        return $counter;
}


# FUNCION PARA REVISAR SI UN MOVIMIENTO EXISTE EN ci_pases@INFORMIX::trate
# DEVUELVE EL NUMERO DE REGISTROS EN INFORMIX::trate CON ESE MOVIMIENTO SI ES CERO SIGNIFICA QUE EL PASE NO EXISTE EN ci_pases@INFORMIX::trate
sub existe_movimiento_en_trate {
        my ($sql, $sth);
        my $siono;
        my ($log_arc,$t_referencia,$t_fecha_hora,$t_litros_real) = @_;
        $sql = sprintf "SELECT count(*) FROM ci_movimientos WHERE referencia=%d AND fecha_hora = '%s' AND litros_real=%f",$t_referencia,$t_fecha_hora,$t_litros_real;
        $sth = $dbin->prepare($sql);
        $sth->execute() or &wr_log($log_arc, "LA FUNCION existe_movimiento_en_trate NO PUDO EJECUTAR EL SIGUIENTE COMANDO MYSQL:orpak: $sql",0);
	$siono = $sth->fetchrow();
        return $siono;
}

sub dame_transacciones_no_sincronizadas {
	my ($transacciones, $sql, $sth);
	my ($log_arc) = @_;

	$sql = sprintf "SELECT count(*) FROM transactions_t WHERE transaction_id NOT IN (SELECT transaction_id FROM ci_movimientos) AND transaction_timestamp >= '%s'", $date_from;
	$sth = $dbmy->prepare($sql);
	$sth->execute() or &wr_log($log_arc, "NO PUDO EJECUTAR EL SIGUIENTE COMANDO EN MYSQL:orpak: $sql",1);
	$transacciones = $sth->fetchrow_array;
	$sth->finish;

	#return $sql.$transacciones;
	return $transacciones;
}

sub inserta_movimiento_trate {
	my ($log_arc) = $_[0];
	my $sql;
	my ($so_fecha_hora, $so_estacion, $so_dispensador, $so_supervisor, $so_despachador, $so_viaje, $so_camion, $so_chofer, $so_sello, $so_tipo_referencia, $so_serie, $so_referencia, $so_movimiento, $so_litros_esp, $so_litros_real, $so_costo_esp, $so_costo_real, $so_iva, $so_ieps, $so_status, $so_procesada);
	$so_fecha_hora = $_[1]; 
	$so_estacion = $_[2]; 
	$so_dispensador = $_[3]; 
	$so_supervisor = $_[4]; 
	$so_despachador = $_[5]; 
	$so_viaje = $_[6]; 
	$so_camion = $_[7]; 
	$so_chofer = $_[8]; 
	$so_sello = $_[9] or $so_sello = "";
	$so_tipo_referencia = $_[10]; 
	$so_referencia = $_[11];
	$so_movimiento = $_[12]; 
	$so_litros_esp = $_[13]; 
	$so_litros_real = $_[14]; 
	$so_costo_esp = $_[15];
	$so_costo_real = $_[16];
	$so_iva = $_[17];
	$so_ieps = $_[18];
	$so_status = $_[19];
	$so_procesada = $_[20];

	$sql = sprintf "INSERT INTO ci_movimientos (fecha_hora,estacion,dispensador,supervisor,despachador,viaje,camion,chofer,tipo_referencia,referencia,movimiento,litros_esp,litros_real,costo_esp,costo_real,iva,ieps,status,procesada) VALUES ('%s',%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%f,%f,%f,%f,%f,%f,%d,'%s')",$so_fecha_hora, $so_estacion, $so_dispensador, $so_supervisor, $so_despachador, $so_viaje, $so_camion, $so_chofer, $so_tipo_referencia, $so_referencia, $so_movimiento, $so_litros_esp, $so_litros_real, $so_costo_esp, $so_costo_real, $so_iva, $so_ieps, $so_status, $so_procesada;
	$dbin->do($sql) or &inserta_error_log($log_arc, $dbmy, $IDINFMX, "Informix:trate", $sql);
        if ($EXITO == 0){
                &wr_log($log_arc, "LA FUNCION inserta_movimiento_trate EJECUTO EL SIGUIENTE COMANDO EN INFORMIX:master: $sql",0);
        }
	return $EXITO;
}

sub main {
    $dbmy = Orpak::DbLib::Connect() or &wr_log(*ARC_LOG, "NO SE PUDO CONECTAR AL SERVIDOR MYSQL", 1);
    $dbin = Connect_Informix_trate(*ARC_LOG, $dbmy);
    &begin_commit_rollback_trans_trate(*ARC_LOG, $dbmy, $BEGINTRAN);
    &begin_commit_rollback_trans_trate(*ARC_LOG, $dbin, $BEGINTRAN);
    
	printf ("\nSE SINCRONIZARON " . &dame_pases_trate(*ARC_LOG,$date_from,$date_until) . " REGISTROS DE PASE PARA EL PERIODO INDICADO.\n");
	printf ("\nSE SINCRONIZARON " . &dame_movimientos_siteomat(*ARC_LOG,$date_from,$date_until) . " REGISTROS DE MOVIMIENTOS PARA EL PERIODO INDICADO.\n");
	#printf(&actualiza_movimiento_trate(*ARC_LOG,10));
	#printf(&actualiza_pase_trate(*ARC_LOG,8,'D','239.1100','85121','','2011-10-27 11:36:25'). "\n");
	#printf(&inserta_movimiento_trate(*ARC_LOG,'2011-10-27 10:32','1423','2','85121','87300','281176','1350','65628','3','10','2','9999','217.234','0.000','2154.960','288.2913','64.9095','0','N'));
	#if(&dame_transacciones_no_sincronizadas(*ARC_LOG) eq 0) {
	#	printf("NADA POR HACER");
	#}
	#else {
	#	printf("SE REQUIEREN SINCRONIZAR " . &dame_transacciones_no_sincronizadas(*ARC_LOG)." TRANSACCIONES ___ \n");
	#}

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

# CASO: perl $camion $litros $status_new $status_old
  
($date_from,$date_until) = @ARGV;

&wr_log(*ARC_LOG, "==== INICIALIZANDO ==== |Programa $0 en EJECUCION", 0);

$mensaje_log = "DATOS A PROCESAR: \nLAST SYNC: $date_from - $date_until\n";
&wr_log(*ARC_LOG, $mensaje_log, 0);

if ($#ARGV != 1 ) {
	print "Numero de Argumentos Invalido. Faltan parametros de fecha... uso sincronizaxxx fecha_inicio:'yyyy-mm-dd hh:mm' fecha_fin:'yyyy-mm-dd hh:mm'\n";
	&wr_log(*ARC_LOG, "Numero de Argumentos Invalido. Faltan Datos", 0);
	exit 1;
}

&main();
close(ARC_LOG);

exit $EXITO;
