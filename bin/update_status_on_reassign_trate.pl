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

my ($status_new, $pase, $supervisor, $observaciones);
my ($dbmy, $dbin);

sub actualiza_pases_trate {
  my ($log_arc) = @_;
  my $sql;
  
  $sql = sprintf "UPDATE ci_pases SET status='%s',supervisor='%d',observaciones='%s' WHERE pase=%d", $status_new, $supervisor, $observaciones, $pase;
  #printf $sql;
  $dbin->do($sql) or &inserta_error_log($log_arc, 2, "Informix:trate", $sql);

  return $EXITO;
}

sub main {
  $dbmy=Orpak::DbLib::Connect() or &wr_log(*ARC_LOG, "NO SE PUDO CONECTAR AL SERVIDOR MYSQL", 1);
  #$dbin=Connect_Informix_trate(*ARC_LOG, $dbmy);
  $dbin=DBI->connect("dbi:Informix:master","trateusr","usrtrate") or die "Ramses y Carmona dicen No se puede conectar informix";
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

# CASO: perl $pase $status_new $supervisor $observaciones
  
($pase, $status_new, $supervisor, $observaciones) = @ARGV;

&wr_log(*ARC_LOG, "==== INICIALIZANDO ==== |Programa $0 en EJECUCION", 0);

$mensaje_log = "DATOS A PROCESAR: \nPASE: $pase\nSTATUS: $status_new\nSUPERVISOR: $supervisor\nOBSERVACIONES: $observaciones";
&wr_log(*ARC_LOG, $mensaje_log, 0);
&main();
close(ARC_LOG);

exit $EXITO;
