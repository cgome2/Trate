#!/usr/bin/perl

use Trate::Lib::Pase;
use Try::Catch;
use Trate::Lib::Mean;
use Trate::Lib::Constants qw(LOGGER WITHINFORMIX INFORMIX_SERVER);
use Data::Dump qw(dump);
 
$ENV{INFORMIXSERVER} = INFORMIX_SERVER;

use warnings;

my $connector = Trate::Lib::ConnectorInformix->new();
my $preps;
$preps = sprintf " SELECT * from ci_movimientos ";    
LOGGER->debug("Ejecutando sql[ ", $preps, " ]");
try {
	my $sth = $connector->{DBH}->prepare($preps) or die(LOGGER->fatal("Hacer el prepare" . $connector->{DBH}->errstr));
	$sth->execute() or die LOGGER->fatal("NO PUDO EJECUTAR EL SIGUIENTE COMANDO en INFORMIX:orpak: $preps ");
	$sth->finish;
	$connector->destroy();
	exit 1;
} catch {
	exit 0;
}
