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
my $transaction_id = 142300099000000;

my $dbh = DBI->connect($dsn, $userid, $password) or die $DBI::errstr;



my $preps = sprintf "INSERT INTO ci_movimientos VALUES (\'%s\',%.4d,NULL,%d,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,0,NULL,%.4f,NULL,%.4f,NULL,NULL,0,'N',%.15d)",$fecha_hora, $estacion, $supervisor, $litros_real, $costo_real, $transaction_id;

printf("el preps[" . $preps . "]\n");
my $sth = $dbh->prepare($preps);
$sth->execute() or die $DBI::errstr;

$dbh->disconnect;
exit;
