#!/usr/bin/perl
##########################################################################
# Name: 
# Description: 
# Author: 
# Adapted by: 
# Date : 
# Version: 
##########################################################################
use Trate::Lib::Movimiento;
use Try::Catch;
use Trate::Lib::Constants qw(LOGGER INFORMIX_SERVER);
use strict;

$ENV{INFORMIXSERVER} = INFORMIX_SERVER;

LOGGER->info("Entro correctamente pero creo que no trae parametros");
my $j = 0;
foreach my $arg (@ARGV){
	LOGGER->info("arg" . $j . " = " . $arg);
	$j++;
}
