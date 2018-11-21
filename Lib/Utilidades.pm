package Trate::Lib::Utilidades;

#########################################################
#Utilidades - Clase Utilidades							#
#                                                       #
#Autor: Ramses                                          #
#Fecha: Noviembre, 2018                                 #
#Revision: 1.0                                          #
#                                                       #
#########################################################

use strict;
use Trate::Lib::Constants qw(LOGGER ORCURETRIEVEFILE);

sub getCurrentTimestampMariaDB {
	my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime(time);
	my $mysqlDate = $year + 1900;
	$mysqlDate .= "-";
	$mysqlDate .= $mon + 1;
	$mysqlDate .= "-";
	$mysqlDate .= $mday;
	$mysqlDate .= " ";
	$mysqlDate .= $hour;
	$mysqlDate .= ":";
	$mysqlDate .= $min;
	$mysqlDate .= ":";
	$mysqlDate .= sprintf("%02d", $sec);
	return $mysqlDate;
}

1;
#EOF