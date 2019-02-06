#!/usr/bin/perl
use Trate::Lib::Constants qw(LOGGER);
use Trate::Lib::ConnectorInformix;
use Trate::Lib::ConnectorMariaDB;
use Trate::Lib::Utilidades;

use Try::Catch;
use strict;

# (1) salir a menos que envien los 4 argumentos
my $num_args = $#ARGV + 1;
my $return = 0;

if ($num_args != 4) {
	print("Uso: create_pase.pl pase viaje camion chofer\n");
    exit $return;
}
my ($pase,$viaje,$camion,$chofer) = @ARGV;
my $fecha_solicitud = Trate::Lib::Utilidades->getCurrentTimestampMariaDB();
my $fecha_solicitud_informix = substr($fecha_solicitud,0,16);

my $connifmx = Trate::Lib::ConnectorInformix->new();


my $prepsifmx = "INSERT INTO ci_pases (fecha_solicitud,pase,viaje,camion,chofer,litros,status,ultima_modificacion) " .
                "VALUES ('" .
                $fecha_solicitud_informix . "','" .
                $pase . "','" .
                $viaje . "','" .
                $camion . "','" .
                $chofer . "','" .
                "9999" . "','" .
                "A" . "','" .
                $fecha_solicitud . "'" .
                ")";
my $sthifmx = $connifmx->dbh->prepare($prepsifmx) or die(LOGGER->fatal("NO SE PUDO CONECTAR A INFORMIX:master"));
$sthifmx->execute() or die print("NO PUDO EJECUTAR EL SIGUIENTE COMANDO en INFORMIX:orpak: $prepsifmx \n");
$sthifmx->finish;
$connifmx->destroy();

my $connmdb = Trate::Lib::ConnectorMariaDB->new();
my $prepsmdb = "INSERT INTO ci_pases (fecha_solicitud,pase,viaje,camion,chofer,litros,status,ultima_modificacion) " .
                "VALUES ('" .
                $fecha_solicitud . "','" .
                $pase . "','" .
                $viaje . "','" .
                $camion . "','" .
                $chofer . "','" .
                "9999" . "','" .
                "A" . "','" .
                $fecha_solicitud . "'" .
                ")";
my $sthmdb = $connmdb->dbh->prepare($prepsmdb);
$sthmdb->execute() or die print("NO PUDO EJECUTAR EL SIGUIENTE COMANDO en MARIADB:orpak: $prepsmdb \n");
$sthmdb->finish;
$connmdb->destroy();

1;