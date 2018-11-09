#!/usr/bin/perl
use strict;
use Trate::Lib::Pase;
use Trate::Lib::ConnectorMariaDB;
use Trate::Lib::Constants qw(LOGGER TRUE FALSE);


my $pase = Trate::Lib::Pase->new();
$pase->fechaSolicitud('2018-10-01 00:00:00');
$pase->pase(5000);
$pase->viaje(102);
$pase->camion('AutoTag');
$pase->chofer(3001);
$pase->litros(9.00);
$pase->contingencia('NULL');
$pase->status('A');
$pase->litrosReal(9.00);
$pase->litrosEsp(9.00);
$pase->viajeSust('NULL');
$pase->supervisor('NULL');
$pase->observaciones('NULL');
$pase->ultimaModificacion('NOW()');
my $preps1 = $pase->psInsertarPaseMariaDB;

my $pase2 = Trate::Lib::Pase->new();
$pase2->fechaSolicitud('2018-10-01 00:00:00');
$pase2->pase(5001);
$pase2->viaje(102);
$pase2->camion('AutoTag');
$pase2->chofer(3001);
$pase2->litros(9.00);
$pase2->contingencia('NULL');
$pase2->status('A');
$pase2->litrosReal(9.00);
$pase2->litrosEsp(9.00);
$pase2->viajeSust('NULL');
$pase2->supervisor('NULL');
$pase2->observaciones('NULL');
$pase2->ultimaModificacion('NOW()');
my $preps2 = $pase2->psInsertarPaseMariaDB;

my $cmdb = Trate::Lib::ConnectorMariaDB->new();
my $dbh = $cmdb->dbh;

$dbh->{AutoCommit} = 0; # enable transactions
$dbh->{RaiseError} = 1; # die( ) if a query has problems

eval {
	my $sth = $dbh->prepare($preps1);
	$sth->execute() or warn LOGGER->error($DBI::errstr);
	LOGGER->debug("Ejecuta $preps1");
	$sth = $dbh->prepare($preps2);
	$sth->execute() or warn LOGGER->error($DBI::errstr);
	LOGGER->debug("Ejecuta $preps2");
#	$sth = $dbh->prepare($preps1);
#	$sth->execute() or warn LOGGER->error($DBI::errstr);
#	LOGGER->debug("Ejecuta $preps1");
	$dbh->commit();
	$sth->finish;
};

if ($@) {
	LOGGER->fatal("Transaction aborted: $@");
	eval { $dbh->rollback( ); LOGGER->info("ROLLBACK"); };   # in case rollback( ) fails
} else {
	LOGGER->info("COMMIT EXITOSO");
}

$cmdb->destroy();

exit;
