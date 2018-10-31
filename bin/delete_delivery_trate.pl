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
use DBI;
use Orpak::DbLib;
use Orpak::Trate::Trate_functions;

my ($sdt, $edt);
my ($dbmy, $dbin);

sub borra_edt_sdt_trate {
  my ($log_arc) = @_;
  my $sql;
  
  $sql = sprintf "DELETE FROM ci_movimientos WHERE fecha_hora=\'%s\' AND movimiento=0", $sdt;
  $dbin->do($sql) or &inserta_error_log($log_arc, 2, "Informix:trate", $sql);

  $sql = sprintf "DELETE FROM ci_movimientos WHERE fecha_hora=\'%s\' AND movimiento=1", $edt;
  $dbin->do($sql) or &inserta_error_log($log_arc, 2, "Informix:trate", $sql);

  return $EXITO;
}

sub main {
  
  $dbmy=Orpak::DbLib::Connect() or &wr_log(*ARC_LOG, "NO SE PUDO CONECTAR AL SERVIDOR MYSQL", 1);
  $dbin = Connect_Informix_trate(*ARC_LOG, $dbmy);
  &begin_commit_rollback_trans_trate(*ARC_LOG, $dbin, $BEGINTRAN);
  
  &borra_edt_sdt_trate(*ARC_LOG);
#  system "echo $sql2 >> windows";

  if ($ERRDB == $FALSE) {
    &begin_commit_rollback_trans_trate(*ARC_LOG, $dbin, $COMITTRAN);
  }
  else {
    &begin_commit_rollback_trans_trate(*ARC_LOG, $dbin, $ROLLBTRAN);
  }
  
  $dbin->disconnect;
  $dbmy->disconnect;
}

open(ARC_LOG, ">> $ARC_LOG") or die "NO PUDE CREAR EL ARCHIVO $ARC_LOG: $!";

select ARC_LOG;
$| = 1;  # Flush la salida 
select STDOUT;

($sdt, $edt) = @ARGV;

&wr_log(*ARC_LOG, "==== INICIALIZANDO ==== |Programa $0 en EJECUCION", 0);

$mensaje_log = "DATOS A PROCESAR: \nSDT: $sdt\nEDT: $edt";
&wr_log(*ARC_LOG, $mensaje_log, 0);
&main();
close(ARC_LOG);

exit $EXITO;
