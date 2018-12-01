#!/usr/bin/perl
##########################################################################
# Name: 
# Description: 
# Author: 
# Adapted by: 
# Date : 
# Version: 
##########################################################################
use strict;
use warnings;
use Trate::Lib::Transacciones;
use Trate::Lib::Constants qw(LOGGER);

my $transacciones = Trate::Lib::Transacciones->new();
my $message = $transacciones->getLastTransactionsFromORCU();
#LOGGER->debug($message);
#if(@$message>0){
#	$transacciones->procesaTransacciones($message);
#} else {
#	LOGGER->info("Ninguna transaccion por descargar");
#}
exit 1;