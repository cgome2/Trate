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

my ($litros, $chofer, $camion, $pase, $viaje, $status);
my ($dbmy, $dbin);

sub actualiza_pases_trate {
  my ($log_arc) = @_;
  my $sql;
  
  $sql = sprintf "UPDATE ci_pases SET status='%s' WHERE pase='%s' AND litros='%s' AND chofer='%s' AND viaje='%s'", $status, $pase, $litros, $chofer, $viaje;
  $dbin->do($sql) or &inserta_error_log($log_arc, 2, "Informix:trate", $sql);

  return $EXITO;
}

sub main {
  $dbmy=Orpak::DbLib::Connect() or &wr_log(*ARC_LOG, "NO SE PUDO CONECTAR AL SERVIDOR MYSQL", 1);
  $dbin=Connect_Informix_trate(*ARC_LOG, $dbmy);
  &begin_commit_rollback_trans_trate(*ARC_LOG, $dbin, $BEGINTRAN);
  
  &actualiza_pases_trate(*ARC_LOG);

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

# CASO: perl $litros $chofer $camion $pase $viaje $status
  
($litros, $chofer, $camion, $pase, $viaje, $status) = @ARGV;

&wr_log(*ARC_LOG, "==== INICIALIZANDO ==== |Programa $0 en EJECUCION", 0);

$mensaje_log = "DATOS A PROCESAR: \nLITROS: $litros\nCHOFER: $chofer\nCAMION: $camion\nPASE: $pase\nVIAJE: $viaje\nSTATUS: $status";
&wr_log(*ARC_LOG, $mensaje_log, 0);
&main();
close(ARC_LOG);

exit $EXITO;
