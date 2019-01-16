#!/usr/bin/perl -w
##########################################################################
# Name: 
# Description: 
# Author: 
# Adapted by: 
# Date : 
# Version: 
##########################################################################
use strict;
use Trate::Lib::LecturasTLS;
use Trate::Lib::Constants qw(LOGGER);

my $lecturas_tls = Trate::Lib::LecturasTLS->new();
my $message = $lecturas_tls->getLastLecturasTLSFromORCU();
if(@$message>0){
	$lecturas_tls->procesaLecturasTLS($message);
} else {
	LOGGER->info("Ninguna recepcion por descargar");
}
exit 1;








