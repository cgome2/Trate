#!/usr/bin/perl
use strict;
use Trate::Lib::Pase;

my $pase = Trate::Lib::Pase->new();
$pase->fechaSolicitud('2018-10-01 00:00:00');
$pase->pase(1);
$pase->viaje(1);
$pase->camion(2);
$pase->chofer(3);
$pase->litros(100.00);
$pase->contingencia('NULL');
$pase->status('A');
$pase->litrosReal(98.00);
$pase->litrosEsp(99.00);
$pase->viajeSust('NULL');
$pase->supervisor('NULL');
$pase->observaciones('NULL');
$pase->ultimaModificacion('NOW()');
$pase->insertarPaseMariaDB;
exit;
