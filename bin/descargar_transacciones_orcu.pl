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

my $transacciones = Trate::Lib::Transacciones->new();
my $message = $transacciones->getLastTransactionsFromORCU();
LOGGER->debug($message);
if(@$message>0){
	$transacciones->procesaTransacciones($message);
} else {
	LOGGER->info("Ninguna transaccion por descargar");
}
exit 1;