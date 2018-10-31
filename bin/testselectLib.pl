#!/usr/bin/perl

use Trate::Lib::ConnectorInformix;
use strict;

my $connector = Trate::Lib::ConnectorInformix->new();

my $preps = "SELECT * FROM ci_movimientos where transaction_id=142300099000000";
my $sth = $connector->dbh->prepare($preps);
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
$connector->destroy();
exit;
