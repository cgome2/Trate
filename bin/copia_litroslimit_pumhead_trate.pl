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

my ($poid, $litros_limit);
my $dbmy;

sub inserta_litros_siteomat {
  my ($log_arc) = @_;
  my $sql;
  
  $sql = sprintf "INSERT ins_litros_lim (pump_object_id, litros_limit, status) VALUES (%s,%.4f, 1)", $poid, $litros_limit;
  $dbmy->do($sql) or &inserta_error_log($log_arc, $dbmy, $IDMYSQL, "Mysql:Orpak", $sql);
  return $EXITO;
}

sub main {
    $dbmy=Orpak::DbLib::Connect() or &wr_log(*ARC_LOG, "NO SE PUDO CONECTAR AL SERVIDOR MYSQL", 1);
    &begin_commit_rollback_trans_trate(*ARC_LOG, $dbmy, $BEGINTRAN);
    
    &inserta_litros_siteomat(*ARC_LOG);

    if ($ERRDB == $FALSE) {
      &begin_commit_rollback_trans_trate(*ARC_LOG, $dbmy, $COMITTRAN);
    }
    else {
      &begin_commit_rollback_trans_trate(*ARC_LOG, $dbmy, $ROLLBTRAN);
    }
  
    $dbmy->disconnect();
}

open(ARC_LOG, ">> $ARC_LOG") or die "NO PUDE CREAR EL ARCHIVO $ARC_LOG: $!";

select ARC_LOG;
$| = 1;  # Flush la salida 
select STDOUT;

# CASO: perl $nozzle_id $litros_limit
  
($poid, $litros_limit) = @ARGV;

&wr_log(*ARC_LOG, "==== INICIALIZANDO ==== |Programa $0 en EJECUCION", 0);

$mensaje_log = "DATOS A PROCESAR: \nOID BOMBA: $poid\nLITROS: $litros_limit";
&wr_log(*ARC_LOG, $mensaje_log, 0);

if ($#ARGV != 1 ) {
  &wr_log(*ARC_LOG, "Numero de Argumentos Invalido. Faltan Datos", 0);
  exit 1;
}

&main();
close(ARC_LOG);

exit $EXITO;
