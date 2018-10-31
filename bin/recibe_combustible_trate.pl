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
use warnings;
use POSIX qw(strftime);
use Orpak::LIB;
use Orpak::Constants;
use DBI;
use Orpak::DbLib;
use Socket;
use File::Copy;
use Orpak::Trate::Trate_functions;

my ($fecha_hora, $fecha_fin, $estacion, $supervisor, $litros_esp, $litros_real);
my ($costo_esp, $costo_real, $sello, $referencia, $tipo_producto, $final_vol);
my ($ppv, $iva, $ieps, $serie, $new_price, $fecha_horamy, $fecha_finmy);
my $tipo_comando;  # 1 Para actualizacion, 2 para insercion.    
my $OP_UPDATE=1;
my $OP_INSERT=2;
my $OP_INSERT_MANUAL=3;
my ($dbmy, $dbin);
my $nom_cmd;

sub toma_costo_real {
    my ($log_arc) = @_;
    my $sth;

    $new_price=0;
    my $sql = sprintf "select if(now()>timestamp,new_price,price) from object_product_matrix where product_id=%s", $tipo_producto;
    $sth = $dbmy->prepare($sql);
    $sth->execute() or &wr_log($log_arc, "NO PUDO EJECUTAR EL SIGUIENTE COMANDO en MYSQL:orpak: $sql", 1);
    $new_price = $sth->fetchrow_array;
#    printf "$costo_real = ($final_vol - $litros_real) * $new_price\n";
    $costo_real = ($final_vol - $litros_real) * $new_price;
#    printf "$costo_real\n";
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
    $iva = ((($ppv - $ieps_tmp) / (1 + $iva_tmp))) * $iva_tmp * $litros_esp;
    $ieps = $ieps_tmp * $litros_esp;
    $sth->finish;

    return $EXITO;
}

sub inserta_movimientos_siteomat {
	my ($log_arc) = @_;
	my $sql;
	my $litros_real_tmp;
	my $costo_real_tmp;
  
	$litros_real_tmp = $final_vol - $litros_real;
	$costo_real_tmp = $litros_real * $new_price;
  
	if ($tipo_comando == $OP_INSERT || $tipo_comando == $OP_INSERT_MANUAL) {
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
				 iva, ieps,
				 status,
				 procesada)
			 VALUES (\'%s\',%.4d,NULL,%d,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,0,NULL,%.4f,NULL,%.4f,NULL,NULL,0,'N')",
				 $fecha_horamy,
				 $estacion,
				 $supervisor,
				 $litros_real,
				 $costo_real_tmp;
  	}
  
   #    else {
   #	$sql = sprintf 
   #	    "UPDATE ci_movimientos SET fecha_hora=\'%s\', estacion=%.4d, supervisor=%d, litros_real=%.4f, costo_real=%.4f where referencia=?",
   #	    $fecha_hora, $estacion, $supervisor, $litros_real, $costo_real;
   #    }
  
	$dbmy->do($sql) or &inserta_error_log($log_arc, $dbmy, $IDMYSQL, "Mysql:Orpak", $sql);
  
	if ($tipo_comando == $OP_INSERT) {
		if ($serie eq "NULL") {
      			$sql = sprintf 
			"INSERT ci_movimientos 
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
					 procesada)
				 VALUES (\'%s\',%.4d,NULL,%d,NULL,NULL,NULL,NULL,\'%s\',2,%s,%d,1,%.4f,%.4f,%.4f,%.4f,%.4f,%.4f,0,'N')",
					 $fecha_finmy,
					 $estacion,
					 $supervisor,
					 $sello,
					 $serie,
					 $referencia,
					 $litros_esp,
					 $litros_real_tmp,
					 $costo_esp,
					 $costo_real,
					 $iva,
					 $ieps;
    		}
    		else {
      			$sql = sprintf 
			"INSERT ci_movimientos 
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
					 procesada)
				 VALUES (\'%s\',%.4d,NULL,%d,NULL,NULL,NULL,NULL,\'%s\',2,\'%s\',%d,1,%.4f,%.4f,%.4f,%.4f,%.4f,%.4f,0,'N')",
					 $fecha_finmy,
					 $estacion,
					 $supervisor,
					 $sello,
					 $serie,
					 $referencia,
					 $litros_esp,
					 $litros_real_tmp,
					 $costo_esp,
					 $costo_real,
					 $iva,
					 $ieps;
		}
  	}
	elsif ($tipo_comando == $OP_INSERT_MANUAL){
		$sql = sprintf
		"INSERT ci_movimientos 
					(fecha_hora,
					 estacion,
					 supervisor,
					 sello,
					 serie,
					 tipo_referencia,
					 referencia,
					 movimiento,
					 litros_esp,
					 litros_real,
					 costo_esp,
					 costo_real,
					 iva,
					 ieps,
					 status,
					 procesada)
				 VALUES (\'%s\',%.4d,%d,\'%s\',NULL,2,%d,1,%.4f,%.4f,%.4f,%.4f,%.4f,%.4f,1,'N')",
					 $fecha_finmy,
					 $estacion,
					 $supervisor,
					 $sello,
					 $referencia,
					 $litros_esp,
					 $litros_real_tmp,
					 $costo_esp,
					 $costo_real,
					 $iva,
					 $ieps;
	}
  #     else {
  #		$sql = sprintf 
  #	    	"UPDATE ci_movimientos SET fecha_hora=\'%s\', estacion=%.4d, supervisor=%d, sello=\'%s\', serie=\'%s\', referencia=%d, litros_esp=%.4f, litros_real=%.4f, costo_esp=%.4f, costo_real=%.4f, iva=%.4f, ieps=%.4f where referencia=?",
  #	    	$fecha_finmy, $estacion, $supervisor, $sello, $referencia, $litros_esp, $litros_real, $costo_esp, $costo_real, $iva, $ieps;
  #    }
    
  $dbmy->do($sql) or &inserta_error_log($log_arc, $dbmy, $IDMYSQL, "Mysql:Orpak", $sql);
  return $EXITO;

}

sub inserta_movimientos_trate {
	my ($log_arc) = @_;
  	my $sql;
  	my $litros_real_tmp;
  	my $costo_real_tmp;
  
  	$litros_real_tmp = $final_vol - $litros_real;
  	$costo_real_tmp = $litros_real * $new_price;
  
  	if ($tipo_comando == $OP_INSERT || $tipo_comando == $OP_INSERT_MANUAL) {
    		$sql = sprintf 
      		"INSERT INTO ci_movimientos (fecha_hora, estacion, dispensador, supervisor, despachador, viaje, camion, chofer, sello, tipo_referencia, serie, referencia, movimiento, litros_esp, litros_real, costo_esp, costo_real, iva, ieps, status, procesada) VALUES (\'%s\',%.4d,NULL,%d,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,0,NULL,%.4f,NULL,%.4f,NULL,NULL,0,'N')", 
		$fecha_hora, $estacion, $supervisor, $litros_real, $costo_real_tmp;
  	}
  #   	else {
  #		$sql = sprintf 
  #	    	"UPDATE ci_movimientos SET fecha_hora=\'%s\', estacion=%.4d, supervisor=%d, litros_real=%.4f, costo_real=%.4f where referencia=?",
  #	    	$fecha_hora, $estacion, $supervisor, $litros_real, $costo_real;
  #  	}
  
  	$dbin->do($sql) or &inserta_error_log($log_arc, $dbmy, $IDINFMX, "Informix:trate", $sql);
  
  	if ($tipo_comando == $OP_INSERT) {
    		if ($serie eq "NULL") {
      			$sql = sprintf
			"INSERT INTO ci_movimientos (fecha_hora, estacion, dispensador, supervisor, despachador, viaje, camion, chofer, sello, tipo_referencia, serie, referencia, movimiento, litros_esp, litros_real, costo_esp, costo_real, iva, ieps, status, procesada) VALUES (\'%s\',%.4d,NULL,%d,NULL,NULL,NULL,NULL,\'%s\',2,%s,%d,1,%.4f,%.4f,%.4f,%.4f,%.4f,%.4f,0,'N')",
	  		$fecha_fin, $estacion, $supervisor, $sello, $serie, $referencia, $litros_esp, $litros_real_tmp, $costo_esp, $costo_real, $iva, $ieps;
    		}
    		else {
      			$sql = sprintf
			"INSERT INTO ci_movimientos (fecha_hora, estacion, dispensador, supervisor, despachador, viaje, camion, chofer, sello, tipo_referencia, serie, referencia, movimiento, litros_esp, litros_real, costo_esp, costo_real, iva, ieps, status, procesada) VALUES (\'%s\',%.4d,NULL,%d,NULL,NULL,NULL,NULL,\'%s\',2,\'%s\',%d,1,%.4f,%.4f,%.4f,%.4f,%.4f,%.4f,0,'N')",
	  		$fecha_fin, $estacion, $supervisor, $sello, $serie, $referencia, $litros_esp, $litros_real_tmp, $costo_esp, $costo_real, $iva, $ieps;
    		}
	}
  	elsif ($tipo_comando == $OP_INSERT_MANUAL){
    		$sql = sprintf
      		"INSERT INTO ci_movimientos (fecha_hora, estacion, supervisor, sello, serie, tipo_referencia, referencia, movimiento, litros_esp, litros_real, costo_esp, costo_real, iva, ieps, status, procesada) VALUES (\'%s\',%.4d,%d,\'%s\',NULL,2,%d,1,%.4f,%.4f,%.4f,%.4f,%.4f,%.4f,1,'N')",
		$fecha_fin, $estacion, $supervisor, $sello, $referencia, $litros_esp, $litros_real_tmp, $costo_esp, $costo_real, $iva, $ieps;
  	}
  #    	else {
  #		$sql = sprintf 
  #	    	"UPDATE ci_movimientos SET fecha_hora=\'%s\', estacion=%.4d, supervisor=%d, sello=\'%s\', serie=\'%s\', referencia=%d, litros_esp=%.4f, litros_real=%.4f, costo_esp=%.4f, costo_real=%.4f, iva=%.4f, ieps=%.4f where referencia=?",
  #	    	$fecha_fin, $estacion, $supervisor, $sello, $referencia, $litros_esp, $litros_real, $costo_esp, $costo_real, $iva, $ieps;
  #    	}
  
  	$dbin->do($sql) or &inserta_error_log($log_arc, $dbmy, $IDINFMX, "Informix:trate", $sql);
  	return $EXITO;
}

sub main {
	$dbmy=Orpak::DbLib::Connect() or &wr_log(*ARC_LOG, "NO SE PUDO CONECTAR AL SERVIDOR MYSQL", 1);
	&begin_commit_rollback_trans_trate(*ARC_LOG, $dbmy, $BEGINTRAN);
	$estacion=&toma_numero_estacion(*ARC_LOG, $dbmy);
	$supervisor=&toma_numero_supervisor(*ARC_LOG, $dbmy);
	&toma_costo_real(*ARC_LOG);
	&toma_numero_iva_ieps(*ARC_LOG);
  
	$supervisor = (defined($supervisor) && $supervisor =~ /\d+$/ ) ? $supervisor : 0;
	$referencia = (defined($referencia) && $referencia =~ /\d+$/ ) ? $referencia : 0;
	$sello = (defined($sello) && length($sello) < 20) ? $sello : substr($sello, -20); 
	$serie = (defined($serie) && length($serie) < 20) ? $serie : substr($serie, -20); 

	$fecha_horamy = $fecha_hora;
	$fecha_finmy = $fecha_fin;

	$fecha_hora = substr($fecha_hora, 0, 16);
	$fecha_fin = substr($fecha_fin, 0, 16);
  
	&inserta_movimientos_siteomat(*ARC_LOG);
  
	$dbin=Connect_Informix_trate(*ARC_LOG, $dbmy);
	&begin_commit_rollback_trans_trate(*ARC_LOG, $dbin, $BEGINTRAN);
	&inserta_movimientos_trate(*ARC_LOG);
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

($tipo_comando, $fecha_hora, $fecha_fin, $litros_esp, $litros_real, $costo_esp, $sello, $referencia, $tipo_producto, $ppv, $final_vol, $serie) = @ARGV;
&wr_log(*ARC_LOG, "==== INICIALIZANDO ==== |Programa $0 en EJECUCION", 0);

if ($tipo_comando == $OP_INSERT) {
  $nom_cmd="INSERCION";
}
elsif ($tipo_comando == $OP_INSERT_MANUAL) {
  $nom_cmd="INSERCION_MANUAL";
}
else {
  $nom_cmd="ACTUALIZACION";
}

$mensaje_log= "DATOS A PROCESAR: \nACTIVIDAD A REALIZAR: $nom_cmd\nFECHA INICIO: $fecha_hora\nFECHA FIN: $fecha_fin\nLITROS ESPERADOS: $litros_esp\nLITROS REALES: $litros_real\nCOSTO ESPERADO: $costo_esp\nSELLO: $sello\nREFERENCIA: $referencia\nTIPO PRODUCTO: $tipo_producto\nPPV: $ppv\nVOLUMEN FINAL: $final_vol\nSERIE: $serie";
&wr_log(*ARC_LOG, $mensaje_log, 0);

if ($#ARGV != 11 ) {
  &wr_log(*ARC_LOG, "Numero de Argumentos Invalido. Faltan Datos", 0);
  exit 1;
}

&main();
close(ARC_LOG);

exit $EXITO;
