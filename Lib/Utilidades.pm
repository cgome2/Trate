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
	$mysqlDate .= sprintf("%02d", $mon);
	$mysqlDate .= "-";
	$mysqlDate .= sprintf("%02d", $mday);
	$mysqlDate .= " ";
	$mysqlDate .= sprintf("%02d", $hour);
	$mysqlDate .= ":";
	$mysqlDate .= sprintf("%02d", $min);
	$mysqlDate .= ":";
	$mysqlDate .= sprintf("%02d", $sec);
	return $mysqlDate;
}

sub getInformixDate($){
	my $mariaDBdate = shift;
	my @fecha = split /-/, $mariaDBdate;
	my $year = $fecha[0];
	my $month = $fecha[1];
	my $day = $fecha[2];
	return $day . "/" . $month . "/" . $year;
}

1;
#EOF