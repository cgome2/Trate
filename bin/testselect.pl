#!/usr/bin/perl

use DBI;
use strict;

my $driver = "Informix";
my $database = "master";
my $dsn = "DBI:$driver:$database";
my $userid = "trateusr";
my $password = "t1710e";

printf("dsn: [" . $dsn . "]\n");




my $dbh = DBI->connect($dsn, $userid, $password) or die $DBI::errstr;

my $preps = "SELECT * FROM ci_movimientos where transaction_id=142300099000000";
my $sth = $dbh->prepare($preps);
$sth->execute() or die $DBI::errstr;
print "Numero de registros: [" . $sth->rows . "]\n";

my @results;
my $count;
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
