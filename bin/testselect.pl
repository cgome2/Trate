#!/usr/bin/perl

use DBI;
use strict;
use Data::Dump qw(dump);


my $driver = "Informix";
my $database = "master";
my $dsn = "DBI:$driver:$database";
my $userid = "informix";
my $password = "ortech";

printf("dsn: [" . $dsn . "]\n");




my $dbh = DBI->connect($dsn, $userid, $password) or die $DBI::errstr;

my $preps = "SELECT fserie,factura,fecha,proveedor FROM pfacturas";
my $sth = $dbh->prepare($preps);
$sth->execute() or die $DBI::errstr;

print ref $sth . "\n";
print "Numero de registros: [" . $sth->rows . "]\n";

my @results;
my $count;

print dump($sth->{NAME}) . "\n";
my @arr = $sth->{NAME};


while (@results = $sth->fetchrow()){
	$count = 0;
		my $stringtoprint = "|";
		while ($count < @results) {
			$stringtoprint = $stringtoprint.$results[$count]."\t|";
				$count ++;
		}
	printf $stringtoprint . "\n";
}
$dbh->disconnect;
exit;
