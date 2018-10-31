#!/usr/bin/perl -w
##########################################################################
# Name: 
# Description: 
# Author: 
# Adapted by: 
# Date : 
# Version: 
##########################################################################
use strict;
use Orpak::DbLib;
use DBI;
use Orpak::Trate::Trate_functions;

my ($invoiceid, $invoicedate, $serie, $andquery);
my ($dbmy, $dbin);

sub verifica_facturas_id {
    my ($log_arc) = @_;
    my ($sth, $sql, $conteo);

    $sql = sprintf "SELECT COUNT(*) FROM pfacturas WHERE fecha='%s' AND factura='%s' AND proveedor='15002' ", $invoicedate, $invoiceid;
    $sql = $sql . $andquery;
    $sth = $dbin->prepare($sql);
    $sth->execute() or &wr_log($log_arc, "NO PUDO EJECUTAR EL SIGUIENTE COMANDO en INFORMIX:Trate: $sql", 0);
    $conteo = $sth->fetchrow_array;
    $sth->finish;
    print "$conteo";

    return $EXITO;
}

sub main {
  $dbmy=Orpak::DbLib::Connect() or &wr_log(*ARC_LOG, "NO SE PUDO CONECTAR AL SERVIDOR MYSQL", 1);
  $dbin = Connect_Informix_trate(*ARC_LOG, $dbmy);
  
  $andquery=(defined($serie)) ? " AND fserie='$serie' " : " AND fserie='00' ";
  &verifica_facturas_id(*ARC_LOG);

  $dbin->disconnect;
  $dbmy->disconnect;
}

open(ARC_LOG, ">> $ARC_LOG") or die "NO PUDE CREAR EL ARCHIVO $ARC_LOG: $!";

select ARC_LOG;
$| = 1;  # Flush la salida 
select STDOUT;

($invoiceid, $invoicedate, $serie) = @ARGV;

&wr_log(*ARC_LOG, "==== INICIALIZANDO ==== |Programa $0 en EJECUCION", 0);

$mensaje_log = "DATOS A PROCESAR: \nID INVOICE: $invoiceid\nDATE INVOICE: $invoicedate";
&wr_log(*ARC_LOG, $mensaje_log, 0);
&main();
close(ARC_LOG);

exit $EXITO;
