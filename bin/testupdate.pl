#!/usr/bin/perl

use DBI;
use strict;

my $driver = "Informix";
my $database = "master";
my $dsn = "DBI:$driver:$database";
my $userid = "trateusr";
my $password = "t1710e";

printf("dsn: [" . $dsn . "]\n");

my $fecha_hora = '2018-10-22 16:55';
my $estacion = '1423';
my $supervisor = '1';
my $litros_real = '250.00';
my $costo_real = '5000.00';
my $supervisor = 9997;
my $transaction_id = 142300099000000;

my $dbh = DBI->connect($dsn, $userid, $password) or die $DBI::errstr;



my $preps = sprintf "UPDATE ci_movimientos SET supervisor=%.4d where transaction_id=%d", $supervisor, $transaction_id;

printf("el preps[" . $preps . "]\n");
my $sth = $dbh->prepare($preps);
$sth->execute() or die $DBI::errstr;

$dbh->disconnect;
exit;
