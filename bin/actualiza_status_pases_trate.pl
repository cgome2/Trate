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

my ($camion, $litros, $status_new, $status_old, $id_vehiculo);
my ($dbmy, $dbin);

sub dame_camion_pases {
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
  
  return $EXITO;
}

sub actualiza_pases_siteomat {
  my ($log_arc) = @_;
  my $sql;
  
  $sql = sprintf "UPDATE ci_pases SET status='%s' WHERE camion=%d AND (status='A' OR status='R')", $status_new, $camion;
  $dbmy->do($sql) or &inserta_error_log($log_arc, $dbmy, $IDMYSQL, "Mysql:Orpak", $sql);
  return $EXITO;
}

sub actualiza_pases_trate {
  my ($log_arc) = @_;
  my $sql;
  
  $sql = sprintf "UPDATE ci_pases SET status='%s' WHERE camion=%d AND (status='A' OR status='R')", $status_new, $camion;
  $dbin->do($sql) or &inserta_error_log($log_arc, $dbmy, $IDINFMX, "Informix:trate", $sql);
  return $EXITO;
}

sub main {
  if (defined($camion)) {
    $dbmy=Orpak::DbLib::Connect() or &wr_log(*ARC_LOG, "NO SE PUDO CONECTAR AL SERVIDOR MYSQL", 1);
    $dbin = Connect_Informix_trate(*ARC_LOG, $dbmy);
    &begin_commit_rollback_trans_trate(*ARC_LOG, $dbmy, $BEGINTRAN);
    &begin_commit_rollback_trans_trate(*ARC_LOG, $dbin, $BEGINTRAN);
    
    &dame_camion_pases(*ARC_LOG);
    &actualiza_pases_siteomat(*ARC_LOG);
    &actualiza_pases_trate(*ARC_LOG);

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
}

open(ARC_LOG, ">> $ARC_LOG") or die "NO PUDE CREAR EL ARCHIVO $ARC_LOG: $!";

select ARC_LOG;
$| = 1;  # Flush la salida 
select STDOUT;

# CASO: perl $camion $litros $status_new $status_old
  
($camion, $litros, $status_new, $status_old) = @ARGV;

&wr_log(*ARC_LOG, "==== INICIALIZANDO ==== |Programa $0 en EJECUCION", 0);

$mensaje_log = "DATOS A PROCESAR: \nCAMION: $camion\nLITROS: $litros\nESTATUS NUEVO: $status_new\nESTATUS ANTERIOR: $status_old";
&wr_log(*ARC_LOG, $mensaje_log, 0);

if ($#ARGV != 3 ) {
  &wr_log(*ARC_LOG, "Numero de Argumentos Invalido. Faltan Datos", 0);
  exit 1;
}

&main();
close(ARC_LOG);

exit $EXITO;
