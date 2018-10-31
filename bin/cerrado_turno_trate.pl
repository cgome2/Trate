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

my ($se,$mi,$ho,$di,$me,$an) = (localtime(time))[0,1,2,3,4,5];
my $DIR_ARCLOG="/tmp";
my $ARCHIVO_LOG=sprintf "${DIR_ARCLOG}/Aplic_Turnos_Trate_%.4d%.2d.log", $an+1900, $me+1;
my ($fecha_hora, $estacion, $entrega_turno, $recibe_turno, $fecha_hora_recep, $inv_recib_lts, $movtos_turno_lts);
my ($inv_entreg_lts, $dif_lts, $inv_recib_cto, $movtos_turno_cto, $inv_entreg_cto, $dif_cto, $movtos_dispensario_lts);
my ($ppv, $turno_id_op, $turno_nom_op, $turno_fec_op, $id_turno_start, $tipo_producto, $turno_inv_cl, $turno_inv_op);
my ($start_date, $end_date, $num_turnos, $processed_tab_ctl, $turno_nom, $fecha_horamy, $fecha_hora_recepmy);
my $EXISTE_TURNO_TABCONTR;
my $CERRO_TURNO;
my ($dbmy, $dbin, $dbmy2);
my @Turnos;

sub verifica_mismo_turno {
	my ($log_arc) = @_;
	my ($sth, $sql, $conteo);

	$sql = sprintf "SELECT count(*) FROM objects_t WHERE objtyp_code=22 AND status_code=2 AND field1='OPEN' AND object_id=%s", $id_turno_start;
	#&wr_log($log_arc, "EJECUTARA EL SIGUIENTE COMANDO MYSQL:orpak: $sql", 0);
	$sth = $dbmy->prepare($sql);
	$sth->execute() or &wr_log($log_arc, "NO PUDO EJECUTAR EL SIGUIENTE COMANDO en MYSQL:orpak: $sql", 0);
	$conteo = $sth->fetchrow_array;
	$sth->finish;

	if ($conteo == 0) {
		$CERRO_TURNO=$TRUE;
	}
	else {
		$CERRO_TURNO=$FALSE;
	}

	return $EXITO;
}

sub verifica_turnos_procesados {
	my ($log_arc) = @_;
	my ($sth, $sql, $conteo);

	$sql = sprintf "SELECT count(*) FROM shift_control_t WHERE readytoprocess=1";
 	#&wr_log($log_arc, "EJECUTARA EL SIGUIENTE COMANDO MYSQL:orpak: $sql", 0);
	$sth = $dbmy->prepare($sql);
	$sth->execute() or &wr_log($log_arc, "NO PUDO EJECUTAR EL SIGUIENTE COMANDO en MYSQL:orpak: $sql", 0);
	$processed_tab_ctl = $sth->fetchrow_array;
	$sth->finish;

	return $EXITO;
}
  
sub toma_datos_turno_inserc {
	my ($log_arc, $nom_dturno) = @_;
	my ($sth, $sql, $row_hash);
	my ($conteo, $mas_oid);

	$sql = sprintf "SELECT count(*) FROM shift_control_t WHERE readytoprocess=1 AND nombreturno=\'%s\'", $nom_dturno;
	&wr_log($log_arc, "EJECUTARA EL SIGUIENTE COMANDO MYSQL:orpak: $sql", 0);
	$sth = $dbmy->prepare($sql);
	$sth->execute() or &wr_log($log_arc, "NO PUDO EJECUTAR EL SIGUIENTE COMANDO en MYSQL:orpak: $sql", 0);
	$conteo = $sth->fetchrow_array;
	$sth->finish;

	if ($conteo == 0) {  # NO EXISTE EN LA TABLA DE CONTROL POR LO TANTO SE ACTUALIZAN LOS DATOS DE CIERRE DE TURNO
		$sql = sprintf "SELECT field5 FROM objects_t WHERE object_id=%s", $id_turno_start;
 
		&wr_log($log_arc, "EJECUTARA EL SIGUIENTE COMANDO MYSQL:orpak: $sql", 0);
		$sth = $dbmy->prepare($sql);
		$sth->execute() or &wr_log($log_arc, "NO PUDO EJECUTAR EL SIGUIENTE COMANDO en MYSQL:orpak: $sql", 0);
		$row_hash = $sth->fetchrow_hashref;
		$end_date=$row_hash->{field5};
		$sth->finish;

		$turno_inv_cl=`/usr/local/orpak/web/general-bin/read_tanks_trate.pl -i`; # OBTIENE EL INVENTARIO DE CIERRE DEL TURNO
		chomp($turno_inv_cl);
		# $turno_inv_cl=substr($turno_inv_cl, 0, 8);
      
		$sql = sprintf "UPDATE shift_control_t SET status=1, inventariodecierre=%.4f, fechayhoradecierre=\'%s\', readytoprocess=1 WHERE status=2 AND shift_id=%s", $turno_inv_cl, $end_date, $id_turno_start;
		&wr_log($log_arc, "EJECUTARA EL SIGUIENTE COMANDO MYSQL:orpak: $sql", 0);
		$dbmy->do($sql) or &inserta_error_log($log_arc, $dbmy, $IDMYSQL, "Mysql:Orpak", $sql);
      
		$sql = sprintf "SELECT shift_master_id FROM shift_control_t WHERE status=1 AND readytoprocess=1 AND shift_id=%s", $id_turno_start;
		&wr_log($log_arc, "EJECUTARA EL SIGUIENTE COMANDO MYSQL:orpak: $sql", 0);
		$sth = $dbmy->prepare($sql);
		$sth->execute() or &wr_log($log_arc, "NO PUDO EJECUTAR EL SIGUIENTE COMANDO en MYSQL:orpak: $sql", 0);
		$mas_oid = $sth->fetchrow_array;
		$sth->finish;

		$sql = sprintf "UPDATE objects_t SET status_code=0 WHERE object_id=%s AND objtyp_code=34", $mas_oid;
		&wr_log($log_arc, "EJECUTARA EL SIGUIENTE COMANDO MYSQL:orpak: $sql", 0);

		$dbmy->do($sql) or &inserta_error_log($log_arc, $dbmy, $IDMYSQL, "Mysql:Orpak", $sql);
		&insert_datos_dispensario_control_table($log_arc, $id_turno_start);
	}
	else {   # VERIFICA QUE QUIEN ABRIO EL TURNO SEA EL MISMO QUE LO CERRO
		&verifica_mismo_jefe_turno($log_arc, $nom_dturno);
	}      

	return $EXITO;
}

sub verifica_mismo_jefe_turno {
  my ($log_arc, $nom_dturno) = @_;
  my ($sth, $sql, $row_hash);
  my ($id_turno_old, $oi_openshiftold, $oi_openshiftnew);
  my ($date_turno_old, $inv_turno_old);
  
  $sql = sprintf "SELECT shift_id, fechayhoradeapertura, inventariodeapertura FROM shift_control_t WHERE readytoprocess=1 AND nombreturno=\'%s\'", $nom_dturno;
  &wr_log($log_arc, "EJECUTARA EL SIGUIENTE COMANDO MYSQL:orpak: $sql", 0);
  $sth = $dbmy->prepare($sql);
  $sth->execute() or &wr_log($log_arc, "NO PUDO EJECUTAR EL SIGUIENTE COMANDO en MYSQL:orpak: $sql", 0);
  $row_hash = $sth->fetchrow_hashref;
  $id_turno_old=$row_hash->{object_id};
  $date_turno_old=$row_hash->{fechayhoradeapertura};
  $inv_turno_old=$row_hash->{inventariodeapertura};
  $sth->finish;
  
  $sql = sprintf "SELECT field4 FROM objects_t WHERE object_id=%s", $id_turno_start;
  &wr_log($log_arc, "EJECUTARA EL SIGUIENTE COMANDO MYSQL:orpak: $sql", 0);
  $sth = $dbmy->prepare($sql);
  $sth->execute() or &wr_log($log_arc, "NO PUDO EJECUTAR EL SIGUIENTE COMANDO en MYSQL:orpak: $sql", 0);
  $oi_openshiftnew = $sth->fetchrow_array;
  $sth->finish;

  $sql = sprintf "SELECT field4 FROM objects_t WHERE object_id=%s", $id_turno_old;
  &wr_log($log_arc, "EJECUTARA EL SIGUIENTE COMANDO MYSQL:orpak: $sql", 0);
  $sth = $dbmy->prepare($sql);
  $sth->execute() or &wr_log($log_arc, "NO PUDO EJECUTAR EL SIGUIENTE COMANDO en MYSQL:orpak: $sql", 0);
  $oi_openshiftold = $sth->fetchrow_array;
  $sth->finish;
  
  if ($oi_openshiftnew eq $oi_openshiftold) {
	$sql = sprintf "UPDATE shift_control_t SET readytoprocess=0 WHERE shift_id=%s", $id_turno_old;
	&wr_log($log_arc, "EJECUTARA EL SIGUIENTE COMANDO MYSQL:orpak: $sql", 0);
	$dbmy->do($sql) or &inserta_error_log($log_arc, $dbmy, $IDMYSQL, "Mysql:Orpak", $sql);
	$sql = sprintf "UPDATE shift_control_t SET fechayhoradeapertura=\'%s\', inventariodeapertura=%.4f WHERE shift_id=%s", $date_turno_old, $inv_turno_old, $id_turno_start;
	&wr_log($log_arc, "EJECUTARA EL SIGUIENTE COMANDO MYSQL:orpak: $sql", 0);
	$dbmy->do($sql) or &inserta_error_log($log_arc, $dbmy, $IDMYSQL, "Mysql:Orpak", $sql);
  }
  else {
	$sql = sprintf "UPDATE objects_t SET field1='CLOSE',status_code=1 WHERE object_id=%s", $id_turno_start;
	&wr_log($log_arc, "EJECUTARA EL SIGUIENTE COMANDO MYSQL:orpak: $sql", 0);
	printf "UPDATE objects_t SET field1='CLOSE',status_code=1 WHERE object_id=%s\n", $id_turno_start;
	$dbmy->do($sql) or &inserta_error_log($log_arc, $dbmy, $IDMYSQL, "Mysql:Orpak", $sql);

	$sql = sprintf "UPDATE shift_control_t SET status=1 WHERE shift_id=%s", $id_turno_start;
	&wr_log($log_arc, "EJECUTARA EL SIGUIENTE COMANDO MYSQL:orpak: $sql", 0);
	$dbmy->do($sql) or &inserta_error_log($log_arc, $dbmy, $IDMYSQL, "Mysql:Orpak", $sql);
  }
}

sub limpia_toprocess {
	my ($log_arc) = @_;
	my $sql;
  
	$sql = sprintf "UPDATE dispenser_control_t SET status=0 WHERE status=1";
	&wr_log($log_arc, "EJECUTARA EL SIGUIENTE COMANDO MYSQL:orpak: $sql", 0);
	$dbmy->do($sql) or &inserta_error_log($log_arc, $dbmy, $IDMYSQL, "Mysql:Orpak", $sql);
  
	$sql = sprintf "UPDATE shift_control_t SET readytoprocess=0 WHERE readytoprocess=1";
	&wr_log($log_arc, "EJECUTARA EL SIGUIENTE COMANDO MYSQL:orpak: $sql", 0);
	$dbmy->do($sql) or &inserta_error_log($log_arc, $dbmy, $IDMYSQL, "Mysql:Orpak", $sql);
  
	return $EXITO;
}

sub verifica_existe_turno_abierto {
	my ($log_arc, $nom_dturno) = @_;
	my ($sth, $sql, $cont_turno);

	$sql = sprintf "SELECT count(*) FROM shift_control_t WHERE status=2 AND nombreturno=\'%s\'", $nom_dturno;
	#&wr_log($log_arc, "EJECUTARA EL SIGUIENTE COMANDO MYSQL:orpak: $sql", 0);
	$sth = $dbmy->prepare($sql);
    	$sth->execute() or &wr_log($log_arc, "NO PUDO EJECUTAR EL SIGUIENTE COMANDO en MYSQL:orpak: $sql", 0);
    	$cont_turno = $sth->fetchrow_array;
    	$sth->finish;

    	if ($cont_turno == 0) {
      		$EXISTE_TURNO_TABCONTR=$FALSE;
    	}
    	else {
      		$EXISTE_TURNO_TABCONTR=$TRUE;
      		$sql = sprintf "SELECT shift_id FROM shift_control_t WHERE status=2 AND nombreturno=\'%s\'", $nom_dturno;
      		#&wr_log($log_arc, "EJECUTARA EL SIGUIENTE COMANDO MYSQL:orpak: $sql", 0);
		$sth = $dbmy->prepare($sql);
      		$sth->execute() or &wr_log($log_arc, "NO PUDO EJECUTAR EL SIGUIENTE COMANDO en MYSQL:orpak: $sql", 0);
      		$id_turno_start = $sth->fetchrow_array;
      		$sth->finish;
    	}

	return $EXITO;
}

sub toma_todos_turnos {
	my ($log_arc) = @_;
    	my ($sth, $sql, @registro);
    
    	$sql = sprintf "SELECT object_desc FROM object_language_matrix WHERE object_id IN (SELECT shift_oid FROM shift_pumps)";
#    	&wr_log($log_arc, "EJECUTARA EL SIGUIENTE COMANDO MYSQL:orpak: $sql", 0);
	$sth = $dbmy->prepare($sql);
    	$sth->execute() or &wr_log($log_arc, "NO PUDO EJECUTAR EL SIGUIENTE COMANDO en MYSQL:orpak: $sql", 0);
    	while ( @registro=$sth->fetchrow_array()) {
      		push @Turnos, $registro[0];
    	}

    	$sth->finish;

    	$num_turnos=$#Turnos + 1;
    	return $EXITO;
}

sub toma_turno_abierto {
  	my ($log_arc, $nom_dturno) = @_;
  	my ($sth, $sql, $registro);
  
  	$sql = sprintf "SELECT OT.object_id as oid, OLM.object_desc as name, OT.field2 FROM objects_t OT, object_language_matrix OLM WHERE OT.object_id=OLM.object_id AND OLM.language_code = \'es\' AND OT.objtyp_code = 22 AND OT.object_ref is null AND OT.status_code = 2 AND OT.field1 = \"OPEN\" AND OLM.object_desc=\'%s\'", $nom_dturno;
  	#&wr_log($log_arc, "EJECUTARA EL SIGUIENTE COMANDO MYSQL:orpak: $sql", 0);
	$sth = $dbmy->prepare($sql);
  	$sth->execute() or &wr_log($log_arc, "NO PUDO EJECUTAR EL SIGUIENTE COMANDO en MYSQL:orpak: $sql", 0);
  	$registro=$sth->fetchrow_arrayref();
  	$turno_id_op=$registro->[0];
  	$turno_nom_op=$registro->[1];
  	$turno_fec_op=$registro->[2];
  	$sth->finish;

  	return $EXITO;
}

sub insert_open_shift_control_table {
	my ($log_arc, $nom_dturno) = @_;
	my ($sql, $sth, $oid_master, $registro);
  
	$sql = sprintf "SELECT olm.object_id FROM object_language_matrix olm LEFT JOIN objects_t ot ON olm.object_id=ot.object_id WHERE ot.objtyp_code=34 AND ot.status_code> 0 and olm.object_desc=\'%s\'", $nom_dturno;
	#&wr_log($log_arc, "EJECUTARA EL SIGUIENTE COMANDO MYSQL:orpak: $sql", 0);
	$sth = $dbmy->prepare($sql);
	$sth->execute() or &wr_log($log_arc, "NO PUDO EJECUTAR EL SIGUIENTE COMANDO en MYSQL:orpak: $sql", 0);
	$registro=$sth->fetchrow_arrayref();
	$oid_master=$registro->[0];

	$sql = sprintf "INSERT INTO shift_control_t VALUES (%s, %s,\'%s\',\'%s\',NULL,%.4f,NULL,2, 0);",
	$oid_master, $turno_id_op, $turno_nom_op, $turno_fec_op, $turno_inv_op;
	&wr_log($log_arc, "EJECUTARA EL SIGUIENTE COMANDO MYSQL:orpak: $sql", 0);  
	$dbmy->do($sql) or &inserta_error_log($log_arc, $dbmy, $IDMYSQL, "Mysql:Orpak", $sql);
  
	return $EXITO;
}

sub toma_invs_fechas_idcierreapertura {
    my ($log_arc) = @_;
    my ($sth, $sql, $row_hash, $oid_shift);
 
    $sql = sprintf "SELECT shift_id FROM shift_control_t WHERE readytoprocess=1 LIMIT 1";
    &wr_log($log_arc, "EJECUTARA EL SIGUIENTE COMANDO MYSQL:orpak: $sql", 0);

    $sth = $dbmy->prepare($sql);
    $sth->execute() or &wr_log($log_arc, "NO PUDO EJECUTAR EL SIGUIENTE COMANDO en MYSQL:orpak: $sql", 0);
    $oid_shift = $sth->fetchrow_array;
    $sth->finish;
    
    $sql = sprintf "SELECT olm.object_desc FROM object_language_matrix olm LEFT JOIN objects_t ot on olm.object_id=ot.field4 where ot.object_id=%s and olm.language_code=\'es\'", $oid_shift;
    &wr_log($log_arc, "EJECUTARA EL SIGUIENTE COMANDO MYSQL:orpak: $sql", 0);

    $sth = $dbmy->prepare($sql);
    $sth->execute() or &wr_log($log_arc, "NO PUDO EJECUTAR EL SIGUIENTE COMANDO en MYSQL:orpak: $sql", 0);
    $entrega_turno = $sth->fetchrow_array;
    $sth->finish;
    
    $entrega_turno=($entrega_turno =~ /\d+$/ ) ? $entrega_turno : 0;
    
    $sql = sprintf "SELECT olm.object_desc FROM object_language_matrix olm LEFT JOIN objects_t ot on olm.object_id=ot.field7 where ot.object_id=%s and olm.language_code=\'es\'", $oid_shift;
    &wr_log($log_arc, "EJECUTARA EL SIGUIENTE COMANDO MYSQL:orpak: $sql", 0);

    $sth = $dbmy->prepare($sql);
    $sth->execute() or &wr_log($log_arc, "NO PUDO EJECUTAR EL SIGUIENTE COMANDO en MYSQL:orpak: $sql", 0);
    $recibe_turno = $sth->fetchrow_array;
    $sth->finish;
    
    $recibe_turno=($recibe_turno =~ /\d+$/ ) ? $recibe_turno : 0;

    $sql = sprintf "SELECT MIN(fechayhoradeapertura) AS fecha_i, MAX(fechayhoradecierre) AS fecha_f from shift_control_t WHERE readytoprocess=1";
    &wr_log($log_arc, "EJECUTARA EL SIGUIENTE COMANDO MYSQL:orpak: $sql", 0);

    $sth = $dbmy->prepare($sql);
    $sth->execute() or &wr_log($log_arc, "NO PUDO EJECUTAR EL SIGUIENTE COMANDO en MYSQL:orpak: $sql", 0);
    $row_hash = $sth->fetchrow_hashref;
    $start_date=$row_hash->{fecha_i};
    $end_date=$row_hash->{fecha_f};
    $sth->finish;

    $sql = sprintf "SELECT inventariodeapertura FROM shift_control_t WHERE fechayhoradeapertura=\'%s\' AND readytoprocess=1", $start_date;
    $sth = $dbmy->prepare($sql);
    $sth->execute() or &wr_log($log_arc, "NO PUDO EJECUTAR EL SIGUIENTE COMANDO en MYSQL:orpak: $sql", 0);
    $row_hash = $sth->fetchrow_hashref;
    $inv_recib_lts=$row_hash->{inventariodeapertura};
    $sth->finish;

    $sql = sprintf "SELECT inventariodecierre FROM shift_control_t WHERE fechayhoradecierre=\'%s\' AND readytoprocess=1", $end_date;
    &wr_log($log_arc, "EJECUTARA EL SIGUIENTE COMANDO MYSQL:orpak: $sql", 0);

    $sth = $dbmy->prepare($sql);
    $sth->execute() or &wr_log($log_arc, "NO PUDO EJECUTAR EL SIGUIENTE COMANDO en MYSQL:orpak: $sql", 0);
    $row_hash = $sth->fetchrow_hashref;
    $inv_entreg_lts=$row_hash->{inventariodecierre};
    $sth->finish;

    $fecha_horamy = $end_date;
    $fecha_hora_recepmy = $start_date;

    $fecha_hora = substr($end_date, 0, 16);
    $fecha_hora_recep = substr($start_date, 0, 16);

    return $EXITO;
}

sub toma_product_id {
	my ($log_arc) = @_;
	my ($sth, $sql);

	$sql = sprintf "SELECT product_id FROM products_t WHERE product_external_code != 99 and status_code=2 LIMIT 1";
	#&wr_log($log_arc, "EJECUTARA EL SIGUIENTE COMANDO MYSQL:orpak: $sql", 0);

	$sth = $dbmy->prepare($sql);
	$sth->execute() or &wr_log($log_arc, "NO PUDO EJECUTAR EL SIGUIENTE COMANDO en MYSQL:orpak: $sql", 0);
	$tipo_producto = $sth->fetchrow_array;
	$sth->finish;

	return $EXITO;
}

sub movtos_turno_lts {
    my ($log_arc) = @_;
    my ($sql, $sth, $lits_tank, $lits_tran, $lits_movs);

    $sql = sprintf "SELECT sum(end_volume - start_volume) FROM tank_delivery_readings_t WHERE end_delivery_timestamp BETWEEN \'%s\' AND \'%s\'", 
      $start_date, $end_date;
    &wr_log($log_arc, "EJECUTARA EL SIGUIENTE COMANDO MYSQL:orpak: $sql", 0);

    $sth = $dbmy->prepare($sql);
    $sth->execute() or &wr_log($log_arc, "NO PUDO EJECUTAR EL SIGUIENTE COMANDO en MYSQL:orpak: $sql", 0);
    $lits_tank = $sth->fetchrow_array;
    $sth->finish;

    $sql = sprintf "SELECT sum(litros_real) FROM ci_movimientos WHERE movimiento=1 AND status=1 AND fecha_hora BETWEEN \'%s\' AND \'%s\'", 
      $start_date, $end_date;
    &wr_log($log_arc, "EJECUTARA EL SIGUIENTE COMANDO MYSQL:orpak: $sql", 0);

    $sth = $dbmy->prepare($sql);
    $sth->execute() or &wr_log($log_arc, "NO PUDO EJECUTAR EL SIGUIENTE COMANDO en MYSQL:orpak: $sql", 0);
    $lits_movs = $sth->fetchrow_array;
    $sth->finish;
    $lits_tank = $lits_tank + $lits_movs;

    $sql = sprintf "SELECT sum(dispensed_quantity) FROM transactions_t WHERE transaction_timestamp BETWEEN \'%s\' AND \'%s\'", $start_date, $end_date;
    &wr_log($log_arc, "SE EJECUTO EL SIGUIENTE COMANDO en MYSQL:orpak: $sql", 0);

    $sth = $dbmy->prepare($sql);
    $sth->execute() or &wr_log($log_arc, "NO PUDO EJECUTAR EL SIGUIENTE COMANDO en MYSQL:orpak: $sql", 0);
    $lits_tran = $sth->fetchrow_array;
    $sth->finish;
    
    $movtos_turno_lts = $lits_tank - $lits_tran;
    return $EXITO;
}

sub toma_ppv {
    my ($log_arc) = @_;
    my $sth;

    my $sql = sprintf "SELECT if(now()>timestamp,new_price,price) FROM object_product_matrix WHERE product_id=%s", $tipo_producto;
    &wr_log($log_arc, "EJECUTARA EL SIGUIENTE COMANDO MYSQL:orpak: $sql", 0);

    $sth = $dbmy->prepare($sql);
    $sth->execute() or &wr_log($log_arc, "NO PUDO EJECUTAR EL SIGUIENTE COMANDO en MYSQL:orpak: $sql", 0);
    $ppv = $sth->fetchrow_array;
    $sth->finish;

    return $EXITO;
}

sub calcula_datos_turno {
    my ($movtos_litros)=@_;

    $dif_lts = (($inv_recib_lts + $movtos_litros) - $inv_entreg_lts);
    $inv_recib_cto = $inv_recib_lts * $ppv;
    $movtos_turno_cto = $movtos_litros * $ppv;
    $inv_entreg_cto = $inv_entreg_lts * $ppv;
    $dif_cto = $dif_lts * $ppv;
    return $EXITO;
}

sub activa_turnos_trate {
	my ($log_arc)=@_;
	my ($sth, $reg_hash, $sql, $sql2);

	$sql = sprintf "SELECT shift_master_id FROM shift_control_t WHERE readytoprocess=1";
	#&wr_log($log_arc, "EJECUTARA EL SIGUIENTE COMANDO MYSQL:orpak: $sql", 0);

	$sth = $dbmy2->prepare($sql);
	$sth->execute() or &wr_log($log_arc, "NO PUDO EJECUTAR EL SIGUIENTE COMANDO en MYSQL:orpak: $sql", 0);
	while($reg_hash = $sth->fetchrow_hashref) {
		$sql2 = sprintf "UPDATE objects_t SET status_code=2 WHERE object_id=%s AND objtyp_code=34", $reg_hash->{shift_master_id};
		#&wr_log($log_arc, "EJECUTARA EL SIGUIENTE COMANDO MYSQL:orpak: $sql2", 0);
		$dbmy->do($sql2) or &inserta_error_log($log_arc, $dbmy, $IDMYSQL, "Mysql:Orpak", $sql2);
	}
	$sth->finish;
  
	return $EXITO;
}

sub insert_datos_dispensario_control_table {
  my ($log_arc, $oid_dturno) = @_;
  my ($sth, $sql, $sql2, @disp);
  
  $sql = sprintf "SELECT c.object_desc,a.object_id,a.object_timestamp,a.status_code,a.field2,a.field4,a.field6 FROM object_dependency_matrix odm INNER JOIN object_dependency_matrix xxod ON xxod.object_parent_id=odm.object_id INNER JOIN objects_t a on a.object_id = xxod.object_id AND a.objtyp_code=33 LEFT JOIN objects_t b ON a.field1=b.object_id LEFT JOIN object_language_matrix c ON b.object_id=c.object_id AND c.language_code='es' WHERE odm.object_parent_id=%s", $oid_dturno;
  &wr_log($log_arc, "EJECUTARA EL SIGUIENTE COMANDO MYSQL:orpak: $sql", 0);

  $sth = $dbmy2->prepare($sql);
  $sth->execute() or &wr_log($log_arc, "NO PUDO EJECUTAR EL SIGUIENTE COMANDO en MYSQL:orpak: $sql", 0);
  while ( @disp=$sth->fetchrow_array()) {
    $sql2 = sprintf "INSERT INTO dispenser_control_t VALUES (%s, %d, %s,\'%s\', %d, %.4f, %.4f, \'%s\', NULL, 1)", $oid_dturno, $disp[0], $disp[1], $disp[2], $disp[3], $disp[4], $disp[5], $disp[6];
    &wr_log($log_arc, "EJECUTARA EL SIGUIENTE COMANDO MYSQL:orpak: $sql", 0);

    $dbmy->do($sql2) or &inserta_error_log($log_arc, $dbmy, $IDMYSQL, "Mysql:Orpak", $sql2);
  }
  $sth->finish;

  return $EXITO;
}

sub inserta_datos_turno_siteomat {
  my ($log_arc) = @_;
  my $sql;
  
  $sql = sprintf 
    "INSERT INTO ci_cortes (fecha_hora, estacion, dispensador, entrega_turno, recibe_turno, fecha_hora_recep, inventario_recibido_lts, movtos_turno_lts, inventario_entregado_lts, diferencia_lts, inventario_recibido_cto, movtos_turno_cto, inventario_entregado_cto, diferencia_cto, autorizo_dif, contador_inicial, contador_final) VALUES (\'%s\',%.4d,0,%d,%d,\'%s\',%.4f,%.4f,%.4f,%.4f,%.4f,%.4f,%.4f,%.4f,NULL,NULL,NULL)",
      $fecha_horamy, $estacion, $entrega_turno, $recibe_turno, $fecha_hora_recepmy, $inv_recib_lts, $movtos_turno_lts,
	$inv_entreg_lts, $dif_lts, $inv_recib_cto, $movtos_turno_cto, $inv_entreg_cto, $dif_cto;
  &wr_log($log_arc, "EJECUTARA EL SIGUIENTE COMANDO MYSQL:orpak: $sql", 0);
  $dbmy->do($sql) or &inserta_error_log($log_arc, $dbmy, $IDMYSQL, "Mysql:Orpak", $sql);
}

sub inserta_datos_turno_trate {
	my ($log_arc) = @_;
	my $sql;
  
	$sql = sprintf 
    "INSERT INTO ci_cortes (fecha_hora, estacion, dispensador, entrega_turno, recibe_turno, fecha_hora_recep, inventario_recibido_lts, movtos_turno_lts, inventario_entregado_lts, diferencia_lts, inventario_recibido_cto, movtos_turno_cto, inventario_entregado_cto, diferencia_cto, autorizo_dif, contador_inicial, contador_final) VALUES (\'%s\',%.4d,0,%d,%d,\'%s\',%.4f,%.4f,%.4f,%.4f,%.4f,%.4f,%.4f,%.4f,NULL,NULL,NULL)",
      	$fecha_hora, $estacion, $entrega_turno, $recibe_turno, $fecha_hora_recep, $inv_recib_lts, $movtos_turno_lts,
	$inv_entreg_lts, $dif_lts, $inv_recib_cto, $movtos_turno_cto, $inv_entreg_cto, $dif_cto;
  	&wr_log($log_arc, "EJECUTARA EL SIGUIENTE COMANDO INFORMIX:orpak: $sql", 0);
  	$dbin->do($sql) or &inserta_error_log($log_arc, $dbmy, $IDINFMX, "Informix:trate", $sql);
 
	return $EXITO;
}

sub inserta_datos_dispensador {
  my ($log_arc) = @_;
  my ($sql, $sth1, $sth2, @disp, $sql2, $movtos_dispensario_lts_ci);
  
  $sql = sprintf "SELECT dispensador, contador_inicial, contador_final, despachador FROM dispenser_control_t WHERE status=1 AND shift_id IN (SELECT shift_id FROM shift_control_t WHERE readytoprocess=1)";
  &wr_log($log_arc, "EJECUTARA EL SIGUIENTE COMANDO MYSQL:orpak: $sql", 0);

  $sth1 = $dbmy2->prepare($sql);
  $sth1->execute() or &wr_log($log_arc, "NO PUDO EJECUTAR EL SIGUIENTE COMANDO en MYSQL:orpak: $sql", 0);
  while ( @disp=$sth1->fetchrow_array()) {
    $sql2 = sprintf "SELECT sum(dispensed_quantity) FROM transactions_t WHERE transaction_timestamp BETWEEN \'%s\' AND \'%s\' AND pump_head_external_code=%d", 
      $start_date, $end_date, $disp[0];
    &wr_log($log_arc, "EJECUTARA EL SIGUIENTE COMANDO MYSQL:orpak: $sql2", 0);

    $sth2 = $dbmy->prepare($sql2);
    $sth2->execute() or &wr_log($log_arc, "NO PUDO EJECUTAR EL SIGUIENTE COMANDO en MYSQL:orpak: $sql2", 0);
    $movtos_dispensario_lts = $sth2->fetchrow_array;
    $sth2->finish;

    $sql2 = sprintf "SELECT sum(litros_real) FROM ci_movimientos WHERE movimiento=2 AND status=2 AND dispensador=%d AND fecha_hora BETWEEN \'%s\' AND \'%s\'", 
      $disp[0], $start_date, $end_date;
    &wr_log($log_arc, "EJECUTARA EL SIGUIENTE COMANDO MYSQL:orpak: $sql2", 0);
    $sth2 = $dbmy->prepare($sql2);
    $sth2->execute() or &wr_log($log_arc, "NO PUDO EJECUTAR EL SIGUIENTE COMANDO en MYSQL:orpak: $sql2", 0);
    $movtos_dispensario_lts_ci = $sth2->fetchrow_array;
    $sth2->finish;
    $movtos_dispensario_lts = $movtos_dispensario_lts + $movtos_dispensario_lts_ci;

    $inv_recib_lts = $disp[1];
    $inv_entreg_lts = $disp[2];
    &calcula_datos_turno($movtos_dispensario_lts);
  
    $sql2 = sprintf 
      "INSERT INTO ci_cortes (fecha_hora, estacion, dispensador, entrega_turno, recibe_turno, fecha_hora_recep, inventario_recibido_lts, movtos_turno_lts, inventario_entregado_lts, diferencia_lts, inventario_recibido_cto, movtos_turno_cto, inventario_entregado_cto, diferencia_cto, autorizo_dif, contador_inicial, contador_final) VALUES (\'%s\',%.4d,%d,%d,%d,\'%s\',%.4f,%.4f,%.4f,%.4f,%.4f,%.4f,%.4f,%.4f,NULL,NULL,NULL)",
	$fecha_horamy, $estacion, $disp[0], $disp[3], $recibe_turno, $fecha_hora_recepmy, $inv_recib_lts, $movtos_dispensario_lts,
	  $inv_entreg_lts, $dif_lts, $inv_recib_cto, $movtos_turno_cto, $inv_entreg_cto, $dif_cto;
    &wr_log($log_arc, "EJECUTARA EL SIGUIENTE COMANDO MYSQL:orpak: $sql2", 0);
    $dbmy->do($sql2) or &inserta_error_log($log_arc, $dbmy, $IDMYSQL, "Mysql:Orpak", $sql2);
    
    $sql2 = sprintf 
      "INSERT INTO ci_cortes (fecha_hora, estacion, dispensador, entrega_turno, recibe_turno, fecha_hora_recep, inventario_recibido_lts, movtos_turno_lts, inventario_entregado_lts, diferencia_lts, inventario_recibido_cto, movtos_turno_cto, inventario_entregado_cto, diferencia_cto, autorizo_dif, contador_inicial, contador_final) VALUES (\'%s\',%.4d,%d,%d,%d,\'%s\',%.4f,%.4f,%.4f,%.4f,%.4f,%.4f,%.4f,%.4f,NULL,NULL,NULL)",
	$fecha_hora, $estacion, $disp[0], $disp[3], $recibe_turno, $fecha_hora_recep, $inv_recib_lts, $movtos_dispensario_lts,
	  $inv_entreg_lts, $dif_lts, $inv_recib_cto, $movtos_turno_cto, $inv_entreg_cto, $dif_cto;
    &wr_log($log_arc, "EJECUTARA EL SIGUIENTE COMANDO MYSQL:orpak: $sql2", 0);
    $dbin->do($sql2) or &inserta_error_log($log_arc, $dbmy, $IDINFMX, "Informix:trate", $sql2);
  }
  $sth1->finish;
}

sub toma_despachador_turno {
  my ($log_arc) = @_;
  my ($sql, $sth1, $sth2, @turns, $sql2, $despachador);
  
  $sql = sprintf "SELECT shift_id FROM shift_control_t WHERE readytoprocess=1";
  &wr_log($log_arc, "EJECUTARA EL SIGUIENTE COMANDO MYSQL:orpak: $sql", 0);
  $sth1 = $dbmy2->prepare($sql);
  $sth1->execute() or &wr_log($log_arc, "NO PUDO EJECUTAR EL SIGUIENTE COMANDO en MYSQL:orpak: $sql", 0);
  while ( @turns=$sth1->fetchrow_array()) {
    $sql2 = sprintf "SELECT b.object_desc AS despachador FROM history_log_t a LEFT JOIN object_language_matrix b ON b.object_id = a.field2 AND b.language_code =\"es\" LEFT JOIN object_language_matrix c ON c.object_id = a.field3 AND c.language_code =\"es\" LEFT JOIN tbl t ON t.tbl = \"SFTGST\" AND t.language_code =\"es\" AND t.code = a.field4 WHERE a.histyp_code = \"3\" AND t.name = \"ENTRO\" AND a.field1 = %s", $turns[0];
    &wr_log($log_arc, "EJECUTARA EL SIGUIENTE COMANDO MYSQL:orpak: $sql2", 0);
    $sth2 = $dbmy->prepare($sql2);
    $sth2->execute() or &wr_log($log_arc, "NO PUDO EJECUTAR EL SIGUIENTE COMANDO en MYSQL:orpak: $sql2", 0);
    $despachador = $sth2->fetchrow_array;
    $sth2->finish;

    $despachador = defined($despachador) ? $despachador : 0;
    $sql2 = sprintf "UPDATE dispenser_control_t SET despachador=%d WHERE shift_id=%s AND status=1", $despachador, $turns[0];
    &wr_log($log_arc, "EJECUTARA EL SIGUIENTE COMANDO MYSQL:orpak: $sql2", 0);
    $dbmy->do($sql2) or &inserta_error_log($log_arc, $dbmy, $IDMYSQL, "Mysql:Orpak", $sql2);
  }
  $sth1->finish;
}

sub main {

	$dbmy=Orpak::DbLib::Connect() or &wr_log(*ARC_LOG, "NO SE PUDO CONECTAR AL SERVIDOR MYSQL", 1);
	$dbmy2=Orpak::DbLib::Connect() or &wr_log(*ARC_LOG, "NO SE PUDO CONECTAR AL SERVIDOR MYSQL", 1);
  
	&toma_todos_turnos(*ARC_LOG);
	foreach $turno_nom (@Turnos) {
		&verifica_existe_turno_abierto(*ARC_LOG, $turno_nom);
		if ($EXISTE_TURNO_TABCONTR == $FALSE) { # NO EXISTE EL TURNO EN LA TABLA DE CONTROL
			&toma_turno_abierto(*ARC_LOG, $turno_nom); 
			if (defined($turno_id_op) && defined($turno_nom_op) && defined($turno_fec_op)) {
				$turno_inv_op=`/usr/local/orpak/web/general-bin/read_tanks_trate.pl -i`; # OBTIENE EL INVENTARIO DE APERTURA DEL TURNO
				chomp($turno_inv_op);
			#	$turno_inv_op=substr($turno_inv_op, 0, 8);
				&insert_open_shift_control_table(*ARC_LOG, $turno_nom);
      			}
		}
		else {
			&verifica_mismo_turno(*ARC_LOG);
			if ($CERRO_TURNO == $TRUE) {
				&toma_datos_turno_inserc(*ARC_LOG, $turno_nom);
			}
		}
	}

	&verifica_turnos_procesados(*ARC_LOG);
#	printf "$num_turnos == $processed_tab_ctl\n";
	if ($num_turnos == $processed_tab_ctl) {
		&activa_turnos_trate(*ARC_LOG);
		&toma_product_id(*ARC_LOG);
		&toma_ppv(*ARC_LOG);
		$estacion=&toma_numero_estacion(*ARC_LOG, $dbmy);
		&toma_invs_fechas_idcierreapertura(*ARC_LOG);
		&movtos_turno_lts(*ARC_LOG);
		&calcula_datos_turno($movtos_turno_lts);
		&begin_commit_rollback_trans_trate(*ARC_LOG, $dbmy, $BEGINTRAN);
		&inserta_datos_turno_siteomat(*ARC_LOG);
		#$dbin=&Connect_Informix_trate(*ARC_LOG, $dbmy);
		$dbin=DBI->connect("dbi:Informix:master","trateusr","usrtrate") 
			or &wr_log(*ARC_LOG, "RAMSES DESDE cerrado_turno_trate.pl::. No se pudo conectar al servidor INFORMIX", 1);
		&begin_commit_rollback_trans_trate(*ARC_LOG, $dbin, $BEGINTRAN);
		&inserta_datos_turno_trate(*ARC_LOG);
		&toma_despachador_turno(*ARC_LOG);
		&inserta_datos_dispensador(*ARC_LOG);
		 if ($ERRDB == $FALSE) {
		&begin_commit_rollback_trans_trate(*ARC_LOG, $dbmy, $COMITTRAN);
		&begin_commit_rollback_trans_trate(*ARC_LOG, $dbin, $COMITTRAN);
	}
	else {
		&begin_commit_rollback_trans_trate(*ARC_LOG, $dbmy, $ROLLBTRAN);
		&begin_commit_rollback_trans_trate(*ARC_LOG, $dbin, $ROLLBTRAN);
	}
	$dbin->disconnect;
	$dbmy->{AutoCommit} = 1;
	&limpia_toprocess(*ARC_LOG);
  }
  $dbmy->disconnect();
  $dbmy2->disconnect();
} 

open(ARC_LOG, ">> $ARCHIVO_LOG") or die "NO PUDE CREAR EL ARCHIVO $ARCHIVO_LOG: $!";

select ARC_LOG;
$| = 1;  # Flush la salida 
select STDOUT;

&wr_log(*ARC_LOG, "==== INICIALIZANDO ==== |Programa $0 en EJECUCION", 0);

while (1) {
    &main();
    ($fecha_hora, $estacion, $entrega_turno, $recibe_turno, $fecha_hora_recep, $inv_recib_lts, $movtos_turno_lts) = undef;
    ($inv_entreg_lts, $dif_lts, $inv_recib_cto, $movtos_turno_cto, $inv_entreg_cto, $dif_cto, $movtos_dispensario_lts) = undef;
    ($ppv, $turno_id_op, $turno_nom_op, $turno_fec_op, $id_turno_start, $tipo_producto, $turno_inv_cl, $turno_inv_op) = undef;
    ($start_date, $end_date, $num_turnos, $processed_tab_ctl, $turno_nom) = undef;
    ($EXISTE_TURNO_TABCONTR, $CERRO_TURNO, $dbmy, $dbin, $dbmy2, @Turnos) = undef;
    sleep 5;
}

close(ARC_LOG);

exit $EXITO;
