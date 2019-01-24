#!/usr/bin/perl

# Name:			descargar_transacciones_orcu.pl 
# Description:  obtiene las últimas transacciones realizadas y las persiste en MariaDB así como las envía a trate
# Author: 		carlos gomez
# Adapted by: 	maacsa
# Date : 		noviembre 2018
# Version: 		1.0


use strict;
use warnings;
use Trate::Lib::Transacciones;
use Trate::Lib::Constants qw(LOGGER);
use Try::Catch;

my $return = 0;
my $transacciones = Trate::Lib::Transacciones->new();
LOGGER->info("ramses lets start");
try {
	#my $message = $transacciones->getLastTransactionsFromORCU();
	my $message = $transacciones->getNewUpdatedTransactionsFromOrcu();
	LOGGER->debug($message);
	 if(@$message>0){
	 	$return = $transacciones->procesaTransaccionesNuevas($message);
	 } else {
	 	LOGGER->info("Ninguna transaccion por descargar");
		$return = 1;
	 }
} catch {
	$return = 0;
} finally {
	print $return;
}
