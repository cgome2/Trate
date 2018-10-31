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

my ($dbmy1, $dbmy2, $dbin);

sub clear_log_orpak_trate {
  my ($id_servidor, $dbtmp, $dbtmp2)=@_;
  my ($sth, $rtot, $reg_hash, $sql, $sql2);

  $sql = sprintf "SELECT queryerr, exe_date FROM error_log_inserts WHERE tip_bdservidor = %d", $id_servidor;
  $sth = $dbmy1->prepare($sql);
  $sth->execute() or printf "NO PUDO EJECUTAR EL SIGUIENTE COMANDO en MYSQL:orpak: $sql\n";
  while($reg_hash = $sth->fetchrow_hashref) {
    $rtot=$dbtmp->do($reg_hash->{queryerr})
      or printf "No se pudo ejecutar el comando $reg_hash->{queryerr}\n";
    if ($rtot == 1) { # Se inserto el registro por lo tanto se borra de la bitacora.
      $sql2 = sprintf "DELETE FROM error_log_inserts WHERE exe_date='%s' and tip_bdservidor=%d", $reg_hash->{exe_date}, $id_servidor;
      $dbtmp2->do($sql2) or printf "No se pudo ejecutar $sql2\n";
    }
  }
  $sth->finish;
  
  return $EXITO;
}

sub main {

    $dbmy1=Orpak::DbLib::Connect() or printf "NO SE PUDO CONECTAR AL SERVIDOR MYSQL\n";
    $dbmy2=Orpak::DbLib::Connect() or printf "NO SE PUDO CONECTAR AL SERVIDOR MYSQL\n";
    $dbin = Connect_Informix_trate(*ARC_LOG, $dbmy1);
    &begin_commit_rollback_trans_trate(*ARC_LOG, $dbmy2, $BEGINTRAN);
    &begin_commit_rollback_trans_trate(*ARC_LOG, $dbin, $BEGINTRAN);

    &clear_log_orpak_trate(1, $dbmy2, $dbmy2);
    &clear_log_orpak_trate(2, $dbin, $dbmy2);

    if ($ERRDB == $FALSE) {
      &begin_commit_rollback_trans_trate(*ARC_LOG, $dbmy2, $COMITTRAN);
      &begin_commit_rollback_trans_trate(*ARC_LOG, $dbin, $COMITTRAN);
    }
    else {
      &begin_commit_rollback_trans_trate(*ARC_LOG, $dbmy2, $ROLLBTRAN);
      &begin_commit_rollback_trans_trate(*ARC_LOG, $dbin, $ROLLBTRAN);
    }

    $dbin->disconnect();
    $dbmy1->disconnect();
    $dbmy2->disconnect();
} 

&main();
exit $EXITO;
